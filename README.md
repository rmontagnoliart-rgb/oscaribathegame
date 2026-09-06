# Oscaribas — Board Game Web

Protótipo jogável do Oscaribas em HTML/CSS/JS puro (sem build step), pensado para
tablet. Hospedado na Vercel como site estático.

As regras completas ficam em [`RULES.md`](RULES.md) — é o manual oficial (setembro/2026),
usado como referência ao mexer em qualquer lógica de jogo.

## Estrutura

```
index.html              Todo o jogo: markup, CSS e lógica (single-page app)
assets/
  board/                 Arte de fundo do tabuleiro, uma por estação
    tabuleiro-primavera.jpg
    tabuleiro-verao.jpg
    tabuleiro-outono.jpg
    tabuleiro-inverno.jpg
  img/                    Ícones e arte solta do tabuleiro
    dragon.png            Emblema do dragão no ninho
    shock.png              Ilustração de "raio" (evento Tempestade)
    village.png             Medalhão redondo de vilarejo
    drop.png                 Gota de marcador de umidade
  ficha/                  Cartas das fichas do Ninho (manual novo, setembro/2026)
    ficha-ovo.webp          Frente "Ovo de Dragão"
    ficha-esterco.webp       Frente "Cocô de Dragão"
    ficha-armadilha.webp      Frente "Armadilha"
    ficha-verso.webp           Verso genérico de ficha
  magia/                  Cartas de Magia (substituem o antigo baralho de Tesouro)
    magia-visao.webp         Frente "Visão de Dragão"
    magia-alagar.webp         Frente "Alagar"
    magia-amedrontar.webp      Frente "Amedrontar"
    magia-verso.webp            Verso genérico de carta de Magia
  evt/                    Cartas de evento
    card-<evento>.webp     Ícone quadrado da carta ativa (painel direito/baralho)
    evt-<evento>.webp        Carta grande usada na revelação de evento (manual novo)
    evt-verso.webp             Verso genérico de carta de evento
                              (sol, chuva, tempestade, nevasca, dragao, maldicao, ventos)
  audio/
    dice-sound.mp3         Som do dado
```

Nenhum outro arquivo é necessário para rodar o jogo — é só abrir `index.html`
(ou servir a pasta com qualquer servidor estático; é isso que a Vercel faz).

## Por que os assets são arquivos e não base64 embutido

Até a reorganização de agosto/2026, todas as imagens e o áudio ficavam embutidos
como `data:...;base64,...` direto dentro de `index.html`, o que deixava o arquivo
com mais de 7 MB e difícil de editar. Tudo foi extraído para arquivos reais em
`assets/`, e o HTML/JS agora referencia caminhos relativos
(`const ART_PRIMAVERA='assets/board/tabuleiro-primavera.jpg'`, etc.).
Isso também corrigiu um bug real: o áudio do dado embutido estava corrompido
(tinha `......` literal no meio da string base64), causando o problema de som
relatado antes. Agora `index.html` aponta direto para `assets/audio/dice-sound.mp3`.

## Como adicionar/trocar uma arte

1. Salve o arquivo em `assets/board/` (arte de tabuleiro) ou `assets/img/`
   (ficha/ícone/carta), com um nome minúsculo e sem espaços/acentos.
2. Se for uma arte nova (não uma substituição), declare uma const apontando pra
   ela perto das outras, por exemplo:
   ```js
   const ART_INVERNO='assets/board/tabuleiro-inverno.jpg';
   ```
3. Ligue essa const onde ela precisa aparecer:
   - Arte de tabuleiro por estação → array `SEASON_ART` (~linha 536).
   - Arte da ficha de carta de evento → objetos `EVT_IMG`/`EVT_CARD` (perto da definição de `EVT`).
   - Fichas/ícones do tabuleiro (ovo, esterco, armadilha, dragão, vilarejo, gota) →
     são usados diretamente como `href` de `<image>` dentro de `drawBoard()`.

## Onde mexer em cada coisa

| O que mudar                                       | Onde                                            |
|----------------------------------------------------|--------------------------------------------------|
| Regras/probabilidades do baralho de evento         | `SEASONS[i].deck` (quantidade de cada carta)     |
| Texto/cor de um evento                              | objeto `EVT`                                      |
| Texto/cor de uma carta de Magia                     | objeto `MAGIA`                                     |
| Quantidade de fichas/Magia por nº de jogadores      | `POOL_BY_PLAYERS` / `MAGIA_PER_TYPE`                |
| Arte de fundo do tabuleiro por estação              | `SEASON_ART` / consts `ART_*`                        |
| Arte da ficha no baralho de evento + na revelação   | `EVT_IMG` / `EVT_CARD`                                |
| Lógica de turno, movimento, roubo, dragão           | funções a partir de `function startTurn()`            |
| Layout/CSS                                           | bloco `<style>` no topo do `index.html`                 |
| Rede, salas e mao no celular                          | secoes 11 / 11b / 11c: `Net`, `MPUI`, `Phone`            |

