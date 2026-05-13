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
      children: widget.specialty.fields.map((field) {
        final name = field['name'] as String;
        final type = field['type'] as String;
        final label = name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildField(name, type, label),
        );
      }).toList(),
    );
  }

  Widget _buildField(String name, String type, String label) {
    switch (type) {
      case 'number':
        return TextFormField(
          initialValue: _data[name]?.toString(),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _data[name] = num.tryParse(v);
            widget.onChanged(_data);
          },
        );
      case 'text':
        return TextFormField(
          initialValue: _data[name]?.toString(),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          maxLines: 3,
          onChanged: (v) {
            _data[name] = v;
            widget.onChanged(_data);
          },
        );
      case 'select':
        final options = List<String>.from(widget.specialty.fields.firstWhere((f) => f['name'] == name)['options'] ?? []);
        return DropdownButtonFormField<String>(
          value: _data[name],
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          onChanged: (v) {
            _data[name] = v;
            widget.onChanged(_data);
          },
        );
      default:
        return TextFormField(
          initialValue: _data[name]?.toString(),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          onChanged: (v) {
            _data[name] = v;
            widget.onChanged(_data);
          },
        );
    }
  }
}
