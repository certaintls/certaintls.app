import 'package:certaintls/x509certificate.dart';

abstract class CertificateVerifier {

  Future<bool> verify(X509Certificate cert);
  Future verifyAll();
}