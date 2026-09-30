import { Link } from "@tanstack/react-router";
import type { PostListItem } from "@/lib/blog.functions";
import { coverFor } from "@/lib/covers";
import { formatNumber } from "@/lib/format";

export function PostCard({ post }: { post: PostListItem }) {
  return (
    <Link
      to="/clanek/$slug"
      params={{ slug: post.slug }}
      className="glass flex items-center gap-3 rounded-2xl p-3 transition-shadow hover:shadow-glass"
    >
      <img
        src={coverFor(post.slug, post.cover_url)}
        alt={post.title}
        loading="lazy"
        width={512}
        height={512}
        className="size-14 shrink-0 rounded-xl object-cover"
      />
      <div className="min-w-0 flex-1">
        <p className="font-display text-[15px] leading-snug font-semibold">{post.title}</p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          {[
            post.categoryName ?? "Bez kategorie",
            `${post.reading_minutes} min`,
            `${formatNumber(post.views)} zhlédnutí`,
          ].join(" · ")}
        </p>
      </div>
    </Link>
  );
}
