-- Hlavní administrátor = nejdříve registrovaný administrátor.
CREATE OR REPLACE FUNCTION private.is_owner(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT _user_id = (
    SELECT ur.user_id
    FROM public.user_roles ur
    JOIN public.profiles p ON p.id = ur.user_id
    WHERE ur.role = 'admin'
    ORDER BY p.created_at ASC, p.id ASC
    LIMIT 1
  )
$$;

REVOKE ALL ON FUNCTION private.is_owner(uuid) FROM public, anon;
GRANT EXECUTE ON FUNCTION private.is_owner(uuid) TO authenticated;
GRANT ALL ON FUNCTION private.is_owner(uuid) TO service_role;

-- Role smí měnit jen hlavní administrátor (dříve každý administrátor).
DROP POLICY IF EXISTS user_roles_admin_manage ON public.user_roles;
CREATE POLICY user_roles_owner_manage ON public.user_roles FOR ALL TO authenticated
  USING (private.is_owner(auth.uid()))
  WITH CHECK (private.is_owner(auth.uid()));
