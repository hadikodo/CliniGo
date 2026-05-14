import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/specialty_service.dart';

class DynamicSpecialtyForm extends ConsumerStatefulWidget {
  final Specialty specialty;
  final Map<String, dynamic> initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DynamicSpecialtyForm({
    super.key,
    required this.specialty,
    required this.initialData,
    required this.onChanged,
  });

  @override
  ConsumerState<DynamicSpecialtyForm> createState() => _DynamicSpecialtyFormState();
}

class _DynamicSpecialtyFormState extends ConsumerState<DynamicSpecialtyForm> {
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = Map.from(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasSmartSuggestions) ...[
          _buildSmartSuggestions(),
          const SizedBox(height: 24),
        ],
        ...widget.specialty.fields.map((field) {
          final name = field['name'] as String;
          final type = field['type'] as String;
          final label = name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildField(name, type, label),
          );
        }),
        if (widget.specialty.name.toLowerCase().contains('dental'))
          _buildDentalChartPlaceholder(),
        if (widget.specialty.name.toLowerCase().contains('pediatrics'))
          _buildGrowthChartLink(),
      ],
    );
  }

  bool get _hasSmartSuggestions => 
      ['pediatrics', 'cardiology', 'general medicine'].any((s) => widget.specialty.name.toLowerCase().contains(s));

  Widget _buildSmartSuggestions() {
    final suggestions = widget.specialty.name.toLowerCase().contains('pediatrics')
        ? ['Fever', 'Cough', 'Skin Rash', 'Vomiting', 'Growth Check']
        : ['Chest Pain', 'Shortness of Breath', 'Palpitations', 'High BP'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SMART SUGGESTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((s) => ActionChip(
            label: Text(s),
            onPressed: () {},
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDentalChartPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Row(
        children: [
          Icon(Icons.grid_view_rounded, color: Color(0xFF64748B)),
          SizedBox(width: 16),
          Text('Interactive Dental Charting Tool', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
          Spacer(),
          Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildGrowthChartLink() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2))),
      child: const Row(
        children: [
          Icon(Icons.show_chart_rounded, color: Color(0xFF10B981)),
          SizedBox(width: 16),
          Text('Analyze Pediatric Growth Curve', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
          Spacer(),
          Icon(Icons.arrow_outward_rounded, color: Color(0xFF10B981), size: 18),
        ],
      ),
    );
  }

  Widget _buildField(String name, String type, String label) {
    final decoration = InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
      floatingLabelStyle: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w800),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );

    switch (type) {
      case 'number':
        return TextFormField(
          initialValue: _data[name]?.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: decoration,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _data[name] = num.tryParse(v);
            widget.onChanged(_data);
          },
        );
      case 'text':
        return TextFormField(
          initialValue: _data[name]?.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: decoration,
          maxLines: 3,
          onChanged: (v) {
            _data[name] = v;
            widget.onChanged(_data);
          },
        );
      case 'select':
        final options = List<String>.from(widget.specialty.fields.firstWhere((f) => f['name'] == name)['options'] ?? []);
        return DropdownButtonFormField<String>(
          initialValue: _data[name],
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          decoration: decoration,
          onChanged: (v) {
            _data[name] = v;
            widget.onChanged(_data);
          },
        );
      default:
        return TextFormField(
          initialValue: _data[name]?.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: decoration,
          onChanged: (v) {
            _data[name] = v;
            widget.onChanged(_data);
          },
        );
    }
  }
}
