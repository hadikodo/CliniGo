import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Artificial delay to show the nice animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    
    // If we're authenticated, go_router redirect will automatically take us to dashboard/joker.
    // If not, we want to go to the onboarding screen (welcome screen) first.
    if (authState.value?.session != null) {
      context.go('/dashboard'); // Will be caught by router redirect if joker
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient Pattern
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [CliniGoTheme.primaryColor.withValues(alpha: 0.1), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 3.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [CliniGoTheme.accentColor.withValues(alpha: 0.05), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          
          // Logo & Name Animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png', height: 120),
                )
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 1.seconds, color: CliniGoTheme.primaryColor.withValues(alpha: 0.2)),
                
                const SizedBox(height: 32),
                const Text(
                  'CLINIGO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Color(0xFF0F172A),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Intelligent Clinic Management',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
