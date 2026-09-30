CREATE POLICY "media_read_all" ON storage.objects FOR SELECT USING (bucket_id = 'media');
CREATE POLICY "media_upload_auth" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'media');
CREATE POLICY "media_update_auth" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'media');
CREATE POLICY "media_delete_auth" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'media');