## Regras implementadas (agosto/2026, com ajustes de setembro/2026 ao novo manual)

### Fluxo de turno

Não existe mais barra inferior nem botão "Encerrar turno". O dado vive apenas no
modal que abre no começo de cada turno; assim que a casa é resolvida, o turno do
próximo jogador começa sozinho.

### Revelação de evento

Ao terminar o turno do último jogador da rodada, a carta de evento é revelada como
uma placa grande no centro do tabuleiro: ela desce do alto, as rotas do grafo somem
para a arte respirar, e um toque em qualquer lugar devolve o tabuleiro ao jogo.
Controlado por `showEventReveal()` e pela classe `.artbox.reveal`.

### Dragão (carta reescrita)

Quando a carta **Dragão** ou **Maldição do Dragão** está em jogo, quem pisar no
Ninho rola 1d6 em vez da antiga barganha de pares/ímpares:

| Carta               | Amaldiçoa | Ignora | Abençoa |
|---------------------|-----------|--------|---------|
| Dragão              | 1–2       | 3–4    | 5–6     |
| Maldição do Dragão  | 1–3       | 4–6    | —       |

- **Bênção do Dragão** — o jogador passa a carregar **duas fichas** ao mesmo tempo.
- **Maldição do Dragão** — o jogador **não pode roubar nada**, mas continua podendo
  ser roubado.
- **Ignora** — o jogador pega do ninho normalmente (ficha ou tesouro).

Ambos os estados valem **enquanto o dragão estiver no ninho**: quando entra uma carta
de evento que não é de dragão, bênção e maldição se desfazem (e fichas excedentes
voltam ao monte). A penalidade antiga de quem já estava no ninho quando o dragão
chega — largar a ficha e recuar — continua valendo (`dragonPenalty()`).

### Ventos da Sorte

Enquanto a carta está em jogo, **ao fim da jogada** cada jogador escolhe entre
**avançar +2 casas** (movimento normal, com escolha de rota e encontros valendo) ou
**ganhar 1 carta de Magia**.

### Magia (substitui o antigo Tesouro)

Três cartas, sempre usáveis a qualquer momento por qualquer jogador que as tenha em
mãos (objeto `MAGIA`, painel "Cartas de Magia"): **Visão de Dragão** (espia 2 fichas
de um vilarejo em segredo), **Alagar** (+2 água num vilarejo à escolha) e
**Amedrontar** (arma uma defesa que impede o próximo roubo sofrido — não vale contra
Armadilha). A quantidade de cada uma no baralho escala com o número de jogadores
(`MAGIA_PER_TYPE`), assim como o Monte do Dragão (`POOL_BY_PLAYERS`) — ver `RULES.md`.

### Composição dos baralhos de evento

12 cartas por estação (`SEASONS[i].deck`, manual setembro/2026):

| Estação    | Sol | Chuva | Tempestade | Nevasca | Dragão | Maldição | Ventos |
|------------|-----|-------|------------|---------|--------|----------|--------|
| Primavera  | 4   | 3     | 1          | 0       | 0      | 1        | 3      |
| Verão      | 4   | 2     | 1          | 0       | 3      | 0        | 2      |
| Outono     | 2   | 2     | 3          | 0       | 2      | 2        | 1      |
| Inverno    | 1   | 1     | 2          | 4       | 1      | 2        | 1      |

### Simular rodada

Botão ao lado de "Simular jogada": encerra a rodada corrente na hora, contabiliza a
rodada, troca de estação se for o caso e revela a próxima carta de evento na mesma
ordem cronológica das regras. Não mexe na posição dos jogadores.

## Multiplayer (tablet + celulares)

A capa oferece **SINGLEPLAYER** (tudo na tablet, fluxo antigo) e **MULTIPLAYER**.

Não há servidor: a tablet abre a *mesa* de uma sala e continua dona do estado
(`G` segue sendo a única verdade). Cada celular abre a **mesma URL**, escolhe a
sala e conecta direto na tablet por WebRTC (PeerJS — o corretor público só
apresenta os dois lados; os dados trafegam P2P). Nada precisa ser configurado,
não há chave nem conta, e o deploy no Vercel continua sendo estático.

