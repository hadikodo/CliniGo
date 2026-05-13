enum AppointmentStatus {
  pending,
  running,
  finished,
  paymentPending,
  completed,
  cancelled,
  noShow,
  needsReschedule;

  static AppointmentStatus fromString(String? s) {
    switch (s) {
      case 'running':
        return AppointmentStatus.running;
      case 'finished':
        return AppointmentStatus.finished;
      case 'payment_pending':
        return AppointmentStatus.paymentPending;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'needs_reschedule':
        return AppointmentStatus.needsReschedule;
      default:
        return AppointmentStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case AppointmentStatus.running:
        return 'running';
      case AppointmentStatus.finished:
        return 'finished';
      case AppointmentStatus.paymentPending:
        return 'payment_pending';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.noShow:
        return 'no_show';
      case AppointmentStatus.needsReschedule:
        return 'needs_reschedule';
      default:
        return 'pending';
    }
  }
}

class Appointment {
  final String id;
  final String? clinicId;
  final String? patientId;
  final String? doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final AppointmentStatus status;
  final String? appointmentType;
  final double? billingAmount;
  final String? notes;

  // Populated via join — not stored in appointments table
  final String? patientFirstName;
  final String? patientLastName;
  final String? patientPhone;

  Appointment({
    required this.id,
    this.clinicId,
    this.patientId,
    this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.appointmentType = 'consultation',
    this.billingAmount = 0,
    this.notes,
    this.patientFirstName,
    this.patientLastName,
    this.patientPhone,
  });

  Duration get duration => Duration(minutes: durationMinutes);

  String get patientName =>
      '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim().isEmpty
          ? 'Unknown Patient'
          : '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim();

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final patient = json['patients'] as Map<String, dynamic>?;
    return Appointment(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String?,
      patientId: json['patient_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      durationMinutes: (json['duration_minutes'] as int?) ?? 30,
      status: AppointmentStatus.fromString(json['status'] as String?),
      appointmentType: json['appointment_type'] as String? ?? 'consultation',
      billingAmount: (json['billing_amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      patientFirstName: patient?['first_name'] as String?,
      patientLastName: patient?['last_name'] as String?,
      patientPhone: patient?['phone'] as String?,
    );
  }

  Appointment copyWith({
    String? id,
    String? clinicId,
    String? patientId,
    String? doctorId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    AppointmentStatus? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      patientFirstName: patientFirstName,
      patientLastName: patientLastName,
    );
  }
}
