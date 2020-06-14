@Timeout(const Duration(seconds: 1800))

import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:json_api/client.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';
import 'package:certaintls/drupal_util.dart';
import 'dart:io';
import 'package:http/http.dart' as generic;

void main() async {
  await DotEnv().load('.env');
  final String baseUrl = DotEnv().env['BASE_URL'] ?? drupalBaseUrl;
  final authorizationEndpoint = Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier = Platform.environment['MOZ_OAUTH2_ID'] ?? DotEnv().env['MOZ_OAUTH2_ID'];
  final secret = Platform.environment['MOZ_OAUTH2_SECRET'] ?? DotEnv().env['MOZ_OAUTH2_SECRET'];
  final program = 'mozilla';

  test('Upload Mozilla stock CA root certificates', () async {
    var onlineCerts = await getRemoteTrustedStore();
    print('The number of root certificates found in $program root CA program: ' + onlineCerts.length.toString());
    JsonApiClient jsonApiClient;
    var httpClient = await clientCredentialsGrant(authorizationEndpoint, identifier, secret, basicAuth: false);
    var httpHandler = DartHttp(httpClient);
    jsonApiClient = JsonApiClient(httpHandler);
    await syncCertsToDrupal(onlineCerts, jsonApiClient, program, baseUrl: baseUrl, blindTrust: true);
  });
}

Future<List<X509Certificate>> getRemoteTrustedStore() async {
  final String mozillaCurrentTrustedStore = 'https://ccadb-public.secure.force.com/mozilla/IncludedCACertificateReport';
  List<X509Certificate> onlineCerts = [];
  bool downloadOnlineCert = true;

  var client = generic.Client();
  generic.Response response = await client.get(mozillaCurrentTrustedStore);

  // Use html parser and query selector
  var document = parse(response.body);

  List<Element> fileUrls = document.querySelectorAll('.slds-table tr > td:nth-child(11)');

  for (int i = 0; i < fileUrls.length; i++) {
    String url = fileUrls[i].querySelector('a').attributes['href'];
    X509CertificateData data;
    if (downloadOnlineCert) {
      data = await certDownload(url, client: client);
    }
    if (!downloadOnlineCert || data != null) {
      onlineCerts.add(X509Certificate(data: data));
    }
  }

  return onlineCerts;
}