### Fluxo

1. **Tablet** → MULTIPLAYER → aba *Abrir a mesa* → escolhe Sala 1 ou 2 → **Abrir a mesa**.
2. **Celular** → mesma URL → MULTIPLAYER → aba *Entrar como jogador* → digita o nome,
   escolhe a sala (cada sala mostra quantos jogadores já estão nela) → **Entrar na sala**.
3. A tablet anuncia *"Fulano entrou na sala"* e lista o jogador no lobby.
4. Com 3 a 6 jogadores, a tablet clica em **Começar a partida**. Os assentos ficam na
   ordem de entrada e cada jogador joga com o nome que digitou.

### O que cada tela mostra

- **Celular**: banner com a sala e o nome, aviso de vez, as Cartas de Magia com botão
  **Usar** (valem a qualquer momento) e as fichas do Monte do Dragão viradas para baixo,
  com um botão 👁 que só espia localmente. A ordem das cartas na mão é fixa.
- **Tablet**: o tabuleiro público. Em multiplayer o painel de Magia mostra só o **verso**
  e a contagem por jogador, e a ficha carregada aparece de cara para cima apenas quando
  o teto do vilarejo desabou. Um chip `📱 Sala N · conectados/total` fica na topbar.

### Bots

Com a mesa aberta, **+ Adicionar bot (joga sozinho)** cria um assento sem celular.
No turno dele, `startTurn()` chama automaticamente a mesma IA do botão
*Simular jogada* (`autoPlayTurn`) — o bot rola o dado, escolhe a rota, invade,
rouba e resolve o ninho por conta própria. Um bot nunca usa Magia.
Antes de começar, cada bot pode ser removido pelo ✕ no lobby.

### Controle da mesa (admin)

- **Fechar mesa** encerra a sala na hora: avisa os celulares conectados, destrói o
  peer e libera o id para reabrir. Antes disso, a única saída era fechar a aba e
  esperar o broker expirar o id sozinho — o que deixava a sala presa em *ocupada*.
- `pagehide`/`beforeunload` fazem o mesmo automaticamente se a aba fechar ou recarregar.
- Uma sala marcada como ocupada **continua clicável**: quem manda é a resposta real do
  broker ao tentar abrir, não a sondagem. Assim um registro fantasma nunca bloqueia o admin.
- O lobby resonda as salas a cada 6s, sem piscar "Procurando…" (`probeAll`).

### A mão no celular

Tema claro e minimalista, no mesmo sistema visual do resto do app (fundo branco,
cinzas do Material, azul só onde é ação).

Além da própria mão, o celular lista os **vilarejos** de todos os jogadores. Ao tocar
em um, abre uma camada emoldurada na cor do dono, com o nome no topo e um botão
**✕ Sair** — para nunca haver dúvida de qual mão está na tela. As fichas aparecem
viradas para baixo, salvo quando o teto desabou (públicas) ou é o próprio vilarejo.

As magias com alvo são resolvidas no celular, tocando nas próprias cartas:

- **Visão de Dragão** → escolhe o vilarejo → toca em 2 cartas → só aquele celular vê o
  resultado (`visaoPick` → `peek`). Antes isso abria um modal na tablet, à vista de todos.
- **Alagar** → escolhe o vilarejo → a mesa aplica os +2 marcadores (`alagarPick`).
- **Amedrontar** não tem alvo: segue indo direto como `useMagia`.

O tipo de uma ficha só viaja pela rede quando ela já é pública ou pertence a quem
está pedindo — o celular não recebe dado que não pode ver.

### Modal de magia (celular)

Usar uma Magia abre uma tela própria (`#phMagic`): a arte da carta ao fundo, o nome e o
efeito, os alvos em botões na parte de baixo (ao alcance do polegar) e cancelar.
É a mesma tela para os três casos — só muda o conteúdo passado a `paintMagic()`.

- **Alagar**: escolhe o vilarejo e manda `alagarPick`.
- **Visão de Dragão**: escolhe o vilarejo e cai na moldura do vilarejo para tocar em 2 cartas.
- **Amedrontar**: não abre por escolha do jogador — abre sozinha, veja abaixo.

### Amedrontar virou defesa reativa

O manual (seção 12) diz *"use quando outro jogador tentar roubar você"*, mas a carta era
armada com antecedência (`medoShield`) e disparava sozinha. Agora ela fica na mão e
`askDefense(vitima, ladrao, cb)` pergunta no instante em que o roubo ia dar certo:

