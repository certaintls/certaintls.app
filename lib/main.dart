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
              Icon(Icons.directions_car),
              Icon(Icons.directions_transit),
            ],
          )
        ),
      ),
    );
  }
}
