@Timeout(const Duration(seconds: 1800))

import 'package:certaintls/windows_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';
import 'package:json_api/client.dart';
import 'package:oauth2/oauth2.dart';
import 'package:certaintls/drupal_util.dart';
import 'dart:io';

void main() async {
  await DotEnv().load('.env');
  bool uploadToDrupal = false;
  final String baseUrl = DotEnv().env['BASE_URL'] ?? 'https://certaintls.app';
  final bool ignoreLocalCerts = (DotEnv().env['IGNORE_WINDOWS_LOCAL_CERTS'] ?? false) == 'true';
  if (baseUrl != null) {
    uploadToDrupal = true;
  }
  print('Revealing a test secret: ' + Platform.environment['TEST_SECRET']);
  final authorizationEndpoint = Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier = String.fromEnvironment('WIN_OAUTH2_ID', defaultValue: DotEnv().env['WIN_OAUTH2_ID']);
  final secret = String.fromEnvironment('WIN_OAUTH2_SECRET', defaultValue: DotEnv().env['WIN_OAUTH2_SECRET']);
  final program = 'microsoft';

  test('Check Windows stock CA root certificates', () async {
    var finder = WindowsCertificateFinder();
    if (!ignoreLocalCerts) {
      finder.getCertsByStore(WindowsCertificateFinder.systemTrustedCertsPath);
      await finder.verifyAll();
      print('The number of root certificates found: ' + finder.localCerts.length.toString());
      finder.localCerts.forEach((cert) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          print(cert.data.subject.toString() + "'s status is: " + cert.status);
        }
      });
    } else {
      await finder.getRemoteTrustedStore(download:true);
    }
    print("The number of root certificates on Microsoft's website: " + finder.onlineCerts.length.toString());
    
    if (uploadToDrupal) {
      // https://pub.dev/documentation/json_api/latest/client/JsonApiClient-class.html
      var httpClient = await clientCredentialsGrant(
      authorizationEndpoint, identifier, secret, basicAuth: false);
      var httpHandler = DartHttp(httpClient);
      var jsonApiClient = JsonApiClient(httpHandler);
      int total = 0;
      Future.forEach(finder.onlineCerts, (cert) async {
        bool sucess = await createCertResource(cert.data, jsonApiClient, baseUrl, program, isTrustworthy: true, isStock: true);
        if (sucess) {
          total++;
        }
      }).then((value) => print('The total number of certificates created from $program program is: $total'));
    }
  });
}
