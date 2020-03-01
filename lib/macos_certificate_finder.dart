import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';

class MacOSCertificateFinder implements CertificateFinder {
  static String systemTrustedCertsPath = '/System/Library/Keychains/SystemRootCertificates.keychain';

  @override
  List<X509CertificateData> getSystemRootCerts() {
    Process.run('security', ['find-certificate', '-pa', systemTrustedCertsPath]).then((ProcessResult results) {
      print(results.stdout);
    });
    return null;
  }

  @override
  void getVerifier() {
    // TODO: implement getVerifier
  }
  
}