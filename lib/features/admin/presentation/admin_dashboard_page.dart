import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/theme.dart';
import '../../auth/providers/auth_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 40),
              _buildMapSection(),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildActiveClinicsList()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildLiveLogStream()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CliniGoTheme.accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMMAND CENTER', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            Text('CliniGo Global Infrastructure Status', style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.map_rounded, size: 120, color: Colors.white.withValues(alpha: 0.05)),
          ),
          const Positioned(
            top: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GLOBAL CLINICS MAP', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Text('48 Nodes Online', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          // Pulsing markers (simulated)
          ...List.generate(5, (index) => Positioned(
            top: 60.0 + (index * 40),
            left: 100.0 + (index * 60),
            child: _MapMarker(),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0);
  }

  Widget _buildActiveClinicsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACTIVE CLINICS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _ClinicTile(name: 'Beirut Heart Center', load: '82%', latency: '0m', status: 'Optimal'),
        _ClinicTile(name: 'Cedars Medical', load: '45%', latency: '+15m', status: 'Delayed'),
        _ClinicTile(name: 'Dubai Derm Care', load: '91%', latency: '0m', status: 'Full'),
      ],
    );
  }

  Widget _buildLiveLogStream() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LIVE LOGS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ListView(
            children: [
              _LogEntry(time: '14:20', text: 'Dr. Mansour shifted chain by 15m'),
              _LogEntry(time: '14:18', text: 'New Clinic "Zahle Care" Activated'),
              _LogEntry(time: '14:15', text: 'Backup Node SYNC-A completed'),
              _LogEntry(time: '14:10', text: 'Patient SMS delivered to +961 70...'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(1,1), end: const Offset(2, 2)).fadeOut();
  }
}

class _ClinicTile extends StatelessWidget {
  final String name, load, latency, status;
  const _ClinicTile({required this.name, required this.load, required this.latency, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Load: $load · Latency: $latency', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final String time, text;
  const _LogEntry({required this.time, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(color: CliniGoTheme.accentColor, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
