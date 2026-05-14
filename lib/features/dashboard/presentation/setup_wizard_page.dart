import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({super.key});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  int _currentStep = 0;
  bool _isSaving = false;
  
  final _smsTemplateController = TextEditingController(
    text: 'Hi [Name], your appointment at CliniGo is confirmed for [Time].',
  );

  @override
  void dispose() {
    _smsTemplateController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    setState(() => _isSaving = true);
    
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (profile?.clinicId != null) {
        final supabase = ref.read(supabaseClientProvider);
        await supabase.from('clinics').update({
          'is_setup_completed': true,
          // In a real app, we would also save the SMS template and staff invites
        }).eq('id', profile!.clinicId!);
        
        // Refresh clinic provider
        ref.invalidate(clinicProvider);
      }
      
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: CliniGoTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CliniGoTheme.primaryColor.withValues(alpha: 0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 32),
                        _buildStepContent(),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
          
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: CliniGoTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic Onboarding',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Text(
                'Personalizing your workspace',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = _currentStep >= index;
        final isCurrent = _currentStep == index;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0F172A) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFE2E8F0)),
                  boxShadow: isCurrent ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : null,
                ),
                child: Center(
                  child: isActive && !isCurrent 
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: _currentStep > index ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStaffStep();
      case 1:
        return _buildSmsStep();
      case 2:
        return _buildFinishStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStaffStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Invite Your Team',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ).animate().fadeIn().moveX(begin: -20, end: 0),
        const SizedBox(height: 8),
        const Text(
          'Add your secretaries and assistants to help manage the clinic.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        _StaffInviteCard(role: 'Secretary', icon: Icons.support_agent_rounded, color: const Color(0xFF6366F1)),
        const SizedBox(height: 16),
        _StaffInviteCard(role: 'Assistant', icon: Icons.medical_services_outlined, color: const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildSmsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Patient Communications',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ).animate().fadeIn().moveX(begin: -20, end: 0),
        const SizedBox(height: 8),
        const Text(
          'Customize the SMS patients receive when they book an appointment.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sms_outlined, color: CliniGoTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  const Text('BOOKING CONFIRMATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _smsTemplateController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagChip(label: '[Name]'),
                  _TagChip(label: '[Time]'),
                  _TagChip(label: '[Date]'),
                  _TagChip(label: '[Clinic]'),
                ],
              ),
            ],
          ),
        ).animate().scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildFinishStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48)),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        const Text(
          'Everything is Ready',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        const Text(
          'Your clinic is configured and the Domino Engine is primed. Welcome to the future of medical management.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Text('Back', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep < 2 ? () => setState(() => _currentStep++) : _completeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _currentStep < 2 ? 'Continue' : 'Launch Dashboard',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffInviteCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final Color color;

  const _StaffInviteCard({required this.role, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
                const Text('Invite via email', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CliniGoTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CliniGoTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Text(label, style: const TextStyle(color: CliniGoTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}
