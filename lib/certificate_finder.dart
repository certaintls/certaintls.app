import 'package:certaintls/x509certificate.dart';

abstract class CertificateFinder {

  List<X509Certificate> getCertsByStore(String storePath);
  Future<bool> verify(X509Certificate cert);
  void verifyAll();
  Map<String, String> getCertStores();
}