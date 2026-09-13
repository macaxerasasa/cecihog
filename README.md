# O Mapa do Maroto — Hogwarts

Fan site em forma de **Mapa do Maroto**: uma planta de Hogwarts em tinta sobre pergaminho dobrado. A entrada pede o juramento (toque a varinha no pergaminho); a tinta se espalha, o mapa se desenha e as salas passam a abrir **folhas dobradas** com o conteúdo — o castelo, as matérias, as casas e o sumário dos 163 feitiços dos sete anos, com busca.

## Como executar

```bash
npm install
npm run dev
```

Servidor: `http://127.0.0.1:45217`. Em desenvolvimento, `?aberto` na URL pula o juramento.

```bash
npm run build
npm run preview
```

## Estrutura

- `src/components/Oath.tsx` — o juramento: veias de tinta a partir do toque e a apresentação dos senhores Aluado, Rabicho, Almofadinhas e Pontas.
- `src/components/CastleMap.tsx` — a planta em SVG: salas com portas, corredores, escadas, bússola, floresta, lago e as pegadas que rondam os corredores (`Walkers.tsx`).
- `src/components/FoldOut.tsx` — a folha que se ergue da sala e se desdobra em duas metades; as dobras seguintes viram na prega. `MapBlocks.tsx` desenha os blocos de conteúdo, `SpellEntry.tsx` os verbetes e `SpellSearch.tsx` a busca.
- `src/data/` — os textos: `books.ts` (títulos, subtítulos, lemas), `content.ts` (páginas), `spells.json` (feitiços, importados do documento via `npm run spells`) e `map.ts` (onde cada sala fica na planta, em paisagem e em retrato).
- `src/styles/map.css` — toda a estética: só transformações, opacidade e `clip-path` animam; o único filtro SVG (o tremor de traço à mão) fica numa camada estática.

Cada sala tem endereço próprio (`/tomo/<id>`); o botão voltar dobra a folha. `Travessura feita` apaga a tinta e devolve o pergaminho em branco.

## Publicar

**GitHub Pages** — o workflow `.github/workflows/deploy-pages.yml` publica a cada push em `main` (Settings → Pages → Source: GitHub Actions). O caminho base sai do nome do repositório; para testar localmente:

```bash
VITE_BASE=/cecihog/ npm run build
npm run preview
```

**Vercel** — `vercel.json` já configura framework, saída e o rewrite de `/tomo/:id`. Importe o repositório em [vercel.com/new](https://vercel.com/new) e cada push publica sozinho.

## Créditos visuais

Pergaminhos e gravuras a tinta gerados por IA para este projeto; tipografia IM Fell English, IM Fell English SC, Pinyon Script e Homemade Apple (Google Fonts, servidas localmente).
