import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/theme.dart';
import '../providers/billing_provider.dart';
import '../../patient_management/providers/patient_provider.dart';
import '../../../shared/models/invoice.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateInvoiceSheet(context, ref),
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Invoice', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: _RevenueChartHeader(invoicesAsync: invoicesAsync),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
          invoicesAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (invoices) {
              if (invoices.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No invoices recorded', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: _InvoiceCard(invoice: invoices[i], ref: ref),
                  ),
                  childCount: invoices.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  void _showCreateInvoiceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateInvoiceSheet(ref: ref),
    );
  }
}

class _RevenueChartHeader extends StatelessWidget {
  final AsyncValue<List<Invoice>> invoicesAsync;
  const _RevenueChartHeader({required this.invoicesAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL REVENUE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          invoicesAsync.when(
            data: (data) {
              final total = data.where((i) => i.status == 'paid').fold<double>(0, (sum, i) => sum + i.amount);
              return Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1));
            },
            loading: () => const Text('...', style: TextStyle(color: Colors.white, fontSize: 36)),
            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white, fontSize: 36)),
          ),
          const Spacer(),
          SizedBox(
            height: 100,
            child: invoicesAsync.when(
              data: (data) => _BarChart(invoices: data),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<Invoice> invoices;
  const _BarChart({required this.invoices});

  @override
  Widget build(BuildContext context) {
    // Simplified chart data
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _group(0, 400),
          _group(1, 700),
          _group(2, 500),
          _group(3, 900),
          _group(4, 300),
          _group(5, 600),
          _group(6, 800),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0);
  }

  BarChartGroupData _group(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: CliniGoTheme.accentColor,
          width: 12,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 1000, color: Colors.white.withValues(alpha: 0.05)),
        ),
      ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
                  color: (isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPaid ? Icons.check_rounded : Icons.pending_rounded,
            color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            size: 20,
          ),
        ),
        title: Text(
          invoice.patientName,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  invoice.status.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B), fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              const Text('·', style: TextStyle(color: Color(0xFF94A3B8))),
              const SizedBox(width: 8),
              const Text('Invoice #8271', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${invoice.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
            ),
            if (!isPaid)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: InkWell(
                  onTap: () => ref.read(billingControllerProvider.notifier).markPaid(invoice.id),
                  child: const Text('Mark Paid', style: TextStyle(color: CliniGoTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().moveX(begin: 10, end: 0);
  }
}

class _CreateInvoiceSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _CreateInvoiceSheet({required this.ref});

  @override
  ConsumerState<_CreateInvoiceSheet> createState() => _CreateInvoiceSheetState();
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Create Invoice', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
              const SizedBox(height: 24),
              patientsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (patients) => DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select Patient', Icons.person_rounded),
                  items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                  onChanged: (v) => setState(() => _selectedPatientId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: _inputDecoration('Amount (\$)', Icons.attach_money_rounded),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Generate Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
    );
  }
}
