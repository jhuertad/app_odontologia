import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/medical_history_repository.dart';
import '../../domain/models/medical_history.dart';
import '../../../patients/domain/models/patient.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final Patient patient;

  const MedicalHistoryScreen({super.key, required this.patient});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _repository = MedicalHistoryRepository();

  @override
  Widget build(BuildContext context) {
    final notes = _repository.getNotesForPatient(widget.patient.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historia Clínica • ${widget.patient.fullName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('DNI: ${widget.patient.documentId} • ${widget.patient.age} años', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alerta Médica si aplica
            if (widget.patient.hasCriticalAllergies)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D6D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF4D6D).withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFE63946), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ALERTA CLÍNICA CRÍTICA',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFC9184A), fontSize: 12),
                          ),
                          Text(
                            'El paciente registra hipersensibilidad a: ${widget.patient.criticalAllergies.join(", ")}.',
                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Encabezado de notas
            Row(
              children: [
                const Icon(Icons.history_edu_rounded, color: Color(0xFF00A896), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notas de Evolución SOAP (${notes.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (notes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'No hay notas registradas para este paciente. Presiona el botón inferior para registrar la primera evolución.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
              )
            else
              ...notes.map((note) => _buildSOAPCard(note)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00A896),
        icon: const Icon(Icons.note_add_rounded, color: Colors.white),
        label: const Text('Nueva Nota SOAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showNewSOAPDialog,
      ),
    );
  }

  Widget _buildSOAPCard(SOAPNote note) {
    final dateFormat = DateFormat('dd/MM/yyyy • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A896).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  dateFormat.format(note.date),
                  style: const TextStyle(color: Color(0xFF00A896), fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
              const Spacer(),
              Text(
                note.doctorName,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSOAPRow('S (Subjetivo):', note.subjective, const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _buildSOAPRow('O (Objetivo):', note.objective, const Color(0xFF028090)),
          const SizedBox(height: 8),
          _buildSOAPRow('A (Análisis):', note.analysis, const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _buildSOAPRow('P (Plan):', note.plan, const Color(0xFF10B981)),

          if (note.procedureDone.isNotEmpty) ...[
            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Procedimiento Realizado: ${note.procedureDone}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSOAPRow(String label, String text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color)),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.35),
          ),
        ),
      ],
    );
  }

  void _showNewSOAPDialog() {
    final sCtrl = TextEditingController();
    final oCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    final procCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Registrar Nota SOAP', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'S - Subjetivo (Motivo / Síntomas)',
                  hintText: 'Ej. Dolor a la masticación en molar...',
                ),
              ),
              TextField(
                controller: oCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'O - Objetivo (Examen Clínico / Pruebas)',
                  hintText: 'Ej. Cavidad cariosa en cara oclusal...',
                ),
              ),
              TextField(
                controller: aCtrl,
                decoration: const InputDecoration(
                  labelText: 'A - Análisis (Diagnóstico)',
                  hintText: 'Ej. Caries dentinaria profunda...',
                ),
              ),
              TextField(
                controller: pCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'P - Plan de Tratamiento',
                  hintText: 'Ej. Obturación estética con resina...',
                ),
              ),
              TextField(
                controller: procCtrl,
                decoration: const InputDecoration(
                  labelText: 'Procedimiento Ejecutado Hoy',
                  hintText: 'Ej. Aislamiento y resina compuesta A2...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
            onPressed: () {
              if (sCtrl.text.isEmpty || aCtrl.text.isEmpty) return;
              final newNote = SOAPNote(
                id: 'n-${DateTime.now().millisecondsSinceEpoch}',
                patientId: widget.patient.id,
                doctorId: 'd-1',
                doctorName: 'Dr. John Huerta',
                date: DateTime.now(),
                subjective: sCtrl.text.trim(),
                objective: oCtrl.text.trim(),
                analysis: aCtrl.text.trim(),
                plan: pCtrl.text.trim(),
                procedureDone: procCtrl.text.trim(),
              );
              _repository.addNote(newNote);
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Guardar Nota'),
          ),
        ],
      ),
    );
  }
}
