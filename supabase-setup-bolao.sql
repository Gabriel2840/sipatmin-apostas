-- =====================================================================
-- BOLÃO SIPATMIN 2026 — setup completo
-- Rodar no SQL Editor do painel Supabase (projeto feoxwjsziizfnswqqelt,
-- o mesmo do placar da gincana). Idempotente: pode rodar mais de uma vez.
-- Já semeia os 14 times e os 7 jogos da 1ª fase do futebol (19/08/2026).
-- =====================================================================

-- ---------- Tabelas ----------
create table if not exists public.ap_times (
  id   text primary key,
  nome text not null unique,
  cor  text not null default '#3560B0'
);

create table if not exists public.ap_jogos (
  id             text primary key,
  nome           text not null,
  modalidade     text not null default 'Futebol',
  time_a         text not null,
  time_b         text not null,
  data_hora      timestamptz not null,
  travado        boolean not null default false,
  permite_empate boolean not null default false,
  vencedor       text,
  ordem          int not null default 0
);

create table if not exists public.ap_palpites (
  id            text primary key,
  jogo_id       text not null references public.ap_jogos(id) on delete cascade,
  nome          text not null,
  palpite       text not null,
  atualizado_em timestamptz not null default now()
);

-- ---------- RLS ----------
alter table public.ap_times    enable row level security;
alter table public.ap_jogos    enable row level security;
alter table public.ap_palpites enable row level security;

-- Times e jogos: todo mundo lê; só o admin da gincana (sg_is_admin) escreve
drop policy if exists ap_times_select on public.ap_times;
create policy ap_times_select on public.ap_times
  for select to anon, authenticated using (true);

drop policy if exists ap_times_admin on public.ap_times;
create policy ap_times_admin on public.ap_times
  for all to authenticated using (public.sg_is_admin()) with check (public.sg_is_admin());

drop policy if exists ap_jogos_select on public.ap_jogos;
create policy ap_jogos_select on public.ap_jogos
  for select to anon, authenticated using (true);

drop policy if exists ap_jogos_admin on public.ap_jogos;
create policy ap_jogos_admin on public.ap_jogos
  for all to authenticated using (public.sg_is_admin()) with check (public.sg_is_admin());

-- Palpites: todo mundo lê; qualquer pessoa grava o seu, mas SÓ enquanto o
-- jogo está aberto (não travado, sem resultado, antes do horário) e com
-- palpite válido para aquele confronto. A trava vale no SERVIDOR, não só na tela.
drop policy if exists ap_palpites_select on public.ap_palpites;
create policy ap_palpites_select on public.ap_palpites
  for select to anon, authenticated using (true);

drop policy if exists ap_palpites_insert on public.ap_palpites;
create policy ap_palpites_insert on public.ap_palpites
  for insert to anon, authenticated
  with check (
    char_length(nome) between 5 and 60
    and char_length(id) <= 160
    and exists (
      select 1 from public.ap_jogos j
      where j.id = jogo_id
        and j.travado = false
        and j.vencedor is null
        and j.data_hora > now()
        and (palpite = j.time_a or palpite = j.time_b
             or (palpite = 'Empate' and j.permite_empate))
    )
  );

drop policy if exists ap_palpites_update on public.ap_palpites;
create policy ap_palpites_update on public.ap_palpites
  for update to anon, authenticated
  using (
    exists (
      select 1 from public.ap_jogos j
      where j.id = jogo_id and j.travado = false
        and j.vencedor is null and j.data_hora > now()
    )
  )
  with check (
    char_length(nome) between 5 and 60
    and exists (
      select 1 from public.ap_jogos j
      where j.id = jogo_id
        and j.travado = false
        and j.vencedor is null
        and j.data_hora > now()
        and (palpite = j.time_a or palpite = j.time_b
             or (palpite = 'Empate' and j.permite_empate))
    )
  );

drop policy if exists ap_palpites_admin on public.ap_palpites;
create policy ap_palpites_admin on public.ap_palpites
  for all to authenticated using (public.sg_is_admin()) with check (public.sg_is_admin());

