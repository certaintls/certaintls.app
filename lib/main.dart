import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:x509/x509.dart';
import 'package:pem/pem.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CertainTLS',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Device Certificates'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Certificate Authorities', icon: Icon(Icons.public)),
                Tab(text: 'User Installed', icon: Icon(Icons.folder_shared)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DeviceTrustedCerts(), // ‘system-trusted ‘ certificates /system/etc/security/
              Icon(Icons.directions_transit), // ‘user-trusted’ certificates /data/misc/keychain/certs-added
            ],
          )
        ),
      ),
    );
  }
}

class DeviceTrustedCerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var certsDir = new Directory('/system/etc/security/cacerts');
    List<FileSystemEntity> certs = certsDir.listSync(recursive: false, followLinks: false);
    return ListView.builder(
      itemCount: certs.length,
      itemBuilder: (context, i) {
        //var certString = File(certs[i].path).readAsStringSync();
        String certTxt = new File(certs[i].path).readAsStringSync();
        List<int> certData = PemCodec(PemLabel.certificate).decode(certTxt);
        String encoded = PemCodec(PemLabel.certificate).encode(certData);
        X509CertificateData data = X509Utils.x509CertificateFromPem(encoded);
        if (data.subject["2.5.4.10"] != null) {
          return ListTile(title: Text(i.toString() + ' : ' +data.subject["2.5.4.10"] + ' (' +data.subject["2.5.4.6"] + ')'));
        } else {return ListTile(title: Text(data.issuer.toString()));}
      }

    );
  }

}
