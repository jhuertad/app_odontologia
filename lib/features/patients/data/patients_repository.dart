import '../domain/models/patient.dart';

class PatientsRepository {
  // Singleton para mantener estado en memoria durante la sesión
  static final PatientsRepository _instance = PatientsRepository._internal();
  factory PatientsRepository() => _instance;
  PatientsRepository._internal() {
    _initSampleData();
  }

  final List<Patient> _patients = [];

  void _initSampleData() {
    if (_patients.isNotEmpty) return;
    _patients.addAll([
      Patient(
        id: 'p-1',
        firstName: 'Camila',
        lastName: 'Ramos Vega',
        documentId: '47892104',
        phoneWhatsapp: '+51 987 654 321',
        email: 'camila.ramos@email.com',
        birthDate: DateTime(1996, 4, 15),
        criticalAllergies: ['Penicilina', 'Látex'],
        medicalHistory: {'hipertension': false, 'diabetes': false, 'embarazo': false},
        activeTreatment: 'Operatoria Dental (Piezas 16 y 21)',
      ),
      Patient(
        id: 'p-2',
        firstName: 'Marcos',
        lastName: 'Delgado Solís',
        documentId: '09812455',
        phoneWhatsapp: '+51 912 345 678',
        email: 'marcos.delgado@email.com',
        birthDate: DateTime(1988, 11, 23),
        criticalAllergies: [],
        medicalHistory: {'hipertension': true, 'diabetes': false},
        activeTreatment: 'Endodoncia Molar 36 y Corona',
      ),
      Patient(
        id: 'p-3',
        firstName: 'Valentina',
        lastName: 'Gómez Castro',
        documentId: '71239844',
        phoneWhatsapp: '+51 945 678 123',
        email: 'valentina.gomez@email.com',
        birthDate: DateTime(2018, 7, 9), // Pediátrico
        criticalAllergies: ['Ibuprofeno'],
        medicalHistory: {'fluorosis': false},
        activeTreatment: 'Odontopediatría: Pulpotomía 64 y Sellantes',
      ),
      Patient(
        id: 'p-4',
        firstName: 'Rodrigo',
        lastName: 'Pérez Méndez',
        documentId: '45678912',
        phoneWhatsapp: '+51 922 444 888',
        email: 'rodrigo.perez@email.com',
        birthDate: DateTime(1982, 2, 19),
        criticalAllergies: [],
        medicalHistory: {'diabetes': true},
        activeTreatment: 'Implante Dental en pieza 24',
      ),
    ]);
  }

  List<Patient> getAllPatients() => List.unmodifiable(_patients);

  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Patient> searchPatients(String query) {
    if (query.trim().isEmpty) return getAllPatients();
    final q = query.toLowerCase();
    return _patients.where((p) {
      return p.fullName.toLowerCase().contains(q) ||
          p.documentId.contains(q) ||
          p.phoneWhatsapp.contains(q);
    }).toList();
  }

  void addPatient(Patient patient) {
    _patients.insert(0, patient);
  }
}
