import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../billing/providers/billing_provider.dart';
import '../../billing/providers/subscription_provider.dart';
import '../../../core/constants/theme.dart';

class DashboardShell extends ConsumerWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: CliniGoTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Hero(
          tag: 'logo',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CliniGoTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('assets/logo.png', height: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'CliniGo',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          profileAsync.when(
            data: (profile) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        profile?.fullName ?? '',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        profile?.role.toUpperCase() ?? '',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CliniGoTheme.accentColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: CliniGoTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      (profile?.fullName ?? 'C')[0],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CliniGoTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      drawer: const _AppDrawer(),
      body: Stack(
        children: [
          child,
          subscriptionAsync.when(
            data: (sub) {
              if (!sub.isSubscribed && !sub.isTrialActive) {
                return const _TrialEndedOverlay();
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CliniGoTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset('assets/logo.png', height: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'CliniGo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _DrawerItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  isActive: location == '/dashboard',
                  onTap: () => context.go('/dashboard'),
                ),
                _DrawerItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Patients',
                  isActive: location.startsWith('/patients'),
                  onTap: () => context.go('/patients'),
                ),
                _DrawerItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Calendar',
                  isActive: location == '/calendar',
                  onTap: () => context.go('/calendar'),
                ),
                _DrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Billing',
                  isActive: location == '/billing',
                  onTap: () => context.go('/billing'),
                ),
                Consumer(builder: (context, ref, _) {
                  final profile = ref.watch(userProfileProvider).value;
                  if (profile?.role != 'doctor') return const SizedBox.shrink();
                  return _DrawerItem(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Staff Settings',
                    isActive: location == '/staff',
                    onTap: () => context.go('/staff'),
                  );
                }),
                Consumer(builder: (context, ref, _) {
                  final isJoker = ref.watch(isJokerProvider);
                  if (!isJoker) return const SizedBox.shrink();
                  return _DrawerItem(
                    icon: Icons.auto_fix_high_rounded,
                    label: 'Joker Console',
                    isActive: location == '/joker',
                    onTap: () => context.go('/joker'),
                  );
                }),
              ],
            ),
          ),
          const Divider(indent: 24, endIndent: 24),
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            isActive: false,
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isActive ? CliniGoTheme.primaryColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(
            icon,
            color: isActive ? CliniGoTheme.primaryColor : const Color(0xFF64748B),
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isActive ? CliniGoTheme.primaryColor : const Color(0xFF475569),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: isActive
              ? Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: CliniGoTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _TrialEndedOverlay extends StatelessWidget {
  const _TrialEndedOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Trial Period Ended',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please upgrade to a premium plan to continue managing your clinic with CliniGo.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/billing'),
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
