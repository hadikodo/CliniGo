-- Enable uuid-ossp extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User Roles
CREATE TYPE user_role AS ENUM (
  'doctor',
  'secretary',
  'assistant',
  'superadmin'
);

-- Clinics Table
CREATE TABLE clinics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  specialty_type TEXT NOT NULL,
  work_hour_start TIME NOT NULL,
  work_hour_end TIME NOT NULL,
  subscription_status TEXT DEFAULT 'trial',
  trial_ends_at TIMESTAMP WITH TIME ZONE DEFAULT (now() + interval '30 days')
);

-- User Profiles Table
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  clinic_id UUID REFERENCES clinics(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  full_name TEXT
);

-- Patients Table
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID REFERENCES clinics(id) ON DELETE CASCADE,
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  birth_date DATE,
  gender TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Appointments Table
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID REFERENCES clinics(id) ON DELETE CASCADE,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  duration_minutes INTEGER,
  status TEXT,
  notes TEXT
);

-- Medical Records Table
CREATE TABLE medical_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID REFERENCES clinics(id) ON DELETE CASCADE,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  clinical_data JSONB,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Invoices Table
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID REFERENCES clinics(id) ON DELETE CASCADE,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  amount NUMERIC,
  status TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Security & RLS
ALTER TABLE clinics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Joker Override Function
CREATE OR REPLACE FUNCTION is_joker() RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT email
    FROM auth.users
    WHERE id = auth.uid()
  ) = 'jocker@supertechlb.com';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clinics RLS
CREATE POLICY "Clinic Access or Joker Override" ON clinics
FOR ALL USING (
  id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

-- Global RLS for other tables
CREATE POLICY "Clinic Access or Joker Override" ON user_profiles
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

CREATE POLICY "Clinic Access or Joker Override" ON patients
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

CREATE POLICY "Clinic Access or Joker Override" ON appointments
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

CREATE POLICY "Clinic Access or Joker Override" ON medical_records
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

CREATE POLICY "Clinic Access or Joker Override" ON invoices
FOR ALL USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  ) OR is_joker()
);

-- Registration RPC function
CREATE OR REPLACE FUNCTION register_clinic(
  p_clinic_name TEXT,
  p_specialty TEXT,
  p_work_hour_start TIME,
  p_work_hour_end TIME,
  p_owner_id UUID,
  p_owner_full_name TEXT
) RETURNS UUID AS $$
DECLARE
  v_clinic_id UUID;
BEGIN
  -- Create the clinic
  INSERT INTO clinics (name, specialty_type, work_hour_start, work_hour_end)
  VALUES (p_clinic_name, p_specialty, p_work_hour_start, p_work_hour_end)
  RETURNING id INTO v_clinic_id;

  -- Link owner profile
  INSERT INTO user_profiles (id, clinic_id, role, full_name)
  VALUES (p_owner_id, v_clinic_id, 'doctor', p_owner_full_name);

  RETURN v_clinic_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
