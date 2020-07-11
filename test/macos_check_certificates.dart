@Timeout(const Duration(seconds: 1800))

import 'package:certaintls/macos_certificate_finder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_api/client.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';
import 'package:certaintls/drupal_util.dart';
import 'dart:io';

void main() async {
  await DotEnv().load('.env');
  bool uploadToDrupal = false;
  final String baseUrl = DotEnv().env['BASE_URL'] ?? drupalBaseUrl;
  if (baseUrl != null) {
    uploadToDrupal = true;
  }
  final authorizationEndpoint =
      Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier =
      Platform.environment['MAC_OAUTH2_ID'] ?? DotEnv().env['MAC_OAUTH2_ID'];
  final secret = Platform.environment['MAC_OAUTH2_SECRET'] ??
      DotEnv().env['MAC_OAUTH2_SECRET'];
  final program = 'apple';

  test('Check MacOS stock CA root certificates', () async {
    var finder = MacOSCertificateFinder();
    var certs =
        finder.getCertsByStore(MacOSCertificateFinder.systemTrustedCertsPath);
    await finder.verifyAll(certs);
    print('The number of root certificates found: ' + certs.length.toString());
    print("The number of root certificates on Apple's website: " +
        finder.onlineCerts.length.toString());
    JsonApiClient jsonApiClient;
    if (uploadToDrupal) {
      var httpClient = await clientCredentialsGrant(
          authorizationEndpoint, identifier, secret,
          basicAuth: false);
      var httpHandler = DartHttp(httpClient);
      jsonApiClient = JsonApiClient(httpHandler);
      await syncCertsToDrupal(certs, jsonApiClient, program, baseUrl: baseUrl);
    }
  });
}
