import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/models/tooth.dart';

class TreatmentPalette extends StatelessWidget {
  final ToothCondition activeCondition;
  final ValueChanged<ToothCondition> onConditionSelected;

  const TreatmentPalette({
    super.key,
    required this.activeCondition,
    required this.onConditionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToolPill(
                  condition: ToothCondition.cavity,
                  label: 'Caries',
                  gradient: const [Color(0xFFFF4D6D), Color(0xFFC9184A)],
                  icon: Icons.lens,
                ),
                _buildToolPill(
                  condition: ToothCondition.restored,
                  label: 'Restaurado',
                  gradient: const [Color(0xFF00B4D8), Color(0xFF0077B6)],
                  icon: Icons.check_circle_rounded,
                ),
                _buildToolPill(
                  condition: ToothCondition.planned,
                  label: 'Planificado',
                  gradient: const [Color(0xFFFFB703), Color(0xFFFB8500)],
                  icon: Icons.schedule_rounded,
                ),
                _buildToolPill(
                  condition: ToothCondition.executedToday,
                  label: 'Ejecutado Hoy',
                  gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                  icon: Icons.task_alt_rounded,
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(0xFFE2E8F0),
                ),
                _buildToolPill(
                  condition: ToothCondition.missing,
                  label: 'Ausente',
                  gradient: const [Color(0xFF475569), Color(0xFF1E293B)],
                  icon: Icons.close_rounded,
                ),
                _buildToolPill(
                  condition: ToothCondition.crown,
                  label: 'Corona',
                  gradient: const [Color(0xFFFFD700), Color(0xFFFFA500)],
                  icon: Icons.shield_rounded,
                ),
                _buildToolPill(
                  condition: ToothCondition.endodontic,
                  label: 'Endodoncia',
                  gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  icon: Icons.timeline_rounded,
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(0xFFE2E8F0),
                ),
                _buildToolPill(
                  condition: ToothCondition.healthy,
                  label: 'Borrador',
                  gradient: const [Color(0xFF94A3B8), Color(0xFF64748B)],
                  icon: Icons.auto_fix_high_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolPill({
    required ToothCondition condition,
    required String label,
    required List<Color> gradient,
    required IconData icon,
  }) {
    final isSelected = activeCondition == condition;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => onConditionSelected(condition),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : gradient.first,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
