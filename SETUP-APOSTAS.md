# Bolão SIPATMIN 2026 — Setup do backend (Firebase)

O site é um HTML único hospedado no GitHub Pages. Os dados (times, jogos, palpites)
ficam no **Firestore** de um projeto Firebase **próprio do bolão** — separado do
Supabase do placar e de qualquer outro app. Enquanto o Firebase não for configurado,
o site roda em **modo demonstração** (dados só no aparelho de quem abre).

> A `apiKey` do Firebase **não é segredo** — é um identificador público de projeto.
> A segurança real vem das *Security Rules* abaixo. Nenhuma senha fica no código.

## Passo 1 — Criar o projeto (≈5 min, no seu login Google)

1. Acesse https://console.firebase.google.com e clique em **Adicionar projeto**.
2. Nome: `bolao-sipatmin` (ou outro). **Desative** o Google Analytics (não precisa).
3. Criado o projeto, no menu lateral: **Criação (Build) → Firestore Database → Criar banco de dados**.
   - Local: `southamerica-east1` (São Paulo).
   - Modo: pode escolher qualquer um — as regras do Passo 2 substituem.

## Passo 2 — Colar as Security Rules

Em **Firestore Database → Regras (Rules)**, apague tudo e cole:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Times e jogos: todo mundo lê, só o organizador logado escreve
    match /ap_times/{id} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /ap_jogos/{id} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Palpites: todo mundo lê; qualquer pessoa cria/atualiza o seu,
    // mas SÓ enquanto o jogo está aberto (não travado, sem resultado,
    // antes do horário) e com um palpite válido para aquele jogo.
    match /ap_palpites/{id} {
      allow read: if true;
      allow write: if request.auth != null; // organizador pode corrigir/excluir
      allow create, update: if
        request.resource.data.keys().hasOnly(['jogoId','nome','palpite','atualizadoEm']) &&
        request.resource.data.jogoId is string &&
        request.resource.data.nome is string &&
        request.resource.data.nome.size() >= 5 &&
        request.resource.data.nome.size() <= 60 &&
        request.resource.data.palpite is string &&
        get(/databases/$(database)/documents/ap_jogos/$(request.resource.data.jogoId)).data.travado == false &&
        get(/databases/$(database)/documents/ap_jogos/$(request.resource.data.jogoId)).data.vencedor == null &&
        request.time < get(/databases/$(database)/documents/ap_jogos/$(request.resource.data.jogoId)).data.dataHora &&
        (
          request.resource.data.palpite == get(/databases/$(database)/documents/ap_jogos/$(request.resource.data.jogoId)).data.timeA ||
          request.resource.data.palpite == get(/databases/$(database)/documents/ap_jogos/$(request.resource.data.jogoId)).data.timeB ||
          (
            request.resource.data.palpite == 'Empate' &&
            get(/databases/$(database)/documents/ap_jogos/$(request.resource.data.jogoId)).data.permiteEmpate == true
          )
        );
    }
  }
}
```

Clique em **Publicar**.

Com isso o servidor recusa palpite fora de hora mesmo que alguém tente burlar o site
(a trava não é só visual).

## Passo 3 — Criar a conta do organizador

1. Menu lateral: **Criação (Build) → Authentication → Vamos começar**.
2. Aba **Sign-in method**: ative **E-mail/senha** (só a primeira chave; deixe "link por e-mail" desligado).
3. Aba **Users → Adicionar usuário**: crie o organizador, por exemplo
   `admin@bolao.sipatmin` + uma senha forte que só você saiba.
   (O e-mail não precisa existir de verdade — é só o login.)

## Passo 4 — Pegar a configuração e me mandar

1. Engrenagem ⚙ (canto superior esquerdo) → **Configurações do projeto**.
2. Seção **Seus aplicativos** → ícone **`</>` (Web)** → registre um app (nome livre, sem Hosting).
3. Vai aparecer um bloco `firebaseConfig`. Só preciso de **2 valores**:
   - `apiKey`
   - `projectId`
4. Me mande os dois no chat que eu coloco no site e publico a versão final.

## Operação no dia a dia

- **Área do organizador**: link "área do organizador" no rodapé do site → login do Passo 3.
- Cadastre os **times** (nome + cor), depois os **jogos** (modalidade ⚽/🏐/⛱️, confronto, data/hora).
- Palpites **travam sozinhos** no horário do jogo; o botão "🔒 Travar agora" antecipa.
- Terminou o jogo: escolha o resultado no seletor e clique **🏁 Lançar** — o ranking atualiza para todo mundo.
- **⬇ Palpites (CSV)** exporta tudo em formato Excel-BR.

## Limites do plano gratuito (Spark) — folga enorme

- 50.000 leituras/dia · 20.000 gravações/dia · 1 GB de armazenamento.
- Cenário de pico (500 pessoas × 4 acessos/dia): ~20 mil leituras/dia → menos da metade do limite.
- Palpites são texto puro: o evento inteiro ocupa < 1 MB.
