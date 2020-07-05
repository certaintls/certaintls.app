import 'package:certaintls/certificate_detail.dart';
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
    List<DeviceCerts> bodies = [];
    bodies.add(DeviceCerts(0));
    bodies.add(DeviceCerts(1));
    bodies.add(DeviceCerts(2));

    return MaterialApp(
        title: 'CertainTLS',
        home: Scaffold(
          appBar: AppBar(
            title: Text('CertainTLS'),
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
                title: Text('User Installed'),
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
  final listRef;

  DeviceCerts(this.listRef);

  @override
  Widget build(BuildContext context) {
    return Consumer<CertsModel>(
      builder: (context, m, child) => Column(children: [
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: m.storeCerts[listRef].length,
              itemBuilder: (context, i) => Hero(
                    tag: i,
                    child: Material(
                      child: GestureDetector(
                          child: CertificateTile(m.storeCerts[listRef][i]),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CertificateDetail(
                                        m.storeCerts[listRef][i], i)));
                          }),
                    ),
                  )),
        ),
        _showProgressIndicator(m, listRef)
      ]),
    );
  }

  Widget _showProgressIndicator(CertsModel m, int listRef) {
    var length = m.storeCerts[listRef].length;
    return listRef == 2
        ? SizedBox()
        : LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[300]),
            backgroundColor: Colors.white,
            value: length == 0 ? 0 : m.progress[listRef] / length);
  }
}
