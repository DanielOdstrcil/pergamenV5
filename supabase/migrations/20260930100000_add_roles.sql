-- Nové role: korektor a fotograf.
-- (Nové hodnoty výčtu se smí použít až v další migraci.)
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'proofreader';
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'photographer';
