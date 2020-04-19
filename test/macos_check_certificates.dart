import 'package:certaintls/macos_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:test/test.dart';

void main() {
  test('Check MacOS stock CA root certificates', () async {
    var finder = MacOSCertificateFinder();
    finder.getCertsByStore(MacOSCertificateFinder.systemTrustedCertsPath);
    await finder.verifyAll();
    expect(finder.certs.length, finder.onlineCerts.length);
    finder.certs.forEach((cert) { 
      expect(cert.status, X509CertificateStatus.statusVerified);
    });
  });
}