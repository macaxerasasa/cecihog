# Ateneu de Cinderis

Biblioteca mágica interativa: a própria estante é o menu. Dez tomos físicos abrem em perspectiva 3D — ambientação, habilidades, raças e os sete anos da academia.

## Como executar

```bash
npm install
npm run dev
```

O servidor local sobe em `http://127.0.0.1:45217`.

```bash
npm run build
npm run preview
```

## Conteúdo

Os volumes vivem em `src/data/books.ts`. Cada tomo tem paleta, lombada e *spreads* (páginas pares). Os anos já trazem espaços reservados para matérias, feitiços e anotações.

## Controles

- Clique ou toque em um livro para retirá-lo e abri-lo
- `Esc` fecha o tomo
- Setas na estante movem o foco entre os volumes
- Com o livro aberto: cadernos, tomo anterior/seguinte e selo de fechar
- `prefers-reduced-motion` encurta as transições sem bloquear a leitura
