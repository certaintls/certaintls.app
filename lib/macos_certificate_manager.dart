import 'dart:io';
import 'package:async/async.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_distruster.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class MacOSCertificateManager
    implements CertificateFinder, CertificateVerifier, CertificateDistruster {
  static String systemTrustedCertsPath =
      '/System/Library/Keychains/SystemRootCertificates.keychain';
  static String userInstalledCertsPath = '/Library/Keychains/System.keychain';
  static String delimiter = '-----END CERTIFICATE-----\n';
  static String appleCurrentTrustedStore =
      'https://support.apple.com/en-us/HT210770';
  List<AppleCertificateInfo> onlineCerts;
  final _closeMemo = new AsyncMemoizer();

  @override
  List<X509Certificate> getCertsByStore(String storePath) {
    List<X509Certificate> certs = [];
    ProcessResult results =
        Process.runSync('security', ['find-certificate', '-pa', storePath]);
    String output = results.stdout as String;
    output.split(delimiter).forEach((pem) {
      if (pem.startsWith('-----BEGIN CERTIFICATE-----')) {
        X509CertificateData data =
            X509Utils.x509CertificateFromPem(pem + delimiter);
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

    String certName = CertificateFinder.getCertName(cert.data);
    // Add spaces
    String prettyPrint = StringUtils.addCharAtPosition(
        cert.data.sha256Thumbprint, ' ', 2,
        repeat: true);
    // 1. Check if any cert hash matches
    int i = onlineCerts
        .indexWhere((onlineCert) => onlineCert.certFingerPrint == prettyPrint);
    if (i != -1) {
      // There is a match
      cert.status = X509CertificateStatus.statusVerified;
      // 2. If a name matches
    } else if ((onlineCerts
            .indexWhere((onlineCert) => onlineCert.name == certName)) !=
        -1) {
      cert.status = X509CertificateStatus.statusCompromised;
      // 3. Can't find any matches
    } else
      cert.status = X509CertificateStatus.statusUnverifiable;

    return true;
  }

  @override
  Future verifyAll(List<X509Certificate> certs) async {
    await Future.forEach(certs, (cert) async {
      await verify(cert);
    });
  }

  Future getRemoteTrustedStore() async {
    var client = Client();
    Response response = await client.get(appleCurrentTrustedStore);

    // Use html parser and query selector
    var document = parse(response.body);
    List<Element> names = document
        .querySelector('#trusted + div')
        .querySelectorAll('tr > td:first-child');
    List<Element> issuers = document
        .querySelector('#trusted + div')
        .querySelectorAll('tr > td:nth-child(2)');
    List<Element> fingerprints = document
        .querySelector('#trusted + div')
        .querySelectorAll('tr > td:last-child');
    onlineCerts = _buildList(names, issuers, fingerprints);
  }

  List<AppleCertificateInfo> _buildList(
      List<Element> names, List<Element> issuers, List<Element> fingerprints) {
    List<AppleCertificateInfo> certs = [];
    names.asMap().forEach((i, element) {
      certs.add(AppleCertificateInfo(element.text.trim(),
          issuers[i].text.trim(), fingerprints[i].text.trim()));
    });
    return certs;
  }

  @override
  Map<String, String> getCertStores() {
    return {
      'System Root Certificates': systemTrustedCertsPath,
      'User Installed Certificates': userInstalledCertsPath
    };
  }

  /// Method recommended by https://apple.stackexchange.com/a/45626
  @override
  ProcessResult distrust(X509Certificate cert) {
    return Process.runSync(
        'security', ['delete-certificate', '-Z', cert.data.sha1Thumbprint]);
  }
}

class AppleCertificateInfo {
  String name;
  String issuedBy;
  String certFingerPrint;
  AppleCertificateInfo(this.name, this.issuedBy, this.certFingerPrint);
}
