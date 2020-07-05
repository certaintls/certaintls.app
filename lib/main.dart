import 'dart:io';
import 'package:certaintls/certificate_detail.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CertsModel.dart';
import 'certificate_tile.dart';

void main() => runApp(
    ChangeNotifierProvider(create: (context) => CertsModel(), child: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<CertsModel>(context, listen: false);
    model.verifyAll();
    List<DeviceCerts> bodies = [];
    bodies.add(DeviceCerts(certs: model.storeCerts[0]));
    bodies.add(DeviceCerts(certs: null));
    bodies.add(DeviceCerts(certs: model.storeCerts[2]));

    return MaterialApp(
        title: 'CertainTLS',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Device Certificates'),
          ),
          body: bodies[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.public),
                title: Text('Authorities'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud_download),
                title: Text('Custom Installed'),
              ),
              BottomNavigationBarItem(
                  icon: Stack(alignment: Alignment.topRight, children: <Widget>[
                    Icon(Icons.warning),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Consumer<CertsModel>(
                                builder: (context, certsModel, child) => Text(
                                      certsModel.storeCerts[2].length
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    )))),
                  ]),
                  title: Text('Problems'))
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class DeviceCerts extends StatelessWidget {
  final List<X509Certificate> certs;

  DeviceCerts({this.certs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(top: 10),
        itemCount: certs.length,
        itemBuilder: (context, i) => Hero(
              tag: i,
              child: Material(
                child: GestureDetector(
                    child: CertificateTile(certs[i]),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CertificateDetail(certs[i], i)));
                    }),
              ),
            ));
  }
}
