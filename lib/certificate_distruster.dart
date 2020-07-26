import 'dart:io';

import 'x509certificate.dart';

/// A distruster can distrust a certificate on a OS.
/// Android calls the action "Disable" (A user can enable a certificate)
/// MacOS calls the action "Delete" (Once a certificate is deleted, it is gone)
/// Windows calls the action "Revoke", but there is no "Reinstate"
abstract class CertificateDistruster {
  ProcessResult distrust(X509Certificate cert, String storePath);
}
