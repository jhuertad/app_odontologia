import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/appointments_repository.dart';
import '../../domain/models/appointment.dart';
import '../../../patients/data/patients_repository.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _repository = AppointmentsRepository();
  DateTime _selectedDate = DateTime.now();
  AppointmentStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final allForDate = _repository.getAppointmentsForDate(_selectedDate);
    final appointments = _filterStatus == null
        ? allForDate
        : allForDate.where((a) => a.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agenda Clínica & Turnos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Gestión de citas por sillón dental', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selector de fecha
          _buildDateSelector(),

          // Filtros de estado
          _buildStatusFilters(allForDate.length),

          // Lista de citas
          Expanded(
            child: appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available_rounded, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No hay citas para esta fecha con el filtro seleccionado.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(appointments[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00A896),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Nueva Cita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showNewAppointmentDialog,
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
            },
          ),
          Expanded(
            child: Text(
              dateFormat.format(_selectedDate),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
            },
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Hoy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
            onPressed: () {
              setState(() => _selectedDate = DateTime.now());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todas ($totalCount)', null),
            _buildFilterChip('En Tratamiento', AppointmentStatus.inTreatment),
            _buildFilterChip('En Espera', AppointmentStatus.inWaitingRoom),
            _buildFilterChip('Confirmadas', AppointmentStatus.confirmed),
            _buildFilterChip('Finalizadas', AppointmentStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AppointmentStatus? status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterStatus = status),
        selectedColor: const Color(0xFF00A896).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF00A896) : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment apt) {
    final timeFormat = DateFormat('hh:mm a');
    final timeStr = '${timeFormat.format(apt.startTime)} - ${timeFormat.format(apt.endTime)}';

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF0F172A)),
                    const SizedBox(width: 5),
                    Text(
                      timeStr,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A896).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'SILLÓN ${apt.chairNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF00A896)),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(apt),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            apt.patientName,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            apt.reason,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          const Divider(height: 20),
          Row(
            children: [
              if (apt.whatsappReminderSent)
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text('WhatsApp Enviado', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Color(0xFFF59E0B), size: 14),
                    SizedBox(width: 4),
                    Text('Recordatorio Pendiente', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                  ],
                ),
              const Spacer(),
              // Menú para cambiar estado
              PopupMenuButton<AppointmentStatus>(
                onSelected: (newStatus) {
                  setState(() {
                    _repository.updateAppointmentStatus(apt.id, newStatus);
                  });
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: AppointmentStatus.inWaitingRoom,
                    child: Text('Pasar a Sala de Espera'),
                  ),
                  const PopupMenuItem(
                    value: AppointmentStatus.inTreatment,
                    child: Text('Iniciar Atención (En Sillón)'),
                  ),
                  const PopupMenuItem(
                    value: AppointmentStatus.completed,
                    child: Text('Finalizar Consulta'),
                  ),
                  const PopupMenuItem(
                    value: AppointmentStatus.cancelled,
                    child: Text('Cancelar Cita'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Text('Cambiar Estado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Appointment apt) {
    Color bg;
    Color fg;
    String text;

    switch (apt.status) {
      case AppointmentStatus.inTreatment:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF059669);
        text = 'EN ATENCIÓN';
        break;
      case AppointmentStatus.inWaitingRoom:
        bg = const Color(0xFF028090).withValues(alpha: 0.15);
        fg = const Color(0xFF028090);
        text = 'EN ESPERA';
        break;
      case AppointmentStatus.confirmed:
        bg = const Color(0xFF3B82F6).withValues(alpha: 0.15);
        fg = const Color(0xFF1D4ED8);
        text = 'CONFIRMADA';
        break;
      case AppointmentStatus.completed:
        bg = const Color(0xFF64748B).withValues(alpha: 0.15);
        fg = const Color(0xFF475569);
        text = 'FINALIZADA';
        break;
      case AppointmentStatus.cancelled:
        bg = const Color(0xFFE63946).withValues(alpha: 0.15);
        fg = const Color(0xFFC9184A);
        text = 'CANCELADA';
        break;
      default:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFD97706);
        text = 'PROGRAMADA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 10)),
    );
  }

  void _showNewAppointmentDialog() {
    final patients = PatientsRepository().getAllPatients();
    String selectedPatientId = patients.first.id;
    final reasonCtrl = TextEditingController();
    int chair = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Programar Nueva Cita', style: TextStyle(fontWeight: FontWeight.w800)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedPatientId,
                    decoration: const InputDecoration(labelText: 'Paciente'),
                    items: patients.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.fullName));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedPatientId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Motivo / Procedimiento',
                      hintText: 'Ej. Consulta general, profilaxis...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: chair,
                    decoration: const InputDecoration(labelText: 'Sillón Dental'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Sillón 1 (Principal)')),
                      DropdownMenuItem(value: 2, child: Text('Sillón 2 (Secundario)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => chair = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
                onPressed: () {
                  if (reasonCtrl.text.trim().isEmpty) return;
                  final patient = patients.firstWhere((p) => p.id == selectedPatientId);
                  final now = DateTime.now();
                  final newApt = Appointment(
                    id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
                    patientId: patient.id,
                    patientName: patient.fullName,
                    doctorId: 'd-1',
                    startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour + 1, 0),
                    endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour + 1, 45),
                    reason: reasonCtrl.text.trim(),
                    chairNumber: chair,
                    status: AppointmentStatus.scheduled,
                    whatsappReminderSent: false,
                  );
                  _repository.addAppointment(newApt);
                  setState(() {});
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar Cita'),
              ),
            ],
          );
        },
      ),
    );
  }
}
