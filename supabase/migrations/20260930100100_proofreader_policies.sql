-- Korektor smí číst a upravovat všechny články.
CREATE OR REPLACE FUNCTION private.is_proofreader(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = 'proofreader')
$$;

REVOKE ALL ON FUNCTION private.is_proofreader(uuid) FROM public, anon;
GRANT EXECUTE ON FUNCTION private.is_proofreader(uuid) TO authenticated;
GRANT ALL ON FUNCTION private.is_proofreader(uuid) TO service_role;

DROP POLICY IF EXISTS posts_read_own ON public.posts;
CREATE POLICY posts_read_own ON public.posts FOR SELECT TO authenticated
  USING ((auth.uid() = author_id) OR private.is_staff(auth.uid()) OR private.is_proofreader(auth.uid()));

DROP POLICY IF EXISTS posts_update ON public.posts;
CREATE POLICY posts_update ON public.posts FOR UPDATE TO authenticated
  USING ((auth.uid() = author_id) OR private.is_staff(auth.uid()) OR private.is_proofreader(auth.uid()))
  WITH CHECK ((auth.uid() = author_id) OR private.is_staff(auth.uid()) OR private.is_proofreader(auth.uid()));
