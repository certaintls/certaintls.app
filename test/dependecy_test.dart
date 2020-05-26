@Timeout(const Duration(seconds: 1800))

import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/windows_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:test/test.dart';

void main() {
  test('X509CertificateData can be constructed from imcomplete data returned by CertUtil on Windows', () async {
    var subject = <String, String>{};
    subject.putIfAbsent('2.5.4.3', () => 'A-Trust-Root-07');
    subject.putIfAbsent('2.5.4.10', () => 'A-Trust Ges. f. Sicherheitssysteme im elektr. Datenverkehr GmbH');
    subject.putIfAbsent('2.5.4.11', () => 'A-Trust-Root-07');
    subject.putIfAbsent('2.5.4.6', () => 'AT');
    X509CertificateData data = X509CertificateData(
      version: 3,
      sha256Thumbprint: '8AC552AD577E37AD2C6808D72AA331D6A96B4B3FEBFF34CE9BC0578E08055EC3',
      subject: subject,
    );

    var finder = WindowsCertificateFinder();
    var cert = X509Certificate(data: data);
    await finder.verify(cert);
    expect(cert.status, X509CertificateStatus.statusVerified);
  });
}