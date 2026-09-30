-- pergamen-seed-cleaned
DELETE FROM public.posts;
DELETE FROM public.categories;
DELETE FROM public.tags;

--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '67124607-dfe1-4345-885c-cbc9c1e70767', 'authenticated', 'authenticated', 'admin2@example.cz', '$2a$10$m0uTps7gYjxQTMK4YhRmp.S1MmS.xyU52P.2jITZCchjXq3ze8G3m', '2026-09-30 10:29:07.972498+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-30 10:29:07.978635+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "67124607-dfe1-4345-885c-cbc9c1e70767", "email": "admin2@example.cz", "display_name": "Admin2", "email_verified": true, "phone_verified": false}', NULL, '2026-09-30 10:29:07.962124+00', '2026-09-30 10:29:07.979965+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '2d33b3c0-0981-4650-865c-f26d243c754b', 'authenticated', 'authenticated', 'admin@example.cz', '$2a$10$lzNvCCMygpCuqBWmYGRrOuSo1Z/ARQFm.Y1W6qUvW9n8BUjJExENW', '2026-09-30 10:28:40.084249+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-30 10:29:30.102609+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "2d33b3c0-0981-4650-865c-f26d243c754b", "email": "admin@example.cz", "display_name": "Admin", "email_verified": true, "phone_verified": false}', NULL, '2026-09-30 10:28:40.078497+00', '2026-09-30 12:43:08.750535+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--


INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('2d33b3c0-0981-4650-865c-f26d243c754b', '2d33b3c0-0981-4650-865c-f26d243c754b', '{"sub": "2d33b3c0-0981-4650-865c-f26d243c754b", "email": "admin@example.cz", "display_name": "Admin", "email_verified": false, "phone_verified": false}', 'email', '2026-09-30 10:28:40.082689+00', '2026-09-30 10:28:40.08271+00', '2026-09-30 10:28:40.08271+00', 'f10b6f75-f428-4cc4-aeed-f6b371eb18ad') ON CONFLICT DO NOTHING;
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('67124607-dfe1-4345-885c-cbc9c1e70767', '67124607-dfe1-4345-885c-cbc9c1e70767', '{"sub": "67124607-dfe1-4345-885c-cbc9c1e70767", "email": "admin2@example.cz", "display_name": "Admin2", "email_verified": false, "phone_verified": false}', 'email', '2026-09-30 10:29:07.969038+00', '2026-09-30 10:29:07.969089+00', '2026-09-30 10:29:07.969089+00', '2d8c368a-bc7d-4bbc-9672-0fdb18f8bd11') ON CONFLICT DO NOTHING;



--
DELETE FROM public.user_roles;
DELETE FROM public.profiles;

