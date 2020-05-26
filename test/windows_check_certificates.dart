@Timeout(const Duration(seconds: 1800))

import 'package:certaintls/windows_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';
import 'package:json_api/client.dart';
import 'package:oauth2/oauth2.dart';
import 'package:certaintls/drupal_util.dart';

void main() async {
  await DotEnv().load('.env');
  bool uploadToDrupal = false;
  final baseUrl = Uri.parse(DotEnv().env['BASE_URL'];
  if (baseUrl != null) {
    uploadToDrupal = true;
  }
  final authorizationEndpoint = Uri.parse(DotEnv().env['BASE_URL'] + drupalEndpoints['oauth2_token']);
  final identifier = DotEnv().env['OAUTH2_ID'];
  final secret = DotEnv().env['OAUTH2_SECRET'];
  final program = 'microsoft';

  test('Check Windows stock CA root certificates', () async {
    var finder = WindowsCertificateFinder();
    finder.getCertsByStore(WindowsCertificateFinder.systemTrustedCertsPath);
    await finder.getRemoteTrustedStore(download: true);
    await finder.verifyAll();
    print('The number of root certificates found: ' + finder.localCerts.length.toString());
    print("The number of root certificates on Microsoft's website: " + finder.onlineCerts.length.toString());
    finder.localCerts.forEach((cert) {
      expect(cert.status, X509CertificateStatus.statusVerified, reason: cert.data.subject.toString() + "'s status is: " + cert.status);
    });
    if (uploadToDrupal) {
      // https://pub.dev/documentation/json_api/latest/client/JsonApiClient-class.html
      var httpClient = await clientCredentialsGrant(
      authorizationEndpoint, identifier, secret, basicAuth: false);
      var httpHandler = DartHttp(httpClient);
      var jsonApiClient = JsonApiClient(httpHandler);
      int total = 0;
      finder.onlineCerts.forEach((cert) async {
        bool sucess = await createCertResource(cert.data, jsonApiClient, program, isTrustworthy: true, isStock: true);
        if (sucess) {
          total++;
        }
      });
      print('The total number of certificates created from $program program is: $total');
    }
  });
}
