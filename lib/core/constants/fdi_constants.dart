/// Constantes para el Odontograma Internacional FDI (ISO 3950)
class FdiConstants {
  FdiConstants._();

  // Cuadrantes Adultos (Dentición Permanente: 32 piezas)
  // Cuadrante 1: Superior Derecho (18 al 11)
  static const List<int> adultQuadrant1 = [18, 17, 16, 15, 14, 13, 12, 11];
  // Cuadrante 2: Superior Izquierdo (21 al 28)
  static const List<int> adultQuadrant2 = [21, 22, 23, 24, 25, 26, 27, 28];
  // Cuadrante 4: Inferior Derecho (48 al 41)
  static const List<int> adultQuadrant4 = [48, 47, 46, 45, 44, 43, 42, 41];
  // Cuadrante 3: Inferior Izquierdo (31 al 38)
  static const List<int> adultQuadrant3 = [31, 32, 33, 34, 35, 36, 37, 38];

  // Cuadrantes Pediátricos (Dentición Decidua: 20 piezas)
  // Cuadrante 5: Superior Derecho Infantil (55 al 51)
  static const List<int> childQuadrant5 = [55, 54, 53, 52, 51];
  // Cuadrante 6: Superior Izquierdo Infantil (61 al 65)
  static const List<int> childQuadrant6 = [61, 62, 63, 64, 65];
  // Cuadrante 8: Inferior Derecho Infantil (85 al 81)
  static const List<int> childQuadrant8 = [85, 84, 83, 82, 81];
  // Cuadrante 7: Inferior Izquierdo Infantil (71 al 75)
  static const List<int> childQuadrant7 = [71, 72, 73, 74, 75];

  /// Caras de cada pieza dental
  static const String surfaceVestibular = 'V';
  static const String surfaceLingual = 'L'; // Lingual (inferior) o Palatino (superior)
  static const String surfaceMesial = 'M';
  static const String surfaceDistal = 'D';
  static const String surfaceOcclusal = 'O'; // Oclusal en molares o Incisal en anteriores
}
