import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';

class CertificateDetail extends StatelessWidget {
  final X509Certificate cert;
  // Needed for hero animation
  final int index;

  CertificateDetail(this.cert, this.index);

  @override
  Widget build(BuildContext context) {
    X509CertificateData data = cert.data;
    return Scaffold(
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
                        Text(' -- ' + cert.programs.toString())
                      ]),
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
}

String getPrettyJSONString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}
