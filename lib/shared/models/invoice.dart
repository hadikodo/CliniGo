class Invoice {
  final String id;
  final String? clinicId;
  final String? patientId;
  final double amount;
  final String status; // 'pending' | 'paid' | 'cancelled'
  final String? createdAt;

  // Populated via join
  final String? patientFirstName;
  final String? patientLastName;

  Invoice({
    required this.id,
    this.clinicId,
    this.patientId,
    required this.amount,
    required this.status,
    this.createdAt,
    this.patientFirstName,
    this.patientLastName,
  });

  String get patientName =>
      '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim().isEmpty
          ? 'Unknown Patient'
          : '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim();

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final patient = json['patients'] as Map<String, dynamic>?;
    return Invoice(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String?,
      patientId: json['patient_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
      patientFirstName: patient?['first_name'] as String?,
      patientLastName: patient?['last_name'] as String?,
    );
  }
}
