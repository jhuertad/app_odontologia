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
  final String doctorName;
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
    this.doctorName = 'Dr. John Huerta',
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.status = AppointmentStatus.scheduled,
    this.chairNumber = 1,
    this.whatsappReminderSent = false,
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    DateTime? startTime,
    DateTime? endTime,
    String? reason,
    AppointmentStatus? status,
    int? chairNumber,
    bool? whatsappReminderSent,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      chairNumber: chairNumber ?? this.chairNumber,
      whatsappReminderSent: whatsappReminderSent ?? this.whatsappReminderSent,
    );
  }
}
