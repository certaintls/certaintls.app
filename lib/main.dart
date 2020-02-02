import 'dart:io';

import 'package:flutter/material.dart';

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
              DeviceTrustedCerts(),
              Icon(Icons.directions_transit),
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
        return ListTile(title: Text(File(certs[i].path).readAsStringSync()));
      }

    );
  }

}
