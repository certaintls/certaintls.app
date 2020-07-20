import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/x509certificate.dart';

abstract class CertificateFinder {
  /// Return the list of certificates from the specified store/keychain
  List<X509Certificate> getCertsByStore(String storePath);

  /// Return the stores/keychains avaiable in the OS
  Map<String, String> getCertStores();

  /// If the OS allows the application to disable/remove certificates
  //bool allowDisableCert();

  static String getCertName(X509CertificateData data) {
    return data.subject['2.5.4.3'] != null
        ? data.subject['2.5.4.3']
        : (data.subject['2.5.4.11'] ?? '');
  }
}
