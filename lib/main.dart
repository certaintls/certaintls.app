import 'dart:async';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:certaintls/certificate_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'certs_model.dart';
import 'certificate_tile.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(ChangeNotifierProvider(
    create: (context) => CertsModel(),
    child: MaterialApp(title: 'CertainTLS', home: MyApp())));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool _allowReporting = false;

  @override
  void initState() {
    super.initState();
    Timer.run(() => _showAboutDialog(context));
  }

  @override
  Widget build(BuildContext context) {
    List<DeviceCerts> bodies = [];
    bodies.add(DeviceCerts(0));
    bodies.add(DeviceCerts(1));
    bodies.add(DeviceCerts(2));

    return Scaffold(
      appBar: AppBar(
        title: Text('CertainTLS'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _showAboutDialog(context))
        ],
      ),
      body: bodies[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.public),
            label: 'Authorities',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.cloud_download),
            label: 'User Installed',
          ),
          BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Stack(alignment: Alignment.topRight, children: <Widget>[
                Icon(Icons.warning),
                Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Consumer<CertsModel>(
                            builder: (context, certsModel, child) => Text(
                                  certsModel.storeCerts[2].length.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                )))),
              ]),
              label: 'Problems')
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAboutDialog(BuildContext ctx) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        bool allowReporting =
            prefs.getBool('allow_reporting') ?? _allowReporting;
        return StatefulBuilder(builder: (context, setState) {
          String userName = prefs.getString('user_name');
          return AboutDialog(
            applicationVersion: '1.4.2',
            applicationIcon: Image.asset('images/logo.png'),
            children: [
              Text(
                  "Please help make CertainTLS better by allowing us to collect device operating system metadata and certificates' fingerprints for analysis. None of the above is personally identifying information. You can optionally provide your name below:"),
              TextField(
                  decoration: InputDecoration(hintText: 'Your name'),
                  controller: TextEditingController()..text = userName,
                  onChanged: _onNameUpdate),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                FlatButton(
                  onPressed: _openPrivacyPolicy,
                  child: Text(
                    'Read the CertainTLS privacy policy ',
                    style: TextStyle(color: Colors.blue),
                  ),
                  padding: EdgeInsets.zero,
                ),
                Icon(Icons.open_in_browser_outlined, color: Colors.blue)
              ]),
              Row(children: [
                Text('Allow data collection?'),
                Switch(
                    value: allowReporting,
                    onChanged: (changed) {
                      setState(() {
                        allowReporting = changed;
                        _saveAllowReportingPreference(changed);
                      });
                    })
              ]),
            ],
          );
        });
      },
    );
  }

  void _onNameUpdate(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_name', name);
  }

  void _saveAllowReportingPreference(bool isAllowed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('allow_reporting', isAllowed);
  }

  void _openPrivacyPolicy() async {
    const url =
        'https://github.com/certaintls/certaintls/blob/master/PRIVACY.md#privacy-statement---certaintls';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class DeviceCerts extends StatelessWidget {
  final listRef;

  DeviceCerts(this.listRef);

  @override
  Widget build(BuildContext context) {
    return Consumer<CertsModel>(
      builder: (context, m, child) => Column(children: [
        _showProgressIndicator(m, listRef),
        Expanded(
            child: m.storeCerts[listRef].isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: m.storeCerts[listRef].length,
                    itemBuilder: (context, i) => Hero(
                          tag: i,
                          child: Material(
                            child: GestureDetector(
                                child:
                                    CertificateTile(m.storeCerts[listRef][i]),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CertificateDetail(
                                                  m.storeCerts[listRef][i],
                                                  i,
                                                  m.distruster)));
                                }),
                          ),
                        ))
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: Wrap(children: [
                      Text(
                        m.noUserCertsHelperText,
                        style: TextStyle(fontSize: 20),
                      ),
                      Platform.isAndroid
                          ? Row(
                              children: [
                                RaisedButton(
                                    onPressed: () {
                                      final AndroidIntent intent =
                                          AndroidIntent(
                                        action:
                                            'com.android.settings.TRUSTED_CREDENTIALS_USER',
                                      );
                                      intent.launch();
                                    },
                                    child: Text(
                                        'View installed certificates via System UI')),
                                SizedBox(width: 20),
                                Icon(Icons.android,
                                    color: Color.fromRGBO(164, 198, 57, 1))
                              ],
                            )
                          : SizedBox.shrink()
                    ]))))
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
