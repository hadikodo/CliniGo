import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medical_record_provider.dart';
import '../../../shared/services/specialty_service.dart';
import '../../../core/widgets/dynamic_specialty_form.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/models/medical_record.dart';

import 'package:flutter_animate/flutter_animate.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: specialtyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading specialty: $e')),
        data: (specialty) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: const Color(0xFF0F172A),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HISTORY', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text(
                        patientName,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (specialty != null)
              SliverToBoxAdapter(
                child: _SpecialtyActionHeader(specialty: specialty, patientId: patientId),
              ),
            recordsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
              data: (records) {
                if (records.isEmpty) {
                  return SliverFillRemaining(child: _EmptyHistoryState());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = records[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: _RecordCard(record: record, specialty: specialty)
                            .animate()
                            .fadeIn(delay: (index * 100).ms)
                            .moveY(begin: 10, end: 0, delay: (index * 100).ms),
                      );
                    },
                    childCount: records.length,
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Icon(Icons.history_edu_rounded, size: 64, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 24),
          const Text('No Entries Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () => _showNewRecordForm(context, ref),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: CliniGoTheme.primaryColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: CliniGoTheme.primaryColor.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: CliniGoTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, color: CliniGoTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New ${specialty.name} Entry', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 16)),
                    const Text('Create a detailed clinical record.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
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
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Clinical Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                    Text(specialty?.name.toUpperCase() ?? 'ENTRY', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz_rounded, size: 18, color: Color(0xFFCBD5E1)),
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
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)),
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
