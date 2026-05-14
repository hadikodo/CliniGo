import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/theme.dart';

class JokerConsolePage extends ConsumerWidget {
  const JokerConsolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('🃏', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              const Text('Joker Command Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: TabBar(
              indicatorColor: CliniGoTheme.accentColor,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
              tabs: const [
                Tab(text: 'INCOMING LEADS'),
                Tab(text: 'SYSTEM HEALTH'),
                Tab(text: 'REVENUE'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _LeadsTab(),
            _ClinicsTab(),
            _SubscriptionTab(),
          ],
        ),
      ),
    );
  }
}

final leadsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase.from('clinic_leads').select().order('created_at', ascending: false);
  return response as List;
});

class _LeadsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ref.watch(leadsProvider).when(
      data: (leads) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          final lead = leads[index];
          return _LeadConsoleCard(lead: lead, onReview: () => _showLeadDetails(context, lead));
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: CliniGoTheme.accentColor)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
    );
  }

  void _showLeadDetails(BuildContext context, Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LeadDetailSheet(lead: lead),
    );
  }
}

class _LeadConsoleCard extends StatelessWidget {
  final Map<String, dynamic> lead;
  final VoidCallback onReview;

  const _LeadConsoleCard({required this.lead, required this.onReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.business_rounded, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead['clinic_name'] ?? 'Unknown Clinic', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                Text(
                  '${lead['clinic_specialty']} · ${lead['city']}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _LeadDetailSheet extends StatelessWidget {
  final Map<String, dynamic> lead;
  const _LeadDetailSheet({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(lead['clinic_name'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _LeadDetailTile(icon: Icons.medical_services_rounded, label: 'Specialty', value: lead['clinic_specialty']),
          _LeadDetailTile(icon: Icons.phone_rounded, label: 'Mobile', value: lead['mobile_number']),
          _LeadDetailTile(icon: Icons.groups_rounded, label: 'Estimated Monthly Patients', value: lead['estimated_monthly_patients'].toString()),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: CliniGoTheme.accentColor, foregroundColor: Colors.white, minimumSize: const Size(0, 56)),
            child: const Text('Activate Subscription'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss', style: TextStyle(color: Colors.white38))),
        ],
      ),
    );
  }
}

class _LeadDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LeadDetailTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClinicsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Monitoring Node: Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)));
  }
}

class _SubscriptionTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Revenue Cluster: Latency 12ms', style: TextStyle(color: Colors.white38)));
  }
}
