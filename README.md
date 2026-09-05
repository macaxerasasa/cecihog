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

## Entrada

Trace o glifo dourado com o rato ou o dedo, a partir do nó brilhante. Com `prefers-reduced-motion`, há um atalho acessível para completar o gesto.

## Conteúdo

Os volumes estão em `src/data/books.ts` (Hogwarts, Matérias, Casas e os sete anos). Os feitiços concretos ficam como espaços reservados.

## Controles

- Traçar Alohomora para entrar
- Clique ou toque num livro para o abrir
- `Esc` fecha o tomo
- Setas na estante movem o foco
