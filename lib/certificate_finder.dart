import 'package:certaintls/x509certificate.dart';

abstract class CertificateFinder {

  List<X509Certificate> getSystemRootCerts();
  Future<bool> verify(X509Certificate cert);
  void verifyAll();
}