# Oscaribas — Board Game Web

Protótipo jogável do Oscaribas em HTML/CSS/JS puro (sem build step), pensado para
tablet. Hospedado na Vercel como site estático.

## Estrutura

```
index.html              Todo o jogo: markup, CSS e lógica (single-page app)
assets/
  board/                 Arte de fundo do tabuleiro, uma por estação
    tabuleiro-primavera.jpg
    tabuleiro-verao.jpg
    tabuleiro-outono.jpg
    tabuleiro-inverno.jpg
  img/                    Ícones e fichas ilustradas
    dragon.png            Emblema do dragão no ninho
    shock.png              Ilustração de "raio" (evento Tempestade)
    village.png             Medalhão redondo de vilarejo
    drop.png                 Gota de marcador de umidade
    ficha-ovo.png             Frente da ficha "Ovo de Dragão"
    ficha-esterco.png          Frente da ficha "Esterco de Dragão"
    ficha-armadilha.png         Frente da ficha "Armadilha"
    ficha-verso.png              Verso genérico de ficha
    ficha-sol.png                 Arte da carta de evento "Sol"
    ficha-chuva.png                Arte da carta de evento "Chuva"
    ficha-tempestade.png            Arte da carta de evento "Tempestade"
    tre-escama.png                   Carta de tesouro "Escama de Dragão"
    tre-sopro.png                     Carta de tesouro "Sopro de Dragão"
    tre-olho.png                       Carta de tesouro "Olho de Dragão"
    treasure-verso.png                  Verso genérico de carta de tesouro
  evt/                                   Cartas de evento ilustradas (agosto/2026)
    card-<evento>.webp                    Arte quadrada exibida no baralho (painel direito)
    modal-<evento>.webp                    Placa grande da revelação de evento
                                            (sol, chuva, tempestade, nevasca, dragao, maldicao, ventos)
  audio/
    dice-sound.mp3                       Som do dado
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
   - Arte de ficha de carta de evento → objeto `EVT_IMG` (perto da definição de `EVT`).
   - Fichas/ícones do tabuleiro (ovo, esterco, armadilha, dragão, vilarejo, gota) →
     são usados diretamente como `href` de `<image>` dentro de `drawBoard()`.

## Onde mexer em cada coisa

| O que mudar                                   | Onde                                          |
|------------------------------------------------|------------------------------------------------|
| Regras/probabilidades do baralho de evento     | `SEASONS[i].deck` (quantidade de cada carta)   |
| Texto/cor de um evento                          | objeto `EVT`                                    |
| Texto/cor de uma carta de tesouro               | objeto `TRE`                                     |
| Arte de fundo do tabuleiro por estação          | `SEASON_ART` / consts `ART_*`                    |
| Arte da ficha no baralho de evento + no modal   | `EVT_IMG`                                         |
| Lógica de turno, movimento, roubo, dragão       | funções a partir de `function startTurn()`        |
| Layout/CSS                                       | bloco `<style>` no topo do `index.html`             |

## Regras implementadas (atualização agosto/2026)

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

### Ventos da Sorte (carta nova)

Enquanto a carta está em jogo, **ao fim da jogada** cada jogador escolhe entre
**avançar +2 casas** (movimento normal, com escolha de rota e encontros valendo) ou
**comprar 1 carta de Tesouro**.

### Composição dos baralhos

12 cartas por estação:

| Estação    | Sol | Chuva | Tempestade | Nevasca | Dragão | Maldição | Ventos |
|------------|-----|-------|------------|---------|--------|----------|--------|
| Primavera  | 4   | 5     | 1          | 0       | 0      | 0        | 2      |
| Verão      | 4   | 2     | 3          | 0       | 2      | 0        | 1      |
| Outono     | 3   | 2     | 2          | 2       | 1      | 1        | 1      |
| Inverno    | 0   | 2     | 3          | 3       | 2      | 2        | 0      |

### Simular rodada

Botão ao lado de "Simular jogada": encerra a rodada corrente na hora, contabiliza a
rodada, troca de estação se for o caso e revela a próxima carta de evento na mesma
ordem cronológica das regras. Não mexe na posição dos jogadores.

## Rodando localmente

```bash
python3 -m http.server 8000
# abra http://localhost:8000/index.html
```
