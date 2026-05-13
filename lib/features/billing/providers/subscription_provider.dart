import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/subscription_service.dart';
import '../../auth/providers/auth_provider.dart';

class SubscriptionState {
  final bool isSubscribed;
  final bool isTrialActive;
  final bool isLoading;

  SubscriptionState({
    this.isSubscribed = false,
    this.isTrialActive = true,
    this.isLoading = true,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    bool? isTrialActive,
    bool? isLoading,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends AsyncNotifier<SubscriptionState> {
  @override
  Future<SubscriptionState> build() async {
    final profile = await ref.watch(userProfileProvider.future);
    if (profile == null) return SubscriptionState(isLoading: false);

    final clinic = await _fetchClinicData(profile.clinicId!);
    final isSubscribed = await subscriptionService.isSubscribed();
    
    bool isTrialActive = true;
    if (clinic?['trial_ends_at'] != null) {
      final trialEnd = DateTime.parse(clinic!['trial_ends_at'] as String);
      isTrialActive = trialEnd.isAfter(DateTime.now());
    }

    return SubscriptionState(
      isSubscribed: isSubscribed,
      isTrialActive: isTrialActive,
      isLoading: false,
    );
  }

  Future<Map<String, dynamic>?> _fetchClinicData(String clinicId) async {
    final supabase = ref.read(supabaseClientProvider);
    final response = await supabase
        .from('clinics')
        .select()
        .eq('id', clinicId)
        .single();
    return response as Map<String, dynamic>?;
  }
}

final subscriptionProvider = AsyncNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
