import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _features = [
    {
      'title': 'The Medical Apple',
      'subtitle': 'A next-generation medical operating system designed for modern clinics.',
      'icon': 'health_and_safety_rounded',
    },
    {
      'title': 'Domino Engine Calendar',
      'subtitle': 'Smart scheduling that adapts to your delays instantly. No more manual rescheduling.',
      'icon': 'calendar_month_rounded',
    },
    {
      'title': 'Instant Prescriptions',
      'subtitle': 'Generate and print structured prescriptions in seconds, fully integrated with patient history.',
      'icon': 'medication_rounded',
    },
  ];

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'health_and_safety_rounded':
        return Icons.health_and_safety_rounded;
      case 'calendar_month_rounded':
        return Icons.calendar_month_rounded;
      case 'medication_rounded':
        return Icons.medication_rounded;
      case 'admin_panel_settings_rounded':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark premium background
      body: Stack(
        children: [
          // Background Gradient Animation
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [CliniGoTheme.primaryColor.withValues(alpha: 0.15), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          Positioned(
            bottom: -200,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [CliniGoTheme.accentColor.withValues(alpha: 0.1), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => context.go('/login'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign In', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                
                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      final feature = _features[index];
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Icon(
                                _getIcon(feature['icon']!),
                                size: 80,
                                color: Colors.white,
                              ),
                            ).animate(key: ValueKey('icon_$index')).scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                            const SizedBox(height: 48),
                            Text(
                              feature['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.center,
                            ).animate(key: ValueKey('title_$index')).slideY(begin: 0.2, end: 0, duration: 600.ms).fadeIn(),
                            const SizedBox(height: 16),
                            Text(
                              feature['subtitle']!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ).animate(key: ValueKey('subtitle_$index')).slideY(begin: 0.2, end: 0, duration: 800.ms).fadeIn(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Indicators & Actions
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _features.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? CliniGoTheme.accentColor : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CliniGoTheme.accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Free Trial',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms).fadeIn(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
