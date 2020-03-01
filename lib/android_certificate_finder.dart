import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:pem/pem.dart';

class AndroidCertificateFinder implements CertificateFinder {
  static String systemTrustedCertsPath = '/system/etc/security/cacerts';
  // https://stackoverflow.com/a/35132508/1966269
  static String userTrustedCertsPath = '/data/misc/keychain/certs-added';

  @override
  List<X509CertificateData> getSystemRootCerts() {
    var certsDir = new Directory(systemTrustedCertsPath);
    List<FileSystemEntity> certsList = certsDir.listSync(recursive: false, followLinks: false);
    List<X509CertificateData> certs = new List();

    certsList.forEach((cert) {
      File file = new File(cert.path);
      String certTxt = file.readAsStringSync();
      List<int> certData = PemCodec(PemLabel.certificate).decode(certTxt);
      String encoded = PemCodec(PemLabel.certificate).encode(certData);
      X509CertificateData data = X509Utils.x509CertificateFromPem(encoded);
      certs.add(data);
    });

    return certs;
  }

  @override
  void getVerifier() {
    // TODO: implement getVerifier
  }
  
}