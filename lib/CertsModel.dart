
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'android_certificate_finder.dart';
import 'certaintls_server_verifier.dart';
import 'certificate_finder.dart';
import 'certificate_verifier.dart';
import 'macos_certificate_finder.dart';
import 'windows_certificate_finder.dart';
import 'x509certificate.dart';

class CertsModel extends ChangeNotifier {
  List<List<X509Certificate>> storeCerts = [];
  CertificateVerifier verifier;
  Map<String, String> stores;

  CertsModel() {
    CertificateFinder finder;
    if (Platform.isAndroid) {
      finder = AndroidCertificateFinder();
    } else if (Platform.isMacOS) {
      finder = MacOSCertificateFinder();
    } else if (Platform.isWindows) {
      finder = WindowsCertificateFinder();
    }
    stores = finder.getCertStores();
    stores.forEach((key, path) {
      storeCerts.add(finder.getCertsByStore(path));
    });

    verifier = CertainTLSServerVerifier(storeCerts[0]);
  }

  void verifyAll() async {
    await Future.forEach(storeCerts[0], (cert) async {
      await verifier.verify(cert).then((sucess) {
        notifyListeners();
      });
    });
  }

  Map<String, String> getStores() => stores;

  Tab getTab(int i) {
    return Tab(text: stores.keys.toList()[i], icon: Icon(Icons.public));
  }

}