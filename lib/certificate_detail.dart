import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/certificate_distruster.dart';
import 'package:certaintls/macos_certificate_manager.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';

class CertificateDetail extends StatelessWidget {
  final X509Certificate cert;
  // Needed for hero animation
  final int index;
  final CertificateDistruster distruster;

  CertificateDetail(this.cert, this.index, this.distruster);

  @override
  Widget build(BuildContext context) {
    X509CertificateData data = cert.data;
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _handleDisableAction(context, cert),
            icon: Icon(Icons.delete_forever),
            label: Text('Disable'),
            backgroundColor: Colors.red),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        appBar: AppBar(
          title: Text(getTitle(data)),
        ),
        body: Hero(
          tag: index,
          child: SingleChildScrollView(
            child: Material(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getSubtitle(data),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [
                        generateStatusIcon(cert.status),
                        Text(cert.status.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                      Text('Root Certificate Authority Programs:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(cert.programs.join(', ').toUpperCase()),
                      SizedBox(height: 10),
                      Text('Issued to:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Common name:'),
                      Text(data.subject[X509Utils.DN['commonName']] ?? ''),
                      SizedBox(height: 10),
                      Text('Organization:'),
                      Text(
                          data.subject[X509Utils.DN['organizationName']] ?? ''),
                      SizedBox(height: 10),
                      Text('Organization unit:'),
                      Text(data.subject[
                              X509Utils.DN['organizationalUnitName']] ??
                          ''),
                      SizedBox(height: 10),
                      Text('Country:'),
                      Text(data.subject[X509Utils.DN['countryName']] ?? ''),
                      SizedBox(height: 10),
                      Text('Serial number:'),
                      Text(data.serialNumber.toString()),
                      SizedBox(height: 20),
                      Text('Issued by:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Common name:'),
                      Text(data.issuer[X509Utils.DN['commonName']] ?? ''),
                      SizedBox(height: 10),
                      Text('Organization:'),
                      Text(data.issuer[X509Utils.DN['organizationName']] ?? ''),
                      SizedBox(height: 10),
                      Text('Organization unit:'),
                      Text(
                          data.issuer[X509Utils.DN['organizationalUnitName']] ??
                              ''),
                      SizedBox(height: 20),
                      Text('Validity:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Issued on:'),
                      Text(data.validity.notBefore.toLocal().toString()),
                      SizedBox(height: 10),
                      Text('Expires on:'),
                      Text(data.validity.notAfter.toLocal().toString()),
                      SizedBox(height: 20),
                      Text('Fingerprints:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('SHA-256 fingerprint:'),
                      Text(StringUtils.addCharAtPosition(
                          data.publicKeyData.sha256Thumbprint, ' ', 2,
                          repeat: true)),
                      SizedBox(height: 10),
                      Text('SHA-1 fingerprint:'),
                      Text(StringUtils.addCharAtPosition(
                          data.sha1Thumbprint, ' ', 2,
                          repeat: true)),
                      SizedBox(height: 10),
                      Text('Subject Public Key Info (SPKI) fingerprint:'),
                      Text(StringUtils.addCharAtPosition(
                          data.publicKeyData.sha256Thumbprint, ' ', 2,
                          repeat: true)),
                      SizedBox(height: 10),
                    ]),
              ),
            ),
          ),
        ));
  }

  void _handleDisableAction(BuildContext ctx, X509Certificate cert) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: Text('Disable ' + getTitle(cert.data) + '?'),
              content: Text(
                  'Disabling certificate on Android through third party is not supported by the system.\n\n'
                  'However, CertainTLS cannot detect if you have disabled any certificates on Android.'),
              actions: [
                FlatButton(
                    onPressed: () => {Navigator.pop(ctx)}, child: Text('No')),
                FlatButton(onPressed: () => _distrust(ctx), child: Text('Yes'))
              ],
            ),
        barrierDismissible: false);
  }

  void _distrust(BuildContext ctx) {
    if (Platform.isAndroid) {
      _launchAndroidIntent();
    } else {
      var result = distruster.distrust(cert);
      if (result.stderr.isEmpty) {
        Navigator.pop(ctx);
      } else {
        showDialog(
            context: ctx,
            builder: (_) => AlertDialog(
                  title:
                      Text('Failed to distrust ' + getTitle(cert.data) + '!'),
                  content: Text(result.stderr +
                      '\n\n'
                          'You can either close CertainTLS and re-run it as root or \n'
                          'execute the below command manually:\n'
                          'sudo security delete-certificate -Z ' +
                      cert.data.sha1Thumbprint),
                  actions: [
                    FlatButton(
                        onPressed: () => {Navigator.pop(ctx)},
                        child: Text('OK'))
                  ],
                ));
      }
    }
  }
}

String getPrettyJSONString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}

void _launchAndroidIntent() {
  final AndroidIntent intent = AndroidIntent(
    action: 'com.android.settings.TRUSTED_CREDENTIALS',
  );
  intent.launch();
}
