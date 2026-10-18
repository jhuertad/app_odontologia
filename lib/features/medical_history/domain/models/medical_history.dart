/// Nota de Evolución Clínica bajo metodología SOAP
class SOAPNote {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String subjective; // Lo que refiere el paciente (ej. Dolor al frío en molar 16)
  final String objective; // Hallazgos clínicos y pruebas de vitalidad
  final String analysis; // Diagnóstico definitivo
  final String plan; // Tratamiento planificado o farmacología prescrita
  final String procedureDone; // Tratamiento ejecutado en la sesión

  const SOAPNote({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.subjective,
    required this.objective,
    required this.analysis,
    required this.plan,
    required this.procedureDone,
  });
}

/// Alergia médica registrada con nivel de criticidad
class MedicalAllergy {
  final String name;
  final String severity; // 'CRITICAL', 'MODERATE', 'MILD'
  final String? reaction;

  const MedicalAllergy({
    required this.name,
    this.severity = 'CRITICAL',
    this.reaction,
  });

  bool get isCritical => severity == 'CRITICAL';
}
