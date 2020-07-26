@Timeout(const Duration(seconds: 1800))

import 'package:certaintls/windows_certificate_manager.dart';
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
  final String baseUrl = DotEnv().env['BASE_URL'] ?? drupalBaseUrl;
  final bool ignoreLocalCerts =
      (DotEnv().env['IGNORE_WINDOWS_LOCAL_CERTS'] ?? false) == 'true';
  if (baseUrl != null) {
    uploadToDrupal = true;
  }
  final authorizationEndpoint =
      Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier =
      Platform.environment['WIN_OAUTH2_ID'] ?? DotEnv().env['WIN_OAUTH2_ID'];
  final secret = Platform.environment['WIN_OAUTH2_SECRET'] ??
      DotEnv().env['WIN_OAUTH2_SECRET'];
  final program = 'microsoft';

  test('Check Windows stock CA root certificates', () async {
    var finder = WindowsCertificateManager();
    var certs = finder
        .getCertsByStore(WindowsCertificateManager.systemTrustedCertsPath);
    if (!ignoreLocalCerts) {
      await finder.verifyAll(certs);
      print(
          'The number of root certificates found: ' + certs.length.toString());
      certs.forEach((cert) {
        if (cert.status != X509CertificateStatus.statusVerified) {
          print(cert.data.subject.toString() + "'s status is: " + cert.status);
        }
      });
    } else {
      await finder.getRemoteTrustedStore();
    }
    print("The number of root certificates on Microsoft's website: " +
        finder.onlineCerts.length.toString());

    if (uploadToDrupal) {
      var httpClient = await clientCredentialsGrant(
          authorizationEndpoint, identifier, secret,
          basicAuth: false);
      var httpHandler = DartHttp(httpClient);
      var jsonApiClient = JsonApiClient(httpHandler);
      await syncCertsToDrupal(certs, jsonApiClient, program, baseUrl: baseUrl);
    }
  });
}
