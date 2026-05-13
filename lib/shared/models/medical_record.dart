class MedicalRecord {
  final String id;
  final String? clinicId;
  final String? patientId;
  final Map<String, dynamic> clinicalData;
  final String? createdBy;
  final String? createdAt;

  MedicalRecord({
    required this.id,
    this.clinicId,
    this.patientId,
    required this.clinicalData,
    this.createdBy,
    this.createdAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String?,
      patientId: json['patient_id'] as String?,
      clinicalData: (json['clinical_data'] as Map<String, dynamic>?) ?? {},
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'clinic_id': clinicId,
        'patient_id': patientId,
        'clinical_data': clinicalData,
        'created_by': createdBy,
      };
}