- Com celular: a mesa manda `defend`, o modal abre automático perguntando se quer usar
  contra o ladrão (nomeado), e a resposta volta em `defendUse`. A mesa mostra só que o
  jogador está decidindo. Se ninguém responder em 25s, o roubo segue.
- Sem celular (bot ou singleplayer): usa sozinho, já que a carta só tem vantagem.

Vale na Trombada (roubo entre jogadores), nos dois sentidos — ladrão humano ou bot.
O roubo de vilarejo ainda não consulta a defesa.

### Roubo em vilarejo (pelo celular)

Pisar no vilarejo de outro jogador **sempre** dá um retorno — antes, quando o dono
estava em casa, o jogo seguia em silêncio e parecia bug. Agora `villageEncounter()`
trata os três casos:

- **Dono presente**: avisa na mesa que um vilarejo com o dono dentro não pode ser
  assaltado (manual, seção 8) e segue o movimento.
- **Jogador com celular**: a mesa manda `steal` para aquele celular e fica esperando,
  mostrando só *"fulano está escolhendo no celular"*. A moldura do vilarejo vira a tela
  do roubo: fichas de costas, o jogador toca em uma (ou em *Não roubar e seguir*), e só
  ele vê o que era. A resposta volta em `stealPick`/`stealSkip`.
- **Bot ou sem celular**: cai no modal antigo da tablet, como antes.

Na versão pelo celular o ovo roubado entra na mão como `revealed:false` — a mesa vê
que alguém carrega alguma coisa, não o quê. Esterco e Armadilha resolvem igual, mas o
log da mesa é neutro ("vasculhou e saiu sem levar nada"); a armadilha, por ter efeito
público, continua aparecendo.

### Partida pausada por desconexão

Um celular fora do ar é uma mão que ninguém pode jogar. Quando isso acontece com a
partida já rolando, `netPresenceChanged()` liga `G.paused`, cobre a mesa com o aviso
`#netPause` e congela tudo: bot não joga (`autoPlayTurn` e o disparo em `startTurn`
checam a flag) e nada vindo de celular é aceito.

O jogador volta abrindo a mesma página e entrando **com o mesmo nome** — a reconexão
por assento já existia, e ao voltar a pausa sai sozinha e o turno retoma de onde parou.
Se ele não voltar, **Continuar com bot no lugar** converte o assento em bot
(`Net.makeBot`) para a partida não morrer ali.

### Artes das cartas

As 8 cartas (4 de Magia, 4 de Ficha) vêm dos PDFs de impressão, rasterizados a 640px
de largura e salvos em WebP q82 — ~1,7 MB no total, contra ~46 MB dos PDFs originais.
Os arquivos mantêm os nomes de sempre em `assets/magia/` e `assets/ficha/`, então nada
no código precisa mudar quando a arte for atualizada de novo.

A arte nova é mais quadrada (proporção ~1,34) que a moldura do jogo (`CARD_RATIO`
≈ 1,54). Não é problema: todo lugar que exibe carta usa recorte de cobertura
(`preserveAspectRatio="xMidYMid slice"` no SVG, `object-fit:cover` no CSS), então
sobra só um corte nas laterais decorativas — título e ilustração ficam inteiros.

### Detalhes de implementação

- IDs de peer fixos: `oscariba-mesa-1` e `oscariba-mesa-2`. Abrir a mesa numa sala já
  ocupada devolve *"Já existe uma mesa aberta"* — inclusive se o ocupante for outro grupo
  usando o mesmo site ao mesmo tempo.
- Antes de entrar, o celular *sonda* as duas salas para mostrar a contagem; sala sem mesa
  aparece como *Mesa fechada*.
- Se um celular cair, o assento é guardado: basta entrar de novo **com o mesmo nome** para
  voltar ao lugar. Quem for novo é recusado depois que a partida começa.
- A mesa empurra para cada celular só a mão daquele jogador; o celular devolve apenas
  intenções (`useMagia`), nunca estado.
- Nomes são limpos na entrada (`cleanName`) porque entram em `innerHTML` no placar,
  no log e no ranking.
- Capa, lobby e a mão do celular vivem **fora** de `#stage`: precisam funcionar em retrato,
  sem o scale de 1440x900 e sem o aviso "gire o tablet". O tabuleiro continua exigindo paisagem.

## Rodando localmente

```bash
node serve.js
# abra http://localhost:8791/index.html
```
