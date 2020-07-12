import 'dart:convert';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:pem/pem.dart';

class X509Certificate {
  X509CertificateData data;
  String status = X509CertificateStatus.statusUnchecked;
  String filename;
  List programs = [];
  bool isTrustworthy;

  /// UUID, used in entity reference
  String remoteId;

  X509Certificate({@required this.data, this.filename});
}

class X509CertificateStatus {
  static const String statusUnchecked = 'Unchecked';
  static const String statusCompromised = 'Untrustworhy';
  static const String statusVerified = 'Verified';
  static const String statusTriedError = 'Error';
  static const String statusUnverifiable = 'Unverifiable';
}

String getCommonName(X509CertificateData data) {
  // If commone name is missing, use the org unit
  return data.subject['2.5.4.3'] != null
      ? data.subject['2.5.4.3']
      : (data.subject['2.5.4.11'] ?? '');
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
  } else
    return null;
}

String getTitle(X509CertificateData data) =>
    getOrg(data) + ' (' + (getCountry(data) ?? '') + ')';

String getSubtitle(X509CertificateData data) => getCommonName(data);

String getOU(X509CertificateData data) {
  var temp = X509Utils.DN['organizationalUnit'];
  return data.subject[temp];
}

Widget generateStatusIcon(String status) {
  Icon iconDisplay;
  bool isInProgress = false;
  switch (status) {
    case X509CertificateStatus.statusUnchecked:
      iconDisplay = Icon(Icons.info);
      isInProgress = true;
      break;
    case X509CertificateStatus.statusCompromised:
      iconDisplay = Icon(Icons.highlight_off, color: Colors.red[500]);
      break;
    case X509CertificateStatus.statusVerified:
      iconDisplay = Icon(Icons.security, color: Colors.green[500]);
      break;
    case X509CertificateStatus.statusTriedError:
      iconDisplay = Icon(Icons.autorenew, color: Colors.yellow[500]);
      isInProgress = true;
      break;
    case X509CertificateStatus.statusUnverifiable:
      iconDisplay = Icon(Icons.priority_high, color: Colors.yellow[500]);
      break;
  }
  return Stack(alignment: Alignment.center, children: [
    IconButton(
      icon: iconDisplay,
      onPressed: () {},
    ),
    SizedBox(
        height: 24.0,
        width: 24.0,
        child: Visibility(
            visible: isInProgress,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            )))
  ]);
}
