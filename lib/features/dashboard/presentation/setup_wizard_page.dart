import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';

class SetupWizardPage extends StatefulWidget {
  const SetupWizardPage({super.key});

  @override
  State<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends State<SetupWizardPage> {
  int _currentStep = 0;
  final _smsTemplateController = TextEditingController(
    text: 'Hi [Name], your appointment at CliniGo is confirmed for [Time].',
  );

  @override
  void dispose() {
    _smsTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Setup Wizard'),
        automaticallyImplyLeading: false,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _completeSetup();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: const Text('Staff'),
            isActive: _currentStep >= 0,
            content: _StaffInviteStep(),
          ),
          Step(
            title: const Text('SMS'),
            isActive: _currentStep >= 1,
            content: _SmsTemplateStep(controller: _smsTemplateController),
          ),
          Step(
            title: const Text('Finish'),
            isActive: _currentStep >= 2,
            content: _FinalizeStep(),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSetup() async {
    // In a real app, we would update the clinic's is_setup_completed flag in Supabase
    // For now, we just redirect to the dashboard
    context.go('/dashboard');
  }
}

class _StaffInviteStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invite your team to CliniGo.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _StaffInviteRow(label: 'Secretary', icon: Icons.person_add_alt_1_outlined),
        const SizedBox(height: 12),
        _StaffInviteRow(label: 'Assistant', icon: Icons.person_add_alt_1_outlined),
        const SizedBox(height: 24),
        const Text(
          'You can also do this later from Settings.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _StaffInviteRow extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StaffInviteRow({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: CliniGoTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(child: Text('Invite $label (Email)')),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _SmsTemplateStep extends StatelessWidget {
  final TextEditingController controller;
  const _SmsTemplateStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize your booking confirmation SMS.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter template...',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tags: [Name], [Time], [Date], [Clinic]',
          style: TextStyle(color: CliniGoTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _FinalizeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        SizedBox(height: 24),
        Text(
          'You\'re all set!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Your clinic is ready for patients. Click continue to enter your dashboard.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
