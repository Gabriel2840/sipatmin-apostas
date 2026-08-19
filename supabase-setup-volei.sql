-- =====================================================================
-- BOLÃO SIPATMIN 2026 — VÔLEI (fase de grupos)
-- Rodar no SQL Editor (mesmo projeto). Idempotente: pode rodar 2x sem duplicar.
-- Semifinais e final (02/09) dependem dos classificados → cadastrar pelo admin.
-- Obs.: "Manutenção" já existe (futebol) e é reaproveitado no vôlei.
-- =====================================================================

-- ---------- Times do VÔLEI (7 novos + Manutenção reaproveitado) ----------
insert into public.ap_times (id, nome, cor) values
  ('time-jovens-ph',        'Jovens PH',        '#7C3AED'),
  ('time-aguias-do-sertao', 'Águias do Sertão', '#B45309'),
  ('time-bola-na-rede',     'Bola na Rede',     '#0E7490'),
  ('time-gold-rush',        'Gold Rush',        '#CA8A04'),
  ('time-ags-volei',        'AGS Vôlei',        '#DC2626'),
  ('time-adm',              'ADM',              '#334155'),
  ('time-sepat',            'SEPAT',            '#16A34A')
on conflict (id) do nothing;

-- ---------- Jogos do VÔLEI — grupos (19/08 e 26/08, horário local -03) ----------
insert into public.ap_jogos (id, nome, modalidade, time_a, time_b, data_hora, travado, permite_empate, vencedor, ordem) values
  ('jogo-v-1',  'Jogo 1 — Grupos',  'Vôlei', 'Jovens PH',        'Águias do Sertão', '2026-08-19 19:00:00-03', false, false, null, 1),
  ('jogo-v-2',  'Jogo 2 — Grupos',  'Vôlei', 'Bola na Rede',     'Gold Rush',        '2026-08-19 19:30:00-03', false, false, null, 2),
  ('jogo-v-3',  'Jogo 3 — Grupos',  'Vôlei', 'AGS Vôlei',        'ADM',              '2026-08-19 20:00:00-03', false, false, null, 3),
  ('jogo-v-4',  'Jogo 4 — Grupos',  'Vôlei', 'Águias do Sertão', 'Bola na Rede',     '2026-08-19 20:30:00-03', false, false, null, 4),
  ('jogo-v-5',  'Jogo 5 — Grupos',  'Vôlei', 'Gold Rush',        'Jovens PH',        '2026-08-19 21:00:00-03', false, false, null, 5),
  ('jogo-v-6',  'Jogo 6 — Grupos',  'Vôlei', 'SEPAT',            'Manutenção',       '2026-08-19 21:30:00-03', false, false, null, 6),
  ('jogo-v-7',  'Jogo 7 — Grupos',  'Vôlei', 'AGS Vôlei',        'Manutenção',       '2026-08-26 19:00:00-03', false, false, null, 7),
  ('jogo-v-8',  'Jogo 8 — Grupos',  'Vôlei', 'Águias do Sertão', 'Gold Rush',        '2026-08-26 19:30:00-03', false, false, null, 8),
  ('jogo-v-9',  'Jogo 9 — Grupos',  'Vôlei', 'Manutenção',       'ADM',              '2026-08-26 20:00:00-03', false, false, null, 9),
  ('jogo-v-10', 'Jogo 10 — Grupos', 'Vôlei', 'Jovens PH',        'Bola na Rede',     '2026-08-26 20:30:00-03', false, false, null, 10),
  ('jogo-v-11', 'Jogo 11 — Grupos', 'Vôlei', 'SEPAT',            'AGS Vôlei',        '2026-08-26 21:00:00-03', false, false, null, 11),
  ('jogo-v-12', 'Jogo 12 — Grupos', 'Vôlei', 'ADM',              'SEPAT',            '2026-08-26 21:30:00-03', false, false, null, 12)
on conflict (id) do nothing;
