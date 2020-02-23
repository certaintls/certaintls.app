import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifierWidget extends StatefulWidget {
  final String certName;
  final String certString;
  VerifierWidget({this.certName, this.certString});
  @override
  _VerifierWidgetState createState() => _VerifierWidgetState(fileString: certString, filename: certName);
}

class _VerifierWidgetState extends State<VerifierWidget> {
  final String fileString;
  final String filename;

  bool _isVerified = false;
  
  _VerifierWidgetState({this.fileString, this.filename});

  @override
  Widget build(BuildContext context) {
    _verify();
    return IconButton(
            icon: (_isVerified ? Icon(Icons.check_circle, color: Colors.green[500]) : Icon(Icons.info)),
            onPressed: _verify,
          );
  }

  void _verify() async {
    String url = 'https://android.googlesource.com/platform/system/ca-certificates/+/master/files/' + filename + '?format=TEXT';
    http.Client client = new http.Client();
    var response = await client.get(Uri.parse(url));
    var bytes = response.bodyBytes;
    String encoded = utf8.decode(bytes);
    String readable = utf8.decode(base64.decode(encoded));  

    setState(() {
      if (readable == fileString) {
        _isVerified = true;
      }
    });
  }

}