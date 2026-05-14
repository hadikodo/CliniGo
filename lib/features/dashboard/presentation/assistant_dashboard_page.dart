import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/providers/appointment_provider.dart';
import '../../medical_records/providers/medical_record_provider.dart';
import '../../../shared/models/appointment.dart' as model;
import '../../../shared/models/prescription.dart';
import '../../medical_records/presentation/prescription_page.dart';
import '../../../core/constants/theme.dart';

import 'package:flutter_animate/flutter_animate.dart';

class AssistantDashboardPage extends ConsumerWidget {
  const AssistantDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _AssistantHeader()),
          appointmentsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (appointments) {
              final todayQueue = appointments
                  .where(
                    (a) =>
                        a.status == model.AppointmentStatus.pending ||
                        a.status == model.AppointmentStatus.running ||
                        a.status == model.AppointmentStatus.finished ||
                        a.status == model.AppointmentStatus.paymentPending,
                  )
                  .toList();

              if (todayQueue.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rtl_rounded, size: 64, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        const Text('Queue is empty', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: _QueueCard(appointment: todayQueue[i], ref: ref)
                        .animate()
                        .fadeIn(delay: (i * 100).ms)
                        .moveX(begin: 20, end: 0, delay: (i * 100).ms),
                  ),
                  childCount: todayQueue.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CLINICAL OPERATIONS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          const Text(
            'Daily Patient Queue',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monitor_heart_rounded, color: Colors.white60, size: 14),
                SizedBox(width: 8),
                Text('Real-time synchronization active.', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().moveY(begin: -20, end: 0);
  }
}

class _QueueCard extends StatelessWidget {
  final model.Appointment appointment;
  final WidgetRef ref;
  const _QueueCard({required this.appointment, required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;
    final isRunning = status == model.AppointmentStatus.running;
    final isFinished = status == model.AppointmentStatus.finished;
    final isPaymentPending = status == model.AppointmentStatus.paymentPending;

    Color statusColor = CliniGoTheme.primaryColor;
    String statusText = 'WAITING';
    IconData trailingIcon = Icons.add_circle_outline_rounded;

    if (isRunning) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'DOCTOR ROOM';
      trailingIcon = Icons.play_circle_filled_rounded;
    } else if (isFinished) {
      statusColor = const Color(0xFF10B981);
      statusText = 'GO TO RECEPTION';
      trailingIcon = Icons.arrow_forward_rounded;
    } else if (isPaymentPending) {
      statusColor = const Color(0xFF6366F1);
      statusText = 'BILLING DUE';
      trailingIcon = Icons.receipt_long_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: () => _showVitalsSheet(context, ref),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              appointment.patientFirstName?[0].toUpperCase() ?? '?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: statusColor),
            ),
          ),
        ),
        title: Text(
          appointment.patientName,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              const Text('·', style: TextStyle(color: Color(0xFFCBD5E1))),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(trailingIcon, color: statusColor.withValues(alpha: 0.8)),
      ),
    );
  }

  void _showVitalsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VitalsEntrySheet(appointment: appointment, ref: ref),
    );
  }
}

class _VitalsEntrySheet extends StatefulWidget {
  final model.Appointment appointment;
  final WidgetRef ref;
  const _VitalsEntrySheet({required this.appointment, required this.ref});

  @override
  State<_VitalsEntrySheet> createState() => _VitalsEntrySheetState();
}

class _VitalsEntrySheetState extends State<_VitalsEntrySheet> {
  final _bpController = TextEditingController();
  final _tempController = TextEditingController();
  final _weightController = TextEditingController();
  final _pulseController = TextEditingController();
  final _billingController = TextEditingController();
  final _prescriptionController = TextEditingController();

  @override
  void dispose() {
    _bpController.dispose();
    _tempController.dispose();
    _weightController.dispose();
    _pulseController.dispose();
    _billingController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  Future<void> _openFullPrescription(BuildContext context) async {
    final List<Medicine>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPage(
          patientId: widget.appointment.patientId!,
          appointmentId: widget.appointment.id,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      _prescriptionController.text = result
          .map((m) => '${m.name} (${m.dosage})')
          .join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.appointment.status;
    final isFinished = status == model.AppointmentStatus.finished;
    final isPaymentPending = status == model.AppointmentStatus.paymentPending;
    final isCompleted = status == model.AppointmentStatus.completed;

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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CLINICAL RECORD', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(widget.appointment.patientName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                  child: Text(status.toDbString().toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isPaymentPending && !isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: _VitalsField(
                      controller: _bpController,
                      label: 'BP',
                      icon: Icons.compress_rounded,
                      placeholder: '120/80',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VitalsField(
                      controller: _tempController,
                      label: 'Temp',
                      icon: Icons.thermostat_rounded,
                      placeholder: '36.6',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VitalsField(
                      controller: _weightController,
                      label: 'Weight',
                      icon: Icons.monitor_weight_outlined,
                      placeholder: '75.0',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VitalsField(
                      controller: _pulseController,
                      label: 'Pulse',
                      icon: Icons.favorite_border_rounded,
                      placeholder: '72',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _VitalsField(
                controller: _prescriptionController,
                label: 'Quick Prescription Note',
                icon: Icons.medication_outlined,
                placeholder: 'Initial medication notes...',
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _openFullPrescription(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 18, color: CliniGoTheme.primaryColor),
                      SizedBox(width: 12),
                      Text('Open Full Prescription Builder', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (isFinished || isPaymentPending || isCompleted)
              _VitalsField(
                controller: _billingController,
                label: 'Billing Amount (\$)',
                icon: Icons.payments_outlined,
                placeholder: '50.00',
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 32),
            _buildActionButtons(status),
            const SizedBox(height: 12),
            if (!isCompleted)
              TextButton(
                onPressed: () => _saveVitalsOnly(close: true),
                child: const Text('Save & Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(model.AppointmentStatus status) {
    switch (status) {
      case model.AppointmentStatus.pending:
        return ElevatedButton(
          onPressed: () => _updateStatus(model.AppointmentStatus.running),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Start Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        );
      case model.AppointmentStatus.running:
        return ElevatedButton(
          onPressed: () => _updateStatus(model.AppointmentStatus.finished),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Finish Consultation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        );
      case model.AppointmentStatus.finished:
        return ElevatedButton(
          onPressed: () => _updateStatus(model.AppointmentStatus.paymentPending),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Move to Billing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        );
      case model.AppointmentStatus.paymentPending:
        return ElevatedButton(
          onPressed: () => _updateStatus(model.AppointmentStatus.completed),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Complete Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _updateStatus(model.AppointmentStatus status) async {
    final amount = double.tryParse(_billingController.text) ?? 0;
    await widget.ref.read(appointmentControllerProvider.notifier).updateStatus(widget.appointment.id, status, billingAmount: amount);
    await _saveVitalsOnly(close: true);
  }

  Future<void> _saveVitalsOnly({bool close = false}) async {
    final clinicalData = {
      'vitals': {
        'bp': _bpController.text,
        'temp': _tempController.text,
        'weight': _weightController.text,
        'pulse': _pulseController.text,
      },
      'prescription': _prescriptionController.text,
      'billing_preview': _billingController.text,
    };

    await widget.ref.read(medicalRecordControllerProvider.notifier).saveRecord(
          patientId: widget.appointment.patientId!,
          clinicalData: clinicalData,
        );

    if (close && mounted) Navigator.pop(context);
  }
}

class _VitalsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String placeholder;
  final TextInputType keyboardType;

  const _VitalsField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
      ),
      keyboardType: keyboardType,
    );
  }
}
