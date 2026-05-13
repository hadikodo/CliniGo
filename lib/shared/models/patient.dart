class Patient {
  final String id;
  final String? clinicId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? createdAt;

  Patient({
    required this.id,
    this.clinicId,
    this.firstName,
    this.lastName,
    this.phone,
    this.birthDate,
    this.gender,
    this.createdAt,
  });

  String get fullName =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim().isEmpty
          ? 'Unknown Patient'
          : '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
    };
  }
}
