enum AppointmentStatus {
  scheduled,
  confirmed,
  inWaitingRoom,
  inTreatment,
  completed,
  cancelled,
  noShow,
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final AppointmentStatus status;
  final int chairNumber;
  final bool whatsappReminderSent;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.status = AppointmentStatus.scheduled,
    this.chairNumber = 1,
    this.whatsappReminderSent = false,
  });
}
