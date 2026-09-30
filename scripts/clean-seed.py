import re
import sys
from pathlib import Path

path = Path("supabase/seed.sql")
if not path.exists():
    sys.exit("Soubor supabase/seed.sql neexistuje.")

text = path.read_text(encoding="utf-8")
MARK = "-- pergamen-seed-cleaned"
if MARK in text:
    sys.exit("Soubor už byl opraven, nic se nemění.")

for pattern in (
    r"^\\(?:restrict|unrestrict)\b.*\n",
    r"^SET (?:statement_timeout|lock_timeout|idle_in_transaction_session_timeout|transaction_timeout"
    r"|client_encoding|standard_conforming_strings|xmloption|client_min_messages|row_security"
    r"|check_function_bodies|SESSION AUTHORIZATION DEFAULT) ?[^\n]*;\n",
    r"^SELECT pg_catalog\.set_config.*\n",
    r"^ALTER TABLE .* (?:DISABLE|ENABLE) TRIGGER ALL;\n",
):
    text = re.sub(pattern, "", text, flags=re.MULTILINE)

text, n_urls = re.subn(
    r"http://127\.0\.0\.1:54321/storage/v1/object/sign/media/[^/'\s]+/\d+-([^?'\s]+)\?token=[^'\s]*",
    r"/uploads/\1",
    text,
)

cleanup = (
    "DELETE FROM public.user_roles;\n"
    "DELETE FROM public.profiles;\n\n"
)
m = re.search(r"^-- Data for Name: categories;", text, flags=re.MULTILINE) or re.search(
    r"^INSERT INTO public\.", text, flags=re.MULTILINE
)
if not m:
    sys.exit("V souboru se nepodařilo najít data z tabulek public.")
text = text[: m.start()] + cleanup + text[m.start():]

header = (
    f"{MARK}\n"
    "DELETE FROM public.posts;\n"
    "DELETE FROM public.categories;\n"
    "DELETE FROM public.tags;\n\n"
)
path.write_text(header + text, encoding="utf-8")
files = sorted(set(re.findall(r"/uploads/([^'\s]+)", text)))
print("Hotovo. Soubor supabase/seed.sql byl opraven.")
for f in files:
    print("  obrázek:", f)
