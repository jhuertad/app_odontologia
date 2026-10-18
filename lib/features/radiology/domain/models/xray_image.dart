enum XRayType {
  periapical,
  panoramic,
  cephalometric,
  intraoralPhoto,
}

class XRayImage {
  final String id;
  final String patientId;
  final XRayType type;
  final String imageUrl;
  final DateTime date;
  final int? relatedTooth;
  final String diagnosis;
  final String? notes;

  const XRayImage({
    required this.id,
    required this.patientId,
    required this.type,
    required this.imageUrl,
    required this.date,
    this.relatedTooth,
    required this.diagnosis,
    this.notes,
  });

  String get typeLabel {
    switch (type) {
      case XRayType.periapical:
        return 'Periapical';
      case XRayType.panoramic:
        return 'Panorámica';
      case XRayType.cephalometric:
        return 'Cefalométrica';
      case XRayType.intraoralPhoto:
        return 'Foto Intraoral';
    }
  }
}
