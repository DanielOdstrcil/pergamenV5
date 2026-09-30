import { Link } from "@tanstack/react-router";
import { Logo } from "@/components/Logo";

export function SiteHeader({ title = "Pergamen", tagline = "Blog" }: { title?: string; tagline?: string }) {
  return (
    <header className="flex items-center justify-between">
      <Link to="/" className="flex items-center gap-2.5">
        <Logo size={44} />
        <div>
          <p className="font-display text-lg font-semibold leading-none">{title}</p>
          <p className="mt-0.5 text-[10px] font-medium tracking-[0.2em] text-muted-foreground uppercase">
            {tagline}
          </p>
        </div>
      </Link>
      <Link
        to="/prihlaseni"
        className="glass-strong rounded-full px-4 py-2 text-[11px] font-semibold text-foreground"
      >
        Redakce
      </Link>
    </header>
  );
}

export function SiteFooter({ text = "© Pergamen" }: { text?: string }) {
  return (
    <footer className="mt-10 border-t border-border pt-5 text-center text-[11px] text-muted-foreground">
      {text}
    </footer>
  );
}
