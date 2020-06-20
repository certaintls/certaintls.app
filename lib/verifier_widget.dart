import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class VerifierWidget extends StatefulWidget {

  final List<X509Certificate> certs;
  final CertificateVerifier verifier;
  final int index;
  final BuildContext listContext;

  VerifierWidget({this.certs, this.verifier, this.listContext, this.index});

  @override
  _VerifierWidgetState createState() =>
      _VerifierWidgetState(certs: certs, verifier: verifier, index: index);
}

class _VerifierWidgetState extends State<VerifierWidget> {
  List<X509Certificate> certs;
  final CertificateVerifier verifier;
  List<String> programs;
  final BuildContext listContext;
  final int index;

  _VerifierWidgetState({this.certs, this.verifier, this.listContext, this.index});

  @override
  Widget build(BuildContext context) {
    Icon iconDisplay;
    var cert = certs[index];
    switch (cert.status) {
      case X509CertificateStatus.statusUnchecked:
        iconDisplay = Icon(Icons.info);
        _verify();
        break;
      case X509CertificateStatus.statusCompromised:
        iconDisplay = Icon(Icons.highlight_off, color: Colors.red[500]);
        certs.removeAt(index);
        certs.insert(0, cert);
        setState(() {});
        // AnimatedList.of(listContext).insertItem(0);
        //AnimatedList.of(context).removeItem(index, (context, animation) => null);
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
    await verifier.verify(certs[index]);
    setState(() {});
  }
}
