# Hogwarts — Biblioteca

Fan site interativo da biblioteca de Hogwarts. A entrada exige o gesto de varinha de **Alohomora** (no espírito do treino de feitiços de *Hogwarts Legacy*). Depois, a estante é o menu: dez tomos abrem em 3D.

## Como executar

```bash
npm install
npm run dev
```

Servidor: `http://127.0.0.1:45217`.

```bash
npm run build
npm run preview
```

## Publicar no GitHub Pages (site `cecihog`)

O repositório já traz o workflow `.github/workflows/deploy-pages.yml`, que faz o build e publica a cada push em `main`.

1. No GitHub, crie um repositório chamado **cecihog** (público, vazio, sem README).
2. Envie o código:

   ```bash
   git remote add github https://github.com/SEU-USUARIO/cecihog.git
   git push -u github main
   ```

3. No repositório, abra **Settings → Pages** e em **Build and deployment → Source** escolha **GitHub Actions**.
4. Aguarde a action "Deploy to GitHub Pages" terminar (aba **Actions**).

O site fica em `https://SEU-USUARIO.github.io/cecihog/`. O caminho base é resolvido pelo workflow a partir do nome do repositório; para testar o build com esse caminho localmente:

```bash
VITE_BASE=/cecihog/ npm run build
npm run preview
```

## Entrada

Trace o glifo dourado com o rato ou o dedo, a partir do nó brilhante. Com `prefers-reduced-motion`, há um atalho acessível para completar o gesto.

## Conteúdo

Os volumes estão em `src/data/books.ts` (Hogwarts, Matérias, Casas e os sete anos). Os feitiços concretos ficam como espaços reservados.

## Arte e texturas

As pinturas e materiais em `public/art/` foram geradas por IA e otimizadas para a web (WebP):

- `hall.webp` / `hall-portrait.webp` — o salão da biblioteca atrás da estante (paisagem e retrato); recebe um parallax leve com o rato e um zoom lento na revelação.
- `gate.webp` — a porta gótica do portal Alohomora.
- `wood.webp`, `leather.webp`, `parchment.webp` — ladrilhos sem emendas para a madeira da estante, o couro das lombadas e o papel das páginas.
- `case.webp` / `case-portrait.webp` — a estante pintada (recorte com alfa, versões paisagem e retrato). As prateleiras reais (`.shelf-recess`) são posicionadas em percentagens medidas sobre a pintura, por isso os livros encaixam nos vãos.
- `tool-band.webp`, `tool-frame.webp`, `tool-medallion.webp`, `tool-flourish.webp` — douração das lombadas (faixas, moldura do título em nine-slice, medalhão, florões), aplicada sobre o couro com `mix-blend-mode: screen`.
- `cover-frame.webp`, `cover-medallion.webp` — a moldura e o brasão gravados na capa do livro aberto.
- `page-border.webp` — a cercadura de vinhas iluminada das páginas (`mix-blend-mode: multiply`).
- `prop-candle-a.webp`, `prop-candle-b.webp`, `prop-sconce.webp` — castiçais de latão e a arandela de ferro; só a chama é desenhada ao vivo (SVG sobre o pavio).
- `prop-hourglass.webp`, `prop-orb.webp`, `prop-inkwell.webp`, `prop-potions.webp`, `prop-lantern.webp`, `prop-scrolls.webp`, `prop-stack.webp` — os objetos das prateleiras, recortados com transparência; brilhos do orbe, das poções e da lanterna são camadas CSS animadas por cima.
- `ink-*.webp` — 18 pranchas de gravura a tinta (castelo, coruja, caldeirão, varinha, chapéu, pomo, ampulheta, orbe, pena, diário, cálice, fénix, medalhão, espada, vassoura, vira-tempo, mandrágora, chave) com fundo transparente, usadas nos blocos `plate` de `src/data/books.ts`.

Durante o desenvolvimento, `http://127.0.0.1:45217/?aberto` salta o portal Alohomora e abre a estante directamente.

Em telemóveis e ecrãs de toque o site entra num modo leve (sem desfoques, sem grão animado, sem parallax) para manter a fluidez.

## Controles

- Traçar Alohomora para entrar
- Clique ou toque num livro para o abrir
- `Esc` fecha o tomo
- Setas na estante movem o foco
