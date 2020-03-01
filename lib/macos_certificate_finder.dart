import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_finder.dart';

class MacOSCertificateFinder implements CertificateFinder {
  static String systemTrustedCertsPath = '/System/Library/Keychains/SystemRootCertificates.keychain';
  static String delimiter = '-----END CERTIFICATE-----\n';

  @override
  List<X509CertificateData> getSystemRootCerts() {
    List<String> pems;
    List<X509CertificateData> certs = [];
    Process.run('security', ['find-certificate', '-pa', systemTrustedCertsPath]).then((ProcessResult results) {
      print(results.stdout);
      String output = results.stdout as String;
      pems = output.split(delimiter);
    });

    pems.forEach((pem) {
      X509CertificateData data = X509Utils.x509CertificateFromPem(pem + delimiter);
      certs.add(data);
    });

    return certs;
  }

  @override
  void getVerifier() {
    // TODO: implement getVerifier
  }
  
}