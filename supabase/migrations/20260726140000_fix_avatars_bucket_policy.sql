-- Migration: Fix Avatars Bucket Security Policy
-- Description: Remove broad SELECT policy on storage.objects for avatars bucket
-- This prevents clients from listing all files in the bucket
-- Direct URL access still works, which is sufficient for public avatars
-- Impact: Improved security, prevents unintended data exposure

-- Drop the broad SELECT policy on storage.objects
DROP POLICY IF EXISTS "Avatar Select" ON storage.objects;

-- Create a more restrictive policy that only allows SELECT on the user's own avatar
-- This policy uses the bucket_id and folder structure to ensure users can only access their own avatars
CREATE POLICY "Avatar Select User Own" ON storage.objects
  FOR SELECT TO public
  USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

COMMENT ON POLICY "Avatar Select User Own" ON storage.objects IS 'Allows users to select only their own avatar files';
