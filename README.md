# Jujutsu Kaisen: Era Maldita

Site estático (HTML, CSS e JavaScript puro, sem build) do cenário *Era Maldita*: técnicas, sistemas, vantagens, classes, famílias, arsenal e cronologia.

## Estrutura

- `index.html` — a página única.
- `assets/css/main.css` — toda a estética.
- `assets/js/data.js` — navegação e conteúdo; `tecnicas-texto.js`, `sistemas-texto.js` e `vantagens-texto.js` — os textos longos.
- `assets/js/app.js` — renderização e rotas.

## Executar localmente

```bash
npx serve -s .
```

## Publicar

**Vercel** — `vercel.json` reescreve as rotas (`/tecnicas`, `/sistemas`…) para `index.html`. Importe o repositório em [vercel.com/new](https://vercel.com/new).

**GitHub Pages** — o workflow `.github/workflows/deploy-pages.yml` publica a cada push em `main` (Settings → Pages → Source: GitHub Actions). Em `*.github.io` o site usa rotas com `#` (`#tecnicas`), já que o Pages não reescreve endereços.
