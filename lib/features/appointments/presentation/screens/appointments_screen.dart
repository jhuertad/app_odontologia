import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  bool _showFullCalendar = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
            Text('Navegación por días, meses, años y sillón dental', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          // Botón para alternar vista de calendario mensual completo
          IconButton.filledTonal(
            icon: Icon(_showFullCalendar ? Icons.calendar_view_day_rounded : Icons.calendar_month_rounded, size: 20),
            tooltip: _showFullCalendar ? 'Ocultar Calendario Mensual' : 'Ver Calendario Mensual',
            onPressed: () {
              setState(() => _showFullCalendar = !_showFullCalendar);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Selector rápido de Día, Mes y Año con salto directo
          _buildDateSelector(),

          // 2. Calendario Mensual Desplegable (TableCalendar)
          if (_showFullCalendar) _buildMonthCalendarView(),

          // 3. Filtros de estado
          _buildStatusFilters(allForDate.length),

          // 4. Lista de citas del día seleccionado
          Expanded(
            child: appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No hay citas programadas para el ${DateFormat('d MMMM yyyy').format(_selectedDate)}.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFF00A896)),
                          ),
                          icon: const Icon(Icons.add, color: Color(0xFF00A896), size: 18),
                          label: const Text('Programar Cita en esta fecha', style: TextStyle(color: Color(0xFF00A896), fontWeight: FontWeight.bold)),
                          onPressed: _showNewAppointmentDialog,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Mes anterior
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_left_rounded, size: 20),
                tooltip: 'Mes Anterior',
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
                  });
                },
              ),
              // Día anterior
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                tooltip: 'Día Anterior',
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
              ),

              // Píldora interactiva para abrir selector de Año / Mes / Día
              Expanded(
                child: InkWell(
                  onTap: _pickDateFromPicker,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 15, color: Color(0xFF00A896)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            dateFormat.format(_selectedDate),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              ),

              // Día siguiente
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                tooltip: 'Día Siguiente',
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
              ),
              // Mes siguiente
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_right_rounded, size: 20),
                tooltip: 'Mes Siguiente',
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
                  });
                },
              ),

              // Botón Hoy
              ActionChip(
                label: const Text('Hoy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                onPressed: () {
                  setState(() => _selectedDate = DateTime.now());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2035, 12, 31),
        focusedDay: _selectedDate,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: const Color(0xFF00A896).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          formatButtonTextStyle: const TextStyle(color: Color(0xFF00A896), fontSize: 11, fontWeight: FontWeight.bold),
          titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFF028090),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF00A896),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _pickDateFromPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
      initialDatePickerMode: DatePickerMode.day,
      helpText: 'SELECCIONAR FECHA DE LA AGENDA',
      cancelText: 'CANCELAR',
      confirmText: 'SELECCIONAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A896),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
