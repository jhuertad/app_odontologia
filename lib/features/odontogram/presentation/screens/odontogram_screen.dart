import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    // Inicializar adultos (32 piezas)
    for (final fdiNum in [
      ...FdiConstants.adultQuadrant1,
      ...FdiConstants.adultQuadrant2,
      ...FdiConstants.adultQuadrant4,
      ...FdiConstants.adultQuadrant3,
    ]) {
      _teeth[fdiNum] = Tooth(fdiNumber: fdiNum, isDeciduous: false);
    }

    // Inicializar pediátricos (20 piezas)
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
        // Son condiciones generales de la pieza completa
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Pieza $fdiNumber',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Acción rápida para toda la pieza:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.close_rounded, color: AppColors.toothCavity, size: 18),
                    label: const Text('Marcar Ausente / Extraído'),
                    onPressed: () {
                      setState(() {
                        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: ToothCondition.missing);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.circle_outlined, color: Color(0xFFD4AF37), size: 18),
                    label: const Text('Corona Protésica'),
                    onPressed: () {
                      setState(() {
                        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: ToothCondition.crown);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.line_weight_rounded, color: AppColors.toothRestored, size: 18),
                    label: const Text('Tratamiento de Conducto (Endodoncia)'),
                    onPressed: () {
                      setState(() {
                        _teeth[fdiNumber] = currentTooth.copyWith(generalCondition: ToothCondition.endodontic);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 18),
                    label: const Text('Limpiar Pieza (Sana)'),
                    onPressed: () {
                      setState(() {
                        _teeth[fdiNumber] = Tooth(fdiNumber: fdiNumber, isDeciduous: currentTooth.isDeciduous);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetOdontogram() {
    setState(() {
      _initializeTeeth();
    });
  }

  List<Tooth> get _affectedTeeth => _teeth.values.where((t) => t.hasAnyCondition).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odontograma Digital FDI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reiniciar Odontograma',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Limpiar Odontograma?'),
                  content: const Text('Se restablecerán todas las piezas dentales a su estado sano.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.allergyAlert),
                      onPressed: () {
                        _resetOdontogram();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Limpiar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Guardar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryDark,
                  content: Text('Odontograma guardado con ${_affectedTeeth.length} hallazgos clínicos.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de Dentición: Adulto vs Pediátrico
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Adulto (32 piezas)'), icon: Icon(Icons.person_rounded)),
                    ButtonSegment(value: false, label: Text('Pediátrico (20 piezas)'), icon: Icon(Icons.child_care_rounded)),
                  ],
                  selected: {_isAdultDentition},
                  onSelectionChanged: (set) {
                    setState(() {
                      _isAdultDentition = set.first;
                    });
                  },
                ),
              ],
            ),
          ),

          // Lienzo Odontograma
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                children: [
                  _buildArchCard(isUpper: true),
                  const SizedBox(height: 12),
                  _buildArchCard(isUpper: false),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                ],
              ),
            ),
          ),

          // Paleta flotante de tratamientos
          Padding(
            padding: const EdgeInsets.all(12),
            child: TreatmentPalette(
              activeCondition: _activeCondition,
              onConditionSelected: (cond) {
                setState(() {
                  _activeCondition = cond;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchCard({required bool isUpper}) {
    final title = isUpper ? 'Maxilar Superior (Arcada Superior)' : 'Mandíbula (Arcada Inferior)';
    final quadA = _isAdultDentition
        ? (isUpper ? FdiConstants.adultQuadrant1 : FdiConstants.adultQuadrant4)
        : (isUpper ? FdiConstants.childQuadrant5 : FdiConstants.childQuadrant8);
    final quadB = _isAdultDentition
        ? (isUpper ? FdiConstants.adultQuadrant2 : FdiConstants.adultQuadrant3)
        : (isUpper ? FdiConstants.childQuadrant6 : FdiConstants.childQuadrant7);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
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

                  // Línea Media Dental Vertical
                  Container(
                    width: 2,
                    height: 55,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
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
      ),
    );
  }

  Widget _buildSummaryCard() {
    final affected = _affectedTeeth;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Hallazgos Clínicos (${affected.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(height: 20),
            if (affected.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No se han registrado patologías ni tratamientos. Toca las caras de cualquier pieza para comenzar.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: affected.map((t) {
                  return Chip(
                    backgroundColor: AppColors.backgroundLight,
                    avatar: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${t.fdiNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    label: Text(
                      t.generalCondition != ToothCondition.healthy
                          ? t.generalCondition.name.toUpperCase()
                          : 'Caras: ${t.surfaces.keys.join(", ")}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
