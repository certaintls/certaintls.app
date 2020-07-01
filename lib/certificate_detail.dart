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
                  Text(getSubtitle(data), style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    generateStatusIcon(cert.status),
                    Text(cert.status),
                    Text('  listed on '),
                    Text(cert.programs.toString())
                  ]),
                  Text('Issued to:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Common name:'),
                    Text(getCommonName(data)),
                    SizedBox(height: 10),
                    Text('Organization:'),
                    Text(getOrg(data)),
                    SizedBox(height: 10),
                    Text('Organization unit:'),
                    //Text(getOU(data)),
                    SizedBox(height: 10),
                    Text('Serial number:'),
                    Text(data.serialNumber.toString()),
                    Text(getPrettyJSONString(data.toJson()))
                  ]),

                ]),
              ),
            ),
          ),
        ));
  }
}

String getPrettyJSONString(jsonObject){
   var encoder = new JsonEncoder.withIndent("     ");
   return encoder.convert(jsonObject);
}