import 'package:basic_utils/basic_utils.dart';
import 'package:meta/meta.dart';

class X509Certificate {
  
  X509CertificateData data;
  String status = X509CertificateStatus.statusUnchecked;
  String filename;

  X509Certificate({@required this.data, this.filename});
}

class X509CertificateStatus {
  static const String statusUnchecked = 'toCheck';
  static const String statusCompromised = 'toRevoke';
  static const String statusVerified = 'doCalm';
  static const String statusTriedError = 'tryAgain';
  static const String statusUnverifiable = 'beAlarmed';
}