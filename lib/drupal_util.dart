import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:oauth2/oauth2.dart';
import 'package:faker/faker.dart';

const String drupalBaseUrl = 'https://certaintls.app';
final drupalEndpoints = <String, String>{
  'oauth2_token': '/oauth/token',
  'certificate': '/jsonapi/node/certificate',
  'device': '/jsonapi/user/user',
};

Future<bool> createCertResource(
    X509CertificateData certData, JsonApiClient jsonApiClient, String program,
    {String baseUrl = drupalBaseUrl,
    bool isTrustworthy = false,
    bool isStock = false}) async {
  final url = Uri.parse(baseUrl + drupalEndpoints['certificate']);
  var resource = constructCertRes(certData, program, isTrustworthy, isStock);
  var result =
      await jsonApiClient.createResourceAt(url, resource).catchError((value) {
    print(value.toString());
    return false;
  });

  if (result.statusCode == 201) {
    return true;
  } else
    return false;
}

Resource constructCertRes(X509CertificateData data, String program,
    bool isTrustworthy, bool isStock) {
  var attributes = <String, Object>{
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

Resource constructDeviceRes(String fieldLocaleName, String fieldOS,
    String fieldOSVersion, List<Identifier> fieldCertificates,
    {String uuid, String userName}) {
  var attributes = <String, Object>{
    'name': faker.internet.userName(),
    'field_locale_name': fieldLocaleName,
    'field_os': fieldOS,
    'field_os_version': fieldOSVersion,
    'field_display_name': userName
  };
  var relationships = <String, List<Identifier>>{
    'field_certificates': fieldCertificates
  };
  return Resource('user--user', uuid,
      attributes: attributes, toMany: relationships);
}

/// Search the remote cert by sha256 fingerprint
Future<Response<ResourceCollectionData>> findCert(
    X509CertificateData certData, JsonApiClient jsonApiClient,
    {String baseUrl = drupalBaseUrl}) {
  return jsonApiClient.fetchCollectionAt(
      Uri.parse(baseUrl + drupalEndpoints['certificate']),
      parameters: QueryParameters(
          {'filter[field_cert_sha256]': certData.sha256Thumbprint}));
}

/// Search the remote cert by PSKI fingerprint
Future<Response<ResourceCollectionData>> findkey(
    X509CertificateData certData, JsonApiClient jsonApiClient,
    {String baseUrl = drupalBaseUrl}) {
  return jsonApiClient.fetchCollectionAt(
      Uri.parse(baseUrl + drupalEndpoints['certificate']),
      parameters: QueryParameters(
          {'filter[field_spki_sha256]': certData.sha256Thumbprint}));
}

/// Search the remote device by UUID
Future<Response<ResourceCollectionData>> findDevice(
    String uuid, JsonApiClient jsonApiClient,
    {String baseUrl = drupalBaseUrl}) {
  return jsonApiClient.fetchCollectionAt(
      Uri.parse(baseUrl + drupalEndpoints['device']),
      parameters: QueryParameters({'id': uuid}));
}

/// Create the remote device
Future<Response<ResourceData>> createDeviceResource(String fieldLocaleName,
    String fieldOS, String fieldOSVersion, JsonApiClient jsonApiClient,
    {String baseUrl = drupalBaseUrl,
    List<Identifier> fieldCertificates,
    String userName}) async {
  final url = Uri.parse(baseUrl + drupalEndpoints['device']);
  var resource = constructDeviceRes(
      fieldLocaleName, fieldOS, fieldOSVersion, fieldCertificates,
      userName: userName);
  var result =
      await jsonApiClient.createResourceAt(url, resource).catchError((value) {
    print(value.toString());
  });
  return result;
}

Future<Response<ResourceData>> updateDeviceResource(
    String deviceUuid,
    String fieldLocaleName,
    String fieldOS,
    String fieldOSVersion,
    JsonApiClient jsonApiClient,
    {String baseUrl = drupalBaseUrl,
    List<Identifier> fieldCertificates,
    String userName}) async {
  final url = Uri.parse(baseUrl + drupalEndpoints['device'] + '/$deviceUuid');
  var resource = constructDeviceRes(
      fieldLocaleName, fieldOS, fieldOSVersion, fieldCertificates,
      userName: userName, uuid: deviceUuid);
  var result =
      await jsonApiClient.updateResourceAt(url, resource).catchError((value) {
    print(value.toString());
  });
  return result;
}

bool certBelongProgram(ResourceObject cert, String program) {
  List programs = getCertPrograms(cert);
  return programs.contains(program);
}

List getCertPrograms(ResourceObject cert) {
  return cert.attributes['field_program'];
}

String getUuid(ResourceObject cert) {
  return cert.id;
}

bool isTrustwhorthy(ResourceObject cert) {
  return cert.attributes['field_trustworthy'];
}

ResourceObject certAddProgram(ResourceObject cert, String program) {
  List programs = cert.attributes['field_program'];
  programs.add(program);
  return cert;
}

Future<bool> updateCertProgram(
    ResourceObject resObj, JsonApiClient jsonApiClient, String program,
    {String baseUrl = drupalBaseUrl}) async {
  final url =
      Uri.parse(baseUrl + drupalEndpoints['certificate'] + '/' + resObj.id);
  var result = await jsonApiClient.updateResourceAt(url, resObj.unwrap());
  if (result.statusCode == 200) {
    return true;
  } else
    return false;
}

Future syncCertsToDrupal(Iterable<X509Certificate> localCerts,
    JsonApiClient jsonApiClient, String program,
    {String baseUrl = drupalBaseUrl, bool blindTrust = false}) async {
  int totalUploaded = 0;
  await Future.forEach(localCerts, (cert) async {
    var result = await findCert(cert.data, jsonApiClient, baseUrl: baseUrl);
    if (result.data.collection.length == 1) {
      // Check if the program needs to be updated
      ResourceObject certResource = result.data.collection[0];
      bool contains = certBelongProgram(certResource, program);
      if (!contains) {
        // Add the program
        certResource = certAddProgram(certResource, program);
        Future<bool> sucess = updateCertProgram(
            certResource, jsonApiClient, program,
            baseUrl: baseUrl);
        sucess.then((value) {
          if (value) {
            totalUploaded++;
          }
        });
        return sucess;
      }
    } else {
      bool trust = blindTrust
          ? blindTrust
          : cert.status == X509CertificateStatus.statusVerified;
      Future<bool> sucess = createCertResource(
          cert.data, jsonApiClient, program,
          baseUrl: baseUrl, isTrustworthy: trust, isStock: true);
      sucess.then((value) {
        if (value) {
          totalUploaded++;
        }
      });
      return sucess;
    }
  }).then((value) => print(
      'The total number of certificates synced from $program program to CertainTLS.app server is: $totalUploaded'));
}

/// Return a client with an established authorized connection
Future<JsonApiClient> buildJsonApiClient(
    {String prefix = 'DEFAULT', String baseUrl = drupalBaseUrl}) async {
  await DotEnv().load('.env');
  final String baseUrl = DotEnv().env['BASE_URL'] ?? drupalBaseUrl;
  final authorizationEndpoint =
      Uri.parse(baseUrl + drupalEndpoints['oauth2_token']);
  final identifier = DotEnv().env[prefix + '_OAUTH2_ID'];
  final secret = DotEnv().env[prefix + '_OAUTH2_SECRET'];
  var httpClient = await clientCredentialsGrant(
      authorizationEndpoint, identifier, secret,
      basicAuth: false);
  var httpHandler = DartHttp(httpClient);
  return JsonApiClient(httpHandler);
}

Future<String> getDrupalBaseUrl() async {
  await DotEnv().load('.env');
  return DotEnv().env['BASE_URL'] ?? drupalBaseUrl;
}
