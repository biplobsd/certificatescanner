import 'package:certificatescanner/models/certificate.dart';

class CertificateInfo {
  Certificate? certificate;
  String? errorMsg;

  CertificateInfo({this.certificate, this.errorMsg});

  @override
  String toString() =>
      'CertificateInfo(certificate: $certificate, errorMsg: $errorMsg)';
}
