import '../domain/models/xray_image.dart';

class RadiologyRepository {
  static final RadiologyRepository _instance = RadiologyRepository._internal();
  factory RadiologyRepository() => _instance;
  RadiologyRepository._internal() {
    _initSampleData();
  }

  final List<XRayImage> _images = [];

  void _initSampleData() {
    if (_images.isNotEmpty) return;
    final now = DateTime.now();

    _images.addAll([
      XRayImage(
        id: 'rx-1',
        patientId: 'p-1',
        type: XRayType.periapical,
        // Imagen médica de muestra en alta resolución
        imageUrl: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&w=1200&q=80',
        date: now.subtract(const Duration(days: 7)),
        relatedTooth: 16,
        diagnosis: 'Radiolucidez coronal compatible con caries ocluso-mesial profunda en pieza 16. Espacio de ligamento periodontal conservado sin lesión periapical.',
        notes: 'Pre-operatoria para restauración.',
      ),
      XRayImage(
        id: 'rx-2',
        patientId: 'p-1',
        type: XRayType.panoramic,
        imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
        date: now.subtract(const Duration(days: 30)),
        relatedTooth: null,
        diagnosis: 'Ortopantomografía de diagnóstico inicial. Presencia de terceras molares 18, 28, 38, 48 impactadas. Densidad trabecular ósea normal.',
        notes: 'Control panorámico anual.',
      ),
      XRayImage(
        id: 'rx-3',
        patientId: 'p-2',
        type: XRayType.periapical,
        imageUrl: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&w=1200&q=80',
        date: now.subtract(const Duration(days: 4)),
        relatedTooth: 36,
        diagnosis: 'Compromiso de cámara pulpar por caries profunda en pieza 36. Ligero ensanchamiento del espacio del ligamento periodontal en ápice mesial.',
        notes: 'Conductometría para endodoncia.',
      ),
      XRayImage(
        id: 'rx-4',
        patientId: 'p-1',
        type: XRayType.intraoralPhoto,
        imageUrl: 'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?auto=format&fit=crop&w=1200&q=80',
        date: now.subtract(const Duration(days: 7)),
        relatedTooth: 16,
        diagnosis: 'Fotografía clínica oclusal de control pre-operatorio.',
        notes: 'Registro estético.',
      ),
    ]);
  }

  List<XRayImage> getImagesForPatient(String patientId) {
    return _images.where((img) => img.patientId == patientId).toList();
  }

  List<XRayImage> getAllImages() => List.unmodifiable(_images);

  void addImage(XRayImage image) {
    _images.insert(0, image);
  }
}
