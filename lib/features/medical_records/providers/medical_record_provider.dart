import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/medical_record.dart';

// Per-patient medical records
final medicalRecordsProvider =
    FutureProvider.family<List<MedicalRecord>, String>((ref, patientId) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('medical_records')
      .select()
      .eq('patient_id', patientId)
      .order('created_at', ascending: false);

  return (response as List)
      .map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
      .toList();
});

class MedicalRecordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveRecord({
    required String patientId,
    required Map<String, dynamic> clinicalData,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final profile = await ref.read(userProfileProvider.future);

      await supabase.from('medical_records').insert({
        'clinic_id': profile?.clinicId,
        'patient_id': patientId,
        'clinical_data': clinicalData,
        'created_by': profile?.id,
      });

      ref.invalidate(medicalRecordsProvider(patientId));
    });
  }
}

final medicalRecordControllerProvider =
    AsyncNotifierProvider<MedicalRecordNotifier, void>(
        MedicalRecordNotifier.new);
