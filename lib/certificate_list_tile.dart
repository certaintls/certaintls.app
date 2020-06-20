import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CertificateListTile extends StatefulWidget {
  final X509Certificate cert;
  final CertificateVerifier verifier;
  final Text title;
  final Text subtitle;

  CertificateListTile({this.cert, this.verifier, this.title, this.subtitle});

  @override
  State<StatefulWidget> createState() => CertificateState(cert: cert, verifier: verifier, title: title, subtitle: subtitle);
}

class CertificateState extends State<CertificateListTile> {
  X509Certificate cert;
  CertificateVerifier verifier;
  Text title;
  Text subtitle;

  CertificateState({this.cert, this.verifier, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    _verify();
    return ListTile(title: title, subtitle: subtitle,
      leading: _generateStatusIcon(cert),
      trailing: Container(
        width: 56,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 6.0,
          crossAxisSpacing: 6.0,
          padding: const EdgeInsets.all(8.0),
          children: [
            Image.asset('images/google.png', color: cert.programs.contains('google') ? null : Colors.grey[300]),
            Image.asset('images/microsoft.png', color: cert.programs.contains('microsoft') ? null : Colors.grey[300]),
            Image.asset('images/apple.png', color: cert.programs.contains('apple') ? null : Colors.grey[300]),
            Image.asset('images/mozilla.png', color: cert.programs.contains('mozilla') ? null : Colors.grey[300]),
          ],
        )
      )
    );
  }

  void _verify() async {
    await verifier.verify(cert);
    setState(() {});
  }

  Widget _generateStatusIcon(X509Certificate cert) {
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
}