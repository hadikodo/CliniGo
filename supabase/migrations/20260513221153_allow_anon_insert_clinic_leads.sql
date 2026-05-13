-- Allow anyone (including anonymous users) to insert leads
CREATE POLICY "Allow anon insert leads" 
ON clinic_leads 
FOR INSERT 
TO public
WITH CHECK (true);
