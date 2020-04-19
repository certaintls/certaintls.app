@Timeout(const Duration(seconds: 1800))

import 'package:certaintls/windows_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:test/test.dart';

void main() {
  test('Check Windows stock CA root certificates', () async {
    var finder = WindowsCertificateFinder();
    finder.getCertsByStore(WindowsCertificateFinder.systemTrustedCertsPath);
    await finder.getRemoteTrustedStore(download: true);
    await finder.verifyAll();
    print('The number of root certificates found: ' + finder.certs.length.toString());
    print("The number of root certificates on Microsoft's website: " + finder.onlineCerts.length.toString());
    finder.certs.forEach((cert) { 
      expect(cert.status, X509CertificateStatus.statusVerified, reason: cert.data.subject.toString() + "'s status is: " + cert.status);
    });
  });
}