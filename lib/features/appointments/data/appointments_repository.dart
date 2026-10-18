import '../domain/models/appointment.dart';

class AppointmentsRepository {
  static final AppointmentsRepository _instance = AppointmentsRepository._internal();
  factory AppointmentsRepository() => _instance;
  AppointmentsRepository._internal() {
    _initSampleData();
  }

  final List<Appointment> _appointments = [];

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
      _appointments[idx] = _appointments[idx].copyWith(status: newStatus);
    }
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }
}
