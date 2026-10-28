# Adega Simulator (Roblox)

*Tycoon* de adega brasileira. Cada jogador ganha um terreno vazio e vai construindo a adega: balcão, freezer, prateleira de destilados, estação do copão, paredão de som, mesas de plástico, toldo, LED neon… Cada melhoria traz mais clientes por minuto ou aumenta quanto cada cliente gasta.

Não é preciso modelar nada: os scripts criam o terreno, as construções e os clientes.

## Como jogar

- Você nasce na frente do seu terreno, com R$ 100.
- **Botões** na lateral direita: pise em um para comprar a melhoria. Verde quer dizer que você tem dinheiro suficiente, vermelho que ainda não tem. Cada compra libera as próximas.
- **Clientes** chegam pela rua, compram no balcão e vão embora. O dinheiro fica no **Caixa** (o quadrado amarelo): pise nele para coletar. Depois da *Maquininha de cartão* a coleta fica automática.
- O progresso é salvo (dinheiro e melhorias).

## Instalar no Roblox Studio (copiar e colar)

1. Abra o Roblox Studio → **New** → **Baseplate**.
2. No **Explorer**, clique com o botão direito em **ReplicatedStorage** → **Insert Object** → **ModuleScript**. Renomeie para `AdegaConfig` e cole o conteúdo de [`src/ReplicatedStorage/AdegaConfig.luau`](src/ReplicatedStorage/AdegaConfig.luau).
3. Clique com o botão direito em **ServerScriptService** → **Insert Object** → **Script**. Renomeie para `AdegaServer` e cole o conteúdo de [`src/ServerScriptService/AdegaServer.server.luau`](src/ServerScriptService/AdegaServer.server.luau).
4. Aperte **Play**.

Para o salvamento funcionar no Studio: publique o jogo (**File → Publish to Roblox**) e ative **Game Settings → Security → Enable Studio Access to API Services**. Sem isso o jogo roda normalmente, só não salva (aparece um aviso no Output).

Existem 6 terrenos, então em **Game Settings → Places** coloque o máximo de jogadores por servidor em 6. Se quiser mais, aumente `PlotCount` em `AdegaConfig`.

## Instalar com Rojo (opcional)

Para quem quer editar no VS Code e sincronizar com o Studio:

```bash
rojo serve roblox/adega-simulator/default.project.json
```

## Ajustar o jogo

Tudo que dá para mudar está em `AdegaConfig`:

- `StartingCash`, `PlotCount`, `WalkSpeed`…
- `Upgrades`: a lista de melhorias. Cada uma tem `price`, `requires` (o que precisa ter antes), `customers` (clientes por minuto a mais), `ticket` (R$ a mais por cliente), `autoCollect` e a função `build`, que cria as peças com `add{ size = ..., pos = ..., color = ... }`. As posições são relativas ao centro do terreno; a rua fica do lado `-Z`.
- A ordem da lista define a vaga do botão no terreno.

Para montar a adega inteira são necessários cerca de R$ 191 mil, o que leva aproximadamente uma hora de jogo.

## Publicar

O jogo mostra bebidas alcoólicas, então responda isso no **questionário de maturidade** (Creator Dashboard → seu jogo → Maturity & Compliance). Isso provavelmente vai aumentar a classificação etária. Não use marcas reais de bebida (nomes, logos ou rótulos): o Roblox pode moderar o jogo por isso.
