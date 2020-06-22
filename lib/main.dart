import 'dart:io';
import 'package:certaintls/android_certificate_finder.dart';
import 'package:certaintls/certaintls_server_verifier.dart';
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
      home: DefaultTabController(
        length: stores.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text("Device Certificates",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ))),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey,
                      tabs: tabs
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: bodies,
            )
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

    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: certs.length,
      itemBuilder: (context, i) {
        return CertificateListTile(certs, i, verifier);
      }
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;
  final Container customController = Container(
    height: 60,
    color: Colors.white,
    child: Row(
      children: [
        Text('Total: , Checked: , Not Trustworthy: , Uncertain: '),
        Switch(value: false, onChanged: null)
      ]
    )
  );
  @override
  double get minExtent => 60;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context, double shrinkOffset, bool overlapsContent) {
      if (shrinkOffset == maxExtent) {
        return customController;
      }
      return Container(
        color: Colors.white,
        child: _tabBar,
      );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}