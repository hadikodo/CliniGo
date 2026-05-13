import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ClinicSummary {
  final String id;
  final String name;
  final String specialtyType;
  final String subscriptionStatus;
  final String? trialEndsAt;

  ClinicSummary({
    required this.id,
    required this.name,
    required this.specialtyType,
    required this.subscriptionStatus,
    this.trialEndsAt,
  });

  factory ClinicSummary.fromJson(Map<String, dynamic> json) {
    return ClinicSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      specialtyType: json['specialty_type'] as String,
      subscriptionStatus: json['subscription_status'] as String? ?? 'trial',
      trialEndsAt: json['trial_ends_at'] as String?,
    );
  }
}

/// Provider for all clinics — only accessible to jocker@supertechlb.com
/// because the RLS is_joker() function bypasses restrictions.
final allClinicsProvider = FutureProvider<List<ClinicSummary>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('clinics')
      .select()
      .order('subscription_status');

  return (response as List)
      .map((e) => ClinicSummary.fromJson(e as Map<String, dynamic>))
      .toList();
});

class JokerNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setSubscriptionStatus(
      String clinicId, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('clinics')
          .update({'subscription_status': status})
          .eq('id', clinicId);
      ref.invalidate(allClinicsProvider);
    });
  }

  Future<void> extendTrial(String clinicId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final newTrialEnd = DateTime.now().add(const Duration(days: 30));
      await supabase.from('clinics').update({
        'trial_ends_at': newTrialEnd.toIso8601String(),
        'subscription_status': 'trial',
      }).eq('id', clinicId);
      ref.invalidate(allClinicsProvider);
    });
  }
}

final jokerControllerProvider =
    AsyncNotifierProvider<JokerNotifier, void>(JokerNotifier.new);
