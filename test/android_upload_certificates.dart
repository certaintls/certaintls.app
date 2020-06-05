@Timeout(const Duration(seconds: 1800))

import 'package:certaintls/android_certificate_finder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_api/client.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';
import 'package:certaintls/drupal_util.dart';
import 'dart:io';

void main() async {
  await DotEnv().load('.env');
  final String baseUrl = DotEnv().env['BASE_URL'] ?? 'https://certaintls.app';
  final authorizationEndpoint = Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier = Platform.environment['ANDROID_OAUTH2_ID'] ?? DotEnv().env['ANDROID_OAUTH2_ID'];
  final secret = Platform.environment['ANDROID_OAUTH2_SECRET'] ?? DotEnv().env['ANDROID_OAUTH2_SECRET'];
  final program = 'google';

  test('Upload Android stock CA root certificates', () async {
    var finder = AndroidCertificateFinder();
    finder.getCertsByStore('/tmp/ca-certificates/files');
    await finder.verifyAll();
    print('The number of root certificates found: ' + finder.localCerts.length.toString());
    int totalUploaded = 0;
    JsonApiClient jsonApiClient;
    var httpClient = await clientCredentialsGrant(authorizationEndpoint, identifier, secret, basicAuth: false);
    var httpHandler = DartHttp(httpClient);
    jsonApiClient = JsonApiClient(httpHandler);
    await Future.forEach(finder.localCerts, (cert) {
      Future<bool> sucess = createCertResource(cert.data, jsonApiClient, baseUrl, program, isTrustworthy: true, isStock: true);
      sucess.then((value) {
        if (value) {
          totalUploaded++;
        }
      });
      return sucess;
    }).then((value) => print('The total number of certificates created from $program program is: $totalUploaded'));
  });
}
