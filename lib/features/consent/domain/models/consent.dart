import 'dart:typed_data';

class ConsentTemplate {
  final String id;
  final String procedureName;
  final String description;
  final List<String> risks;
  final List<String> benefits;

  const ConsentTemplate({
    required this.id,
    required this.procedureName,
    required this.description,
    required this.risks,
    required this.benefits,
  });
}

class SignedConsent {
  final String id;
  final String patientId;
  final String patientName;
  final String procedureName;
  final String doctorName;
  final DateTime signedAt;
  final Uint8List signatureBytes;
  final String hashSha256;

  const SignedConsent({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.procedureName,
    required this.doctorName,
    required this.signedAt,
    required this.signatureBytes,
    required this.hashSha256,
  });
}
