import '../domain/models/medical_history.dart';

class MedicalHistoryRepository {
  static final MedicalHistoryRepository _instance = MedicalHistoryRepository._internal();
  factory MedicalHistoryRepository() => _instance;
  MedicalHistoryRepository._internal() {
    _initSampleData();
  }

  final List<SOAPNote> _notes = [];

  void _initSampleData() {
    if (_notes.isNotEmpty) return;
    _notes.addAll([
      SOAPNote(
        id: 'n-1',
        patientId: 'p-1',
        doctorId: 'd-1',
        doctorName: 'Dr. John Huerta',
        date: DateTime.now().subtract(const Duration(days: 7)),
        subjective: 'Paciente femenina acude refiriendo sensibilidad aguda al frío y masticación en molar superior derecho desde hace 4 días.',
        objective: 'Examen clínico revela cavidad cariosa profunda en cara Oclusal y Mesial de pieza 16. Pruebas de vitalidad pulpar positivas con respuesta no persistente. No dolor a la percusión.',
        analysis: 'Caries de esmalte y dentina profunda en pieza 16 (Pulpitis reversible).',
        plan: 'Apertura cavitaria, remoción de caries con fresa de bola, grabado selectivo, adhesivo de 5ta gen y obturación con resina compuesta estética nanohíbrida color A2.',
        procedureDone: 'Aislamiento absoluto con dique de goma, eliminación de caries 16-OM y restauración directa con resina 3M Filtek Z350.',
      ),
      SOAPNote(
        id: 'n-2',
        patientId: 'p-1',
        doctorId: 'd-1',
        doctorName: 'Dr. John Huerta',
        date: DateTime.now().subtract(const Duration(days: 21)),
        subjective: 'Consulta de control general y profilaxis periódica.',
        objective: 'Presencia de placa bacteriana leve y cálculo subgingival en incisivos anteroinferiores. Tejido gingival edematoso leve.',
        analysis: 'Gingivitis marginal inducida por biopelícula dental.',
        plan: 'Destartraje con ultrasonido piezoeléctrico, profilaxis con pasta abrasiva y fluorización tópica.',
        procedureDone: 'Destartraje supragingival completo con scaler ultrasónico y pulido coronario.',
      ),
      SOAPNote(
        id: 'n-3',
        patientId: 'p-2',
        doctorId: 'd-1',
        doctorName: 'Dr. John Huerta',
        date: DateTime.now().subtract(const Duration(days: 3)),
        subjective: 'Dolor pulsátil nocturno intenso en pieza 36 que no calma con analgésicos.',
        objective: 'Caries penetrante extensa con compromiso pulpar. Dolor severo a la percusión horizontal y vertical.',
        analysis: 'Pulpitis irreversible sintomática pieza 36.',
        plan: 'Tratamiento de conductos radiculares (Endodoncia mecanizada multirradicular) en dos sesiones.',
        procedureDone: 'Biopulpectomía, instrumentación rotatoria inicial de conductos mesiales y distal, colocación de hidróxido de calcio intraconducto y sellado provisional.',
      ),
    ]);
  }

  List<SOAPNote> getNotesForPatient(String patientId) {
    return _notes.where((n) => n.patientId == patientId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void addNote(SOAPNote note) {
    _notes.insert(0, note);
  }
}
