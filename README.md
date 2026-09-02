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

## Rodando localmente

```bash
node serve.js
# abra http://localhost:8791/index.html
```
