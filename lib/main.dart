import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/android_certificate_finder.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/macos_certificate_finder.dart';
import 'package:certaintls/verifier_widget.dart';
import 'package:certaintls/windows_certificate_finder.dart';
import 'package:flutter/material.dart';

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
      home: DefaultTabController(
        length: stores.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Device Certificates'),
            bottom: TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: bodies,
          )
        ),
      ),
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
    return ListView.builder(
      itemCount: certs.length,
      itemBuilder: (context, i) {
        X509CertificateData data = certs[i].data;
        String org;
        String country;
        String commonName;
        try {
          // If commone name is missing, use the org unit
          commonName = data.subject['2.5.4.3'] != null ? data.subject['2.5.4.3'] : (data.subject['2.5.4.11'] ?? '');
          // If org is missing, use the common name
          if (data.subject['2.5.4.10'] == null) {
            org = commonName;
            commonName = '';
          } else {
            org = data.subject['2.5.4.10'];
          }
          country = data.subject['2.5.4.6'] != null ? ' (' + data.subject['2.5.4.6']+ ')' : '';
          return ListTile(leading: VerifierWidget(cert: certs[i], finder: finder), title: Text(org + country), subtitle: Text(commonName));
        } catch (e) {
          return ListTile(title: Text(i.toString() + '- Exception:' + e.toString()));
        }
      }

    );
  }

}
