-- =====================================================================
-- BOLÃO SIPATMIN 2026 — BEACH TENNIS MISTO (I Copa Ouro)
-- Fase de grupos: 02/09/2026, 19h00–21h00, 2 quadras, jogos de 20 min.
-- Rodar no SQL Editor (mesmo projeto). Idempotente: pode rodar 2x sem duplicar.
-- Semifinais (21h00, cruzadas) e Grande Final (21h20) dependem dos
-- classificados → cadastrar pelo painel admin na hora.
-- =====================================================================

-- ---------- As 8 duplas ----------
insert into public.ap_times (id, nome, cor) values
  -- Grupo A
  ('time-georgia-alexandre',  'Geórgia Luyse & Alexandre Otávio',        '#2563EB'),
  ('time-icaro-palloma',      'Ícaro Noberto & Palloma Abdias',          '#DB2777'),
  ('time-meirilaine-bernard', 'Meirilaine Silveira & Bernard Frankó',    '#059669'),
  ('time-maryanne-rodrigo',   'Maryanne Costa & Rodrigo Galdino',        '#D97706'),
  -- Grupo B
  ('time-hellany-emanuel',    'Hellany Cybelle & Emanuel Carlos Araújo', '#7C2D12'),
  ('time-sirleya-irineu',     'Sirleya & Irineu Alex',                   '#4F46E5'),
  ('time-mirtes-renan',       'Mirtes Gurge & Renan Rodrigues da Silva', '#0D9488'),
  ('time-igor-karoline',      'Igor Gomes & Karoline Ribas',             '#9333EA')
on conflict (id) do nothing;

-- ---------- Fase de grupos — 02/09/2026 (horário local -03) ----------
insert into public.ap_jogos (id, nome, modalidade, time_a, time_b, data_hora, travado, permite_empate, vencedor, ordem) values
  ('jogo-bt-1',  'Jogo 1 — Grupo A · Quadra 1',  'Beach Tennis', 'Geórgia Luyse & Alexandre Otávio',        'Ícaro Noberto & Palloma Abdias',          '2026-09-02 19:00:00-03', false, false, null, 1),
  ('jogo-bt-2',  'Jogo 2 — Grupo A · Quadra 2',  'Beach Tennis', 'Meirilaine Silveira & Bernard Frankó',    'Maryanne Costa & Rodrigo Galdino',        '2026-09-02 19:00:00-03', false, false, null, 2),
  ('jogo-bt-3',  'Jogo 3 — Grupo B · Quadra 1',  'Beach Tennis', 'Hellany Cybelle & Emanuel Carlos Araújo', 'Sirleya & Irineu Alex',                   '2026-09-02 19:20:00-03', false, false, null, 3),
  ('jogo-bt-4',  'Jogo 4 — Grupo B · Quadra 2',  'Beach Tennis', 'Mirtes Gurge & Renan Rodrigues da Silva', 'Igor Gomes & Karoline Ribas',             '2026-09-02 19:20:00-03', false, false, null, 4),
  ('jogo-bt-5',  'Jogo 5 — Grupo A · Quadra 1',  'Beach Tennis', 'Geórgia Luyse & Alexandre Otávio',        'Meirilaine Silveira & Bernard Frankó',    '2026-09-02 19:40:00-03', false, false, null, 5),
  ('jogo-bt-6',  'Jogo 6 — Grupo A · Quadra 2',  'Beach Tennis', 'Ícaro Noberto & Palloma Abdias',          'Maryanne Costa & Rodrigo Galdino',        '2026-09-02 19:40:00-03', false, false, null, 6),
  ('jogo-bt-7',  'Jogo 7 — Grupo B · Quadra 1',  'Beach Tennis', 'Hellany Cybelle & Emanuel Carlos Araújo', 'Mirtes Gurge & Renan Rodrigues da Silva', '2026-09-02 20:00:00-03', false, false, null, 7),
  ('jogo-bt-8',  'Jogo 8 — Grupo B · Quadra 2',  'Beach Tennis', 'Sirleya & Irineu Alex',                   'Igor Gomes & Karoline Ribas',             '2026-09-02 20:00:00-03', false, false, null, 8),
  ('jogo-bt-9',  'Jogo 9 — Grupo A · Quadra 1',  'Beach Tennis', 'Geórgia Luyse & Alexandre Otávio',        'Maryanne Costa & Rodrigo Galdino',        '2026-09-02 20:20:00-03', false, false, null, 9),
  ('jogo-bt-10', 'Jogo 10 — Grupo A · Quadra 2', 'Beach Tennis', 'Ícaro Noberto & Palloma Abdias',          'Meirilaine Silveira & Bernard Frankó',    '2026-09-02 20:20:00-03', false, false, null, 10),
  ('jogo-bt-11', 'Jogo 11 — Grupo B · Quadra 1', 'Beach Tennis', 'Hellany Cybelle & Emanuel Carlos Araújo', 'Igor Gomes & Karoline Ribas',             '2026-09-02 20:40:00-03', false, false, null, 11),
  ('jogo-bt-12', 'Jogo 12 — Grupo B · Quadra 2', 'Beach Tennis', 'Sirleya & Irineu Alex',                   'Mirtes Gurge & Renan Rodrigues da Silva', '2026-09-02 20:40:00-03', false, false, null, 12)
on conflict (id) do nothing;
