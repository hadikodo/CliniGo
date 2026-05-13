import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../calendar/providers/appointment_provider.dart';
import '../../patient_management/providers/patient_provider.dart';
import '../../billing/providers/billing_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/theme.dart';
import 'assistant_dashboard_page.dart';

class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (profile) {
        if (profile?.role == 'assistant') {
          return const AssistantDashboardPage();
        }
        
        return _DoctorDashboard(profile: profile, ref: ref);
      },
    );
  }
}

class _DoctorDashboard extends StatelessWidget {
  final dynamic profile;
  final WidgetRef ref;
  const _DoctorDashboard({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final patientsAsync = ref.watch(patientsProvider);
    final billingAsync = ref.watch(invoicesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(profile: profile),
          const SizedBox(height: 32),
          _StatGrid(
            appointmentsAsync: appointmentsAsync,
            patientsAsync: patientsAsync,
            billingAsync: billingAsync,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              TextButton(
                onPressed: () => context.go('/calendar'),
                child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 16),
          _RecentAppointmentsList(appointmentsAsync: appointmentsAsync),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final dynamic profile;
  const _HeaderSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ).animate().fadeIn(duration: 400.ms),
              Text(
                '${profile?.fullName ?? 'Doctor'}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).moveY(begin: 10, end: 0),
            ],
          ),
        ),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A)),
        ).animate().fadeIn(delay: 400.ms).scale(),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  final AsyncValue<List<dynamic>> appointmentsAsync;
  final AsyncValue<List<dynamic>> patientsAsync;
  final AsyncValue<List<dynamic>> billingAsync;

  const _StatGrid({
    required this.appointmentsAsync,
    required this.patientsAsync,
    required this.billingAsync,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: Icons.calendar_today_rounded,
          label: 'Today',
          value: appointmentsAsync.when(
            data: (data) => data.length.toString(),
            loading: () => '...',
            error: (_, __) => '!',
          ),
          color: CliniGoTheme.primaryColor,
          delay: 400,
        ),
        _StatCard(
          icon: Icons.people_rounded,
          label: 'Patients',
          value: patientsAsync.when(
            data: (data) => data.length.toString(),
            loading: () => '...',
            error: (_, __) => '!',
          ),
          color: const Color(0xFF6366F1),
          delay: 500,
        ),
        _StatCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Revenue',
          value: billingAsync.when(
            data: (data) {
              final total = data.fold<double>(0, (sum, item) => sum + (item.amount ?? 0));
              return '\$${total.toInt()}';
            },
            loading: () => '...',
            error: (_, __) => '!',
          ),
          color: const Color(0xFF10B981),
          delay: 600,
        ),
        _StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Growth',
          value: '+12%',
          color: const Color(0xFFF59E0B),
          delay: 700,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).moveY(begin: 20, end: 0);
  }
}

class _RecentAppointmentsList extends StatelessWidget {
  final AsyncValue<List<dynamic>> appointmentsAsync;
  const _RecentAppointmentsList({required this.appointmentsAsync});

  @override
  Widget build(BuildContext context) {
    return appointmentsAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('No appointments today'));
        }
        return Column(
          children: data.take(3).map((a) => _AppointmentTile(appointment: a)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final dynamic appointment;
  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: CliniGoTheme.primaryColor.withOpacity(0.05),
            child: const Icon(Icons.person_outline, color: CliniGoTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                Text(
                  '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - Consultation',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CliniGoTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Preregistered',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: CliniGoTheme.primaryColor),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().moveX(begin: 10, end: 0);
  }
}
