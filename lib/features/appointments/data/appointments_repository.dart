import 'package:flutter/foundation.dart';
import '../domain/models/appointment.dart';

class AppointmentsRepository extends ChangeNotifier {
  static final AppointmentsRepository _instance = AppointmentsRepository._internal();
  factory AppointmentsRepository() => _instance;
  AppointmentsRepository._internal() {
    _initSampleData();
  }

  final List<Appointment> _appointments = [];
  String? _lastActiveAppointmentId;

  void _initSampleData() {
    if (_appointments.isNotEmpty) return;
    final now = DateTime.now();

    _appointments.addAll([
      Appointment(
        id: 'apt-1',
        patientId: 'p-1',
        patientName: 'Camila Ramos Vega',
        doctorId: 'd-1',
        startTime: DateTime(now.year, now.month, now.day, 10, 30),
        endTime: DateTime(now.year, now.month, now.day, 11, 15),
        reason: 'Operatoria Dental (Obturaciones Resina Estética Piezas 16 y 21)',
        status: AppointmentStatus.inTreatment,
        chairNumber: 1,
        whatsappReminderSent: true,
      ),
      Appointment(
        id: 'apt-2',
        patientId: 'p-2',
        patientName: 'Marcos Delgado Solís',
        doctorId: 'd-1',
        startTime: DateTime(now.year, now.month, now.day, 11, 30),
        endTime: DateTime(now.year, now.month, now.day, 12, 30),
        reason: 'Endodoncia Molar 36 - 2da Sesión de Obturación',
        status: AppointmentStatus.inWaitingRoom,
        chairNumber: 2,
        whatsappReminderSent: true,
      ),
      Appointment(
        id: 'apt-3',
        patientId: 'p-3',
        patientName: 'Valentina Gómez Castro',
        doctorId: 'd-1',
        startTime: DateTime(now.year, now.month, now.day, 15, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 45),
        reason: 'Control Pediátrico & Sellantes de Fosas y Fisuras',
        status: AppointmentStatus.confirmed,
        chairNumber: 1,
        whatsappReminderSent: true,
      ),
      Appointment(
        id: 'apt-4',
        patientId: 'p-4',
        patientName: 'Rodrigo Pérez Méndez',
        doctorId: 'd-1',
        startTime: DateTime(now.year, now.month, now.day, 16, 30),
        endTime: DateTime(now.year, now.month, now.day, 17, 30),
        reason: 'Evaluación y Toma Tomográfica para Implante #24',
        status: AppointmentStatus.scheduled,
        chairNumber: 1,
        whatsappReminderSent: false,
      ),
      Appointment(
        id: 'apt-5',
        patientId: 'p-5',
        patientName: 'Lucía Benavides Rios',
        doctorId: 'd-1',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 45),
        reason: 'Profilaxis Dental Ultrasónica y Fluorización',
        status: AppointmentStatus.completed,
        chairNumber: 1,
        whatsappReminderSent: true,
      ),
    ]);
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((a) {
      return a.startTime.year == date.year &&
          a.startTime.month == date.month &&
          a.startTime.day == date.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void updateAppointmentStatus(String id, AppointmentStatus newStatus) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final targetApt = _appointments[idx];

      // Si el paciente entra en atención:
      if (newStatus == AppointmentStatus.inTreatment) {
        _lastActiveAppointmentId = id;
        // Un sillón solo puede tener 1 paciente simultáneo en atención.
        // Si había otro paciente en atención en ese mismo sillón, se marca como completado.
        for (int i = 0; i < _appointments.length; i++) {
          if (_appointments[i].id != id &&
              _appointments[i].chairNumber == targetApt.chairNumber &&
              _appointments[i].status == AppointmentStatus.inTreatment) {
            _appointments[i] = _appointments[i].copyWith(status: AppointmentStatus.completed);
          }
        }
      }

      _appointments[idx] = targetApt.copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  Appointment? getActiveAppointment({int? preferredChair}) {
    final todayAppointments = getAppointmentsForDate(DateTime.now());
    if (todayAppointments.isEmpty) return null;

    // Si se especificó un sillón preferido:
    if (preferredChair != null) {
      final chairApts = todayAppointments.where((a) => a.chairNumber == preferredChair).toList();
      final inChair = chairApts.where((a) => a.status == AppointmentStatus.inTreatment).firstOrNull;
      if (inChair != null) return inChair;
      final waitingChair = chairApts.where((a) => a.status == AppointmentStatus.inWaitingRoom).firstOrNull;
      if (waitingChair != null) return waitingChair;
      if (chairApts.isNotEmpty) return chairApts.first;
    }

    // 1. Si hay una cita activada explícitamente y sigue en atención:
    if (_lastActiveAppointmentId != null) {
      final match = todayAppointments.where((a) => a.id == _lastActiveAppointmentId).firstOrNull;
      if (match != null && match.status == AppointmentStatus.inTreatment) {
        return match;
      }
    }

    // 2. Cualquier cita en atención:
    final inTreatment = todayAppointments.where((a) => a.status == AppointmentStatus.inTreatment).toList();
    if (inTreatment.isNotEmpty) return inTreatment.first;

    // 3. Cualquier cita en sala de espera:
    final inWaiting = todayAppointments.where((a) => a.status == AppointmentStatus.inWaitingRoom).toList();
    if (inWaiting.isNotEmpty) return inWaiting.first;

    // 4. Próximas confirmadas o agendadas:
    final upcoming = todayAppointments.where((a) => a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.scheduled).toList();
    if (upcoming.isNotEmpty) return upcoming.first;

    return todayAppointments.first;
  }

  Appointment? getAppointmentForChair(int chairNumber) {
    final todayAppointments = getAppointmentsForDate(DateTime.now());
    final chairApts = todayAppointments.where((a) => a.chairNumber == chairNumber).toList();
    final inTreatment = chairApts.where((a) => a.status == AppointmentStatus.inTreatment).firstOrNull;
    if (inTreatment != null) return inTreatment;
    final inWaiting = chairApts.where((a) => a.status == AppointmentStatus.inWaitingRoom).firstOrNull;
    if (inWaiting != null) return inWaiting;
    return chairApts.firstOrNull;
  }
}

