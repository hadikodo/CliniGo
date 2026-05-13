import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

class Specialty {
  final String id;
  final String name;
  final List<Map<String, dynamic>> fields;
  final int durationMinutes;

  Specialty({
    required this.id,
    required this.name,
    required this.fields,
    required this.durationMinutes,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'] as String,
      name: json['name'] as String,
      fields: List<Map<String, dynamic>>.from(json['fields'] as List),
      durationMinutes: json['duration_minutes'] as int,
    );
  }
}

final specialtiesProvider = FutureProvider<List<Specialty>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase.from('specialties').select();
  return (response as List).map((e) => Specialty.fromJson(e)).toList();
});

final currentClinicSpecialtyProvider = FutureProvider<Specialty?>((ref) async {
  final profile = await ref.read(userProfileProvider.future);
  if (profile?.clinicId == null) return null;

  final supabase = ref.read(supabaseClientProvider);
  final clinicResponse = await supabase
      .from('clinics')
      .select('specialty_type')
      .eq('id', profile!.clinicId!)
      .single();

  final specialtyId = clinicResponse['specialty_type'] as String;
  
  final specialties = await ref.read(specialtiesProvider.future);
  return specialties.firstWhere((s) => s.id == specialtyId, orElse: () => specialties.first);
});
