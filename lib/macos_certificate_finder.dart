import 'dart:io';
import 'package:async/async.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class MacOSCertificateFinder implements CertificateFinder {
  List<X509Certificate> certs;
  static String systemTrustedCertsPath = '/System/Library/Keychains/SystemRootCertificates.keychain';
  static String userInstalledCertsPath = '/Library/Keychains/System.keychain';
  static String delimiter = '-----END CERTIFICATE-----\n';
  static String appleCurrentTrustedStore = 'https://support.apple.com/en-us/HT210770';
  List<AppleCertificateInfo> onlineCerts;
  final _closeMemo = new AsyncMemoizer();

  @override
  List<X509Certificate> getCertsByStore(String storePath) {
    List<X509Certificate> certs = [];
    ProcessResult results = Process.runSync('security', ['find-certificate', '-pa', storePath]);
    String output = results.stdout as String;
    output.split(delimiter).forEach((pem) {
      if (pem.startsWith('-----BEGIN CERTIFICATE-----')) {
        X509CertificateData data = X509Utils.x509CertificateFromPem(pem + delimiter);
        certs.add(X509Certificate(data: data));
      }
    });

    return certs;
  }

  @override
  Future<bool> verify(X509Certificate cert) async {
    // Only run once
    await _closeMemo.runOnce(() async {
       await getRemoteTrustedStore();
    });

    bool match = false;
    onlineCerts.forEach((remoteCert) {
      String commonName = cert.data.subject['2.5.4.3'] != null ? cert.data.subject['2.5.4.3'] : (cert.data.subject['2.5.4.11'] ?? '');
      if (remoteCert.name == commonName) {
        match = true;
        // Add spaces
        String prettyPrint = StringUtils.addCharAtPosition(cert.data.sha256Thumbprint, ' ', 2, repeat: true);
        if (remoteCert.certFingerPrint == prettyPrint) {
          cert.status = X509CertificateStatus.statusVerified;
        } else cert.status = X509CertificateStatus.statusCompromised;
      }
    });

    if (!match && cert.status == X509CertificateStatus.statusUnchecked) {
      cert.status = X509CertificateStatus.statusUnverifiable;
    }
    return true;
  }

  @override
  void verifyAll() async {
    await Future.forEach(certs, (cert) async {
      await verify(cert);
    });
  }

  Future getRemoteTrustedStore() async {
    var client = Client();
    Response response = await client.get(appleCurrentTrustedStore);

    // Use html parser and query selector
    var document = parse(response.body);
    List<Element> names = document.querySelector('#trusted + div').querySelectorAll('tr > td:first-child');
    List<Element> issuers = document.querySelector('#trusted + div').querySelectorAll('tr > td:nth-child(2)');
    List<Element> fingerprints = document.querySelector('#trusted + div').querySelectorAll('tr > td:last-child');
    onlineCerts = _buildList(names, issuers, fingerprints);
  }

  List<AppleCertificateInfo> _buildList(List<Element> names, List<Element> issuers, List<Element> fingerprints) {
    List<AppleCertificateInfo> certs = [];
    names.asMap().forEach((i, element) {
      certs.add(AppleCertificateInfo(element.text.trim(), issuers[i].text.trim(), fingerprints[i].text.trim()));
    });
    return certs;
  }

  @override
  Map<String, String> getCertStores() {
    return {'System Root Certificates': systemTrustedCertsPath, 'User Installed Certificates': userInstalledCertsPath};
  }
}

class AppleCertificateInfo {
  String name;
  String issuedBy;
  String certFingerPrint;
  AppleCertificateInfo(this.name, this.issuedBy, this.certFingerPrint);
}