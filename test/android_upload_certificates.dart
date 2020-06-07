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
  final String baseUrl = DotEnv().env['BASE_URL'] ?? drupalBaseUrl;
  final authorizationEndpoint = Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier = Platform.environment['ANDROID_OAUTH2_ID'] ?? DotEnv().env['ANDROID_OAUTH2_ID'];
  final secret = Platform.environment['ANDROID_OAUTH2_SECRET'] ?? DotEnv().env['ANDROID_OAUTH2_SECRET'];
  final program = 'google';
  final bool ignoreLocalCerts = (DotEnv().env['IGNORE_ANDROID_LOCAL_CERTS'] ?? true) == 'true';
  // @see android-cron.yml for cloning ca-certificates repo
  final certsPath = Platform.isAndroid ? AndroidCertificateFinder.systemTrustedCertsPath : '/tmp/ca-certificates/files';

  test('Upload Android stock CA root certificates', () async {
    var finder = AndroidCertificateFinder();
    finder.getCertsByStore(certsPath);
    if (!ignoreLocalCerts) {
      await finder.verifyAll();
    }
    print('The number of root certificates found in $certsPath: ' + finder.localCerts.length.toString());
    JsonApiClient jsonApiClient;
    var httpClient = await clientCredentialsGrant(authorizationEndpoint, identifier, secret, basicAuth: false);
    var httpHandler = DartHttp(httpClient);
    jsonApiClient = JsonApiClient(httpHandler);
    await syncCertsToDrupal(finder.localCerts, jsonApiClient, program, baseUrl: baseUrl, blindTrust: ignoreLocalCerts);
  });
}
