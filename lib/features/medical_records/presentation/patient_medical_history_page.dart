import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medical_record_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/services/specialty_service.dart';
import '../../../core/widgets/dynamic_specialty_form.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/models/medical_record.dart';

class PatientMedicalHistoryPage extends ConsumerWidget {
  final String patientId;
  final String patientName;

  const PatientMedicalHistoryPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsProvider(patientId));
    final specialtyAsync = ref.watch(currentClinicSpecialtyProvider);

    return Scaffold(
      backgroundColor: CliniGoTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('$patientName History', style: const TextStyle(fontSize: 18)),
      ),
      body: specialtyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading specialty: $e')),
        data: (specialty) => Column(
          children: [
            if (specialty != null)
              _SpecialtyActionHeader(specialty: specialty, patientId: patientId),
            Expanded(
              child: recordsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (records) {
                  if (records.isEmpty) {
                    return _EmptyHistoryState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: records.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _RecordCard(record: record, specialty: specialty);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('No medical records found', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SpecialtyActionHeader extends ConsumerWidget {
  final Specialty specialty;
  final String patientId;

  const _SpecialtyActionHeader({required this.specialty, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE FORM',
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showNewRecordForm(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: CliniGoTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.add_rounded, size: 18),
                SizedBox(width: 8),
                Text('Add Entry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewRecordForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewRecordSheet(specialty: specialty, patientId: patientId),
    );
  }
}

class _NewRecordSheet extends ConsumerStatefulWidget {
  final Specialty specialty;
  final String patientId;

  const _NewRecordSheet({required this.specialty, required this.patientId});

  @override
  ConsumerState<_NewRecordSheet> createState() => _NewRecordSheetState();
}

class _NewRecordSheetState extends ConsumerState<_NewRecordSheet> {
  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
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
            Text(
              'New ${widget.specialty.name} Entry',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
            ),
            const SizedBox(height: 24),
            DynamicSpecialtyForm(
              specialty: widget.specialty,
              initialData: _formData,
              onChanged: (data) => _formData = data,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await ref.read(medicalRecordControllerProvider.notifier).saveRecord(
                      patientId: widget.patientId,
                      clinicalData: _formData,
                    );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save Clinical Record'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final Specialty? specialty;

  const _RecordCard({required this.record, this.specialty});

  @override
  Widget build(BuildContext context) {
    final date = record.createdAt != null ? DateTime.tryParse(record.createdAt!) : null;
    final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : 'Unknown date';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: CliniGoTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.history_edu_rounded, size: 16, color: CliniGoTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  dateStr,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const Spacer(),
                const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x0A000000)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: record.clinicalData.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          e.key.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
