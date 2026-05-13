import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/theme.dart';

class RegisterClinicScreen extends ConsumerStatefulWidget {
  const RegisterClinicScreen({super.key});

  @override
  ConsumerState<RegisterClinicScreen> createState() => _RegisterClinicScreenState();
}

class _RegisterClinicScreenState extends ConsumerState<RegisterClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();
  final _patientsController = TextEditingController();
  String _clinicSize = 'Small (1-2 doctors)';

  @override
  void dispose() {
    _clinicNameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    _patientsController.dispose();
    super.dispose();
  }

  Future<void> _submitLead() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = ref.read(supabaseClientProvider);
    
    try {
      await supabase.from('clinic_leads').insert({
        'clinic_name': _clinicNameController.text.trim(),
        'clinic_specialty': _specialtyController.text.trim(),
        'estimated_monthly_patients': int.tryParse(_patientsController.text) ?? 0,
        'mobile_number': _phoneController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim(),
        'city': _cityController.text.trim(),
        'clinic_size': _clinicSize,
        'message': _messageController.text.trim(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Request Received'),
          content: const Text(
            'Thank you for your interest in CliniGo. Our team will review your clinic information and contact you shortly to activate your account and start your trial.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Register Your Clinic',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us about your clinic to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _SectionLabel('Clinic Details'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _clinicNameController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter clinic name' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Primary Specialty',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    items: ['General Medicine', 'Cardiology', 'Dermatology', 'Dentistry', 'Pediatrics', 'OB/GYN']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => _specialtyController.text = v ?? '',
                    validator: (v) => v == null ? 'Select specialty' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _patientsController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Monthly Patients',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _clinicSize,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Size',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    items: ['Small (1-2 doctors)', 'Medium (3-10 doctors)', 'Large (10+ doctors)']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _clinicSize = v ?? ''),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Contact Information'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _whatsappController,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp Number (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.chat_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City / Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Additional Message'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'How can we help you?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitLead,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: CliniGoTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Registration Request'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Already have an account? Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
