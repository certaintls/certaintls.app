import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';

class VerifierWidget extends StatefulWidget {

  final X509Certificate cert;
  final CertificateVerifier verifier;

  VerifierWidget({this.cert, this.verifier});

  @override
  _VerifierWidgetState createState() =>
      _VerifierWidgetState(cert: cert, verifier: verifier);
}

class _VerifierWidgetState extends State<VerifierWidget> {
  final X509Certificate cert;
  final CertificateVerifier verifier;
  List<String> programs;

  _VerifierWidgetState({this.cert, this.verifier});

  @override
  Widget build(BuildContext context) {
    Icon iconDisplay;
    switch (cert.status) {
      case X509CertificateStatus.statusUnchecked:
        iconDisplay = Icon(Icons.info);
        _verify();
        break;
      case X509CertificateStatus.statusCompromised:
        iconDisplay = Icon(Icons.highlight_off, color: Colors.red[500]);
        break;
      case X509CertificateStatus.statusVerified:
        iconDisplay = Icon(Icons.security, color: Colors.green[500]);
        break;
      case X509CertificateStatus.statusTriedError:
        iconDisplay = Icon(Icons.autorenew, color: Colors.yellow[500]);
        _verify();
        break;
      case X509CertificateStatus.statusUnverifiable:
        iconDisplay = Icon(Icons.priority_high, color: Colors.yellow[500]);
        break;
    }
    return Container(
      width: 63,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 5), child: Image.asset('images/google.png', width: 12, color: cert.programs.contains('google') ? null : Colors.grey[300])),
              Image.asset('images/microsoft.png', width: 12, color: cert.programs.contains('microsoft') ? null : Colors.grey[300]),
              Padding(padding: EdgeInsets.only(top: 5), child: Image.asset('images/apple.png', width: 12, color: cert.programs.contains('apple') ? null : Colors.grey[300])),
            ],
          ),
          IconButton(
            icon: iconDisplay,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }

  void _verify() async {
    await verifier.verify(cert);
    setState(() {});
  }
}
