import 'dart:convert';
import 'package:basic_utils/basic_utils.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:pem/pem.dart';

class X509Certificate {

  X509CertificateData data;
  String status = X509CertificateStatus.statusUnchecked;
  String filename;
  List programs = [];
  bool isTrustworthy;

  X509Certificate({@required this.data, this.filename});
}

class X509CertificateStatus {
  static const String statusUnchecked = 'toCheck';
  static const String statusCompromised = 'toRevoke';
  static const String statusVerified = 'doCalm';
  static const String statusTriedError = 'tryAgain';
  static const String statusUnverifiable = 'beAlarmed';
}

String getCommonName(X509CertificateData data) {
  // If commone name is missing, use the org unit
  return data.subject['2.5.4.3'] != null ? data.subject['2.5.4.3'] : (data.subject['2.5.4.11'] ?? '');
}

String getOrg(X509CertificateData data) {
  // If org is missing, use the common name
  if (data.subject['2.5.4.10'] == null) {
    return getCommonName(data);
  } else {
    return data.subject['2.5.4.10'];
  }
}

String getCountry(X509CertificateData data) {
  return data.subject['2.5.4.6'];
}

Future<X509CertificateData> certDownload(String url, {Client client}) async {
  if (client == null) {
    client = Client();
  }
  var response = await client.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var bytes = response.bodyBytes;
    String encoded = utf8.decode(bytes);
    List<int> certData = PemCodec(PemLabel.certificate).decode(encoded);
    String onlinePEM = PemCodec(PemLabel.certificate).encode(certData);
    return X509Utils.x509CertificateFromPem(onlinePEM);
  } else return null;
}
