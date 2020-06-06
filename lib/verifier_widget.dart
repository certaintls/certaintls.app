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
    return IconButton(
      icon: iconDisplay,
      onPressed: _verify,
    );
  }

  void _verify() async {
    await verifier.verify(cert);
    setState(() {});
  }
}
