/// Estado del tratamiento o diagnóstico de una cara dental o pieza completa
enum ToothCondition {
  healthy, // Sano (Blanco/Gris)
  cavity, // Caries activa (Rojo)
  restored, // Obturación/Resina en buen estado (Azul)
  planned, // Tratamiento planificado (Amarillo)
  executedToday, // Realizado hoy (Verde)
  missing, // Diente ausente / Extraído
  crown, // Corona
  endodontic, // Endodoncia realizada
  implant, // Implante dental
}

/// Representa una pieza dental en el Odontograma FDI
class Tooth {
  final int fdiNumber;
  final bool isDeciduous; // true si es infantil (51-85)
  final Map<String, ToothCondition> surfaces; // 'V', 'L', 'M', 'D', 'O'
  final ToothCondition generalCondition;
  final String? notes;

  const Tooth({
    required this.fdiNumber,
    this.isDeciduous = false,
    this.surfaces = const {},
    this.generalCondition = ToothCondition.healthy,
    this.notes,
  });

  bool get isMissing => generalCondition == ToothCondition.missing;
  bool get hasCrown => generalCondition == ToothCondition.crown;
  bool get hasEndodontic => generalCondition == ToothCondition.endodontic;
  bool get hasImplant => generalCondition == ToothCondition.implant;

  bool get hasAnyCondition {
    if (generalCondition != ToothCondition.healthy) return true;
    return surfaces.values.any((c) => c != ToothCondition.healthy);
  }

  Tooth copyWith({
    int? fdiNumber,
    bool? isDeciduous,
    Map<String, ToothCondition>? surfaces,
    ToothCondition? generalCondition,
    String? notes,
  }) {
    return Tooth(
      fdiNumber: fdiNumber ?? this.fdiNumber,
      isDeciduous: isDeciduous ?? this.isDeciduous,
      surfaces: surfaces ?? this.surfaces,
      generalCondition: generalCondition ?? this.generalCondition,
      notes: notes ?? this.notes,
    );
  }
}
