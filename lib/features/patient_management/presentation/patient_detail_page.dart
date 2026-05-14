import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/models/patient.dart';

class PatientDetailPage extends ConsumerWidget {
  final Patient patient;
  const PatientDetailPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Patient Record', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            _PatientProfileHeader(patient: patient).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 32),
            _ActionGrid(patient: patient),
            const SizedBox(height: 32),
            _InfoSection(patient: patient).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PatientProfileHeader extends StatelessWidget {
  final Patient patient;
  const _PatientProfileHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CliniGoTheme.primaryColor.withValues(alpha: 0.08), width: 6),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: CliniGoTheme.primaryColor.withValues(alpha: 0.05),
            child: Text(
              patient.firstName?[0].toUpperCase() ?? '?',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: CliniGoTheme.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          patient.fullName,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: ${patient.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final Patient patient;
  const _ActionGrid({required this.patient});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.25,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ActionCard(
          icon: Icons.history_edu_rounded,
          label: 'Medical History',
          color: CliniGoTheme.primaryColor,
          delay: 200,
          onTap: () => context.go('/patient/${patient.id}/history?name=${patient.fullName}'),
        ),
        _ActionCard(
          icon: Icons.note_add_rounded,
          label: 'New Entry',
          color: const Color(0xFF10B981),
          delay: 300,
          onTap: () => context.go('/patient/${patient.id}/history?name=${patient.fullName}'),
        ),
        const _ActionCard(
          icon: Icons.calendar_month_rounded,
          label: 'Appointments',
          color: Color(0xFF6366F1),
          delay: 400,
        ),
        const _ActionCard(
          icon: Icons.payments_rounded,
          label: 'Billing / Invoices',
          color: Color(0xFFF59E0B),
          delay: 500,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int delay;
  final VoidCallback? onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.delay, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: -0.2)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9), delay: delay.ms);
  }
}

class _InfoSection extends StatelessWidget {
  final Patient patient;
  const _InfoSection({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          _InfoTile(label: 'Phone Number', value: patient.phone ?? 'N/A', icon: Icons.phone_android_rounded),
          const _InfoDivider(),
          _InfoTile(label: 'Gender', value: patient.gender?.toUpperCase() ?? 'N/A', icon: Icons.wc_rounded),
          const _InfoDivider(),
          _InfoTile(label: 'Birth Date', value: patient.birthDate ?? 'N/A', icon: Icons.cake_rounded),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.black.withValues(alpha: 0.03), height: 1),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[400]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }
}
