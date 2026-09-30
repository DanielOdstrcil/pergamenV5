import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export type AuthInfo = {
  userId: string | null;
  email: string | null;
  displayName: string;
  roles: string[];
  isAdmin: boolean;
  isOwner: boolean;
  isStaff: boolean;
};

export function useAuth() {
  return useQuery<AuthInfo>({
    queryKey: ["auth-info"],
    queryFn: async () => {
      const { data } = await supabase.auth.getUser();
      const user = data.user;
      if (!user) {
        return {
          userId: null,
          email: null,
          displayName: "",
          roles: [],
          isAdmin: false,
          isOwner: false,
          isStaff: false,
        };
      }
      const [{ data: profile }, { data: roleRows }] = await Promise.all([
        supabase.from("profiles").select("display_name").eq("id", user.id).maybeSingle(),
        supabase.from("user_roles").select("role").eq("user_id", user.id),
      ]);
      const roles = (roleRows ?? []).map((r) => r.role as string);
      const isAdmin = roles.includes("admin");
      let isOwner = false;
      if (isAdmin) {
        isOwner = (await findOwnerId()) === user.id;
      }
      return {
        userId: user.id,
        email: user.email ?? null,
        displayName: profile?.display_name || (user.email ?? "").split("@")[0] || "Redaktor",
        roles,
        isAdmin,
        isOwner,
        isStaff: roles.includes("admin") || roles.includes("editor"),
      };
    },
  });
}

// Hlavní administrátor je nejdříve registrovaný administrátor
// (první uživatel systému). Stejné pravidlo používá i databáze.
export async function findOwnerId(): Promise<string | null> {
  const { data: adminRows } = await supabase.from("user_roles").select("user_id").eq("role", "admin");
  const ids = (adminRows ?? []).map((r) => r.user_id);
  if (ids.length === 0) return null;
  const { data: profiles } = await supabase
    .from("profiles")
    .select("id,created_at")
    .in("id", ids)
    .order("created_at", { ascending: true })
    .order("id", { ascending: true })
    .limit(1);
  return profiles?.[0]?.id ?? null;
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).slice(0, 2);
  if (parts.length === 0) return "PG";
  return parts.map((p) => p[0]?.toUpperCase() ?? "").join("") || "PG";
}
