import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fdi_constants.dart';
import '../../domain/models/tooth.dart';

class ToothWidget extends StatefulWidget {
  final Tooth tooth;
  final bool isUpperArch;
  final Function(String surface) onSurfaceTap;
  final VoidCallback onToothTap;

  const ToothWidget({
    super.key,
    required this.tooth,
    required this.isUpperArch,
    required this.onSurfaceTap,
    required this.onToothTap,
  });

  @override
  State<ToothWidget> createState() => _ToothWidgetState();
}

class _ToothWidgetState extends State<ToothWidget> {
  bool _isHovered = false;

  LinearGradient _getGradientForCondition(ToothCondition? condition) {
    switch (condition) {
      case ToothCondition.cavity:
        return const LinearGradient(
          colors: [Color(0xFFFF4D6D), Color(0xFFC9184A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToothCondition.restored:
        return const LinearGradient(
          colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToothCondition.planned:
        return const LinearGradient(
          colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToothCondition.executedToday:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getSurfaceFromCoordinates(Offset localPosition, double size) {
    final x = localPosition.dx;
    final y = localPosition.dy;
    final margin = size * 0.32;

    // Centro (Oclusal / Incisal)
    if (x >= margin && x <= (size - margin) && y >= margin && y <= (size - margin)) {
      return FdiConstants.surfaceOcclusal;
    }

    // Top
    if (y < x && y < (size - x)) {
      return widget.isUpperArch ? FdiConstants.surfaceVestibular : FdiConstants.surfaceLingual;
    }
    // Bottom
    if (y > x && y > (size - x)) {
      return widget.isUpperArch ? FdiConstants.surfaceLingual : FdiConstants.surfaceVestibular;
    }
    // Left (Mesial)
    if (x < y && x < (size - y)) {
      return FdiConstants.surfaceMesial;
    }
    // Right (Distal)
    return FdiConstants.surfaceDistal;
  }

  @override
  Widget build(BuildContext context) {
    const double toothSize = 44.0;
    final isHighlighted = widget.tooth.hasAnyCondition;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Número FDI superior (Maxilar)
              if (widget.isUpperArch) _buildFdiBadge(isHighlighted),

              const SizedBox(height: 4),

              // Lienzo con diseño biomimético y sombras suaves
              GestureDetector(
                onTapUp: (details) {
                  if (widget.tooth.isMissing) {
                    widget.onToothTap();
                    return;
                  }
                  final surface = _getSurfaceFromCoordinates(details.localPosition, toothSize);
                  widget.onSurfaceTap(surface);
                },
                onLongPress: widget.onToothTap,
                child: Container(
                  width: toothSize,
                  height: toothSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: _isHovered ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomPaint(
                      painter: _AnatomicalToothPainter(
                        tooth: widget.tooth,
                        isUpperArch: widget.isUpperArch,
                        getGradient: _getGradientForCondition,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Número FDI inferior (Mandíbula)
              if (!widget.isUpperArch) _buildFdiBadge(isHighlighted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFdiBadge(bool isHighlighted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary
            : (_isHovered ? AppColors.primary.withValues(alpha: 0.15) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        '${widget.tooth.fdiNumber}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
          color: isHighlighted ? Colors.white : const Color(0xFF475569),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _AnatomicalToothPainter extends CustomPainter {
  final Tooth tooth;
  final bool isUpperArch;
  final LinearGradient Function(ToothCondition?) getGradient;

  _AnatomicalToothPainter({
    required this.tooth,
    required this.isUpperArch,
    required this.getGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final m = w * 0.32; // margen central

    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 1. CARA SUPERIOR (Vestibular / Lingual)
    final topSurface = isUpperArch ? FdiConstants.surfaceVestibular : FdiConstants.surfaceLingual;
    final topRect = Rect.fromLTRB(0, 0, w, m);
    final topPaint = Paint()..shader = getGradient(tooth.surfaces[topSurface]).createShader(topRect);
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - m, m)
      ..lineTo(m, m)
      ..close();
    canvas.drawPath(topPath, topPaint);
    canvas.drawPath(topPath, linePaint);

    // 2. CARA INFERIOR
    final bottomSurface = isUpperArch ? FdiConstants.surfaceLingual : FdiConstants.surfaceVestibular;
    final bottomRect = Rect.fromLTRB(0, h - m, w, h);
    final bottomPaint = Paint()..shader = getGradient(tooth.surfaces[bottomSurface]).createShader(bottomRect);
    final bottomPath = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w - m, h - m)
      ..lineTo(m, h - m)
      ..close();
    canvas.drawPath(bottomPath, bottomPaint);
    canvas.drawPath(bottomPath, linePaint);

    // 3. CARA IZQUIERDA (Mesial)
    final leftRect = Rect.fromLTRB(0, 0, m, h);
    final leftPaint = Paint()..shader = getGradient(tooth.surfaces[FdiConstants.surfaceMesial]).createShader(leftRect);
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h)
      ..lineTo(m, h - m)
      ..lineTo(m, m)
      ..close();
    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(leftPath, linePaint);

    // 4. CARA DERECHA (Distal)
    final rightRect = Rect.fromLTRB(w - m, 0, w, h);
    final rightPaint = Paint()..shader = getGradient(tooth.surfaces[FdiConstants.surfaceDistal]).createShader(rightRect);
    final rightPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w - m, h - m)
      ..lineTo(w - m, m)
      ..close();
    canvas.drawPath(rightPath, rightPaint);
    canvas.drawPath(rightPath, linePaint);

    // 5. CENTRO (Oclusal / Incisal)
    final centerRect = Rect.fromLTRB(m, m, w - m, h - m);
    final centerPaint = Paint()..shader = getGradient(tooth.surfaces[FdiConstants.surfaceOcclusal]).createShader(centerRect);
    canvas.drawRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(3)), centerPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(3)), linePaint);

    // Borde exterior suave del diente
    final outerBorder = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(10)), outerBorder);

    // CONDICIONES GENERALES
    if (tooth.isMissing) {
      // Cruz moderna semi-translúcida con acabado nítido
      final crossPaint = Paint()
        ..color = const Color(0xFFE63946)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.0;
      canvas.drawLine(const Offset(4, 4), Offset(w - 4, h - 4), crossPaint);
      canvas.drawLine(Offset(4, h - 4), Offset(w - 4, 4), crossPaint);
    } else if (tooth.hasCrown) {
      // Corona dorada elegante
      final crownPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), const Radius.circular(8)), crownPaint);
    } else if (tooth.hasEndodontic) {
      // Conducto radicular endodóntico
      final endoPaint = Paint()
        ..color = const Color(0xFF0077B6)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.0;
      canvas.drawLine(Offset(w / 2, 2), Offset(w / 2, h - 2), endoPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnatomicalToothPainter oldDelegate) {
    return oldDelegate.tooth != tooth;
  }
}
