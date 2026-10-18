import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fdi_constants.dart';
import '../../domain/models/tooth.dart';

class ToothWidget extends StatelessWidget {
  final Tooth tooth;
  final bool isUpperArch; // Maxilar superior vs Mandíbula inferior
  final Function(String surface) onSurfaceTap;
  final VoidCallback onToothTap;

  const ToothWidget({
    super.key,
    required this.tooth,
    required this.isUpperArch,
    required this.onSurfaceTap,
    required this.onToothTap,
  });

  Color _getColorForCondition(ToothCondition? condition) {
    switch (condition) {
      case ToothCondition.cavity:
        return AppColors.toothCavity;
      case ToothCondition.restored:
        return AppColors.toothRestored;
      case ToothCondition.planned:
        return AppColors.toothPlanned;
      case ToothCondition.executedToday:
        return AppColors.toothExecutedToday;
      default:
        return AppColors.toothHealthy;
    }
  }

  String _getSurfaceFromCoordinates(Offset localPosition, double size) {
    final x = localPosition.dx;
    final y = localPosition.dy;
    final margin = size * 0.3;

    // Centro (Oclusal / Incisal)
    if (x >= margin && x <= (size - margin) && y >= margin && y <= (size - margin)) {
      return FdiConstants.surfaceOcclusal;
    }

    // Top
    if (y < x && y < (size - x)) {
      return isUpperArch ? FdiConstants.surfaceVestibular : FdiConstants.surfaceLingual;
    }
    // Bottom
    if (y > x && y > (size - x)) {
      return isUpperArch ? FdiConstants.surfaceLingual : FdiConstants.surfaceVestibular;
    }
    // Left
    if (x < y && x < (size - y)) {
      return FdiConstants.surfaceMesial;
    }
    // Right
    return FdiConstants.surfaceDistal;
  }

  @override
  Widget build(BuildContext context) {
    const double toothSize = 42.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Número FDI superior (para maxilar)
          if (isUpperArch) _buildFdiBadge(),

          const SizedBox(height: 3),

          // Lienzo interactivo del diente
          GestureDetector(
            onTapUp: (details) {
              if (tooth.isMissing) {
                onToothTap();
                return;
              }
              final surface = _getSurfaceFromCoordinates(details.localPosition, toothSize);
              onSurfaceTap(surface);
            },
            onLongPress: onToothTap,
            child: SizedBox(
              width: toothSize,
              height: toothSize,
              child: CustomPaint(
                painter: _ToothPainter(
                  tooth: tooth,
                  isUpperArch: isUpperArch,
                  getColor: _getColorForCondition,
                ),
              ),
            ),
          ),

          const SizedBox(height: 3),

          // Número FDI inferior (para mandíbula)
          if (!isUpperArch) _buildFdiBadge(),
        ],
      ),
    );
  }

  Widget _buildFdiBadge() {
    final bool isHighlighted = tooth.hasAnyCondition;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${tooth.fdiNumber}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isHighlighted ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ToothPainter extends CustomPainter {
  final Tooth tooth;
  final bool isUpperArch;
  final Color Function(ToothCondition?) getColor;

  _ToothPainter({
    required this.tooth,
    required this.isUpperArch,
    required this.getColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.borderDark.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;
    final m = w * 0.3; // margen central

    // 1. CARA SUPERIOR
    final topSurface = isUpperArch ? FdiConstants.surfaceVestibular : FdiConstants.surfaceLingual;
    final topPaint = Paint()
      ..color = getColor(tooth.surfaces[topSurface])
      ..style = PaintingStyle.fill;
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - m, m)
      ..lineTo(m, m)
      ..close();
    canvas.drawPath(topPath, topPaint);
    canvas.drawPath(topPath, strokePaint);

    // 2. CARA INFERIOR
    final bottomSurface = isUpperArch ? FdiConstants.surfaceLingual : FdiConstants.surfaceVestibular;
    final bottomPaint = Paint()
      ..color = getColor(tooth.surfaces[bottomSurface])
      ..style = PaintingStyle.fill;
    final bottomPath = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w - m, h - m)
      ..lineTo(m, h - m)
      ..close();
    canvas.drawPath(bottomPath, bottomPaint);
    canvas.drawPath(bottomPath, strokePaint);

    // 3. CARA IZQUIERDA (Mesial)
    final leftPaint = Paint()
      ..color = getColor(tooth.surfaces[FdiConstants.surfaceMesial])
      ..style = PaintingStyle.fill;
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h)
      ..lineTo(m, h - m)
      ..lineTo(m, m)
      ..close();
    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(leftPath, strokePaint);

    // 4. CARA DERECHA (Distal)
    final rightPaint = Paint()
      ..color = getColor(tooth.surfaces[FdiConstants.surfaceDistal])
      ..style = PaintingStyle.fill;
    final rightPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w - m, h - m)
      ..lineTo(w - m, m)
      ..close();
    canvas.drawPath(rightPath, rightPaint);
    canvas.drawPath(rightPath, strokePaint);

    // 5. CENTRO (Oclusal / Incisal)
    final centerPaint = Paint()
      ..color = getColor(tooth.surfaces[FdiConstants.surfaceOcclusal])
      ..style = PaintingStyle.fill;
    final centerRect = Rect.fromLTRB(m, m, w - m, h - m);
    canvas.drawRect(centerRect, centerPaint);
    canvas.drawRect(centerRect, strokePaint);

    // DIBUJO DE ESTADOS GENERALES (Corona, Ausente, Endodoncia, Implante)
    if (tooth.isMissing) {
      // Cruz roja de extracción / ausente
      final crossPaint = Paint()
        ..color = AppColors.toothCavity
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset.zero, Offset(w, h), crossPaint);
      canvas.drawLine(Offset(0, h), Offset(w, 0), crossPaint);
    } else if (tooth.hasCrown) {
      // Corona dental (círculo dorado envolvente)
      final crownPaint = Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.46, crownPaint);
    } else if (tooth.hasEndodontic) {
      // Línea central de conducto radicular
      final endoPaint = Paint()
        ..color = AppColors.toothRestored
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), endoPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ToothPainter oldDelegate) {
    return oldDelegate.tooth != tooth;
  }
}
