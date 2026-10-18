import 'package:flutter/material.dart';
import '../../data/patients_repository.dart';
import '../../domain/models/patient.dart';
import '../../../odontogram/presentation/screens/odontogram_screen.dart';
import '../../../medical_history/presentation/screens/medical_history_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _repository = PatientsRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final patients = _repository.searchPatients(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Directorio de Pacientes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Fichas clínicas y antecedentes médicos', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, DNI o teléfono...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00A896)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Conteo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${patients.length} Pacientes registrados',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Lista de pacientes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final p = patients[index];
                return _buildPatientCard(p);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00A896),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Nuevo Paciente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showNewPatientDialog,
      ),
    );
  }

  Widget _buildPatientCard(Patient p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF00A896).withValues(alpha: 0.12),
                child: Text(
                  p.firstName.substring(0, 1) + p.lastName.substring(0, 1),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00A896), fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DNI: ${p.documentId} • ${p.age} años • Tel: ${p.phoneWhatsapp}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Badge de Alergias Críticas
          if (p.hasCriticalAllergies) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D6D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF4D6D).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE63946), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'ALERGIAS: ${p.criticalAllergies.join(", ")}',
                    style: const TextStyle(color: Color(0xFFC9184A), fontWeight: FontWeight.w800, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],

          if (p.activeTreatment != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tratamiento: ${p.activeTreatment!}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
            ),
          ],

          const Divider(height: 20),

          // Accesos directos a Odontograma e Historia
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFF00A896)),
                  ),
                  icon: const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF00A896)),
                  label: const Text('Odontograma', style: TextStyle(color: Color(0xFF00A896), fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OdontogramScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.assignment_rounded, size: 16),
                  label: const Text('Historia SOAP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MedicalHistoryScreen(patient: p)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewPatientDialog() {
    final nameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final dniCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final allergyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Registrar Nuevo Paciente', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombres', hintText: 'Ej. Juan'),
              ),
              TextField(
                controller: lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Apellidos', hintText: 'Ej. Pérez'),
              ),
              TextField(
                controller: dniCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Documento / DNI', hintText: '8 dígitos'),
              ),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp', hintText: '+51 900 000 000'),
              ),
              TextField(
                controller: allergyCtrl,
                decoration: const InputDecoration(labelText: 'Alergias (separadas por coma)', hintText: 'Penicilina, Látex'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || dniCtrl.text.trim().isEmpty) return;
              final allergies = allergyCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final newP = Patient(
                id: 'p-${DateTime.now().millisecondsSinceEpoch}',
                firstName: nameCtrl.text.trim(),
                lastName: lastNameCtrl.text.trim(),
                documentId: dniCtrl.text.trim(),
                phoneWhatsapp: phoneCtrl.text.trim(),
                birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                criticalAllergies: allergies,
              );
              _repository.addPatient(newP);
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}
