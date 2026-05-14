-- Fix RLS Recursion and Optimize Clinic Access checks

-- 1. Create a SECURITY DEFINER function to break recursion on user_profiles
CREATE OR REPLACE FUNCTION get_my_clinic_id() 
RETURNS uuid 
LANGUAGE sql 
SECURITY DEFINER 
STABLE 
AS $$ 
  SELECT clinic_id FROM user_profiles WHERE id = auth.uid();
$$;

-- 2. Update user_profiles policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON user_profiles;
CREATE POLICY "Clinic Access or Joker Override" ON user_profiles
FOR ALL USING (
  id = auth.uid() OR 
  clinic_id = get_my_clinic_id() OR 
  is_joker()
);

-- 3. Update clinics policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON clinics;
CREATE POLICY "Clinic Access or Joker Override" ON clinics
FOR ALL USING (
  id = get_my_clinic_id() OR is_joker()
);

-- 4. Update patients policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON patients;
CREATE POLICY "Clinic Access or Joker Override" ON patients
FOR ALL USING (
  clinic_id = get_my_clinic_id() OR is_joker()
);

-- 5. Update appointments policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON appointments;
CREATE POLICY "Clinic Access or Joker Override" ON appointments
FOR ALL USING (
  clinic_id = get_my_clinic_id() OR is_joker()
);

-- 6. Update medical_records policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON medical_records;
CREATE POLICY "Clinic Access or Joker Override" ON medical_records
FOR ALL USING (
  clinic_id = get_my_clinic_id() OR is_joker()
);

-- 7. Update invoices policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON invoices;
CREATE POLICY "Clinic Access or Joker Override" ON invoices
FOR ALL USING (
  clinic_id = get_my_clinic_id() OR is_joker()
);

-- 8. Update prescriptions policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON prescriptions;
CREATE POLICY "Clinic Access or Joker Override" ON prescriptions
FOR ALL USING (
  clinic_id = get_my_clinic_id() OR is_joker()
);

-- 9. Update prescription_templates policy
DROP POLICY IF EXISTS "Clinic Access or Joker Override" ON prescription_templates;
CREATE POLICY "Clinic Access or Joker Override" ON prescription_templates
FOR ALL USING (
  clinic_id = get_my_clinic_id() OR is_joker()
);
