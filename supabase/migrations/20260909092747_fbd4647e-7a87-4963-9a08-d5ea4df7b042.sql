-- roles
CREATE TYPE public.app_role AS ENUM ('admin', 'editor', 'author');

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT '',
  bio TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.profiles TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION public.is_staff(_user_id UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role IN ('admin','editor'))
$$;

CREATE POLICY "profiles_public_read" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_admin_all" ON public.profiles FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE POLICY "user_roles_read_all" ON public.user_roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "user_roles_admin_manage" ON public.user_roles FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- new user trigger: profile + first user becomes admin
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE user_count INT;
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)));

  SELECT count(*) INTO user_count FROM auth.users;
  IF user_count <= 1 THEN
    INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'admin');
  ELSE
    INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'author');
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- categories
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.categories TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.categories TO authenticated;
GRANT ALL ON public.categories TO service_role;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_public_read" ON public.categories FOR SELECT USING (true);
CREATE POLICY "categories_staff_manage" ON public.categories FOR ALL TO authenticated USING (public.is_staff(auth.uid())) WITH CHECK (public.is_staff(auth.uid()));

-- tags
CREATE TABLE public.tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.tags TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tags TO authenticated;
GRANT ALL ON public.tags TO service_role;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tags_public_read" ON public.tags FOR SELECT USING (true);
CREATE POLICY "tags_staff_manage" ON public.tags FOR ALL TO authenticated USING (public.is_staff(auth.uid())) WITH CHECK (public.is_staff(auth.uid()));

-- posts
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  excerpt TEXT NOT NULL DEFAULT '',
  content TEXT NOT NULL DEFAULT '',
  cover_url TEXT,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  published_at TIMESTAMPTZ,
  views INT NOT NULL DEFAULT 0,
  reading_minutes INT NOT NULL DEFAULT 3,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.posts TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.posts TO authenticated;
GRANT ALL ON public.posts TO service_role;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "posts_public_read_published" ON public.posts FOR SELECT USING (status = 'published');
CREATE POLICY "posts_read_own" ON public.posts FOR SELECT TO authenticated USING (auth.uid() = author_id OR public.is_staff(auth.uid()));
CREATE POLICY "posts_insert_own" ON public.posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = author_id OR public.is_staff(auth.uid()));
CREATE POLICY "posts_update" ON public.posts FOR UPDATE TO authenticated USING (auth.uid() = author_id OR public.is_staff(auth.uid())) WITH CHECK (auth.uid() = author_id OR public.is_staff(auth.uid()));
CREATE POLICY "posts_delete" ON public.posts FOR DELETE TO authenticated USING (auth.uid() = author_id OR public.is_staff(auth.uid()));

CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;
CREATE TRIGGER posts_touch_updated_at BEFORE UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- post_tags
CREATE TABLE public.post_tags (
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);
GRANT SELECT ON public.post_tags TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.post_tags TO authenticated;
GRANT ALL ON public.post_tags TO service_role;
ALTER TABLE public.post_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "post_tags_public_read" ON public.post_tags FOR SELECT USING (true);
CREATE POLICY "post_tags_manage" ON public.post_tags FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.posts p WHERE p.id = post_id AND (p.author_id = auth.uid() OR public.is_staff(auth.uid()))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.posts p WHERE p.id = post_id AND (p.author_id = auth.uid() OR public.is_staff(auth.uid()))));

-- media
CREATE TABLE public.media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  filename TEXT NOT NULL,
  path TEXT NOT NULL,
  url TEXT NOT NULL,
  mime_type TEXT NOT NULL DEFAULT 'image/jpeg',
  size_bytes BIGINT NOT NULL DEFAULT 0,
  uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.media TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.media TO authenticated;
GRANT ALL ON public.media TO service_role;
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
CREATE POLICY "media_public_read" ON public.media FOR SELECT USING (true);
CREATE POLICY "media_insert" ON public.media FOR INSERT TO authenticated WITH CHECK (auth.uid() = uploaded_by);
CREATE POLICY "media_delete" ON public.media FOR DELETE TO authenticated USING (auth.uid() = uploaded_by OR public.is_staff(auth.uid()));

