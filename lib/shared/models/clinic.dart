class Clinic {
  final String id;
  final String name;
  final String specialtyType;
  final String workHourStart;
  final String workHourEnd;
  final String subscriptionStatus;
  final DateTime? trialEndsAt;
  final bool isSetupCompleted;

  Clinic({
    required this.id,
    required this.name,
    required this.specialtyType,
    required this.workHourStart,
    required this.workHourEnd,
    required this.subscriptionStatus,
    this.trialEndsAt,
    this.isSetupCompleted = false,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      specialtyType: json['specialty_type'] as String,
      workHourStart: json['work_hour_start'] as String,
      workHourEnd: json['work_hour_end'] as String,
      subscriptionStatus: json['subscription_status'] as String? ?? 'trial',
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.parse(json['trial_ends_at'] as String) : null,
      isSetupCompleted: (json['is_setup_completed'] as bool?) ?? false,
    );
  }
}
