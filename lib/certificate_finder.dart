import 'package:basic_utils/basic_utils.dart';

abstract class CertificateFinder {

  CertificateFinder();

  List<X509CertificateData> getSystemRootCerts();
  void getVerifier();

  
}