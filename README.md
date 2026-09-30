# Pergamen

Redakční systém a blog. Veřejný web zobrazuje články, kategorie a štítky,
administrace (`/admin`) slouží redakci k psaní článků, správě obsahu, médií a uživatelů.

**Technologie:** TanStack Start (React, TypeScript), Tailwind CSS, Supabase
(databáze PostgreSQL, přihlášení, úložiště souborů), která běží lokálně v Dockeru.

## Co aplikace umí

- veřejný web: úvodní stránka, detail článku, výpis podle kategorie a štítku
- přihlášení a registrace (`/prihlaseni`)
- administrace: články (koncept / publikováno), kategorie, štítky, knihovna médií, nastavení webu
- role: administrátor, redaktor, autor, korektor, fotograf
- stránku Uživatelé a změny rolí vidí jen hlavní administrátor (nejdříve registrovaný administrátor)
- tlačítko „← Na web" v administraci, odhlášení, ikonka webu a manifest pro přidání na plochu

## Co je potřeba mít nainstalované

1. **Node.js 20 nebo novější** (https://nodejs.org), ověření: `node -v`
2. **Docker Desktop** (https://www.docker.com/products/docker-desktop), musí být spuštěný
3. Internet při prvním spuštění (stahují se balíčky a obrazy pro databázi)

## Spuštění

V terminálu ve složce projektu (tam, kde je `package.json`):

```sh
npm install
npm run db:setup
npm run dev
```

Potom otevřete **http://localhost:3000/**.

- `npm install` nainstaluje balíčky.
- `npm run db:setup` spustí databázi v Dockeru, vytvoří tabulky, načte data ze `supabase/seed.sql`
  a zapíše připojení do souboru `.env`. První spuštění může trvat několik minut.
- `npm run dev` spustí aplikaci. Terminál nechte otevřený, jinak aplikace přestane běžet.

Cesta ke složce projektu nesmí obsahovat dvojtečky, jinak se `npm` nespustí.

## Přihlášení

Do administrace se přihlaste na **http://localhost:3000/prihlaseni**.
V databázi jsou dva účty:

| E-mail            | Heslo        | Jméno  | Poznámka                              |
| ----------------- | ------------ | ------ | ------------------------------------- |
| admin@example.cz  | tPrtTRY30fNl | Admin  | hlavní administrátor (vidí Uživatele) |
| admin2@example.cz | tPrtTRY30fNl | Admin2 | administrátor                         |

Nový účet lze vytvořit na stejné stránce (registrace). První zaregistrovaný účet v prázdné databázi
se stane hlavním administrátorem.

## Správa databáze

Supabase Studio je na **http://127.0.0.1:54323** (tabulky, uživatelé, soubory).

## Užitečné příkazy

| Příkaz                      | Co dělá                                                             |
| --------------------------- | ------------------------------------------------------------------- |
| `npm run dev`               | spustí aplikaci                                                     |
| `npm run build`             | vytvoří produkční sestavení do `.output`                            |
| `npm run db:setup`          | spustí databázi a nastaví `.env`                                    |
| `npm run db:stop`           | zastaví databázi (data zůstanou uložená)                            |
| `npx supabase db reset`     | smaže lokální databázi a vytvoří ji znovu ze seedu                  |
| `npx supabase migration up` | provede chybějící migrace bez mazání dat                            |

## Časté problémy

- **Docker neběží**: spusťte Docker Desktop, počkejte, až naběhne, a příkaz zopakujte.
- **Chyba `Missing Supabase environment variable` nebo bílá stránka**: spusťte `npm run db:setup`
  a potom znovu `npm run dev`.
- **`vite: command not found`**: chybí `npm install`, nebo je v cestě ke složce dvojtečka.
- **Obsazený port** (3000, 54321–54324): ukončete program, který ho používá.
- **Chybí obrázky u článků**: zobrazí se ukázkové obrázky. Vlastní patří do `public/uploads/`.

## Struktura projektu

```
src/routes/           stránky (veřejný web a /admin)
src/components/       komponenty
src/lib/              dotazy do databáze, role, pomocné funkce
src/integrations/     připojení k Supabase
supabase/migrations/  tvorba tabulek, práv a rolí
supabase/seed.sql     data: uživatelé, články, kategorie, štítky
supabase/config.toml  nastavení lokální databáze
public/               ikony, manifest, nahrané obrázky
scripts/              pomocné skripty
```

## Poznámky

- Databáze je jen lokální. Pro nasazení na internet by bylo potřeba vytvořit online projekt Supabase
  a v `.env` změnit adresu a klíč.