import 'package:certaintls/macos_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:test/test.dart';

void main() {
  test('Check MacOS stock CA root certificates', () async {
    var finder = MacOSCertificateFinder();
    finder.getCertsByStore(MacOSCertificateFinder.systemTrustedCertsPath);
    await finder.verifyAll();
    print('The number of root certificates found: ' + finder.certs.length.toString());
    print("The number of root certificates on Apple's website: " + finder.onlineCerts.length.toString());
    finder.certs.forEach((cert) { 
      expect(cert.status, X509CertificateStatus.statusVerified, reason: cert.data.subject.toString() + "'s status is: " + cert.status);
    });
  });
}