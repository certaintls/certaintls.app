import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:pem/pem.dart';

class WindowsCertificateFinder implements CertificateFinder, CertificateVerifier {
  List<X509Certificate> localCerts = [];
  static String systemTrustedCertsPath = 'Root';
  static String userInstalledCertsPath = 'My';
  static RegExp delimiter = RegExp(r'================ Certificate \d* ================');
  static String microsoftCurrentTrustedStore =
      'https://ccadb-public.secure.force.com/microsoft/IncludedCACertificateReportForMSFT';
  List<MicroSoftCertificateInfo> onlineCerts = [];
  final _closeMemo = new AsyncMemoizer();
  bool downloadOnlineCert = true;

  @override
  List<X509Certificate> getCertsByStore(String storePath) {
    ProcessResult results;
    if (storePath == userInstalledCertsPath) {
      results = Process.runSync('CertUtil', ['-v', '-store', '-user', storePath]);
    } else {
      results = Process.runSync('CertUtil', ['-v', '-store', storePath]);
    }

    String output = results.stdout as String;
    var outputSplitted = output.split(delimiter);
    outputSplitted.forEach((s) {
      s = s.trim();
      if (s.startsWith('X509 Certificate:')) {
        var subject = <String, String>{};
        subject.putIfAbsent('2.5.4.3', () => tokenize(s, 'CN='));
        subject.putIfAbsent('2.5.4.10', () => tokenize(s, 'O='));
        subject.putIfAbsent('2.5.4.11', () => tokenize(s, 'OU='));
        subject.putIfAbsent('2.5.4.6', () => tokenize(s, ' C='));
        X509CertificateData data = X509CertificateData(
          sha1Thumbprint: tokenize(s, 'Cert Hash(sha1): ').toUpperCase(),
          sha256Thumbprint: tokenize(s, 'Cert Hash(sha256): ').toUpperCase(),
          subject: subject,
        );
        localCerts.add(X509Certificate(data: data));
      }
    });

    return localCerts;
  }

  @override
  Future<bool> verify(X509Certificate cert) async {
    // Only run once
    await _closeMemo.runOnce(() async {
      await getRemoteTrustedStore();
    });

    String certName = CertificateFinder.getCertName(cert.data);
    // 1. Check if any cert hash matches
    int i = onlineCerts.indexWhere((onlineCert) => onlineCert.fingerprint == cert.data.sha256Thumbprint);
    if (i != -1 ) { // There is a match
      cert.status = X509CertificateStatus.statusVerified;
      // 2. If a name matches
    } else if ((onlineCerts.indexWhere((onlineCert) => onlineCert.commonName == certName)) != -1) {
        // 3. Download the cert file and check SPKI hash
        i = onlineCerts.indexWhere((onlineCert) => onlineCert.commonName == certName);
        X509CertificateData data;
        if (onlineCerts[i].data == null) {
          data = await _downloadCert(onlineCerts[i].fileUrl);
        }
        if (data.publicKeyData.sha256Thumbprint == cert.data.publicKeyData.sha256Thumbprint) {
          cert.status = X509CertificateStatus.statusVerified;
        } else cert.status = X509CertificateStatus.statusCompromised;
      // 4. Can't find any matches
    } else cert.status = X509CertificateStatus.statusUnverifiable;

    return true;
  }

  @override
  Future verifyAll() async {
    await Future.forEach(localCerts, (cert) async {
      await verify(cert);
    });
  }

  Future getRemoteTrustedStore() async {
    var client = Client();
    Response response = await client.get(microsoftCurrentTrustedStore);

    // Use html parser and query selector
    var document = parse(response.body);
    List<Element> caOwners =
        document.querySelectorAll('.slds-table tr > td:first-child');
    // last row is an empty one
    caOwners.removeLast();
    List<Element> commonNames =
        document.querySelectorAll('.slds-table tr > td:nth-child(3)');
    List<Element> fileUrls = document.querySelectorAll('.slds-table tr > td:nth-child(7)');

    for (int i = 0; i < caOwners.length; i++) {
      String caOwner = caOwners[i].querySelector('span').text;
      String commonName = commonNames[i].querySelector('span').text;
      String sha256 = fileUrls[i].querySelector('a').text;
      String url = fileUrls[i].querySelector('a').attributes['href'];
      X509CertificateData data;
      if (downloadOnlineCert) {
        data = await _downloadCert(url, client: client);
      }
      if (!downloadOnlineCert || data != null) {
        onlineCerts.add(MicroSoftCertificateInfo(caOwner, commonName, sha256, url, data));
      }
    }
  }

  @override
  Map<String, String> getCertStores() {
    return {'System Root Certificates': systemTrustedCertsPath, 'User Installed Certificates': userInstalledCertsPath};
  }

  String tokenize(String text, String label) {
    int pos = text.indexOf(label);
    if (pos > 0) {
      int l = label.length;
      return text.substring(pos+l, text.indexOf('\n', pos)).trim();
    }
    return null;
  }

  Future<X509CertificateData> _downloadCert(String url, {Client client}) async {
    if (client == null) {
      client = Client();
    }
    var response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var bytes = response.bodyBytes;
      String encoded = utf8.decode(bytes);
      List<int> certData = PemCodec(PemLabel.certificate).decode(encoded);
      String onlinePEM = PemCodec(PemLabel.certificate).encode(certData);
      return X509Utils.x509CertificateFromPem(onlinePEM);
    } else return null;
  }
}

class MicroSoftCertificateInfo {
  String caOwner;
  String commonName;
  // SHA-256 Fingerprint
  String fingerprint;
  String fileUrl;
  X509CertificateData data;
  MicroSoftCertificateInfo(this.caOwner, this.commonName, this.fingerprint, this.fileUrl, this.data);
}