-- ---------- Views agregadas (economia de tráfego: o app não baixa todos os palpites) ----------
create or replace view public.ap_contagens with (security_invoker = true) as
  select jogo_id, count(*)::int as n
  from public.ap_palpites
  group by jogo_id;

create or replace view public.ap_ranking with (security_invoker = true) as
  select p.nome,
         j.modalidade,
         count(*) filter (where j.vencedor is not null and j.vencedor = p.palpite)::int as acertos,
         count(*)::int as dados
  from public.ap_palpites p
  join public.ap_jogos j on j.id = p.jogo_id
  group by p.nome, j.modalidade;

-- ---------- GRANTS (sem isto o RLS sozinho dá "permission denied") ----------
grant usage on schema public to anon, authenticated;
grant select on public.ap_times, public.ap_jogos, public.ap_palpites,
                public.ap_contagens, public.ap_ranking to anon, authenticated;
grant insert, update on public.ap_palpites to anon, authenticated;
grant insert, update, delete on public.ap_times, public.ap_jogos, public.ap_palpites to authenticated;

-- ---------- Seed: 14 times do futebol ----------
insert into public.ap_times (id, nome, cor) values
  ('time-sk',                             'SK',                              '#3560B0'),
  ('time-g3-iii-letra-c',                 'G3 III – Letra C',                '#12B76A'),
  ('time-a-v-united',                     'A.V United',                      '#FF6A00'),
  ('time-operacao-planta-ii-filtragem',   'Operação Planta II (Filtragem)',  '#8B5CF6'),
  ('time-ph',                             'PH',                              '#E5484D'),
  ('time-mina',                           'Mina',                            '#0EA5B7'),
  ('time-operacao-planta-i',              'Operação Planta I',               '#D4A017'),
  ('time-abracadeira-de-ouro-vipetro',    'Abraçadeira de Ouro (VIPETRO)',   '#EC4899'),
  ('time-administrativo',                 'Administrativo',                  '#2E7D32'),
  ('time-g3-i-letra-a',                   'G3 I – Letra A',                  '#795548'),
  ('time-parex',                          'PAREX',                           '#607D8B'),
  ('time-g3-ii-letra-b',                  'G3 II – Letra B',                 '#9E9D24'),
  ('time-maron',                          'Maron',                           '#800000'),
  ('time-manutencao',                     'Manutenção',                      '#1F6FEB')
on conflict (id) do nothing;

-- ---------- Seed: 7 jogos da 1ª fase (19/08/2026, horário local -03) ----------
-- Mata-mata: sem empate. Quartas/semi/final entram depois pelo painel admin.
insert into public.ap_jogos (id, nome, modalidade, time_a, time_b, data_hora, travado, permite_empate, vencedor, ordem) values
  ('jogo-f1-1', 'Jogo 1 — 1ª fase', 'Futebol', 'SK',                'G3 III – Letra C',               '2026-08-19 19:00:00-03', false, false, null, 1),
  ('jogo-f1-2', 'Jogo 2 — 1ª fase', 'Futebol', 'A.V United',        'Operação Planta II (Filtragem)', '2026-08-19 19:30:00-03', false, false, null, 2),
  ('jogo-f1-3', 'Jogo 3 — 1ª fase', 'Futebol', 'PH',                'Mina',                           '2026-08-19 20:00:00-03', false, false, null, 3),
  ('jogo-f1-4', 'Jogo 4 — 1ª fase', 'Futebol', 'Operação Planta I', 'Abraçadeira de Ouro (VIPETRO)',  '2026-08-19 20:30:00-03', false, false, null, 4),
  ('jogo-f1-5', 'Jogo 5 — 1ª fase', 'Futebol', 'Administrativo',    'G3 I – Letra A',                 '2026-08-19 21:00:00-03', false, false, null, 5),
  ('jogo-f1-6', 'Jogo 6 — 1ª fase', 'Futebol', 'PAREX',             'G3 II – Letra B',                '2026-08-19 21:30:00-03', false, false, null, 6),
  ('jogo-f1-7', 'Jogo 7 — 1ª fase', 'Futebol', 'Maron',             'Manutenção',                     '2026-08-19 22:00:00-03', false, false, null, 7)
on conflict (id) do nothing;
