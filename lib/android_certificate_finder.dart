import 'dart:convert';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:path/path.dart';
import 'package:pem/pem.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:http/http.dart';

class AndroidCertificateFinder implements CertificateFinder {
  static String systemTrustedCertsPath = '/system/etc/security/cacerts';
  // https://stackoverflow.com/a/35132508/1966269
  static String userTrustedCertsPath = '/data/misc/keychain/certs-added';

  List<X509Certificate> certs = [];

  @override
  List<X509Certificate> getSystemRootCerts() {
    var certsDir = new Directory(systemTrustedCertsPath);
    List<FileSystemEntity> certsList =
        certsDir.listSync(recursive: false, followLinks: false);

    certsList.forEach((cert) {
      File file = new File(cert.path);
      String certTxt = file.readAsStringSync();
      List<int> certData = PemCodec(PemLabel.certificate).decode(certTxt);
      String encoded = PemCodec(PemLabel.certificate).encode(certData);
      X509CertificateData data = X509Utils.x509CertificateFromPem(encoded);
      certs.add(X509Certificate(data: data, filename: basename(file.path)));
    });

    return certs;
  }

  @override
  Future<bool> verify(X509Certificate cert) async {
    String url =
        'https://android.googlesource.com/platform/system/ca-certificates/+/master/files/' +
            cert.filename +
            '?format=TEXT';
    Client client = new Client();
    try {
      var response = await client.get(Uri.parse(url));
      switch (response.statusCode) {
        case 200:
          var bytes = response.bodyBytes;
          String encoded = utf8.decode(bytes);
          String remoteCert = utf8.decode(base64.decode(encoded));
          // Compare SPKI hashes: https://www.imperialviolet.org/2011/05/04/pinning.html
          List<int> certData =
              PemCodec(PemLabel.certificate).decode(remoteCert);
          String remotePEM = PemCodec(PemLabel.certificate).encode(certData);
          X509CertificateData data =
              X509Utils.x509CertificateFromPem(remotePEM);
          var remoteSPKIHash = data.publicKeyData.sha256Thumbprint;
          if (remoteSPKIHash == cert.data.publicKeyData.sha256Thumbprint) {
            cert.status = X509CertificateStatus.statusVerified;
          } else {
            cert.status = X509CertificateStatus.statusCompromised;
          }
          break;
        case 404:
          cert.status = X509CertificateStatus.statusUnverifiable;
          break;
        case 500:
        default:
          cert.status = X509CertificateStatus.statusTriedError;
          break;
      }
      return true;
    } catch (e) {
      cert.status = X509CertificateStatus.statusTriedError;
      return false;
    }
  }

  @override
  void verifyAll() {
    certs.forEach((cert) {
      verify(cert);
    });
  }
}
