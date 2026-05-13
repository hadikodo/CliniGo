class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? notes;

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'notes': notes,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        name: json['name'] as String,
        dosage: json['dosage'] as String,
        frequency: json['frequency'] as String,
        duration: json['duration'] as String,
        notes: json['notes'] as String?,
      );
}

class Prescription {
  final String id;
  final String clinicId;
  final String patientId;
  final String appointmentId;
  final List<Medicine> medicines;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.appointmentId,
    required this.medicines,
    required this.createdAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      patientId: json['patient_id'] as String,
      appointmentId: json['appointment_id'] as String,
      medicines: (json['medicines'] as List).map((e) => Medicine.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
