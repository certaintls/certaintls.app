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
  // The third list contains the problematic certs
  List<List<X509Certificate>> storeCerts = List(3);
  CertificateVerifier verifier;
  Map<String, String> stores;

  CertsModel() {
    CertificateFinder finder;
    storeCerts[2] = [];
    if (Platform.isAndroid) {
      finder = AndroidCertificateFinder();
    } else if (Platform.isMacOS) {
      finder = MacOSCertificateFinder();
    } else if (Platform.isWindows) {
      finder = WindowsCertificateFinder();
    }
    stores = finder.getCertStores();
    storeCerts[0] = finder.getCertsByStore(stores.values.toList()[0]);
    storeCerts[1] = null;
    storeCerts[2] = [];

    verifier = CertainTLSServerVerifier(storeCerts[0]);
  }

  void verifyAll() async {
    await Future.forEach(storeCerts[0], (X509Certificate cert) async {
      await verifier.verify(cert).then((sucess) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          storeCerts[2].add(cert);
        }
        notifyListeners();
      });
    });
  }

  Map<String, String> getStores() => stores;
}
