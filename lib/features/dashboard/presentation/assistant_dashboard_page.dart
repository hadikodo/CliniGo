import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/providers/appointment_provider.dart';
import '../../medical_records/providers/medical_record_provider.dart';
import '../../../shared/models/appointment.dart' as model;
import '../../../shared/models/prescription.dart';
import '../../medical_records/presentation/prescription_page.dart';
import '../../../core/constants/theme.dart';
import '../../auth/providers/auth_provider.dart';

class AssistantDashboardPage extends ConsumerWidget {
  const AssistantDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AssistantHeader(),
          Expanded(
            child: appointmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (appointments) {
                final todayQueue = appointments
                    .where(
                      (a) =>
                          a.status == model.AppointmentStatus.pending ||
                          a.status == model.AppointmentStatus.running,
                    )
                    .toList();

                if (todayQueue.isEmpty) {
                  return const Center(child: Text('No patients in queue.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todayQueue.length,
                  itemBuilder: (context, i) =>
                      _QueueCard(appointment: todayQueue[i], ref: ref),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: CliniGoTheme.primaryColor.withAlpha(20),
        border: Border(
          bottom: BorderSide(color: CliniGoTheme.primaryColor.withAlpha(50)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Queue',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: CliniGoTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Focus on vitals and intake today.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final model.Appointment appointment;
  final WidgetRef ref;
  const _QueueCard({required this.appointment, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isRunning = appointment.status == model.AppointmentStatus.running;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showVitalsSheet(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isRunning
                      ? CliniGoTheme.warningColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    appointment.patientFirstName?[0].toUpperCase() ?? '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isRunning ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isRunning)
                const Chip(
                  label: Text(
                    'RUNNING',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: CliniGoTheme.warningColor,
                )
              else
                Icon(
                  Icons.vibration_outlined,
                  color: CliniGoTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVitalsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
    final isRunning =
        widget.appointment.status == model.AppointmentStatus.running;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Clinical Record: ${widget.appointment.patientName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _VitalsField(
                  controller: _bpController,
                  label: 'BP',
                  icon: Icons.compress,
                  placeholder: '120/80',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VitalsField(
                  controller: _tempController,
                  label: 'Temp',
                  icon: Icons.thermostat_outlined,
                  placeholder: '36.6',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VitalsField(
            controller: _prescriptionController,
            label: 'Quick Prescription Note',
            icon: Icons.medication_outlined,
            placeholder: 'Paracetamol 500mg...',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openFullPrescription(context),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Add Full Prescription'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 12),
          _VitalsField(
            controller: _billingController,
            label: 'Billing Amount (\$)',
            icon: Icons.monetization_on_outlined,
            placeholder: '50.00',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          if (!isRunning)
            ElevatedButton(
              onPressed: () => _updateStatus(model.AppointmentStatus.running),
              style: ElevatedButton.styleFrom(
                backgroundColor: CliniGoTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Appointment'),
            )
          else
            ElevatedButton(
              onPressed: () => _updateStatus(model.AppointmentStatus.finished),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Finish Consultation'),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _saveVitalsOnly(),
            child: const Text('Save Vitals Only'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(model.AppointmentStatus status) async {
    final amount = double.tryParse(_billingController.text) ?? 0;

    // Save vitals + update appointment status and billing amount
    await widget.ref
        .read(appointmentControllerProvider.notifier)
        .updateStatus(widget.appointment.id, status, billingAmount: amount);

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

    await widget.ref
        .read(medicalRecordControllerProvider.notifier)
        .saveRecord(
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
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }
}
