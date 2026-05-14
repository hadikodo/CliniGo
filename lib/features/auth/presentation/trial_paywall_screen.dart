import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/services/subscription_service.dart';

class TrialPaywallScreen extends ConsumerWidget {
  const TrialPaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CliniGoTheme.primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CliniGoTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: CliniGoTheme.primaryColor,
                        size: 32,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Try CliniGo Free\nfor 30 Days',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Experience the full power of medical orchestration with zero risk.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 48),
                  
                  _FeatureItem(
                    icon: Icons.bolt_rounded,
                    title: 'Domino Engine',
                    subtitle: 'Recursive appointment shifting and latency management.',
                  ).animate().fadeIn(delay: 500.ms).moveX(begin: -20, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  _FeatureItem(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'Dynamic Specialties',
                    subtitle: 'Custom forms for Dental, Cardiology, and more.',
                  ).animate().fadeIn(delay: 600.ms).moveX(begin: -20, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  _FeatureItem(
                    icon: Icons.sms_outlined,
                    title: 'Smart Notifications',
                    subtitle: 'Automated SMS alerts for delays and reminders.',
                  ).animate().fadeIn(delay: 700.ms).moveX(begin: -20, end: 0),
                  
                  const SizedBox(height: 64),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Standard Plan',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                            Text(
                              '\$49.99/mo',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: CliniGoTheme.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Starts after your 30-day free trial ends. Cancel anytime.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                  
                  const SizedBox(height: 40),
                  
                  ElevatedButton(
                    onPressed: () => _handleStartTrial(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start 30-Day Free Trial',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                  
                  const SizedBox(height: 20),
                  
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'No thanks, take me back',
                        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartTrial(BuildContext context, WidgetRef ref) async {
    // In a real app, this would call RevenueCat
    // For now, we simulate success and move to registration
    await subscriptionService.purchaseTrial();
    if (context.mounted) {
      context.go('/register');
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CliniGoTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: CliniGoTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
