import 'package:basic_utils/basic_utils.dart';
import 'package:certaintls/windows_certificate_finder.dart';
import 'package:certaintls/x509certificate.dart';
import 'package:test/test.dart';

void main() {
/*
================ Certificate 5 ================
X509 Certificate:
Version: 3
Serial Number: 040000000001154b5ac394
Signature Algorithm:
    Algorithm ObjectId: 1.2.840.113549.1.1.5 sha1RSA
    Algorithm Parameters:
    05 00
Issuer:
    CN=GlobalSign Root CA
    OU=Root CA
    O=GlobalSign nv-sa
    C=BE

 NotBefore: 9/1/1998 8:00 PM
 NotAfter: 1/28/2028 8:00 PM

Subject:
    CN=GlobalSign Root CA
    OU=Root CA
    O=GlobalSign nv-sa
    C=BE

Public Key Algorithm:
    Algorithm ObjectId: 1.2.840.113549.1.1.1 RSA (RSA_SIGN)
    Algorithm Parameters:
    05 00
Public Key Length: 2048 bits
Public Key: UnusedBits = 0
    0000  30 82 01 0a 02 82 01 01  00 da 0e e6 99 8d ce a3
    0010  e3 4f 8a 7e fb f1 8b 83  25 6b ea 48 1f f1 2a b0
    0020  b9 95 11 04 bd f0 63 d1  e2 67 66 cf 1c dd cf 1b
    0030  48 2b ee 8d 89 8e 9a af  29 80 65 ab e9 c7 2d 12
    0040  cb ab 1c 4c 70 07 a1 3d  0a 30 cd 15 8d 4f f8 dd
    0050  d4 8c 50 15 1c ef 50 ee  c4 2e f7 fc e9 52 f2 91
    0060  7d e0 6d d5 35 30 8e 5e  43 73 f2 41 e9 d5 6a e3
    0070  b2 89 3a 56 39 38 6f 06  3c 88 69 5b 2a 4d c5 a7
    0080  54 b8 6c 89 cc 9b f9 3c  ca e5 fd 89 f5 12 3c 92
    0090  78 96 d6 dc 74 6e 93 44  61 d1 8d c7 46 b2 75 0e
    00a0  86 e8 19 8a d5 6d 6c d5  78 16 95 a2 e9 c8 0a 38
    00b0  eb f2 24 13 4f 73 54 93  13 85 3a 1b bc 1e 34 b5
    00c0  8b 05 8c b9 77 8b b1 db  1f 20 91 ab 09 53 6e 90
    00d0  ce 7b 37 74 b9 70 47 91  22 51 63 16 79 ae b1 ae
    00e0  41 26 08 c8 19 2b d1 46  aa 48 d6 64 2a d7 83 34
    00f0  ff 2c 2a c1 6c 19 43 4a  07 85 e7 d3 7c f6 21 68
    0100  ef ea f2 52 9f 7f 93 90  cf 02 03 01 00 01
Certificate Extensions: 3
    2.5.29.15: Flags = 1(Critical), Length = 4
    Key Usage
        Certificate Signing, Off-line CRL Signing, CRL Signing (06)

    2.5.29.19: Flags = 1(Critical), Length = 5
    Basic Constraints
        Subject Type=CA
        Path Length Constraint=None

    2.5.29.14: Flags = 0, Length = 16
    Subject Key Identifier
        60 7b 66 1a 45 0d 97 ca 89 50 2f 7d 04 cd 34 a8 ff fc fd 4b

Signature Algorithm:
    Algorithm ObjectId: 1.2.840.113549.1.1.5 sha1RSA
    Algorithm Parameters:
    05 00
Signature: UnusedBits=0
    0000  e0 69 26 29 c9 48 fc e2  55 66 d6 1d 0a 88 0c de
    0010  c9 20 15 6f 80 a4 1f c5  1c 04 b3 81 db 18 41 d2
    0020  85 5f 82 f7 b6 fd c7 e9  2b f4 53 53 bf 52 63 ae
    0030  07 cc 41 de 3d fe f6 d6  5c e1 6a e4 61 3d 56 db
    0040  b7 70 dd 51 99 e4 82 aa  0c 9d 46 5d a6 6c f9 2b
    0050  85 89 67 d0 95 31 56 c4  2a 6e 86 47 f8 c2 8a 5d
    0060  17 ac 97 c8 ca ee 62 71  1c a7 b3 1e 78 24 69 2c
    0070  69 fe a5 1d 0c b5 15 b1  01 8f 29 ef a6 f0 95 e0
    0080  9a 64 48 12 2e fd 69 bc  df fc aa f6 46 63 b9 2c
    0090  ef 0d ff 8f 86 ec 30 55  ff 0d 15 64 75 5d c4 9c
    00a0  41 14 c9 15 d5 94 5f c3  df 04 98 97 94 51 70 0b
    00b0  c4 cd 38 fd 0a c6 f9 56  50 a0 ef 3b 26 8a 2f e6
    00c0  a3 38 b9 43 e1 39 ad ef  ba f2 1b 55 63 e3 a0 c3
    00d0  3e b3 09 46 d3 4d 61 3d  ca b3 a3 08 e5 b6 48 11
    00e0  aa 5e 6b bf 53 9e 09 bd  2b 2c 9c 6c fc 7c b5 32
    00f0  28 c5 34 be a2 ba ec bf  8d d0 76 4f 7c e7 73 d6
Signature matches Public Key
Root Certificate: Subject matches Issuer
Key Id Hash(rfc-sha1): 60 7b 66 1a 45 0d 97 ca 89 50 2f 7d 04 cd 34 a8 ff fc fd
Key Id Hash(sha1): 87 db d4 5f b0 92 8d 4e 1d f8 15 67 e7 f2 ab af d6 2b 67 75
Cert Hash(md5): 3e 45 52 15 09 51 92 e1 b7 5d 37 9f b1 87 29 8a
Cert Hash(sha1): b1 bc 96 8b d4 f4 9d 62 2a a8 9a 81 f2 15 01 52 a4 1d 82 9c

  CERT_ENHKEY_USAGE_PROP_ID(9):
    Enhanced Key Usage
        Server Authentication (1.3.6.1.5.5.7.3.1)
        Client Authentication (1.3.6.1.5.5.7.3.2)
        Code Signing (1.3.6.1.5.5.7.3.3)
        Secure Email (1.3.6.1.5.5.7.3.4)
        Time Stamping (1.3.6.1.5.5.7.3.8)
        OCSP Signing (1.3.6.1.5.5.7.3.9)
        Encrypting File System (1.3.6.1.4.1.311.10.3.4)
        IP security tunnel termination (1.3.6.1.5.5.7.3.6)
        IP security user (1.3.6.1.5.5.7.3.7)
        IP security IKE intermediate (1.3.6.1.5.5.8.2.2)

  CERT_ROOT_PROGRAM_CERT_POLICIES_PROP_ID(83):
    Certificate Policies
        [1]Certificate Policy:
             Policy Identifier=1.3.6.1.4.1.4146.1.1
             [1,1]Policy Qualifier Info:
                  Policy Qualifier Id=Root Program Flags
                  Qualifier:
                       c0

  Unknown Property(98):
    eb d4 10 40 e4 bb 3e c7  42 c9 e3 81 d3 1e f2 a4   ...@..>.B.......
    1a 48 b6 68 5c 96 e7 ce  f3 c1 df 6c d4 33 1c 99   .H.h\......l.3..

  CERT_FRIENDLY_NAME_PROP_ID(11):
    GlobalSign

  CERT_KEY_IDENTIFIER_PROP_ID(20):
    60 7b 66 1a 45 0d 97 ca 89 50 2f 7d 04 cd 34 a8 ff fc fd 4b

  CERT_SUBJECT_NAME_MD5_HASH_PROP_ID(29):
    6e e7 f3 b0 60 d1 0e 90 a3 1b a3 47 1b 99 92 36

  CERT_SHA1_HASH_PROP_ID(3):
    b1 bc 96 8b d4 f4 9d 62 2a a8 9a 81 f2 15 01 52 a4 1d 82 9c

  CERT_SIGNATURE_HASH_PROP_ID(15) disallowedHash:
    5a 6d 07 b6 37 1d 96 6a 2f b6 ba 92 82 8c e5 51 2a 49 51 3d

  CERT_SUBJECT_PUBLIC_KEY_MD5_HASH_PROP_ID(25):
    a8 23 b4 a2 01 80 be b4 60 ca b9 55 c2 4d 7e 21

  CERT_MD5_HASH_PROP_ID(4):
    3e 45 52 15 09 51 92 e1 b7 5d 37 9f b1 87 29 8a 
  */

  test('X509CertificateData can be constructed from imcomplete data returned by CertUtil on Windows', () async {
    var subject = <String, String>{};
    subject.putIfAbsent('2.5.4.3', () => 'GlobalSign Root CA');
    subject.putIfAbsent('2.5.4.10', () => 'GlobalSign nv-sa');
    subject.putIfAbsent('2.5.4.11', () => 'Root CA');
    subject.putIfAbsent('2.5.4.6', () => 'BE');
    X509CertificateData data = X509CertificateData(
      version: 3,
      sha1Thumbprint: 'b1bc968bd4f49d622aa89a81f2150152a41d829c'.toUpperCase(),
      subject: subject,
    );

    var finder = WindowsCertificateFinder();
    var cert = X509Certificate(data: data);
    await finder.verify(cert);
    expect(cert.status, X509CertificateStatus.statusVerified);
  });
}