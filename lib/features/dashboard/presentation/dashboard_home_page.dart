import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analytics_provider.dart';
import '../../calendar/providers/appointment_provider.dart';
import '../../patient_management/providers/patient_provider.dart';
import '../../billing/providers/billing_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/theme.dart';
import 'assistant_dashboard_page.dart';

import '../../admin/presentation/admin_dashboard_page.dart';

class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isJoker = ref.watch(isJokerProvider);

    if (isJoker) {
      return const AdminDashboardPage();
    }

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
    final analytics = ref.watch(analyticsProvider);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
              analytics: analytics,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Schedule',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                    ),
                    Text(
                      'Clinical Session Overview',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => context.go('/calendar'),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 20),
            _RecentAppointmentsList(appointmentsAsync: appointmentsAsync),
          ],
        ),
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
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 28)),
        ).animate().scale(duration: 400.ms),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ).animate().fadeIn(duration: 400.ms),
              Text(
                'Dr. ${profile?.fullName ?? 'Hadi'}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.8),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).moveY(begin: 10, end: 0),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('LIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white24),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  final AsyncValue<List<dynamic>> appointmentsAsync;
  final AsyncValue<List<dynamic>> patientsAsync;
  final AsyncValue<List<dynamic>> billingAsync;
  final ClinicAnalytics analytics;

  const _StatGrid({
    required this.appointmentsAsync,
    required this.patientsAsync,
    required this.billingAsync,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: Icons.calendar_today_rounded,
          label: 'SCHEDULE',
          value: appointmentsAsync.when(
            data: (data) => data.length.toString(),
            loading: () => '...',
            error: (_, __) => '!',
          ),
          subValue: 'Patients Booked',
          color: const Color(0xFF0F172A),
          delay: 400,
        ),
        _StatCard(
          icon: Icons.bolt_rounded,
          label: 'LATENCY',
          value: '${analytics.averageWaitTimeMinutes}m',
          subValue: 'Average Delay',
          color: const Color(0xFFF59E0B),
          delay: 500,
        ),
        _StatCard(
          icon: Icons.wallet_rounded,
          label: 'REVENUE',
          value: billingAsync.when(
            data: (data) {
              final total = data.fold<double>(0, (sum, item) => sum + (item.amount ?? 0));
              return '\$${total.toInt()}';
            },
            loading: () => '...',
            error: (_, __) => '!',
          ),
          subValue: 'Total Earnings',
          color: const Color(0xFF10B981),
          delay: 600,
        ),
        _StatCard(
          icon: Icons.auto_graph_rounded,
          label: 'TREND',
          value: '+${analytics.patientGrowth}%',
          subValue: 'Weekly Growth',
          color: const Color(0xFF6366F1),
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
  final String subValue;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.6), letterSpacing: 1)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
          ),
          Text(
            subValue,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).moveY(begin: 20, end: 0).scale(begin: const Offset(0.95, 0.95));
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: CliniGoTheme.primaryColor.withValues(alpha: 0.05),
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
              color: CliniGoTheme.primaryColor.withValues(alpha: 0.1),
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
