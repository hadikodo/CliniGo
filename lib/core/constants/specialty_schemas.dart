/// Defines the field schema for each supported clinic specialty.
/// Fields drive the dynamic form renderer — no schema rewrites needed
/// when adding new specialties.
enum FieldType { text, number, date, select, multiSelect, teethMap }

class SpecialtyField {
  final String key;
  final String label;
  final FieldType type;
  final List<String>? options; // for select / multiSelect

  const SpecialtyField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });
}

class SpecialtySchema {
  final String id;
  final String name;
  final List<SpecialtyField> fields;

  const SpecialtySchema({
    required this.id,
    required this.name,
    required this.fields,
  });
}

class SpecialtySchemas {
  static const List<SpecialtySchema> all = [
    dental,
    cardiology,
    pediatrics,
    obgyn,
    general,
  ];

  static SpecialtySchema forType(String? type) {
    final lower = (type ?? '').toLowerCase();
    for (final s in all) {
      if (lower.contains(s.id)) return s;
    }
    return general;
  }

  // ------------------------------------------------------------------
  static const SpecialtySchema dental = SpecialtySchema(
    id: 'dental',
    name: 'Dental',
    fields: [
      SpecialtyField(key: 'chief_complaint', label: 'Chief Complaint', type: FieldType.text),
      SpecialtyField(key: 'tooth_number', label: 'Tooth Number', type: FieldType.number),
      SpecialtyField(
        key: 'tooth_condition',
        label: 'Tooth Condition',
        type: FieldType.select,
        options: ['healthy', 'decayed', 'missing', 'filled', 'crown', 'root_canal'],
      ),
      SpecialtyField(key: 'gum_notes', label: 'Gum Notes', type: FieldType.text),
      SpecialtyField(key: 'treatment_plan', label: 'Treatment Plan', type: FieldType.text),
    ],
  );

  // ------------------------------------------------------------------
  static const SpecialtySchema cardiology = SpecialtySchema(
    id: 'cardiology',
    name: 'Cardiology',
    fields: [
      SpecialtyField(key: 'systolic_bp', label: 'Systolic BP (mmHg)', type: FieldType.number),
      SpecialtyField(key: 'diastolic_bp', label: 'Diastolic BP (mmHg)', type: FieldType.number),
      SpecialtyField(key: 'heart_rate', label: 'Heart Rate (bpm)', type: FieldType.number),
      SpecialtyField(key: 'ecg_note', label: 'ECG Notes', type: FieldType.text),
      SpecialtyField(
        key: 'rhythm',
        label: 'Rhythm',
        type: FieldType.select,
        options: ['sinus', 'afib', 'flutter', 'bradycardia', 'tachycardia', 'other'],
      ),
      SpecialtyField(key: 'symptoms', label: 'Symptoms', type: FieldType.text),
    ],
  );

  // ------------------------------------------------------------------
  static const SpecialtySchema pediatrics = SpecialtySchema(
    id: 'pediatrics',
    name: 'Pediatrics',
    fields: [
      SpecialtyField(key: 'weight_kg', label: 'Weight (kg)', type: FieldType.number),
      SpecialtyField(key: 'height_cm', label: 'Height (cm)', type: FieldType.number),
      SpecialtyField(key: 'head_circumference', label: 'Head Circumference (cm)', type: FieldType.number),
      SpecialtyField(
        key: 'vaccines',
        label: 'Vaccines Given',
        type: FieldType.multiSelect,
        options: ['MMR', 'Polio', 'BCG', 'Hepatitis B', 'DTP', 'Hib', 'PCV', 'Rotavirus', 'Varicella'],
      ),
      SpecialtyField(key: 'developmental_notes', label: 'Developmental Notes', type: FieldType.text),
      SpecialtyField(key: 'feeding', label: 'Feeding (breast/formula/solid)', type: FieldType.text),
    ],
  );

  // ------------------------------------------------------------------
  static const SpecialtySchema obgyn = SpecialtySchema(
    id: 'obgyn',
    name: 'OB/GYN',
    fields: [
      SpecialtyField(key: 'lmp', label: 'Last Menstrual Period', type: FieldType.date),
      SpecialtyField(key: 'edd', label: 'Estimated Due Date', type: FieldType.date),
      SpecialtyField(key: 'gestational_age_weeks', label: 'Gestational Age (weeks)', type: FieldType.number),
      SpecialtyField(key: 'fetal_heart_rate', label: 'Fetal Heart Rate (bpm)', type: FieldType.number),
      SpecialtyField(
        key: 'presentation',
        label: 'Fetal Presentation',
        type: FieldType.select,
        options: ['cephalic', 'breech', 'transverse', 'oblique'],
      ),
      SpecialtyField(key: 'ultrasound_notes', label: 'Ultrasound Notes', type: FieldType.text),
    ],
  );

  // ------------------------------------------------------------------
  static const SpecialtySchema general = SpecialtySchema(
    id: 'general',
    name: 'General',
    fields: [
      SpecialtyField(key: 'chief_complaint', label: 'Chief Complaint', type: FieldType.text),
      SpecialtyField(key: 'diagnosis', label: 'Diagnosis', type: FieldType.text),
      SpecialtyField(key: 'prescription', label: 'Prescription', type: FieldType.text),
      SpecialtyField(key: 'follow_up', label: 'Follow-up Instructions', type: FieldType.text),
      SpecialtyField(key: 'notes', label: 'Clinical Notes', type: FieldType.text),
    ],
  );
}
