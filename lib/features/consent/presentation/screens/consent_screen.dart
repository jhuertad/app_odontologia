import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../data/consent_repository.dart';
import '../../domain/models/consent.dart';
import '../../../patients/data/patients_repository.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final _consentRepo = ConsentRepository();
  final _patients = PatientsRepository().getAllPatients();

  late String _selectedPatientId;
  late ConsentTemplate _selectedTemplate;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF0F172A),
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _selectedPatientId = _patients.first.id;
    _selectedTemplate = _consentRepo.getTemplates().first;
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = _consentRepo.getTemplates();
    final patient = _patients.firstWhere((p) => p.id == _selectedPatientId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consentimiento Informado Digital', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Firma biométrica táctil y sellado legal', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector de Paciente y Procedimiento
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPatientId,
                    decoration: const InputDecoration(labelText: 'Paciente a Consentir'),
                    items: _patients.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text('${p.fullName} (DNI ${p.documentId})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPatientId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ConsentTemplate>(
                    initialValue: _selectedTemplate,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Procedimiento Quirúrgico / Clínico'),
                    items: templates.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.procedureName, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTemplate = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Términos, Riesgos y Beneficios del Procedimiento
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTemplate.procedureName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedTemplate.description,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                  const Divider(height: 24),
                  const Text('Riesgos y Molestias Informadas:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFE63946))),
                  const SizedBox(height: 6),
                  ..._selectedTemplate.risks.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFFE63946), fontWeight: FontWeight.bold)),
                            Expanded(child: Text(r, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 10),
                  const Text('Beneficios Esperados:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF00A896))),
                  const SizedBox(height: 6),
                  ..._selectedTemplate.benefits.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF00A896), fontWeight: FontWeight.bold)),
                            Expanded(child: Text(b, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Lienzo de Firma Táctil
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.draw_rounded, color: Color(0xFF00A896), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Firma del Paciente: ${patient.fullName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFE63946)),
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        label: const Text('Limpiar Trazo'),
                        onPressed: () => _signatureController.clear(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Signature(
                        controller: _signatureController,
                        height: 180,
                        backgroundColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Firme dentro del recuadro usando su dedo o lápiz táctil',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00A896),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.lock_rounded, size: 18),
                      label: const Text('Sellar y Registrar Consentimiento Legal', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (_signatureController.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, solicite al paciente que firme en el recuadro.')),
                          );
                          return;
                        }

                        final signatureBytes = await _signatureController.toPngBytes();
                        if (signatureBytes == null) return;

                        final signed = _consentRepo.signConsent(
                          patientId: patient.id,
                          patientName: patient.fullName,
                          procedureName: _selectedTemplate.procedureName,
                          doctorName: 'Dr. John Huerta',
                          signatureBytes: signatureBytes,
                        );

                        if (!context.mounted) return;
                        _showSignatureSuccessDialog(signed);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignatureSuccessDialog(SignedConsent signed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text('Consentimiento Sellado', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paciente: ${signed.patientName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Procedimiento: ${signed.procedureName}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            Text('Fecha: ${signed.signedAt.toString().substring(0, 19)} UTC', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const Divider(height: 20),
            const Text('Hash Criptográfico SHA-256 (Inmutable):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                signed.hashSha256,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
            onPressed: () {
              Navigator.pop(ctx);
              _signatureController.clear();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
