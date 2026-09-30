#!/bin/sh
# Spustí lokální databázi (Docker) a do .env zapíše její adresu a klíč.
set -e

if command -v supabase >/dev/null 2>&1; then
  SB="supabase"
else
  SB="npx --yes supabase"
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker neběží. Spusťte Docker Desktop a zkuste to znovu." >&2
  exit 1
fi

$SB start

# Načte API_URL, ANON_KEY (případně PUBLISHABLE_KEY) z běžící databáze.
eval "$($SB status -o env)"
KEY="${PUBLISHABLE_KEY:-$ANON_KEY}"

cat > .env <<ENVEOF
SUPABASE_PROJECT_ID="pergamen"
SUPABASE_PUBLISHABLE_KEY="$KEY"
SUPABASE_URL="$API_URL"
VITE_SUPABASE_PROJECT_ID="pergamen"
VITE_SUPABASE_PUBLISHABLE_KEY="$KEY"
VITE_SUPABASE_URL="$API_URL"
ENVEOF

echo ""
echo "Hotovo. Databáze běží a soubor .env je nastavený."
echo "Aplikace:            npm run dev  ->  http://localhost:3000"
echo "Správa databáze:     http://127.0.0.1:54323"
