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
  static String userInstalledCertsPath = 'My';
  static RegExp delimiter = RegExp(r'================ Certificate \d* ================');
  static String microsoftCurrentTrustedStore =
      'https://ccadb-public.secure.force.com/microsoft/IncludedCACertificateReportForMSFT';
  List<MicroSoftCertificateInfo> onlineCerts;
  final _closeMemo = new AsyncMemoizer();

  @override
  List<X509Certificate> getCertsByStore(String storePath) {
    List<X509Certificate> certs = [];
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
    onlineCerts.forEach((onlineCert) {
      String commonName = cert.data.subject['2.5.4.3'] != null
          ? cert.data.subject['2.5.4.3']
          : (cert.data.subject['2.5.4.11'] ?? '');
      if (onlineCert.commonName == commonName) {
        match = true;
        if (onlineCert.fingerprint == cert.data.sha1Thumbprint) {
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
}

class MicroSoftCertificateInfo {
  String caOwner;
  String commonName;
  // SHA-1 Fingerprint
  String fingerprint;
  MicroSoftCertificateInfo(this.caOwner, this.commonName, this.fingerprint);
}
