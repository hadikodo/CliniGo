import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/clinic.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = ref.watch(authStateProvider).value?.session;
  if (session == null) return null;

  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('user_profiles')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();

  if (response == null) return null;
  return UserProfile.fromJson(response);
});

final isJokerProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value?.session?.user;
  return user?.email == 'jocker@supertechlb.com';
});

final clinicProvider = FutureProvider<Clinic?>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null || profile.clinicId == null) return null;

  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('clinics')
      .select()
      .eq('id', profile.clinicId!)
      .single();

  return Clinic.fromJson(response);
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).auth.signInWithPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).auth.signOut();
    });
  }

  Future<void> registerClinic({
    required String email,
    required String password,
    required String clinicName,
    required String specialty,
    required String ownerFullName,
    required String workStart,
    required String workEnd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Sign up failed — no user returned.');

      await supabase.rpc('register_clinic', params: {
        'p_clinic_name': clinicName,
        'p_specialty': specialty,
        'p_work_hour_start': workStart,
        'p_work_hour_end': workEnd,
        'p_owner_id': user.id,
        'p_owner_full_name': ownerFullName,
      });
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
