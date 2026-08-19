# Bolão SIPATMIN 2026 — Setup (Supabase)

Site: HTML único no GitHub Pages (`https://gabriel2840.github.io/sipatmin-apostas/`).
Dados: tabelas `ap_*` no **mesmo projeto Supabase do placar da gincana**
(`feoxwjsziizfnswqqelt`) — sem conta nova, sem SDK (REST puro, funciona no Wi-Fi da Aura).

> A chave *publishable* no código é pública por design (igual aos outros apps).
> A segurança vem das policies de RLS do `supabase-setup-bolao.sql`.

## Passo único de configuração

1. Painel do Supabase → **SQL Editor** → colar o conteúdo de `supabase-setup-bolao.sql` → **Run**.
   - Cria `ap_times`, `ap_jogos`, `ap_palpites`, as views `ap_contagens`/`ap_ranking`,
     as policies (com os GRANTs — sem eles dá "permission denied") e **já semeia
     os 14 times + 7 jogos da 1ª fase do futebol (19/08/2026)**.
   - Pode rodar mais de uma vez sem duplicar nada.

Não precisa criar usuário: o organizador entra com o **mesmo login do placar**
(`admin.sipatmin` + a senha de sempre). Quem manda é a função `sg_is_admin()` —
líderes comuns conseguem logar, mas o banco recusa qualquer escrita deles em times/jogos.

## Segurança dos palpites (server-side)

- Qualquer pessoa grava/edita palpite **só enquanto o jogo está aberto**:
  não travado, sem resultado e antes de `data_hora` — verificado pelo banco, não pela tela.
- O palpite precisa ser um dos dois times do jogo (ou "Empate", se o jogo permitir).
- Excluir um jogo apaga os palpites dele junto (`on delete cascade`).

## Operação no dia a dia

- **Área do organizador**: link no rodapé → login `admin.sipatmin`.
- Cadastrar **times** (nome + cor) e **jogos** (modalidade ⚽/🏐/⛱️, confronto, data/hora).
- Palpites travam sozinhos no horário; "🔒 Travar agora" antecipa.
- Fim de jogo: selecionar resultado → **🏁 Lançar** (o ranking atualiza p/ todo mundo).
- **⬇ Palpites (CSV)** exporta tudo em formato Excel-BR.

## Consumo no plano free (compartilhado com os outros apps)

- O app **não baixa todos os palpites**: ranking e contagens vêm agregados por views;
  cada aparelho só baixa os próprios palpites. Cada atualização = poucos KB.
- Dados do evento inteiro: < 1 MB de banco. Zero storage (não há fotos).
