import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:pem/pem.dart';

class VerifierWidget extends StatefulWidget {
  final String certName;
  final String spkiFingerPrint;
  VerifierWidget({this.certName, this.spkiFingerPrint});
  @override
  _VerifierWidgetState createState() =>
      _VerifierWidgetState(localSPKIHash: spkiFingerPrint, filename: certName);
}

class _VerifierWidgetState extends State<VerifierWidget> {
  final String localSPKIHash;
  final String filename;

  static const String statusUnchecked = 'toCheck';
  static const String statusCompromised = 'toRevoke';
  static const String statusVerified = 'doCalm';
  static const String statusTriedError = 'tryAgain';
  static const String statusUnverifiable = 'beAlarmed';
  String status = statusUnchecked;

  _VerifierWidgetState({this.localSPKIHash, this.filename});

  @override
  Widget build(BuildContext context) {
    Icon iconDisplay;
    switch (status) {
      case statusUnchecked:
        iconDisplay = Icon(Icons.info);
        _verify();
        break;
      case statusCompromised:
        iconDisplay = Icon(Icons.highlight_off, color: Colors.red[500]);
        break;
      case statusVerified:
        iconDisplay = Icon(Icons.security, color: Colors.green[500]);
        break;
      case statusTriedError:
        iconDisplay = Icon(Icons.autorenew, color: Colors.yellow[500]);
        _verify();
        break;
      case statusUnverifiable:
        iconDisplay = Icon(Icons.priority_high, color: Colors.yellow[500]);
        break;
    }
    return IconButton(
      icon: iconDisplay,
      onPressed: _verify,
    );
  }

  void _verify() async {
    String url =
        'https://android.googlesource.com/platform/system/ca-certificates/+/master/files/' +
            filename +
            '?format=TEXT';
    Client client = new Client();
    try {
      var response = await client.get(Uri.parse(url));
      switch (response.statusCode) {
        case 200:
          var bytes = response.bodyBytes;
          String encoded = utf8.decode(bytes);
          String remoteCert = utf8.decode(base64.decode(encoded));
          // Compare SPKI hashes: https://www.imperialviolet.org/2011/05/04/pinning.html
          List<int> certData = PemCodec(PemLabel.certificate).decode(remoteCert);
          String remotePEM = PemCodec(PemLabel.certificate).encode(certData);
          X509CertificateData data = X509Utils.x509CertificateFromPem(remotePEM);
          var remoteSPKIHash = data.publicKeyData.sha256Thumbprint;
          if (remoteSPKIHash == localSPKIHash) {
            status = statusVerified;
          } else {
            status = statusCompromised;
          }
          break;
        case 404:
          status = statusUnverifiable;
          break;
        case 500:
        default:
          status = statusTriedError;
          break;
      }
    } catch (e) {
      status = statusTriedError;
    }
    setState(() {});
  }
}
