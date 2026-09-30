export function Logo({ size = 40, className = "" }: { size?: number; className?: string }) {
  return (
    <img
      src="/logo-small.png"
      alt="Pergamen"
      width={size}
      height={size}
      className={`shrink-0 drop-shadow-sm ${className}`}
      style={{ width: size, height: size }}
    />
  );
}
