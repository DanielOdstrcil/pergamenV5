import { useRef, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { slugify } from "@/lib/format";
import { uploadMedia } from "@/lib/media";
import { toast } from "sonner";

export type PostFormValues = {
  title: string;
  slug: string;
  excerpt: string;
  content: string;
  cover_url: string;
  category_id: string | null;
  status: "draft" | "published";
  reading_minutes: number;
  tagIds: string[];
};

export const emptyPost: PostFormValues = {
  title: "",
  slug: "",
  excerpt: "",
  content: "",
  cover_url: "",
  category_id: null,
  status: "draft",
  reading_minutes: 3,
  tagIds: [],
};

export function PostEditor({
  initial,
  onSave,
  saving,
  textOnly = false,
}: {
  textOnly?: boolean;
  initial: PostFormValues;
  onSave: (values: PostFormValues) => Promise<void>;
  saving: boolean;
}) {
  const [values, setValues] = useState<PostFormValues>(initial);
  const [uploading, setUploading] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const { data: categories } = useQuery({
    queryKey: ["admin-categories"],
    queryFn: async () => {
      const { data } = await supabase.from("categories").select("id,name").order("name");
      return data ?? [];
    },
  });
  const { data: tags } = useQuery({
    queryKey: ["admin-tags"],
    queryFn: async () => {
      const { data } = await supabase.from("tags").select("id,name").order("name");
      return data ?? [];
    },
  });

  function set<K extends keyof PostFormValues>(key: K, value: PostFormValues[K]) {
    setValues((v) => ({ ...v, [key]: value }));
  }

  async function handleCoverUpload(file: File) {
    setUploading(true);
    try {
      const media = await uploadMedia(file);
      set("cover_url", media.url);
      toast.success("Obrázek nahrán.");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Nahrávání se nezdařilo.");
    } finally {
      setUploading(false);
    }
  }

  const inputCls = "glass-strong w-full rounded-2xl px-4 py-3 text-sm outline-none";

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        void onSave(values);
      }}
      className="space-y-4"
    >
      <input
        required
        value={values.title}
        onChange={(e) => {
          set("title", e.target.value);
          if (!textOnly && (!initial.slug || initial.slug === slugify(initial.title))) {
            set("slug", slugify(e.target.value));
          }
        }}
        placeholder="Název článku"
        className="glass-strong w-full rounded-2xl px-4 py-3 font-display text-lg font-semibold outline-none"
      />

      <input
        required
        hidden={textOnly}
        value={values.slug}
        onChange={(e) => set("slug", slugify(e.target.value))}
        placeholder="slug-clanku"
        className={inputCls}
      />

      <textarea
        value={values.excerpt}
        onChange={(e) => set("excerpt", e.target.value)}
        placeholder="Krátký úvod (perex)…"
        rows={2}
        className={inputCls}
      />

      <textarea
        required
        value={values.content}
        onChange={(e) => set("content", e.target.value)}
        placeholder="Text článku… Odstavce oddělte prázdným řádkem."
        rows={14}
        className={inputCls}
      />

      {textOnly && (
        <p className="glass rounded-2xl p-3 text-xs text-muted-foreground">
          Jako korektor můžete upravovat název, perex a text. Kategorii, štítky, obrázek ani stav článku měnit nemůžete.
        </p>
      )}

      <div className={textOnly ? "hidden" : "grid grid-cols-2 gap-3"}>
        <select
          value={values.category_id ?? ""}
          onChange={(e) => set("category_id", e.target.value || null)}
          className={inputCls}
        >
          <option value="">Bez kategorie</option>
          {(categories ?? []).map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>
        <select
          value={values.status}
          onChange={(e) => set("status", e.target.value as "draft" | "published")}
          className={inputCls}
        >
          <option value="draft">Koncept</option>
          <option value="published">Publikováno</option>
        </select>
      </div>

      <div className={textOnly ? "hidden" : "glass rounded-2xl p-4"}>
        <p className="label-eyebrow mb-3">Úvodní obrázek</p>
        {values.cover_url && (
          <img
            src={values.cover_url}
            alt="Úvodní obrázek"
            className="mb-3 aspect-[8/5] w-full rounded-xl object-cover"
          />
        )}
        <div className="flex gap-2">
          <button
            type="button"
            disabled={uploading}
            onClick={() => fileRef.current?.click()}
            className="glass-strong rounded-full px-4 py-2 text-xs font-semibold disabled:opacity-60"
          >
            {uploading ? "Nahrávám…" : "Nahrát obrázek"}
          </button>
          {values.cover_url && (
            <button
              type="button"
              onClick={() => set("cover_url", "")}
              className="rounded-full px-4 py-2 text-xs font-semibold text-destructive"
            >
              Odebrat
            </button>
          )}
        </div>
        <input
          ref={fileRef}
          type="file"
          accept="image/*"
          className="hidden"
          onChange={(e) => {
            const file = e.target.files?.[0];
            if (file) void handleCoverUpload(file);
            e.target.value = "";
          }}
        />
      </div>

      {!textOnly && (tags ?? []).length > 0 && (
        <div className="glass rounded-2xl p-4">
          <p className="label-eyebrow mb-3">Štítky</p>
          <div className="flex flex-wrap gap-2">
            {(tags ?? []).map((tag) => {
              const active = values.tagIds.includes(tag.id);
              return (
                <button
                  key={tag.id}
                  type="button"
                  onClick={() =>
                    set(
                      "tagIds",
                      active
                        ? values.tagIds.filter((id) => id !== tag.id)
                        : [...values.tagIds, tag.id],
                    )
                  }
                  className={
                    active
                      ? "rounded-full bg-primary px-3 py-1.5 text-[11px] font-semibold text-primary-foreground"
                      : "glass-strong rounded-full px-3 py-1.5 text-[11px] font-semibold"
                  }
                >
                  #{tag.name}
                </button>
              );
            })}
          </div>
        </div>
      )}

      <button
        type="submit"
        disabled={saving}
        className="gradient-brand w-full rounded-2xl py-3 text-sm font-semibold text-primary-foreground shadow-brand disabled:opacity-60"
      >
        {saving ? "Ukládám…" : "Uložit článek"}
      </button>
    </form>
  );
}
