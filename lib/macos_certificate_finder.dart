import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';

class MacOSCertificateFinder implements CertificateFinder {
  List<X509Certificate> certs;
  static String systemTrustedCertsPath = '/System/Library/Keychains/SystemRootCertificates.keychain';
  static String delimiter = '-----END CERTIFICATE-----\n';

  @override
  List<X509Certificate> getSystemRootCerts() {
    List<X509Certificate> certs = [];
    ProcessResult results = Process.runSync('security', ['find-certificate', '-pa', systemTrustedCertsPath]);
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
    cert.status = X509CertificateStatus.statusUnverifiable;
    return true;
  }

  @override
  void verifyAll() {
    certs.forEach((cert) {
      verify(cert);
    });
  }
  
}