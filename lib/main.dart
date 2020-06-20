import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/android_certificate_finder.dart';
import 'package:certaintls/certaintls_server_verifier.dart';
import 'package:certaintls/certificate_finder.dart';
import 'package:certaintls/macos_certificate_finder.dart';
import 'package:certaintls/windows_certificate_finder.dart';
import 'package:flutter/material.dart';
import 'certificate_list_tile.dart';
import 'x509certificate.dart';

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
    var verifier = CertainTLSServerVerifier(certs);

    return AnimatedList(
      initialItemCount: certs.length,
      itemBuilder: (context, i, animation) {
        X509CertificateData data = certs[i].data;
        String org;
        String country;
        String commonName;
        try {
          commonName = getCommonName(data);
          org = getOrg(data);
          country = getCountry(data) != null ? ' (' + getCountry(data)+ ')' : '';
          return CertificateListTile(cert: certs[i], verifier: verifier, title: Text(org + country), subtitle: Text(commonName));
        } catch (e) {
          return ListTile(title: Text(i.toString() + '- Exception:' + e.toString()));
        }
      }

    );
  }

}
