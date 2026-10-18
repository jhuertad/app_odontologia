import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(
              condition: ToothCondition.cavity,
              label: 'Caries',
              color: AppColors.toothCavity,
              icon: Icons.lens,
            ),
            _buildItem(
              condition: ToothCondition.restored,
              label: 'Restaurado',
              color: AppColors.toothRestored,
              icon: Icons.lens,
            ),
            _buildItem(
              condition: ToothCondition.planned,
              label: 'Planificado',
              color: AppColors.toothPlanned,
              icon: Icons.lens,
            ),
            _buildItem(
              condition: ToothCondition.executedToday,
              label: 'Hoy',
              color: AppColors.toothExecutedToday,
              icon: Icons.lens,
            ),
            const VerticalDivider(width: 16),
            _buildItem(
              condition: ToothCondition.missing,
              label: 'Ausente',
              color: Colors.black87,
              icon: Icons.close_rounded,
            ),
            _buildItem(
              condition: ToothCondition.crown,
              label: 'Corona',
              color: const Color(0xFFD4AF37),
              icon: Icons.circle_outlined,
            ),
            _buildItem(
              condition: ToothCondition.endodontic,
              label: 'Endodoncia',
              color: AppColors.toothRestored,
              icon: Icons.line_weight_rounded,
            ),
            const VerticalDivider(width: 16),
            _buildItem(
              condition: ToothCondition.healthy,
              label: 'Borrador',
              color: Colors.grey,
              icon: Icons.cleaning_services_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required ToothCondition condition,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = activeCondition == condition;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        avatar: Icon(icon, color: color, size: 16),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onConditionSelected(condition),
        selectedColor: color.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}
