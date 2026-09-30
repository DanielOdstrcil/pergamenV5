CREATE SCHEMA IF NOT EXISTS private;

CREATE OR REPLACE FUNCTION private.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION private.is_staff(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','editor'))
$$;

REVOKE ALL ON SCHEMA private FROM public, anon;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT EXECUTE ON FUNCTION private.has_role(uuid, public.app_role) TO authenticated;
GRANT EXECUTE ON FUNCTION private.is_staff(uuid) TO authenticated;
GRANT ALL ON FUNCTION private.has_role(uuid, public.app_role) TO service_role;
GRANT ALL ON FUNCTION private.is_staff(uuid) TO service_role;

-- point policies at the private helpers
DROP POLICY profiles_admin_all ON public.profiles;
CREATE POLICY profiles_admin_all ON public.profiles FOR ALL TO authenticated
  USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));

DROP POLICY settings_admin_write ON public.site_settings;
CREATE POLICY settings_admin_write ON public.site_settings FOR ALL TO authenticated
  USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));

DROP POLICY user_roles_admin_manage ON public.user_roles;
CREATE POLICY user_roles_admin_manage ON public.user_roles FOR ALL TO authenticated
  USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));

DROP POLICY categories_staff_manage ON public.categories;
CREATE POLICY categories_staff_manage ON public.categories FOR ALL TO authenticated
  USING (private.is_staff(auth.uid())) WITH CHECK (private.is_staff(auth.uid()));

DROP POLICY tags_staff_manage ON public.tags;
CREATE POLICY tags_staff_manage ON public.tags FOR ALL TO authenticated
  USING (private.is_staff(auth.uid())) WITH CHECK (private.is_staff(auth.uid()));

DROP POLICY media_delete ON public.media;
CREATE POLICY media_delete ON public.media FOR DELETE TO authenticated
  USING ((auth.uid() = uploaded_by) OR private.is_staff(auth.uid()));

DROP POLICY post_tags_manage ON public.post_tags;
CREATE POLICY post_tags_manage ON public.post_tags FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM posts p WHERE p.id = post_tags.post_id AND (p.author_id = auth.uid() OR private.is_staff(auth.uid()))))
  WITH CHECK (EXISTS (SELECT 1 FROM posts p WHERE p.id = post_tags.post_id AND (p.author_id = auth.uid() OR private.is_staff(auth.uid()))));

DROP POLICY posts_read_own ON public.posts;
CREATE POLICY posts_read_own ON public.posts FOR SELECT TO authenticated
  USING ((auth.uid() = author_id) OR private.is_staff(auth.uid()));

DROP POLICY posts_insert_own ON public.posts;
CREATE POLICY posts_insert_own ON public.posts FOR INSERT TO authenticated
  WITH CHECK ((auth.uid() = author_id) OR private.is_staff(auth.uid()));

DROP POLICY posts_update ON public.posts;
CREATE POLICY posts_update ON public.posts FOR UPDATE TO authenticated
  USING ((auth.uid() = author_id) OR private.is_staff(auth.uid()))
  WITH CHECK ((auth.uid() = author_id) OR private.is_staff(auth.uid()));

DROP POLICY posts_delete ON public.posts;
CREATE POLICY posts_delete ON public.posts FOR DELETE TO authenticated
  USING ((auth.uid() = author_id) OR private.is_staff(auth.uid()));

-- drop the old public helpers
DROP FUNCTION public.has_role(uuid, public.app_role);
DROP FUNCTION public.is_staff(uuid);