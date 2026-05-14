import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/theme.dart';

import 'package:flutter_animate/flutter_animate.dart';

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

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = ref.read(supabaseClientProvider);
    
    try {
      // In a self-serve flow, we create the clinic and then redirect to setup
      // For now, we still insert into leads but also simulate moving to setup
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
      
      // Move to Setup Wizard directly for a seamless experience
      context.go('/setup');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: CliniGoTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => context.go('/trial'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Your Clinic',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1,
                ),
              ).animate().fadeIn().moveY(begin: 10, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Finalize your details to launch CliniGo.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 40),
              
              _buildInputCard([
                _buildLabel('CLINIC IDENTITY'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicNameController,
                  decoration: _inputDecoration('Clinic Name', Icons.local_hospital_rounded),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Primary Specialty', Icons.medical_services_rounded),
                  items: ['General Medicine', 'Cardiology', 'Dermatology', 'Dentistry', 'Pediatrics', 'OB/GYN']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => _specialtyController.text = v ?? '',
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ]).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 24),
              
              _buildInputCard([
                _buildLabel('OPERATIONAL SCALE'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _patientsController,
                        decoration: _inputDecoration('Monthly Patients', Icons.people_rounded),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _clinicSize,
                        decoration: _inputDecoration('Team Size', Icons.business_rounded),
                        items: ['Small (1-2)', 'Medium (3-10)', 'Large (10+)']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _clinicSize = v ?? ''),
                      ),
                    ),
                  ],
                ),
              ]).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 24),
              
              _buildInputCard([
                _buildLabel('CONTACT & LOCATION'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Mobile Number', Icons.phone_rounded),
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: _inputDecoration('City', Icons.location_on_rounded),
                ),
              ]).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Initialize My Clinic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Color(0xFF94A3B8),
        letterSpacing: 1,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CliniGoTheme.primaryColor),
      ),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
    );
  }
}
