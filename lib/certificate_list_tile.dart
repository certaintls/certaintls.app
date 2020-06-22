import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CertificateListTile extends StatefulWidget {
  final List<X509Certificate> certs;
  final CertificateVerifier verifier;
  final int pos;

  CertificateListTile(this.certs, this.pos, this.verifier);

  @override
  State<StatefulWidget> createState() {
    X509Certificate cert = certs[pos];
    X509CertificateData data = cert.data;
    String commonName = getCommonName(data);
    String org = getOrg(data);
    String country = getCountry(data) != null ? ' (' + getCountry(data)+ ')' : '';
    return CertificateState(certs: certs, pos: pos, verifier: verifier, title: Text(org + country), subtitle: Text(commonName));
  }
}

class CertificateState extends State<CertificateListTile> {
  List<X509Certificate> certs;
  int pos;
  CertificateVerifier verifier;
  Text title;
  Text subtitle;

  CertificateState({this.certs, this.pos, this.verifier, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    X509Certificate cert = widget.certs[pos];
    if (cert.status == X509CertificateStatus.statusUnchecked) {
      _verify();
    }
    return ListTile(title: title, subtitle: subtitle,
      leading: _generateStatusIcon(cert.status),
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
    X509Certificate cert = certs[pos];
    if (cert.status == X509CertificateStatus.statusUnchecked) {
      await verifier.verify(cert);
    }
    switch(cert.status) {
      case X509CertificateStatus.statusTriedError:
        _verify();
        break;
      case X509CertificateStatus.statusCompromised:

        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget _generateStatusIcon(String status) {
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
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: iconDisplay,
          onPressed: _verify,
        ),
        SizedBox(
          height: 24.0,
          width: 24.0,
          child: Visibility(
            visible: isInProgress,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            )
          )
        )
      ]
    );
  }
}
