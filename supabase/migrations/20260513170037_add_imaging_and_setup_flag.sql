-- Add setup flag to clinics
ALTER TABLE clinics ADD COLUMN is_setup_completed BOOLEAN DEFAULT FALSE;

-- Update medical_records to ensure we have a place for attachments
-- (JSONB is already flexible, but let's add a comment for clarity)
COMMENT ON COLUMN medical_records.clinical_data IS 'Contains clinical notes and an optional attachments array of URLs';
