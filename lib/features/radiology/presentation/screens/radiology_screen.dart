import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../../data/radiology_repository.dart';
import '../../domain/models/xray_image.dart';

class RadiologyScreen extends StatefulWidget {
  final String? patientId;
  const RadiologyScreen({super.key, this.patientId});

  @override
  State<RadiologyScreen> createState() => _RadiologyScreenState();
}

class _RadiologyScreenState extends State<RadiologyScreen> {
  final _repository = RadiologyRepository();
  XRayType? _filterType;

  @override
  Widget build(BuildContext context) {
    final allImages = widget.patientId != null
        ? _repository.getImagesForPatient(widget.patientId!)
        : _repository.getAllImages();

    final images = _filterType == null
        ? allImages
        : allImages.where((i) => i.type == _filterType).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visor Radiográfico & RX', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Periapicales, panorámicas y fotos diagnósticas', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtros de Tipo de Imagen
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip('Todas (${allImages.length})', null),
                  _buildTypeChip('Periapicales', XRayType.periapical),
                  _buildTypeChip('Panorámicas', XRayType.panoramic),
                  _buildTypeChip('Fotos Clínicas', XRayType.intraoralPhoto),
                ],
              ),
            ),
          ),

          // Galería Grid
          Expanded(
            child: images.isEmpty
                ? const Center(
                    child: Text('No hay radiografías registradas con este filtro.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return _buildXRayCard(images[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, XRayType? type) {
    final isSelected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterType = type),
        selectedColor: const Color(0xFF00A896).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF00A896) : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildXRayCard(XRayImage image) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: () => _openViewerModal(image),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview de la imagen
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.white54),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          image.typeLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (image.relatedTooth != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A896),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${image.relatedTooth}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Metadatos
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(image.date),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image.diagnosis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openViewerModal(XRayImage image) {
    showDialog(
      context: context,
      builder: (ctx) => _MedicalXRayViewerDialog(image: image),
    );
  }
}

class _MedicalXRayViewerDialog extends StatefulWidget {
  final XRayImage image;
  const _MedicalXRayViewerDialog({required this.image});

  @override
  State<_MedicalXRayViewerDialog> createState() => _MedicalXRayViewerDialogState();
}

class _MedicalXRayViewerDialogState extends State<_MedicalXRayViewerDialog> {
  bool _invertColors = false;

  static const ColorFilter _negativeFilter = ColorFilter.matrix(<double>[
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1,   0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          title: Text('${widget.image.typeLabel} ${widget.image.relatedTooth != null ? "• Pieza #${widget.image.relatedTooth}" : ""}'),
          actions: [
            // Filtro de Inversión / Negativo
            IconButton.filledTonal(
              icon: Icon(
                _invertColors ? Icons.invert_colors_off_rounded : Icons.invert_colors_rounded,
                color: _invertColors ? const Color(0xFF00A896) : Colors.white,
              ),
              tooltip: 'Inversión de Color (Negativo)',
              onPressed: () => setState(() => _invertColors = !_invertColors),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Visor interactivo con PhotoView (Zoom y Pan)
            Expanded(
              child: ClipRect(
                child: ColorFiltered(
                  colorFilter: _invertColors
                      ? _negativeFilter
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: PhotoView(
                    imageProvider: NetworkImage(widget.image.imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3.5,
                    backgroundDecoration: const BoxDecoration(color: Colors.black),
                  ),
                ),
              ),
            ),

            // Panel inferior de diagnóstico y controles
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF131C2E),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description_rounded, color: Color(0xFF00A896), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Informe Diagnóstico Radiológico',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          'Zoom táctil activado',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.image.diagnosis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
