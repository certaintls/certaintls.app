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

/// storeCerts[0] is the root certs
/// storeCerts[1] is the user intalled certs
/// storeCerts[2] is the problematic certs added from the first two
class CertsModel extends ChangeNotifier {
  // The third list contains the problematic certs
  List<List<X509Certificate>> storeCerts = List(3);
  List<int> progress = [0, 0];
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
    if (stores.length > 1) {
      storeCerts[1] = finder.getCertsByStore(stores.values.toList()[1]);
    } else {
      storeCerts[1] = [];
    }
    storeCerts[2] = [];
    verifier = CertainTLSServerVerifier();
    verifyAll();
  }

  void verifyAll() async {
    await Future.forEach(storeCerts[0], (X509Certificate cert) async {
      await verifier.verify(cert).then((sucess) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          storeCerts[2].add(cert);
        }
        progress[0]++;
        notifyListeners();
      });
    });
    await Future.forEach(storeCerts[1], (X509Certificate cert) async {
      await verifier.verify(cert).then((sucess) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          storeCerts[2].add(cert);
        }
        progress[1]++;
        notifyListeners();
      });
    });
  }

  Map<String, String> getStores() => stores;
}
