class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String documentId;
  final String phoneWhatsapp;
  final String? email;
  final DateTime? birthDate;
  final List<String> criticalAllergies; // Alergias con badge de advertencia médica roja
  final Map<String, dynamic> medicalHistory;

  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.documentId,
    required this.phoneWhatsapp,
    this.email,
    this.birthDate,
    this.criticalAllergies = const [],
    this.medicalHistory = const {},
  });

  String get fullName => '$firstName $lastName';
  bool get hasCriticalAllergies => criticalAllergies.isNotEmpty;
}
