import '../../../../core/constants/fdi_constants.dart';
import '../domain/models/tooth.dart';

class OdontogramRepository {
  static final OdontogramRepository _instance = OdontogramRepository._internal();
  factory OdontogramRepository() => _instance;
  OdontogramRepository._internal() {
    _initSampleData();
  }

  final Map<String, Map<int, Tooth>> _patientTeeth = {};

  void _initSampleData() {
    // 1. Camila Ramos Vega (p-1)
    final camilaTeeth = _generateInitialTeeth();
    camilaTeeth[16] = camilaTeeth[16]!.copyWith(surfaces: {'occlusal': ToothCondition.cavity});
    camilaTeeth[21] = camilaTeeth[21]!.copyWith(surfaces: {'vestibular': ToothCondition.restored});
    _patientTeeth['p-1'] = camilaTeeth;

    // 2. Marcos Delgado Solís (p-2)
    final marcosTeeth = _generateInitialTeeth();
    marcosTeeth[36] = marcosTeeth[36]!.copyWith(
      generalCondition: ToothCondition.endodontic,
      surfaces: {'occlusal': ToothCondition.planned},
    );
    _patientTeeth['p-2'] = marcosTeeth;

    // 3. Valentina Gómez Castro (p-3)
    final valentinaTeeth = _generateInitialTeeth();
    valentinaTeeth[64] = valentinaTeeth[64]!.copyWith(surfaces: {'occlusal': ToothCondition.cavity});
    _patientTeeth['p-3'] = valentinaTeeth;

    // 4. Rodrigo Pérez Méndez (p-4)
    final rodrigoTeeth = _generateInitialTeeth();
    rodrigoTeeth[24] = rodrigoTeeth[24]!.copyWith(generalCondition: ToothCondition.missing);
    _patientTeeth['p-4'] = rodrigoTeeth;

    // 5. Lucía Benavides Rios (p-5)
    final luciaTeeth = _generateInitialTeeth();
    // Profilaxis realizada, dientes limpios y sanos
    luciaTeeth[17] = luciaTeeth[17]!.copyWith(surfaces: {'occlusal': ToothCondition.restored});
    _patientTeeth['p-5'] = luciaTeeth;
  }

  Map<int, Tooth> _generateInitialTeeth() {
    final Map<int, Tooth> teeth = {};
    for (final fdiNum in [
      ...FdiConstants.adultQuadrant1,
      ...FdiConstants.adultQuadrant2,
      ...FdiConstants.adultQuadrant4,
      ...FdiConstants.adultQuadrant3,
    ]) {
      teeth[fdiNum] = Tooth(fdiNumber: fdiNum, isDeciduous: false);
    }
    for (final fdiNum in [
      ...FdiConstants.childQuadrant5,
      ...FdiConstants.childQuadrant6,
      ...FdiConstants.childQuadrant8,
      ...FdiConstants.childQuadrant7,
    ]) {
      teeth[fdiNum] = Tooth(fdiNumber: fdiNum, isDeciduous: true);
    }
    return teeth;
  }

  Map<int, Tooth> getTeethForPatient(String patientId) {
    if (!_patientTeeth.containsKey(patientId)) {
      _patientTeeth[patientId] = _generateInitialTeeth();
    }
    // Retornar copia defensiva
    return Map<int, Tooth>.from(_patientTeeth[patientId]!);
  }

  void saveTeethForPatient(String patientId, Map<int, Tooth> teeth) {
    _patientTeeth[patientId] = Map<int, Tooth>.from(teeth);
  }
}
