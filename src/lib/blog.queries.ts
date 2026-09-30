import { queryOptions } from "@tanstack/react-query";
import { getPublicHome, getPublicPost, getPostsByCategory, getPostsByTag } from "@/lib/blog.functions";

export const homeQuery = queryOptions({
  queryKey: ["public-home"],
  queryFn: () => getPublicHome(),
});

export const postQuery = (slug: string) =>
  queryOptions({
    queryKey: ["public-post", slug],
    queryFn: () => getPublicPost({ data: { slug } }),
  });

export const categoryQuery = (slug: string) =>
  queryOptions({
    queryKey: ["public-category", slug],
    queryFn: () => getPostsByCategory({ data: { slug } }),
  });

export const tagQuery = (slug: string) =>
  queryOptions({
    queryKey: ["public-tag", slug],
    queryFn: () => getPostsByTag({ data: { slug } }),
  });
