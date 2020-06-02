import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';

final drupalEndpoints = <String, String>{
  'oauth2_token': '/oauth/token',
  'certificate': '/jsonapi/node/certificate',
  'device': '/jsonapi/user/user',
};

Future<bool> createCertResource(X509CertificateData certData, JsonApiClient jsonApiClient, String baseUrl, String program, {bool isTrustworthy = false, bool isStock = false}) async {
  final url = Uri.parse(baseUrl + drupalEndpoints['certificate']);
  var resource = constructCertRes(certData, program, isTrustworthy, isStock);
  jsonApiClient.createResourceAt(url, resource)
  .then((result) {
    print(result.statusCode);
    return true;
  })
  .catchError(onError);
  return false;
}
  onError(e) {
    print(e);
}

Resource constructCertRes(X509CertificateData data, String program, bool isTrustworthy, bool isStock) {
  var attributes = <String, Object> {
    'title': getCommonName(data),
    'field_cert_sha256': data.sha256Thumbprint,
    'field_spki_sha256': data.publicKeyData.sha256Thumbprint,
    'field_country': data.subject['2.5.4.6'],
    'field_issuer': getOrg(data),
    'field_program': program,
    'field_trustworthy': isTrustworthy,
    'field_type': isStock,
  };
  return Resource('node--certificate', null, attributes: attributes);
}