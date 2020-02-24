import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifierWidget extends StatefulWidget {
  final String certName;
  final String certString;
  VerifierWidget({this.certName, this.certString});
  @override
  _VerifierWidgetState createState() =>
      _VerifierWidgetState(fileString: certString, filename: certName);
}

class _VerifierWidgetState extends State<VerifierWidget> {
  final String fileString;
  final String filename;

  static const String statusUnchecked = 'toCheck';
  static const String statusCompromised = 'toRevoke';
  static const String statusVerified = 'doCalm';
  static const String statusTriedError = 'tryAgain';
  static const String statusUnverifiable = 'beAlarmed';
  String status = statusUnchecked;

  _VerifierWidgetState({this.fileString, this.filename});

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
    http.Client client = new http.Client();
    var response = await client.get(Uri.parse(url));
    switch (response.statusCode) {
      case 200:
        var bytes = response.bodyBytes;
        String encoded = utf8.decode(bytes);
        String readable = utf8.decode(base64.decode(encoded));
        if (readable == fileString) {
          status = statusVerified;
        } else {
          status = statusCompromised;
        }
        break;
      case 403:
        status = statusUnverifiable;
        break;
      case 500:
      default:
        status = statusTriedError;
        break;
    }
    setState(() {});
  }
}
