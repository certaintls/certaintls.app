import 'dart:io' show Platform;

class CertificateResource {
  String systemTrustedCertsPath;
  String userTrustedCertsPath;
  
  CertificateResource() {
    if (Platform.isAndroid) {
      this.systemTrustedCertsPath = '/system/etc/security/cacerts';
      // https://stackoverflow.com/a/35132508/1966269
      this.userTrustedCertsPath = '/data/misc/keychain/certs-added';
    } else if (Platform.isWindows) {
      this.systemTrustedCertsPath = '/system/etc/security/';
      this.userTrustedCertsPath = '/data/misc/keychain/certs-added/';
    } else if (Platform.isMacOS) {
      // https://apple.stackexchange.com/a/226383
      this.systemTrustedCertsPath = '/System/Library/Keychains/SystemCACertificates.keychain';
      this.userTrustedCertsPath = '/System/Library/Keychains/SystemRootCertificates.keychain';
    } else {
      throw Exception(Platform.operatingSystem + ' is not supported by CertainTLS!');
    }
  }
}