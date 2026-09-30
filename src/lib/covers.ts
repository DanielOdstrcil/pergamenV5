import postWriting from "@/assets/post-writing.jpg";
import postMorning from "@/assets/post-morning.jpg";
import postTravel from "@/assets/post-travel.jpg";
import mediaVase from "@/assets/media-vase.jpg";
import mediaBread from "@/assets/media-bread.jpg";
import mediaNotebook from "@/assets/media-notebook.jpg";

const bySlug: Record<string, string> = {
  "jak-napsat-clanek": postWriting,
  "rutiny-rana": postMorning,
  "cestovat-pozvolna": postTravel,
};

const fallbacks = [postWriting, postMorning, postTravel, mediaVase, mediaBread, mediaNotebook];

export const galleryFallbacks = [mediaVase, mediaBread, mediaNotebook, postWriting];

export function coverFor(slug: string, coverUrl?: string | null): string {
  if (coverUrl) return coverUrl;
  const direct = bySlug[slug];
  if (direct) return direct;
  let sum = 0;
  for (const ch of slug) sum += ch.charCodeAt(0);
  return fallbacks[sum % fallbacks.length]!;
}
