-- =====================================================================
-- BOLÃO SIPATMIN 2026 — MIGRAÇÃO v3: operador de resultados + placar
--   1) Perfil "lançador de resultados": conta que SÓ pode lançar/limpar
--      resultado, travar/reabrir jogo e informar o placar. Não cria nem
--      apaga jogos, não mexe em times, e não tem NENHUM acesso ao placar
--      da gincana (sg_*).
--   2) Placar opcional do jogo (ex.: 3 × 1) — só informativo.
-- Rodar no SQL Editor DEPOIS da migração v2. Idempotente.
-- DICA: feche as abas do bolão antes de rodar (evita o deadlock de novo).
-- =====================================================================

-- ---------- Placar opcional ----------
alter table public.ap_jogos add column if not exists placar_a int;
alter table public.ap_jogos add column if not exists placar_b int;

-- ---------- Tabela de operadores de resultado ----------
create table if not exists public.ap_operadores (
  user_id uuid primary key,
  login   text not null
);
alter table public.ap_operadores enable row level security;

drop policy if exists ap_operadores_admin on public.ap_operadores;
create policy ap_operadores_admin on public.ap_operadores
  for all to authenticated using (public.sg_is_admin()) with check (public.sg_is_admin());

-- cada um pode ver a própria linha (o site usa isso p/ mostrar o modo certo)
drop policy if exists ap_operadores_self on public.ap_operadores;
create policy ap_operadores_self on public.ap_operadores
  for select to authenticated using (user_id = auth.uid());

grant select on public.ap_operadores to authenticated;

-- ---------- Quem pode lançar resultado: admin OU operador ----------
create or replace function public.ap_pode_lancar() returns boolean
language sql security definer set search_path = public as $$
  select public.sg_is_admin()
      or exists (select 1 from public.ap_operadores o where o.user_id = auth.uid());
$$;

drop policy if exists ap_jogos_resultado on public.ap_jogos;
create policy ap_jogos_resultado on public.ap_jogos
  for update to authenticated
  using (public.ap_pode_lancar())
  with check (public.ap_pode_lancar());

-- ---------- Trava de colunas: operador só mexe em resultado/trava/placar ----------
create or replace function public.ap_guarda_jogos() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  -- vencedor precisa ser válido para o confronto (vale para todos)
  if new.vencedor is not null
     and new.vencedor not in (new.time_a, new.time_b)
     and not (new.vencedor = 'Empate' and new.permite_empate) then
    raise exception 'Vencedor inválido para este jogo';
  end if;
  if public.sg_is_admin() then
    return new;
  end if;
  if new.id is distinct from old.id
     or new.nome is distinct from old.nome
     or new.modalidade is distinct from old.modalidade
     or new.time_a is distinct from old.time_a
     or new.time_b is distinct from old.time_b
     or new.data_hora is distinct from old.data_hora
     or new.permite_empate is distinct from old.permite_empate
     or new.ordem is distinct from old.ordem
     or new.pontos is distinct from old.pontos then
    raise exception 'Operador de resultados só pode alterar vencedor, trava e placar';
  end if;
  return new;
end $$;

drop trigger if exists ap_guarda_jogos_tg on public.ap_jogos;
create trigger ap_guarda_jogos_tg
  before update on public.ap_jogos
  for each row execute function public.ap_guarda_jogos();

-- =====================================================================
-- COMO CADASTRAR O PRESIDENTE (2 passos, depois de rodar o script acima):
--   1) Ele cria a conta NO PRÓPRIO SITE (botão "Criar conta"), com o login
--      combinado — ex.: presidente.resultados — e uma senha dele.
--   2) Você roda o insert abaixo (troque o login se usar outro):
--
-- insert into public.ap_operadores (user_id, login)
-- select id, 'presidente.resultados'
--   from auth.users
--  where email = 'presidente.resultados@bolao.sipatmin'
-- on conflict (user_id) do nothing;
--
-- Para revogar o acesso: delete from public.ap_operadores where login = '...';
-- =====================================================================
