import 'dart:io';
import 'package:certaintls/certificate_verifier.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:json_api/client.dart';
import 'package:http/http.dart';
import 'package:json_api/http.dart';
import 'drupal_util.dart';


class CertainTLSServerVerifier implements CertificateVerifier {
  List<X509Certificate> localCerts = [];
  Uri certUrl;
  final httpClient = new Client();
  HttpHandler httpHandler;
  JsonApiClient jsonApiClient;

  CertainTLSServerVerifier(this.localCerts) {
    httpHandler = DartHttp(httpClient);
    jsonApiClient = JsonApiClient(httpHandler);
    certUrl = Uri.parse(drupalBaseUrl + drupalEndpoints['certificate']);
  }

  @override
  Future<bool> verify(X509Certificate cert) async {
    // 1. Search the cert fingerprint
    var result = await findCert(cert.data, jsonApiClient);
    if (result.data.collection.length == 1) {
      cert.status = X509CertificateStatus.statusVerified;
      return true;
    }
    // 2. Search the SPKI fingerprint
    result = await findkey(cert.data, jsonApiClient);
    if (result.data.collection.length > 0) {
      cert.status = X509CertificateStatus.statusVerified;
      return true;
    }
    cert.status = X509CertificateStatus.statusUnverifiable;
    return true;
  }

  @override
  Future verifyAll() async {
    await Future.forEach(localCerts, (cert) async {
      await verify(cert);
    });
  }

}