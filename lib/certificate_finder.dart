import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/x509certificate.dart';

abstract class CertificateFinder {

  List<X509Certificate> getCertsByStore(String storePath);
  Future<bool> verify(X509Certificate cert);
  Future verifyAll();
  Map<String, String> getCertStores();
  static String getCertName(X509CertificateData data) {
    return data.subject['2.5.4.3'] != null ? data.subject['2.5.4.3'] : (data.subject['2.5.4.11'] ?? '');
  }
}