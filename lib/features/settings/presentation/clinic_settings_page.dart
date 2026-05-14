import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'sms_templates_page.dart';

class ClinicSettingsPage extends ConsumerStatefulWidget {
  const ClinicSettingsPage({super.key});

  @override
  ConsumerState<ClinicSettingsPage> createState() => _ClinicSettingsPageState();
}

class _ClinicSettingsPageState extends ConsumerState<ClinicSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final clinic = ref.watch(clinicProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONFIGURATIONS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(height: 8),
                    Text('Clinic Settings', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Clinic Information'),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.business_rounded,
                          label: 'Clinic Name',
                          value: clinic?.name ?? 'Loading...',
                        ),
                        const _Divider(),
                        _SettingsTile(
                          icon: Icons.medical_services_outlined,
                          label: 'Specialty',
                          value: clinic?.specialtyType ?? 'N/A',
                        ),
                        const _Divider(),
                        _SettingsTile(
                          icon: Icons.phone_android_rounded,
                          label: 'Public Phone',
                          value: '+961 70 123 456',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SectionTitle(title: 'Operational Hours'),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.access_time_rounded,
                          label: 'Start of Day',
                          value: clinic?.workHourStart ?? '08:00 AM',
                        ),
                        const _Divider(),
                        _SettingsTile(
                          icon: Icons.timer_off_outlined,
                          label: 'End of Day',
                          value: clinic?.workHourEnd ?? '05:00 PM',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SectionTitle(title: 'Communications'),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.sms_outlined,
                          label: 'SMS Templates',
                          value: '3 active templates',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmsTemplatesPage())),
                        ),
                        const _Divider(),
                        _SettingsTile(
                          icon: Icons.notifications_active_outlined,
                          label: 'Patient Reminders',
                          value: 'Enabled (24h before)',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save All Configurations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 60);
  }
}
