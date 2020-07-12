import 'dart:io';
import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:json_api/client.dart';
import 'package:http/http.dart';
import 'package:json_api/document.dart';
import 'drupal_util.dart';

class CertainTLSServerVerifier implements CertificateVerifier {
  Uri certUrl;
  String drupalBaseUrl;
  final httpClient = new Client();
  JsonApiClient jsonApiClient;

  CertainTLSServerVerifier(String baseUrl, JsonApiClient client) {
    drupalBaseUrl = baseUrl;
    certUrl = Uri.parse(baseUrl + drupalEndpoints['certificate']);
    jsonApiClient = client;
  }

  static Future<CertainTLSServerVerifier> build() async {
    var baseUrl = await getDrupalBaseUrl();
    var client = await buildJsonApiClient(baseUrl: baseUrl);
    return CertainTLSServerVerifier(baseUrl, client);
  }

  @override
  Future<bool> verify(X509Certificate cert) async {
    // 1. Search the cert fingerprint
    var result =
        await findCert(cert.data, jsonApiClient, baseUrl: drupalBaseUrl);

    if (result.data.collection.length == 1) {
      cert.status = X509CertificateStatus.statusVerified;
      cert.programs = getCertPrograms(result.data.collection[0]);
      cert.remoteId = getUuid(result.data.collection[0]);
      cert.isTrustworthy = isTrustwhorthy(result.data.collection[0]);
      if (!cert.isTrustworthy) {
        cert.status = X509CertificateStatus.statusCompromised;
      }
      return true;
    }
    // 2. Search the SPKI fingerprint
    result = await findkey(cert.data, jsonApiClient, baseUrl: drupalBaseUrl);
    if (result.data.collection.length > 0) {
      cert.programs = getCertPrograms(result.data.collection[0]);
      cert.isTrustworthy = isTrustwhorthy(result.data.collection[0]);
      cert.status = X509CertificateStatus.statusVerified;
      if (!cert.isTrustworthy) {
        cert.status = X509CertificateStatus.statusCompromised;
      }
      return true;
    }

    // 3. Cannot find any cert.
    cert.status = X509CertificateStatus.statusUnverifiable;

    return true;
  }

  @override
  Future verifyAll(List<X509Certificate> certs) async {
    await Future.forEach(certs, (cert) async {
      await verify(cert);
    });
  }

  Future<String> createDevice(List<Identifier> certificates) async {
    var result = await createDeviceResource(
        Platform.localeName,
        Platform.operatingSystem,
        Platform.operatingSystemVersion,
        jsonApiClient,
        baseUrl: drupalBaseUrl,
        fieldCertificates: certificates);
    if (result.statusCode == 201)
      return result.data.resourceObject.id;
    else
      return '';
  }

  Future<bool> updateDevice(
      String deviceUuid, List<Identifier> certificates) async {
    var result = await updateDeviceResource(
        deviceUuid,
        Platform.localeName,
        Platform.operatingSystem,
        Platform.operatingSystemVersion,
        jsonApiClient,
        baseUrl: drupalBaseUrl,
        fieldCertificates: certificates);
    if (result.statusCode == 200)
      return true;
    else
      return false;
  }
}
