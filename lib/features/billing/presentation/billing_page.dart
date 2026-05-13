import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/billing_provider.dart';
import '../../../shared/models/invoice.dart';
import '../../../features/patient_management/providers/patient_provider.dart';
import '../../../core/constants/theme.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateInvoiceSheet(context, ref),
        icon: const Icon(Icons.receipt_long),
        label: const Text('New Invoice'),
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (invoices) {
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No invoices yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          // Summary header
          final totalRevenue = invoices
              .where((i) => i.status == 'paid')
              .fold<double>(0.0, (sum, i) => sum + i.amount);
          final pending = invoices.where((i) => i.status == 'pending').length;

          return Column(
            children: [
              _RevenueHeader(totalRevenue: totalRevenue, pendingCount: pending),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _InvoiceCard(invoice: invoices[i], ref: ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateInvoiceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateInvoiceSheet(ref: ref),
    );
  }
}

class _RevenueHeader extends StatelessWidget {
  final double totalRevenue;
  final int pendingCount;
  const _RevenueHeader(
      {required this.totalRevenue, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CliniGoTheme.primaryColor,
            CliniGoTheme.primaryColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                Text(
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pendingCount pending',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              const Icon(Icons.monetization_on, color: Colors.white, size: 36),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final WidgetRef ref;
  const _InvoiceCard({required this.invoice, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == 'paid';
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              (isPaid ? CliniGoTheme.successColor : CliniGoTheme.warningColor)
                  .withAlpha(26),
          child: Icon(
            isPaid ? Icons.check : Icons.pending_outlined,
            color: isPaid
                ? CliniGoTheme.successColor
                : CliniGoTheme.warningColor,
          ),
        ),
        title: Text(
          invoice.patientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          invoice.status.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            color:
                isPaid ? CliniGoTheme.successColor : CliniGoTheme.warningColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${invoice.amount.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!isPaid)
              GestureDetector(
                onTap: () => ref
                    .read(billingControllerProvider.notifier)
                    .markPaid(invoice.id),
                child: Text(
                  'Mark Paid',
                  style: TextStyle(
                    color: CliniGoTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateInvoiceSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _CreateInvoiceSheet({required this.ref});

  @override
  ConsumerState<_CreateInvoiceSheet> createState() =>
      _CreateInvoiceSheetState();
}

class _CreateInvoiceSheetState extends ConsumerState<_CreateInvoiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  String? _selectedPatientId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(billingControllerProvider.notifier).createInvoice(
          patientId: _selectedPatientId!,
          amount: double.parse(_amountCtrl.text.trim()),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(billingControllerProvider).isLoading;
    final patientsAsync = ref.watch(patientsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create Invoice',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            patientsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (patients) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Patient',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: patients
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.fullName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPatientId = v),
                validator: (v) => v == null ? 'Select a patient' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
