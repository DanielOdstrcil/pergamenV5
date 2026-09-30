-- 1. profiles: limit anonymous reads to published authors
DROP POLICY IF EXISTS profiles_public_read ON public.profiles;

CREATE POLICY profiles_anon_read_authors ON public.profiles
FOR SELECT TO anon
USING (
  EXISTS (
    SELECT 1 FROM public.posts p
    WHERE p.author_id = profiles.id AND p.status = 'published'
  )
);

CREATE POLICY profiles_authenticated_read ON public.profiles
FOR SELECT TO authenticated
USING (true);

-- 2. user_roles: own role or staff
DROP POLICY IF EXISTS user_roles_read_all ON public.user_roles;

CREATE POLICY user_roles_read_own_or_staff ON public.user_roles
FOR SELECT TO authenticated
USING (user_id = auth.uid() OR private.is_staff(auth.uid()));

-- 3. storage.objects media bucket: ownership by folder prefix
DROP POLICY IF EXISTS media_upload_auth ON storage.objects;
DROP POLICY IF EXISTS media_update_auth ON storage.objects;
DROP POLICY IF EXISTS media_delete_auth ON storage.objects;

CREATE POLICY media_upload_own ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'media'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY media_update_own ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'media'
  AND ((storage.foldername(name))[1] = auth.uid()::text OR private.is_staff(auth.uid()))
)
WITH CHECK (
  bucket_id = 'media'
  AND ((storage.foldername(name))[1] = auth.uid()::text OR private.is_staff(auth.uid()))
);

CREATE POLICY media_delete_own ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'media'
  AND ((storage.foldername(name))[1] = auth.uid()::text OR private.is_staff(auth.uid()))
);