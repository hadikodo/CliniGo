-- Add appointment type and billing amount
ALTER TABLE appointments ADD COLUMN appointment_type TEXT DEFAULT 'consultation'; -- 'consultation' or 'surgery'
ALTER TABLE appointments ADD COLUMN billing_amount NUMERIC DEFAULT 0;

-- Ensure we can track staff invitations/status
ALTER TABLE user_profiles ADD COLUMN is_active BOOLEAN DEFAULT TRUE;
