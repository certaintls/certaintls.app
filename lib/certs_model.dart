import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_api/document.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String noUserCertsHelperText = 'No user installed certificates are found!';

  /// Back end entity reference
  List<Identifier> certsRef = [];

  CertsModel() {
    CertificateFinder finder;
    storeCerts[2] = [];
    if (Platform.isAndroid) {
      finder = AndroidCertificateFinder();
      noUserCertsHelperText =
          "Due to Android security model, third party apps like CertainTLS do not have access to the user installed certificates.\n\n"
          "However, a user can view the installer certificates via Android system UI:\n\n";
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
    CertainTLSServerVerifier.build().then((verifier) => verifyAll(verifier));
  }

  void verifyAll(CertainTLSServerVerifier verifier) async {
    await Future.forEach(storeCerts[0], (X509Certificate cert) async {
      await verifier.verify(cert).then((sucess) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          _addToProblemList(cert);
        }
        if (cert.remoteId != null) {
          certsRef.add(Identifier('node--certificate', cert.remoteId));
        }
        progress[0]++;
        notifyListeners();
      });
    });
    await Future.forEach(storeCerts[1], (X509Certificate cert) async {
      await verifier.verify(cert).then((sucess) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          _addToProblemList(cert);
        }
        if (cert.remoteId != null) {
          certsRef.add(Identifier('node--certificate', cert.remoteId));
        }
        progress[1]++;
        notifyListeners();
      });
    });

    // SharedPreference isn't avaiable on Windows yet
    if (!Platform.isWindows) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userUuid = prefs.getString('user_id');
      // 1. Check existing user with UUID from sharedpreference
      if (userUuid == null || userUuid.isEmpty) {
        // 2. Create a new user if UUID empty, and store in sharedpreference
        userUuid = await verifier.createDevice(certsRef);
        prefs.setString('user_id', userUuid);
        // TODO: 3. Check/Upload unknown certs
      } else {
        // TODO: 3. Check/Upload unknown certs
        // 4. Update device info.
        await verifier.updateDevice(userUuid, certsRef);
      }
    }
  }

  Map<String, String> getStores() => stores;

  void _addToProblemList(X509Certificate cert) {
    storeCerts[2].add(cert);
    if (cert.status == X509CertificateStatus.statusUnverifiable) {
      // TODO: Send to Drupal
    }
  }
}