-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.categories (id, name, slug, description, created_at) VALUES ('031e1df3-529c-46d1-9d18-53c990727c80', 'Politika', 'politika', '', '2026-09-30 10:33:53.582152+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, name, slug, description, created_at) VALUES ('bfa53ec9-ac92-46fe-9cf9-c875b3a909e0', 'Hrot', 'hrot', '', '2026-09-30 10:34:00.079806+00') ON CONFLICT DO NOTHING;



--
-- Data for Name: media; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.media (id, filename, path, url, mime_type, size_bytes, uploaded_by, created_at) VALUES ('40c73e98-4f5a-4f6a-8f3c-64cc05871a34', 'IMG_9047.jpg', '2d33b3c0-0981-4650-865c-f26d243c754b/1790764248192-IMG_9047.jpg', '/uploads/IMG_9047.jpg', 'image/jpeg', 2980448, '2d33b3c0-0981-4650-865c-f26d243c754b', '2026-09-30 10:30:48.264466+00') ON CONFLICT DO NOTHING;
INSERT INTO public.media (id, filename, path, url, mime_type, size_bytes, uploaded_by, created_at) VALUES ('b2803f05-7ac0-4428-b9db-d4e3e6502414', 'IMG_9046.jpg', '2d33b3c0-0981-4650-865c-f26d243c754b/1790764344406-IMG_9046.jpg', '/uploads/IMG_9046.jpg', 'image/jpeg', 547915, '2d33b3c0-0981-4650-865c-f26d243c754b', '2026-09-30 10:32:24.461365+00') ON CONFLICT DO NOTHING;



--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.posts (id, title, slug, excerpt, content, cover_url, category_id, author_id, status, published_at, views, reading_minutes, created_at, updated_at) VALUES ('1d651013-d3bb-44ea-9d4d-0a3cd8ea1ae9', 'Volby 2026 v Česku: rozhodovat se bude o obcích i Senátu', 'volby-2026-v-cesku-rozhodovat-se-bude-o-obcich-i-senatu', '', 'Českou republiku čekají v říjnu 2026 další významné volby. V pátek 9. a v sobotu 10. října budou voliči vybírat nové zastupitele obcí a zároveň se uskuteční první kolo voleb do jedné třetiny Senátu Parlamentu České republiky. Pokud bude v některém senátním obvodu nutné druhé kolo, proběhne o týden později, tedy 16. a 17. října. (⁠Statistika)

Komunální volby budou rozhodovat o podobě měst a obcí

Komunální volby jsou pro mnoho lidí nejbližší částí volebního procesu. Voliči v nich rozhodují o složení zastupitelstev měst a obcí, která následně ovlivňují například místní rozvoj, hospodaření obce, veřejný prostor nebo další otázky každodenního života.

Český statistický úřad zveřejnil kandidátní listiny pro letošní volby a údaje jsou průběžně aktualizovány. Oficiální registr obsahuje jména kandidátů, jejich věk, kandidátní listinu, politickou příslušnost, povolání a bydliště. (⁠Statistika a My)

Volby do Senátu

Ve stejném termínu se bude rozhodovat také o třetině Senátu. Senátní volby mají dvoukolový systém. Pokud žádný kandidát v prvním kole nezíská potřebnou většinu, dva nejúspěšnější postupují do druhého kola, které se uskuteční následující týden. (⁠Statistika)

Senát je horní komorou Parlamentu České republiky. Jeho členové jsou voleni na šest let, přičemž každé dva roky se obměňuje přibližně třetina jeho složení.

Jméno Lukáš Hlobil

V souvislosti s volebním rokem 2026 se může ve veřejných debatách objevovat také jméno Lukáš Hlobil. Dostupná oficiální volební data, která jsem ověřoval, však nepotvrzují jeho kandidaturu v letošních komunálních nebo senátních volbách. Proto nelze bez dalšího zdroje tvrdit, že je kandidátem nebo že zastupuje konkrétní politické uskupení.

Pro přesné informace o kandidátech je rozhodující oficiální registr kandidátních listin a jmenné seznamy zveřejněné volebními orgány. (⁠Volby)

Co budou voliči sledovat

Říjnové volby nabídnou možnost rozhodovat jak o místní politice, tak o části složení Senátu. U komunálních voleb bude důležitým tématem především směřování jednotlivých měst a obcí, zatímco u senátních voleb budou voliči vybírat své zástupce v konkrétních volebních obvodech.

Podle oficiálních informací Ministerstva vnitra jsou volby do zastupitelstev obcí a Senátu vyhlášeny na 9. a 10. října 2026. (⁠Ministerstvo vnitra České republiky)

Volby tak budou patřit k nejvýznamnějším politickým událostem podzimu 2026. O jejich výsledku rozhodnou voliči v jednotlivých obcích a senátních obvodech.', '/uploads/IMG_9046.jpg', '031e1df3-529c-46d1-9d18-53c990727c80', '2d33b3c0-0981-4650-865c-f26d243c754b', 'published', '2026-09-30 10:34:12.507+00', 0, 3, '2026-09-30 10:33:00.558102+00', '2026-09-30 10:34:12.518956+00') ON CONFLICT DO NOTHING;
INSERT INTO public.posts (id, title, slug, excerpt, content, cover_url, category_id, author_id, status, published_at, views, reading_minutes, created_at, updated_at) VALUES ('10a9460b-fa3b-4f64-9148-7b7a490a8fea', 'DRAMA V S4C: Kluci během vyučování spustili počítačové hry!', 'drama-v-s4c-kluci-behem-vyucovani-spustili-pocitacove-hry', 'Napětí v učebně by se dalo krájet. Místo soustředění na výklad se během vyučování rozběhla úplně jiná mise – počítačové hry!', 'Byla to obyčejná hodina. Učitel vysvětloval látku, ve třídě bylo na první pohled ticho a všechno vypadalo, že probíhá přesně podle plánu. Jenže potom se ozvalo známé cvaknutí klávesnice.

Kluci ze S4C se totiž rozhodli, že dnešní hodina bude mít poněkud jiný program.

Jeden počítač se rozsvítil. Potom další. A během několika okamžiků se z nenápadného vyučování začala stávat pořádná herní bitva. Na obrazovkách se objevily počítačové hry a soustředění studentů se rázem přesunulo z učebnice na monitory.

„Hlavně ať nás nevidí!“

Napětí postupně rostlo. Každý zvuk z chodby mohl znamenat konec celé akce. Stačilo jediné otevření dveří a herní mise mohla být okamžitě odhalena.

Klávesnice cvakaly, myši se pohybovaly neuvěřitelnou rychlostí a hráči se snažili zachovat naprostý klid.

Jenže ve třídě se začalo schylovat k nevyhnutelnému.

Učitel se otočil.

Na několik sekund zavládlo absolutní ticho.

Někteří hráči okamžitě přepnuli obrazovky zpět. Jiní se snažili tvářit, že se vůbec nic neděje. Atmosféra připomínala scénu z akčního filmu.

Byli odhaleni?

To už je otázka, která zůstává mezi stěnami učebny S4C.

Jedno je ale jisté: na tuto hodinu kluci jen tak nezapomenou.

A pokud se příště během vyučování ozve podezřelé cvakání klávesnice, všichni už budou vědět, co se pravděpodobně děje.

S4C totiž ukázala, že i obyčejná hodina může během několika sekund změnit atmosféru na pořádné herní drama.', '/uploads/IMG_9047.jpg', 'bfa53ec9-ac92-46fe-9cf9-c875b3a909e0', '2d33b3c0-0981-4650-865c-f26d243c754b', 'published', '2026-09-30 10:34:23.488+00', 0, 3, '2026-09-30 10:32:15.026528+00', '2026-09-30 10:34:23.503001+00') ON CONFLICT DO NOTHING;



--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.tags (id, name, slug, created_at) VALUES ('5d38984b-ac2d-4843-a890-865f859800e9', 'S4C', 's4c', '2026-09-30 10:33:21.506457+00') ON CONFLICT DO NOTHING;
INSERT INTO public.tags (id, name, slug, created_at) VALUES ('062f0f2a-3b2c-4206-89d1-64a16c1110eb', 'Drama', 'drama', '2026-09-30 10:33:24.916197+00') ON CONFLICT DO NOTHING;
INSERT INTO public.tags (id, name, slug, created_at) VALUES ('65e391d8-0d07-461a-ba51-04e358a4abc8', 'Politika', 'politika', '2026-09-30 10:33:29.34517+00') ON CONFLICT DO NOTHING;
INSERT INTO public.tags (id, name, slug, created_at) VALUES ('4c2982e4-403b-44ae-9083-74c5c552d3dd', 'Volby 2026', 'volby-2026', '2026-09-30 10:33:47.416123+00') ON CONFLICT DO NOTHING;



--
-- Data for Name: post_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.post_tags (post_id, tag_id) VALUES ('1d651013-d3bb-44ea-9d4d-0a3cd8ea1ae9', '65e391d8-0d07-461a-ba51-04e358a4abc8') ON CONFLICT DO NOTHING;
INSERT INTO public.post_tags (post_id, tag_id) VALUES ('1d651013-d3bb-44ea-9d4d-0a3cd8ea1ae9', '4c2982e4-403b-44ae-9083-74c5c552d3dd') ON CONFLICT DO NOTHING;
INSERT INTO public.post_tags (post_id, tag_id) VALUES ('10a9460b-fa3b-4f64-9148-7b7a490a8fea', '5d38984b-ac2d-4843-a890-865f859800e9') ON CONFLICT DO NOTHING;
INSERT INTO public.post_tags (post_id, tag_id) VALUES ('10a9460b-fa3b-4f64-9148-7b7a490a8fea', '062f0f2a-3b2c-4206-89d1-64a16c1110eb') ON CONFLICT DO NOTHING;



--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.profiles (id, display_name, bio, avatar_url, created_at) VALUES ('2d33b3c0-0981-4650-865c-f26d243c754b', 'Admin', '', NULL, '2026-09-30 10:28:40.078232+00') ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (id, display_name, bio, avatar_url, created_at) VALUES ('67124607-dfe1-4345-885c-cbc9c1e70767', 'Admin2', '', NULL, '2026-09-30 10:29:07.961817+00') ON CONFLICT DO NOTHING;



--
-- Data for Name: site_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.site_settings (id, site_title, tagline, description, footer_text, posts_per_page, updated_at) VALUES (true, 'Pergamen', 'Blog o psaní, designu a pomalém životě', 'Redakční systém Pergamen — články, kategorie a médiová knihovna na jednom místě.', '© Pergamen', 10, '2026-09-30 10:24:10.885298+00') ON CONFLICT DO NOTHING;



--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO public.user_roles (id, user_id, role) VALUES ('a97510e1-c74c-433c-90fd-776142c80613', '2d33b3c0-0981-4650-865c-f26d243c754b', 'admin') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('c2531e8c-2c37-43aa-b1b7-d0f10442addf', '2d33b3c0-0981-4650-865c-f26d243c754b', 'editor') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('5a30b731-bf6d-4806-91df-0b37fb9c9257', '2d33b3c0-0981-4650-865c-f26d243c754b', 'author') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('b8436654-97f4-4c3c-a964-8ee443f50f5a', '2d33b3c0-0981-4650-865c-f26d243c754b', 'proofreader') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('68fa9e0f-012b-46d4-9910-3c942b41001d', '2d33b3c0-0981-4650-865c-f26d243c754b', 'photographer') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('13eab028-312c-4bcd-b710-3fb8a57b76d4', '67124607-dfe1-4345-885c-cbc9c1e70767', 'author') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('e8f1646e-2395-425e-9492-e0da018725d6', '67124607-dfe1-4345-885c-cbc9c1e70767', 'editor') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('242811d2-355f-40e4-9745-c48703111c40', '67124607-dfe1-4345-885c-cbc9c1e70767', 'proofreader') ON CONFLICT DO NOTHING;
INSERT INTO public.user_roles (id, user_id, role) VALUES ('2c748043-cd73-46ae-9513-d9e417dd49e9', '67124607-dfe1-4345-885c-cbc9c1e70767', 'photographer') ON CONFLICT DO NOTHING;



--
-- PostgreSQL database dump complete
--


