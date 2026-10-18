import 'package:flutter/material.dart';
import '../../../../core/constants/fdi_constants.dart';
import '../../domain/models/tooth.dart';
import '../widgets/tooth_widget.dart';
import '../widgets/treatment_palette.dart';

class OdontogramScreen extends StatefulWidget {
  const OdontogramScreen({super.key});

  @override
  State<OdontogramScreen> createState() => _OdontogramScreenState();
}

class _OdontogramScreenState extends State<OdontogramScreen> {
  bool _isAdultDentition = true;
  ToothCondition _activeCondition = ToothCondition.cavity;
  final Map<int, Tooth> _teeth = {};

  @override
  void initState() {
    super.initState();
    _initializeTeeth();
  }

  void _initializeTeeth() {
    for (final fdiNum in [
      ...FdiConstants.adultQuadrant1,
      ...FdiConstants.adultQuadrant2,
      ...FdiConstants.adultQuadrant4,
      ...FdiConstants.adultQuadrant3,
    ]) {
      _teeth[fdiNum] = Tooth(fdiNumber: fdiNum, isDeciduous: false);
    }

    for (final fdiNum in [
      ...FdiConstants.childQuadrant5,
      ...FdiConstants.childQuadrant6,
      ...FdiConstants.childQuadrant8,
      ...FdiConstants.childQuadrant7,
    ]) {
      _teeth[fdiNum] = Tooth(fdiNumber: fdiNum, isDeciduous: true);
    }
  }

