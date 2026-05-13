import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/patient.dart';

final patientsProvider = FutureProvider<List<Patient>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('patients')
      .select()
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => Patient.fromJson(json as Map<String, dynamic>))
      .toList();
});

// ---------------------------------------------------------------------------
// Patient Notifier (Riverpod 3.x compatible)
// ---------------------------------------------------------------------------

class PatientNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addPatient({
    required String firstName,
    required String lastName,
    required String phone,
    String? gender,
    String? birthDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final profile = await ref.read(userProfileProvider.future);

      await supabase.from('patients').insert({
        'clinic_id': profile?.clinicId,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'gender': gender,
        'birth_date': birthDate,
      });

      ref.invalidate(patientsProvider);
    });
  }

  Future<void> deletePatient(String patientId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('patients').delete().eq('id', patientId);
      ref.invalidate(patientsProvider);
    });
  }
}

final patientControllerProvider =
    AsyncNotifierProvider<PatientNotifier, void>(PatientNotifier.new);
