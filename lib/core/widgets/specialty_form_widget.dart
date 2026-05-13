import 'dart:io' as io;
import 'package:flutter/material.dart';
import '../../../core/constants/specialty_schemas.dart';

/// Renders a dynamic form from a [SpecialtySchema].
/// Calls [onChanged] with the updated data map on every field change.
class SpecialtyFormWidget extends StatefulWidget {
  final SpecialtySchema schema;
  final Map<String, dynamic> initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SpecialtyFormWidget({
    super.key,
    required this.schema,
    required this.initialData,
    required this.onChanged,
  });

  @override
  State<SpecialtyFormWidget> createState() => _SpecialtyFormWidgetState();
}

class _SpecialtyFormWidgetState extends State<SpecialtyFormWidget> {
  late Map<String, dynamic> _data;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initialData);
    for (final field in widget.schema.fields) {
      if (field.type == FieldType.text || field.type == FieldType.number) {
        _controllers[field.key] = TextEditingController(
          text: _data[field.key]?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _update(String key, dynamic value) {
    setState(() => _data[key] = value);
    widget.onChanged(_data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.schema.fields.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildField(field),
          );
        }),
        const SizedBox(height: 24),
        _buildAttachmentsSection(),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    final attachments = List<String>.from(_data['attachments'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imaging & Attachments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (attachments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.image_outlined, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Text('No images attached', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.only(right: 12),
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(io.File(attachments[i])), // In reality use FileImage or CachedNetworkImage
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          final updated = List<String>.from(attachments);
                          updated.removeAt(i);
                          _update('attachments', updated);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            final samples = [
              'C:\\Users\\hadih\\.gemini\\antigravity\\brain\\36648d7c-b492-42f5-9fd9-4623cc73d26d\\dental_xray_sample_1778691683924.png',
              'C:\\Users\\hadih\\.gemini\\antigravity\\brain\\36648d7c-b492-42f5-9fd9-4623cc73d26d\\ecg_chart_sample_1778691724984.png',
              'C:\\Users\\hadih\\.gemini\\antigravity\\brain\\36648d7c-b492-42f5-9fd9-4623cc73d26d\\ultrasound_sample_1778691751751.png',
            ];
            final updated = List<String>.from(attachments);
            updated.add(samples[attachments.length % 3]);
            _update('attachments', updated);
          },
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Add Imaging Attachment'),
        ),
      ],
    );
  }

  Widget _buildField(SpecialtyField field) {
    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          controller: _controllers[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          maxLines: field.key.contains('note') || field.key.contains('plan') ? 3 : 1,
          onChanged: (v) => _update(field.key, v),
        );

      case FieldType.number:
        return TextFormField(
          controller: _controllers[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => _update(field.key, num.tryParse(v) ?? v),
        );

      case FieldType.date:
        final value = _data[field.key] as String?;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today),
          title: Text(value ?? 'Not set'),
          subtitle: Text(field.label),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value != null
                  ? DateTime.tryParse(value) ?? DateTime.now()
                  : DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2040),
            );
            if (picked != null) {
              _update(field.key,
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
            }
          },
        );

      case FieldType.select:
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          initialValue: _data[field.key] as String?,
          items: (field.options ?? [])
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => _update(field.key, v),
        );

      case FieldType.multiSelect:
        final selected = List<String>.from(
            (_data[field.key] as List?)?.cast<String>() ?? []);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (field.options ?? []).map((opt) {
                final isSelected = selected.contains(opt);
                return FilterChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (v) {
                    final updated = List<String>.from(selected);
                    if (v) {
                      updated.add(opt);
                    } else {
                      updated.remove(opt);
                    }
                    _update(field.key, updated);
                  },
                );
              }).toList(),
            ),
          ],
        );

      case FieldType.teethMap:
        // Simplified — future: interactive teeth SVG
        return TextFormField(
          controller: _controllers[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            helperText: 'Enter tooth numbers and conditions',
          ),
          maxLines: 2,
          onChanged: (v) => _update(field.key, v),
        );
    }
  }
}
