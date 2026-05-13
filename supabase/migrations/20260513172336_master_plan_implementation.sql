-- Master Plan Implementation Migration

-- 1. Expanded Enums
-- Drop existing and recreate or just alter. Since we are in MVP, I'll add the new statuses to the logic.
-- Actually, let's keep the TEXT type for status but enforce it with check constraints for flexibility.

ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_status_check;
ALTER TABLE appointments ADD CONSTRAINT appointments_status_check 
CHECK (status IN ('pending', 'running', 'finished', 'payment_pending', 'completed', 'cancelled', 'no_show', 'needs_reschedule'));

-- 2. Prescription Module Table
CREATE TABLE prescriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID REFERENCES clinics(id),
  patient_id UUID REFERENCES patients(id),
  appointment_id UUID REFERENCES appointments(id),
  medicines JSONB, -- Array of {name, dosage, frequency, duration, notes}
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Lead Generation Table
CREATE TABLE clinic_leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_name TEXT NOT NULL,
  clinic_specialty TEXT NOT NULL,
  estimated_monthly_patients INTEGER,
  country TEXT,
  city TEXT,
  mobile_number TEXT,
  whatsapp_number TEXT,
  clinic_size TEXT,
  message TEXT,
  status TEXT DEFAULT 'pending', -- 'pending', 'reviewed', 'activated', 'rejected'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. Specialties Schema Registry
CREATE TABLE specialties (
  id TEXT PRIMARY KEY, -- e.g., 'cardiology'
  name TEXT NOT NULL,
  fields JSONB, -- The dynamic fields for this specialty
  duration_minutes INTEGER DEFAULT 30
);

-- 5. Seed Specialties
INSERT INTO specialties (id, name, duration_minutes, fields) VALUES
('general', 'General Medicine', 20, '[{"name": "symptoms", "type": "text"}, {"name": "diagnosis", "type": "text"}, {"name": "chronic_diseases", "type": "text"}]'),
('cardiology', 'Cardiology', 30, '[{"name": "ecg", "type": "image"}, {"name": "heart_rate", "type": "number"}, {"name": "echocardiogram_notes", "type": "text"}]'),
('dermatology', 'Dermatology', 20, '[{"name": "skin_type", "type": "select", "options": ["Dry", "Oily", "Combination"]}, {"name": "lesion_images", "type": "gallery"}]'),
('dentistry', 'Dentistry', 45, '[{"name": "teeth_chart", "type": "dentistry_chart"}, {"name": "procedures", "type": "text"}]'),
('pediatrics', 'Pediatrics', 30, '[{"name": "weight", "type": "number"}, {"name": "height", "type": "number"}, {"name": "vaccines", "type": "multiselect"}]'),
('obgyn', 'OB/GYN', 30, '[{"name": "lmp", "type": "date"}, {"name": "edd", "type": "date"}, {"name": "fetal_heart_rate", "type": "number"}]');

-- 6. Add Prescription Template Table
CREATE TABLE prescription_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID REFERENCES clinics(id),
  name TEXT NOT NULL,
  medicines JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 7. RLS for new tables
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinic_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescription_templates ENABLE ROW LEVEL SECURITY;

-- Prescriptions
CREATE POLICY "Clinic Access or Joker Override" ON prescriptions
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

-- Clinic Leads (Joker only)
CREATE POLICY "Joker Only" ON clinic_leads
FOR ALL USING (is_joker());

-- Specialties (Readable by all, writable by Joker)
CREATE POLICY "Specialties Read for All" ON specialties
FOR SELECT USING (true);

CREATE POLICY "Specialties Joker Edit" ON specialties
FOR ALL USING (is_joker());

-- Prescription Templates
CREATE POLICY "Clinic Access or Joker Override" ON prescription_templates
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);
