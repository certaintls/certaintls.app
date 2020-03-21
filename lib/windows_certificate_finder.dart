import 'dart:io';
import 'package:async/async.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class WindowsCertificateFinder implements CertificateFinder {
  List<X509Certificate> certs;
  static String systemTrustedCertsPath = 'Root';
  static String delimiter = '-----END CERTIFICATE-----\n';
  static String microsoftCurrentTrustedStore =
      'https://ccadb-public.secure.force.com/microsoft/IncludedCACertificateReportForMSFT';
  List<MicroSoftCertificateInfo> onlineCerts;
  final _closeMemo = new AsyncMemoizer();

  @override
  List<X509Certificate> getCertsByStore(String storePath) {
    List<X509Certificate> certs = [];
    ProcessResult results = Process.runSync(
        'CertUtil', ['-v', '-store', storePath]);
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
      await getTrustedStore();
    });

    bool match = false;
    onlineCerts.forEach((remoteCert) {
      String commonName = cert.data.subject['2.5.4.3'] != null
          ? cert.data.subject['2.5.4.3']
          : (cert.data.subject['2.5.4.11'] ?? '');
      if (remoteCert.commonName == commonName) {
        match = true;
        if (remoteCert.fingerprint == cert.data.sha1Thumbprint) {
          cert.status = X509CertificateStatus.statusVerified;
        } else
          cert.status = X509CertificateStatus.statusCompromised;
      }
    });

    if (!match && cert.status == X509CertificateStatus.statusUnchecked) {
      cert.status = X509CertificateStatus.statusUnverifiable;
    }
    return true;
  }

  @override
  void verifyAll() {
    certs.forEach((cert) {
      verify(cert);
    });
  }

  Future getTrustedStore() async {
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
    List<Element> sha1Fingerprints =
        document.querySelectorAll('.slds-table tr > td:nth-child(5)');
    onlineCerts = _buildList(caOwners, commonNames, sha1Fingerprints);
  }

  List<MicroSoftCertificateInfo> _buildList(List<Element> caOwners,
      List<Element> commonNames, List<Element> fingerprints) {
    List<MicroSoftCertificateInfo> certs = [];
    caOwners.asMap().forEach((i, element) {
      certs.add(MicroSoftCertificateInfo(
          element.querySelector('span').text,
          commonNames[i].querySelector('span').text,
          fingerprints[i].querySelector('span').text));
    });
    return certs;
  }

  @override
  Map<String, String> getCertStores() {
    return {'System Root Certificates': systemTrustedCertsPath};
  }
}

class MicroSoftCertificateInfo {
  String caOwner;
  String commonName;
  // SHA-1 Fingerprint
  String fingerprint;
  MicroSoftCertificateInfo(this.caOwner, this.commonName, this.fingerprint);
}