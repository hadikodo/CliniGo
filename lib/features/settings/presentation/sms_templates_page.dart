import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmsTemplatesPage extends ConsumerStatefulWidget {
  const SmsTemplatesPage({super.key});

  @override
  ConsumerState<SmsTemplatesPage> createState() => _SmsTemplatesPageState();
}

class _SmsTemplatesPageState extends ConsumerState<SmsTemplatesPage> {
  final _bookingCtrl = TextEditingController(text: 'Hello [PatientName], your appointment at [ClinicName] is confirmed on [Date] at [Time].');
  final _delayCtrl = TextEditingController(text: 'Hello [PatientName], due to an emergency your appointment at [ClinicName] has been delayed to [NewTime].');
  final _overflowCtrl = TextEditingController(text: 'Hello [PatientName], due to a clinic emergency your appointment has been moved to tomorrow at [Time]. Please confirm.');

  @override
  void dispose() {
    _bookingCtrl.dispose();
    _delayCtrl.dispose();
    _overflowCtrl.dispose();
    super.dispose();
  }

  void _insertVariable(TextEditingController ctrl, String variable) {
    final text = ctrl.text;
    final selection = ctrl.selection;
    final newText = text.replaceRange(selection.start, selection.end, '[$variable]');
    ctrl.text = newText;
    ctrl.selection = TextSelection.collapsed(offset: selection.start + variable.length + 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('SMS Templates', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TemplateEditor(
              title: 'Appointment Confirmation',
              controller: _bookingCtrl,
              variables: const ['PatientName', 'ClinicName', 'Date', 'Time'],
              onVariableTap: (v) => _insertVariable(_bookingCtrl, v),
            ),
            const SizedBox(height: 32),
            _TemplateEditor(
              title: 'Delay Notification',
              controller: _delayCtrl,
              variables: const ['PatientName', 'ClinicName', 'NewTime'],
              onVariableTap: (v) => _insertVariable(_delayCtrl, v),
            ),
            const SizedBox(height: 32),
            _TemplateEditor(
              title: 'Overflow / Reschedule',
              controller: _overflowCtrl,
              variables: const ['PatientName', 'Time'],
              onVariableTap: (v) => _insertVariable(_overflowCtrl, v),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Template Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateEditor extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final List<String> variables;
  final Function(String) onVariableTap;

  const _TemplateEditor({
    required this.title,
    required this.controller,
    required this.variables,
    required this.onVariableTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter template message...',
                  hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                ),
              ),
              const Divider(height: 32, color: Color(0xFFF1F5F9)),
              const Text('INSERT VARIABLES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: variables.map((v) => ActionChip(
                  label: Text('[$v]'),
                  onPressed: () => onVariableTap(v),
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  labelStyle: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 11),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
