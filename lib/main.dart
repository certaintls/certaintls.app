import 'dart:io';
import 'package:certaintls/android_certificate_finder.dart';
import 'package:certaintls/certaintls_server_verifier.dart';
import 'package:certaintls/certificate_detail.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/macos_certificate_finder.dart';
import 'package:certaintls/windows_certificate_finder.dart';
import 'package:flutter/material.dart';
import 'certificate_list_tile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CertificateFinder finder;
    if (Platform.isAndroid) {
      finder = AndroidCertificateFinder();
    } else if (Platform.isMacOS) {
      finder = MacOSCertificateFinder();
    } else if (Platform.isWindows) {
      finder = WindowsCertificateFinder();
    }
    var stores = finder.getCertStores();
    List<Tab> tabs = [];
    List<DeviceCerts> bodies = [];
    stores.forEach((key, value) {
      tabs.add(Tab(text: key, icon: Icon(Icons.public)));
      bodies.add(DeviceCerts(path: value));
    });
    return MaterialApp(
      title: 'CertainTLS',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Device Certificates'),
        ),
        body: bodies[0],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.public),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              title: Text('Business'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              title: Text('Problems'),
            ),
          ]),
      )
    );
  }
}

class DeviceCerts extends StatelessWidget {
  final String path;

  DeviceCerts({this.path});

  @override
  Widget build(BuildContext context) {
    CertificateFinder finder;
    if (Platform.isAndroid) {
      finder = AndroidCertificateFinder();
    } else if (Platform.isMacOS) {
      finder = MacOSCertificateFinder();
    } else if (Platform.isWindows) {
      finder = WindowsCertificateFinder();
    }
    var certs = finder.getCertsByStore(path);
    var verifier = CertainTLSServerVerifier(certs);

    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: certs.length,
      itemBuilder: (context, i) =>
        Hero(
          tag: i,
          child: Material(
            child: GestureDetector(
              child: CertificateListTile(certs, i, verifier),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CertificateDetail(certs[i], i)));
              }
            ),
          ),
        )
    );
  }
}
