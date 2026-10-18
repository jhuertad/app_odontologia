import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../domain/models/consent.dart';

class ConsentRepository {
  static final ConsentRepository _instance = ConsentRepository._internal();
  factory ConsentRepository() => _instance;
  ConsentRepository._internal() {
    _initTemplates();
  }

  final List<ConsentTemplate> _templates = [];
  final List<SignedConsent> _signedConsents = [];

  void _initTemplates() {
    if (_templates.isNotEmpty) return;
    _templates.addAll([
      const ConsentTemplate(
        id: 't-1',
        procedureName: 'Cirugía de Terceras Molares (Muelas del Juicio)',
        description: 'Procedimiento quirúrgico para la extracción de terceras molares erupcionadas, semi-impactadas o impactadas bajo anestesia local.',
        risks: [
          'Inflamación y edema postoperatorio en la zona maxilofacial (3 a 5 días).',
          'Dolor postoperatorio controlable mediante la medicación analgésica prescrita.',
          'Riesgo infrecuente de parestesia temporal del nervio dentario inferior o lingual.',
          'Alveolitis seca en caso de no seguir las indicaciones postoperatorias.',
        ],
        benefits: [
          'Prevención de apiñamiento dental y reabsorción radicular de molares contiguos.',
          'Eliminación de focos infecciosos recurrentes (pericoronaritis).',
        ],
      ),
      const ConsentTemplate(
        id: 't-2',
        procedureName: 'Tratamiento de Conductos Radiculares (Endodoncia)',
        description: 'Terapia para desinfectar y obturar el sistema de conductos radiculares de piezas dentales con afección pulpar o necrosis.',
        risks: [
          'Molestia o sensibilidad leve a la percusión durante las primeras 48 horas.',
          'Riesgo de fractura coronaria antes de la rehabilitación definitiva mediante corona.',
          'Curvaturas anatómicas complejas que requieran varias sesiones o derivación.',
        ],
        benefits: [
          'Conservación de la pieza dental natural en boca, evitando la extracción.',
          'Alivio definitivo del dolor dental de origen pulpar.',
        ],
      ),
      const ConsentTemplate(
        id: 't-3',
        procedureName: 'Colocación de Implante Dental Oseointegrado',
        description: 'Cirugía para la inserción de un tornillo de titanio biocompatible en el hueso maxilar para sustituir una raíz dental perdida.',
        risks: [
          'Proceso inflamatorio local.',
          'Riesgo menor al 2% de falta de oseointegración biológica.',
          'Necesidad de esperar el periodo de oseointegración de 3 a 4 meses antes de cargar la corona.',
        ],
        benefits: [
          'Recuperación de la función masticatoria sin desgastar dientes vecinos.',
          'Estabilidad ósea a largo plazo y estética dental natural.',
        ],
      ),
    ]);
  }

  List<ConsentTemplate> getTemplates() => List.unmodifiable(_templates);
  List<SignedConsent> getSignedConsents() => List.unmodifiable(_signedConsents);

  SignedConsent signConsent({
    required String patientId,
    required String patientName,
    required String procedureName,
    required String doctorName,
    required Uint8List signatureBytes,
  }) {
    final now = DateTime.now();
    // Computar sello SHA-256 inmutable de la firma + datos
    final rawData = '$patientId:$procedureName:${now.toIso8601String()}:${signatureBytes.length}';
    final hash = sha256.convert(utf8.encode(rawData)).toString();

    final signed = SignedConsent(
      id: 'sc-${now.millisecondsSinceEpoch}',
      patientId: patientId,
      patientName: patientName,
      procedureName: procedureName,
      doctorName: doctorName,
      signedAt: now,
      signatureBytes: signatureBytes,
      hashSha256: hash,
    );

    _signedConsents.insert(0, signed);
    return signed;
  }
}
