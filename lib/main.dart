import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/verifier_widget.dart';
import 'package:flutter/material.dart';
import 'package:pem/pem.dart';
import 'certificate_resource.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CertificateResource cerRes = CertificateResource();
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
              DeviceCerts(path: cerRes.systemTrustedCertsPath), 
              DeviceCerts(path: cerRes.userTrustedCertsPath),
            ],
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
    
    var certsDir = new Directory(path);
    List<FileSystemEntity> certs = certsDir.listSync(recursive: false, followLinks: false);
    return ListView.builder(
      itemCount: certs.length,
      itemBuilder: (context, i) {
        //var certString = File(certs[i].path).readAsStringSync();
        File file = new File(certs[i].path);
        String certTxt = file.readAsStringSync();
        List<int> certData = PemCodec(PemLabel.certificate).decode(certTxt);
        String encoded = PemCodec(PemLabel.certificate).encode(certData);
        X509CertificateData data;
        String org;
        String country;
        String commonName;
        try {
          data = X509Utils.x509CertificateFromPem(encoded);
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
          return ListTile(leading: VerifierWidget(spkiFingerPrint: data.publicKeyData.sha256Thumbprint, certName: basename(certs[i].path)), title: Text(org + country), subtitle: Text(commonName));
        } catch (e) {
          return ListTile(title: Text(i.toString() + '- Exception:' + e.toString() +' : ' + certTxt));
        }
      }

    );
  }

}
