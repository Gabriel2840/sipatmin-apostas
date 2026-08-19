-- =====================================================================
-- BOLÃO SIPATMIN 2026 — MIGRAÇÃO v2: pontos por jogo + login obrigatório
-- Regras novas:
--   1) Acertar o vencedor vale os PONTOS do jogo (padrão 10; semifinal 30 —
--      o admin define ao cadastrar).
--   2) Palpite exige CONTA (login nome.setor + senha). Cada palpite fica
--      amarrado à conta — ninguém palpita em nome de outra pessoa.
-- Rodar no SQL Editor DEPOIS do supabase-setup-bolao.sql. Idempotente.
-- =====================================================================

-- ---------- 1. Pontos por jogo ----------
alter table public.ap_jogos
  add column if not exists pontos int not null default 10;

-- Recria a view do ranking somando pontos (drop+create pois a coluna nova
-- entra no meio; view é só uma consulta, nenhum dado é apagado)
drop view if exists public.ap_ranking;
create view public.ap_ranking with (security_invoker = true) as
  select p.nome,
         j.modalidade,
         coalesce(sum(j.pontos) filter (where j.vencedor is not null and j.vencedor = p.palpite), 0)::int as pontos,
         count(*) filter (where j.vencedor is not null and j.vencedor = p.palpite)::int as acertos,
         count(*)::int as dados
  from public.ap_palpites p
  join public.ap_jogos j on j.id = p.jogo_id
  group by p.nome, j.modalidade;

grant select on public.ap_ranking to anon, authenticated;

-- ---------- 2. Palpite amarrado à conta ----------
-- Limpa os palpites de teste (conferido em 2026-08-19: só existe 1, do Claude)
delete from public.ap_palpites;

alter table public.ap_palpites
  add column if not exists user_id uuid not null default auth.uid();

-- Só usuário logado cria/edita palpite, e só o PRÓPRIO
drop policy if exists ap_palpites_insert on public.ap_palpites;
create policy ap_palpites_insert on public.ap_palpites
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and char_length(nome) between 3 and 60
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
  for update to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and char_length(nome) between 3 and 60
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

-- Anônimo agora só lê
revoke insert, update on public.ap_palpites from anon;
