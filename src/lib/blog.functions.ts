import { createServerFn } from "@tanstack/react-start";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";

function publicClient() {
  const key = process.env["SUPABASE_PUBLISHABLE_KEY"]!;
  return createClient<Database>(process.env["SUPABASE_URL"]!, key, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: {
      fetch: (input, init) => {
        const headers = new Headers(init?.headers);
        if (key.startsWith("sb_") && headers.get("Authorization") === `Bearer ${key}`) {
          headers.delete("Authorization");
        }
        headers.set("apikey", key);
        return fetch(input, { ...init, headers });
      },
    },
  });
}

const POST_LIST_SELECT =
  "id,title,slug,excerpt,cover_url,published_at,views,reading_minutes,categories(name,slug),post_tags(tags(name,slug))";

export type PostListItem = {
  id: string;
  title: string;
  slug: string;
  excerpt: string;
  cover_url: string | null;
  published_at: string | null;
  views: number;
  reading_minutes: number;
  categoryName: string | null;
  categorySlug: string | null;
  tags: { name: string; slug: string }[];
};

/* eslint-disable @typescript-eslint/no-explicit-any */
function mapPost(row: any): PostListItem {
  return {
    id: row.id,
    title: row.title,
    slug: row.slug,
    excerpt: row.excerpt ?? "",
    cover_url: row.cover_url ?? null,
    published_at: row.published_at ?? null,
    views: row.views ?? 0,
    reading_minutes: row.reading_minutes ?? 3,
    categoryName: row.categories?.name ?? null,
    categorySlug: row.categories?.slug ?? null,
    tags: (row.post_tags ?? [])
      .map((pt: any) => pt.tags)
      .filter(Boolean)
      .map((t: any) => ({ name: t.name, slug: t.slug })),
  };
}
/* eslint-enable @typescript-eslint/no-explicit-any */

export const getPublicHome = createServerFn({ method: "GET" }).handler(async () => {
  const supabase = publicClient();
  const [posts, categories, tags, settings] = await Promise.all([
    supabase
      .from("posts")
      .select(POST_LIST_SELECT)
      .eq("status", "published")
      .order("published_at", { ascending: false })
      .limit(24),
    supabase.from("categories").select("id,name,slug,description").order("name"),
    supabase.from("tags").select("id,name,slug").order("name"),
    supabase.from("site_settings").select("site_title,tagline,description,footer_text").maybeSingle(),
  ]);

  return {
    posts: (posts.data ?? []).map(mapPost),
    categories: categories.data ?? [],
    tags: tags.data ?? [],
    settings: settings.data ?? null,
  };
});

export const getPublicPost = createServerFn({ method: "GET" })
  .inputValidator((data: { slug: string }) => data)
  .handler(async ({ data }) => {
    const supabase = publicClient();
    const { data: row } = await supabase
      .from("posts")
      .select(
        "id,title,slug,excerpt,content,cover_url,published_at,views,reading_minutes,author_id,categories(name,slug),post_tags(tags(name,slug))",
      )
      .eq("slug", data.slug)
      .eq("status", "published")
      .maybeSingle();

    if (!row) return null;

    let authorName: string | null = null;
    if (row.author_id) {
      const { data: profile } = await supabase
        .from("profiles")
        .select("display_name")
        .eq("id", row.author_id)
        .maybeSingle();
      authorName = profile?.display_name || null;
    }

    const { data: related } = await supabase
      .from("posts")
      .select(POST_LIST_SELECT)
      .eq("status", "published")
      .neq("slug", data.slug)
      .order("published_at", { ascending: false })
      .limit(3);

    return {
      post: { ...mapPost(row), content: (row as { content?: string }).content ?? "", authorName },
      related: (related ?? []).map(mapPost),
    };
  });

export const getPostsByCategory = createServerFn({ method: "GET" })
  .inputValidator((data: { slug: string }) => data)
  .handler(async ({ data }) => {
    const supabase = publicClient();
    const { data: category } = await supabase
      .from("categories")
      .select("id,name,slug,description")
      .eq("slug", data.slug)
      .maybeSingle();
    if (!category) return null;

    const { data: posts } = await supabase
      .from("posts")
      .select(POST_LIST_SELECT)
      .eq("status", "published")
      .eq("category_id", category.id)
      .order("published_at", { ascending: false });

    return { category, posts: (posts ?? []).map(mapPost) };
  });

export const getPostsByTag = createServerFn({ method: "GET" })
  .inputValidator((data: { slug: string }) => data)
  .handler(async ({ data }) => {
    const supabase = publicClient();
    const { data: tag } = await supabase
      .from("tags")
      .select("id,name,slug")
      .eq("slug", data.slug)
      .maybeSingle();
    if (!tag) return null;

    const { data: links } = await supabase.from("post_tags").select("post_id").eq("tag_id", tag.id);
    const ids = (links ?? []).map((l) => l.post_id);
    if (ids.length === 0) return { tag, posts: [] as PostListItem[] };

    const { data: posts } = await supabase
      .from("posts")
      .select(POST_LIST_SELECT)
      .eq("status", "published")
      .in("id", ids)
      .order("published_at", { ascending: false });

    return { tag, posts: (posts ?? []).map(mapPost) };
  });
