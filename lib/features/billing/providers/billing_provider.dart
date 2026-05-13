import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/invoice.dart';

final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('invoices')
      .select('*, patients(first_name, last_name)')
      .order('created_at', ascending: false);

  return (response as List)
      .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
      .toList();
});

class BillingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createInvoice({
    required String patientId,
    required double amount,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final profile = await ref.read(userProfileProvider.future);

      await supabase.from('invoices').insert({
        'clinic_id': profile?.clinicId,
        'patient_id': patientId,
        'amount': amount,
        'status': 'pending',
      });

      ref.invalidate(invoicesProvider);
    });
  }

  Future<void> markPaid(String invoiceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase
          .from('invoices')
          .update({'status': 'paid'})
          .eq('id', invoiceId);
      ref.invalidate(invoicesProvider);
    });
  }
}

final billingControllerProvider =
    AsyncNotifierProvider<BillingNotifier, void>(BillingNotifier.new);