  void _onSurfaceTapped(int fdiNumber, String surface) {
    setState(() {
      final currentTooth = _teeth[fdiNumber]!;
      final updatedSurfaces = Map<String, ToothCondition>.from(currentTooth.surfaces);

      if (_activeCondition == ToothCondition.healthy) {
        updatedSurfaces.remove(surface);
      } else if (_activeCondition == ToothCondition.missing ||
          _activeCondition == ToothCondition.crown ||
          _activeCondition == ToothCondition.endodontic) {
        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: _activeCondition);
        return;
      } else {
        updatedSurfaces[surface] = _activeCondition;
      }

      _teeth[fdiNumber] = currentTooth.copyWith(
        surfaces: updatedSurfaces,
        generalCondition: ToothCondition.healthy,
      );
    });
  }

  void _onToothTapped(int fdiNumber) {
    final currentTooth = _teeth[fdiNumber]!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A896), Color(0xFF028090)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Pieza FDI #$fdiNumber',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Procedimiento Clínico para toda la Pieza:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildActionPill(
                    label: 'Extracción / Ausente',
                    icon: Icons.close_rounded,
                    color: const Color(0xFFE63946),
                    onTap: () {
                      setState(() {
                        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: ToothCondition.missing);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  _buildActionPill(
                    label: 'Corona Protésica',
                    icon: Icons.shield_rounded,
                    color: const Color(0xFFD4AF37),
                    onTap: () {
                      setState(() {
                        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: ToothCondition.crown);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  _buildActionPill(
                    label: 'Endodoncia Radicular',
                    icon: Icons.timeline_rounded,
                    color: const Color(0xFF4F46E5),
                    onTap: () {
                      setState(() {
                        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: ToothCondition.endodontic);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  _buildActionPill(
                    label: 'Restablecer Pieza Sana',
                    icon: Icons.auto_fix_high_rounded,
                    color: const Color(0xFF64748B),
                    onTap: () {
                      setState(() {
                        _teeth[fdiNumber] = Tooth(fdiNumber: fdiNumber, isDeciduous: currentTooth.isDeciduous);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionPill({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  List<Tooth> get _affectedTeeth => _teeth.values.where((t) => t.hasAnyCondition).toList();

  int get _cariesCount {
    int count = 0;
    for (final t in _affectedTeeth) {
      count += t.surfaces.values.where((c) => c == ToothCondition.cavity).length;
    }
    return count;
  }

  int get _restoredCount {
    int count = 0;
    for (final t in _affectedTeeth) {
      count += t.surfaces.values.where((c) => c == ToothCondition.restored).length;
    }
    return count;
  }

  double get _estimatedBudget {
    double total = 0;
    for (final t in _affectedTeeth) {
      if (t.hasCrown) total += 280.0;
      if (t.hasEndodontic) total += 150.0;
      if (t.isMissing) total += 45.0;
      for (final s in t.surfaces.values) {
        if (s == ToothCondition.cavity || s == ToothCondition.planned) {
          total += 55.0; // Obturación en resina compuesta
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odontograma Clínico Inteligente', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Nomenclatura Internacional FDI ISO 3950', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Reiniciar',
            onPressed: () {
              setState(() => _initializeTeeth());
            },
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00A896),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Guardar'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: const Color(0xFF0F172A),
                  content: Text('Odontograma guardado: ${_affectedTeeth.length} piezas registradas.'),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tarjeta Paciente & Alerta Médica Stitch
                _buildPatientCard(),

                const SizedBox(height: 12),

                // 2. Métricas Rápidas & Selector Dentición
                _buildMetricsAndControls(),

                const SizedBox(height: 14),

                // 3. Lienzo Arcada Maxilar Superior
                _buildArchContainer(
                  title: 'MAXILAR SUPERIOR',
                  subTitle: 'Arcada Superior (Cuadrantes 1 y 2)',
                  isUpper: true,
                ),

                const SizedBox(height: 12),

                // 4. Lienzo Arcada Mandibular Inferior
                _buildArchContainer(
                  title: 'MANDÍBULA',
                  subTitle: 'Arcada Inferior (Cuadrantes 4 y 3)',
                  isUpper: false,
                ),

                const SizedBox(height: 16),

                // 5. Presupuesto & Hallazgos
                _buildClinicalFindingsCard(),
              ],
            ),
          ),

          // Paleta Flotante Glassmórfica en la parte inferior
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Center(
              child: TreatmentPalette(
                activeCondition: _activeCondition,
                onConditionSelected: (cond) => setState(() => _activeCondition = cond),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00A896), Color(0xFF028090)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'CR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Camila Ramos Vega',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '#HC-2049',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '28 años • Plan Dental Integral • Sillón 1',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // Badge de Alergia Crítica (Stitch Alert Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D6D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF4D6D).withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFE63946), size: 16),
                SizedBox(width: 5),
                Text(
                  'Alergia: Penicilina',
                  style: TextStyle(
                    color: Color(0xFFC9184A),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsAndControls() {
    return Row(
      children: [
        // Selector Segmentado de Dentición
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildSegmentPill(label: 'Adulto (32)', isSelected: _isAdultDentition, onTap: () => setState(() => _isAdultDentition = true)),
              _buildSegmentPill(label: 'Pediátrico (20)', isSelected: !_isAdultDentition, onTap: () => setState(() => _isAdultDentition = false)),
            ],
          ),
        ),
        const Spacer(),
        // Resumen de Caries y Presupuesto
        _buildStatChip(
          label: '$_cariesCount Caries',
          color: const Color(0xFFFF4D6D),
          icon: Icons.lens,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          label: '$_restoredCount Sanas',
          color: const Color(0xFF00B4D8),
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          label: '\$${_estimatedBudget.toStringAsFixed(0)} Est.',
          color: const Color(0xFF10B981),
          icon: Icons.monetization_on_rounded,
        ),
      ],
    );
  }

  Widget _buildSegmentPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({required String label, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildArchContainer({
    required String title,
    required String subTitle,
    required bool isUpper,
  }) {
    final quadA = _isAdultDentition
        ? (isUpper ? FdiConstants.adultQuadrant1 : FdiConstants.adultQuadrant4)
        : (isUpper ? FdiConstants.childQuadrant5 : FdiConstants.childQuadrant8);
    final quadB = _isAdultDentition
        ? (isUpper ? FdiConstants.adultQuadrant2 : FdiConstants.adultQuadrant3)
        : (isUpper ? FdiConstants.childQuadrant6 : FdiConstants.childQuadrant7);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 6),
              Text(
                '• $subTitle',
                style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cuadrante Derecho
                ...quadA.map((fdiNum) => ToothWidget(
                      tooth: _teeth[fdiNum]!,
                      isUpperArch: isUpper,
                      onSurfaceTap: (surf) => _onSurfaceTapped(fdiNum, surf),
                      onToothTap: () => _onToothTapped(fdiNum),
                    )),

                // Línea Media Dental (Stitch Glowing Midline)
                Container(
                  width: 3,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF02C39A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Cuadrante Izquierdo
                ...quadB.map((fdiNum) => ToothWidget(
                      tooth: _teeth[fdiNum]!,
                      isUpperArch: isUpper,
                      onSurfaceTap: (surf) => _onSurfaceTapped(fdiNum, surf),
                      onToothTap: () => _onToothTapped(fdiNum),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalFindingsCard() {
    final affected = _affectedTeeth;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A896).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF00A896), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plan de Tratamiento & Presupuesto Dental', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('Costos y hallazgos computados automáticamente desde el Odontograma', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Text(
                '\$${_estimatedBudget.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF00A896)),
              ),
            ],
          ),
          const Divider(height: 24),
          if (affected.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Lienzo limpio. Selecciona un tratamiento de la barra flotante y toca cualquier cara dental para comenzar.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: affected.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A896),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${t.fdiNumber}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.generalCondition != ToothCondition.healthy
                            ? t.generalCondition.name.toUpperCase()
                            : 'Caras: ${t.surfaces.keys.join(", ")}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
