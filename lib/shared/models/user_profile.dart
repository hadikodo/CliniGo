class UserProfile {
  final String id;
  final String? clinicId;
  final String role;
  final String? fullName;

  UserProfile({
    required this.id,
    this.clinicId,
    required this.role,
    this.fullName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String?,
      role: json['role'] as String,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'role': role,
      'full_name': fullName,
    };
  }
}