-- site settings (single row)
CREATE TABLE public.site_settings (
  id BOOLEAN PRIMARY KEY DEFAULT true,
  site_title TEXT NOT NULL DEFAULT 'Pergamen',
  tagline TEXT NOT NULL DEFAULT 'Blog o psaní, designu a pomalém životě',
  description TEXT NOT NULL DEFAULT 'Redakční systém Pergamen — články, kategorie a médiová knihovna na jednom místě.',
  footer_text TEXT NOT NULL DEFAULT '© Pergamen',
  posts_per_page INT NOT NULL DEFAULT 10,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT site_settings_singleton CHECK (id)
);
GRANT SELECT ON public.site_settings TO anon;
GRANT SELECT, INSERT, UPDATE ON public.site_settings TO authenticated;
GRANT ALL ON public.site_settings TO service_role;
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "settings_public_read" ON public.site_settings FOR SELECT USING (true);
CREATE POLICY "settings_admin_write" ON public.site_settings FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

INSERT INTO public.site_settings (id) VALUES (true);

-- seed content
INSERT INTO public.categories (id, name, slug, description) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Blog', 'blog', 'Zápisky z redakce'),
  ('22222222-2222-2222-2222-222222222222', 'Životní styl', 'zivotni-styl', 'Rutiny, návyky a pomalé ráno'),
  ('33333333-3333-3333-3333-333333333333', 'Cestování', 'cestovani', 'Pomalé cesty po Evropě');

INSERT INTO public.tags (id, name, slug) VALUES
  ('aaaaaaa1-0000-0000-0000-000000000001', 'blog', 'blog'),
  ('aaaaaaa1-0000-0000-0000-000000000002', 'cesty', 'cesty'),
  ('aaaaaaa1-0000-0000-0000-000000000003', 'inspirace', 'inspirace'),
  ('aaaaaaa1-0000-0000-0000-000000000004', 'recepty', 'recepty');

INSERT INTO public.posts (id, title, slug, excerpt, content, category_id, status, published_at, views, reading_minutes) VALUES
  ('bbbbbbb1-0000-0000-0000-000000000001', 'Jak napsat článek, který lidé skutečně čtou', 'jak-napsat-clanek', 'Dobrý text nevzniká delším psaním, ale kratším škrtáním. Praktický postup od první věty k publikaci.', E'Dobrý text nevzniká delším psaním, ale kratším škrtáním.\n\nZačněte otázkou, kterou má článek zodpovědět. Napište odpověď jednou větou a teprve potom hledejte cestu, jak k ní čtenáře dovést.\n\n## Struktura, která funguje\n\nJedna myšlenka na odstavec. Krátké věty na začátku, delší až tam, kde už čtenář věří, že se vyplatí zůstat.\n\n## Než stisknete Publikovat\n\nPřečtěte text nahlas. Každé místo, kde se zakoktáte, je místo ke škrtání.', '11111111-1111-1111-1111-111111111111', 'published', now() - interval '2 days', 1240, 2),
  ('bbbbbbb1-0000-0000-0000-000000000002', 'Rutiny rána, které změní váš týden', 'rutiny-rana', 'Nemusíte vstávat v pět. Stačí tři drobnosti, které si ráno nastavíte a pak už nemusíte řešit.', E'Nemusíte vstávat v pět.\n\nStačí tři drobnosti, které si nastavíte večer a ráno už o nich nerozhodujete: sklenice vody, deset minut bez telefonu, jedna věta do zápisníku.\n\n## Proč to funguje\n\nRáno je nejdražší část dne, protože rozhodnutí v něm vydrží nejdéle. Když je uděláte předem, ušetříte energii na práci.', '22222222-2222-2222-2222-222222222222', 'published', now() - interval '6 days', 860, 4),
  ('bbbbbbb1-0000-0000-0000-000000000003', 'Pět důvodů proč cestovat pozvolna', 'cestovat-pozvolna', 'Vlak místo letadla, jeden kraj místo pěti zemí. O tom, jak se z dovolené stane skutečný odpočinek.', E'Vlak místo letadla, jeden kraj místo pěti zemí.\n\nPomalé cestování není o tom, že byste viděli méně. Je o tom, že si víc pamatujete.\n\n## Co si z toho odnesete\n\nMísto seznamu odškrtnutých míst si přivezete pár konkrétních rán, chlebů a rozhovorů.', '33333333-3333-3333-3333-333333333333', 'published', now() - interval '11 days', 2010, 3);

INSERT INTO public.post_tags (post_id, tag_id) VALUES
  ('bbbbbbb1-0000-0000-0000-000000000001', 'aaaaaaa1-0000-0000-0000-000000000001'),
  ('bbbbbbb1-0000-0000-0000-000000000001', 'aaaaaaa1-0000-0000-0000-000000000003'),
  ('bbbbbbb1-0000-0000-0000-000000000002', 'aaaaaaa1-0000-0000-0000-000000000003'),
  ('bbbbbbb1-0000-0000-0000-000000000003', 'aaaaaaa1-0000-0000-0000-000000000002');