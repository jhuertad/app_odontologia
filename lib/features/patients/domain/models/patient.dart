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
  final String? activeTreatment;

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
    this.activeTreatment,
  });

  String get fullName => '$firstName $lastName';
  bool get hasCriticalAllergies => criticalAllergies.isNotEmpty;

  int get age {
    if (birthDate == null) return 28;
    final now = DateTime.now();
    int a = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      a--;
    }
    return a;
  }
}
