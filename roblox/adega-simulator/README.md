# Adega Simulator (Roblox)

Simulador de adega brasileira. Você recebe uma adega pequena, com balcão, geladeira de cerveja e um atendente, e vai melhorando aos poucos: mais mesas na calçada, mais funcionários, novos produtos no cardápio e um ambiente cada vez mais bonito.

Não é preciso modelar nada: os scripts constroem a adega, a rua, os clientes e a interface.

## Como funciona

- **Clientes** chegam pela calçada, entram na fila do balcão, fazem o pedido (o balão mostra o quê) e pagam. Se tiver mesa livre, eles sentam; com **garçom**, pedem mais rodadas na mesa.
- O dinheiro cai no **caixa** do balcão: chegue perto e aperte **E** para recolher. O *Operador de caixa* faz isso por você.
- Cada venda dá **XP**. A adega sobe de nível, e cada nível libera itens novos na loja.
- **Dia e noite**: um dia dura 12 minutos. Das 18h às 2h é o *horário nobre*, com 50% mais clientes, e o neon brilha mais.
- **Avaliação (estrelas)**: sobe com o ambiente, os seguranças e o tamanho da equipe. Mais estrelas trazem mais clientes e mais gorjeta.

### A loja (tecla **B** ou os botões embaixo da tela)

| Aba | O que tem |
| --- | --- |
| Mesas | até 24 mesas com 4 cadeiras e a ampliação da calçada |
| Equipe | atendentes (mais filas), garçons, operador de caixa, seguranças, churrasqueiro e DJ |
| Bar | prateleira de destilados, geladeira de energético, máquina de gelo, bancada de caipirinha, estação do copão, churrasqueira e freezer de baldes. Cada item libera um produto no cardápio |
| Ambiente | toldo, plantas, varal de luzes, neon na fachada, TV do futebol, paredão de som, porcelanato, sinuca e letreiro luminoso |

O número verde nos botões mostra quantas coisas você já pode comprar.

## Instalar no Roblox Studio

1. Abra o Roblox Studio → **New** → **Baseplate**.
2. **ReplicatedStorage** → botão direito → **Insert Object** → **ModuleScript**, com o nome `AdegaConfig`. Cole o conteúdo de [`src/ReplicatedStorage/AdegaConfig.luau`](src/ReplicatedStorage/AdegaConfig.luau).
3. **ServerScriptService** → **Insert Object** → **Script**, com o nome `AdegaServer`. Cole o conteúdo de [`src/ServerScriptService/AdegaServer.server.luau`](src/ServerScriptService/AdegaServer.server.luau).
4. **StarterPlayer** → **StarterPlayerScripts** → **Insert Object** → **LocalScript**, com o nome `AdegaHUD`. Cole o conteúdo de [`src/StarterPlayer/StarterPlayerScripts/AdegaHUD.client.luau`](src/StarterPlayer/StarterPlayerScripts/AdegaHUD.client.luau).
5. Aperte **Play**. No Output (**View → Output**) deve aparecer `[Adega] 4 adegas criadas no Workspace`.

Ao copiar uma versão nova, apague todo o conteúdo do script antes de colar.

Para o salvamento funcionar no Studio: publique o jogo e ative **Game Settings → Security → Enable Studio Access to API Services**. Sem isso o jogo roda, só não salva.

São 4 adegas por servidor, então coloque o máximo de jogadores em 4 (**Game Settings → Places**) ou aumente `PlotCount` em `AdegaConfig`.

## Rojo (opcional)

```bash
rojo serve roblox/adega-simulator/default.project.json
```

## Ajustar o jogo

Tudo fica em `AdegaConfig`:

- `StartingCash`, `BaseCustomersPerMinute`, `DayLengthMinutes`, `MaxCustomersPerPlot`…
- `Products`: o cardápio (preço, ícone e qual item libera).
- `Items`: as melhorias da loja: preço inicial (`basePrice`), quanto encarece a cada nível (`growth`), nível mínimo da adega (`levelReq`), requisitos, efeitos e a função `build`, que cria as peças.
- `buildBase`: a loja inicial.
- `TableSlots` e `StaffSpots`: onde ficam as mesas e os funcionários.

## Publicar

O jogo mostra bebidas alcoólicas: declare isso no **questionário de maturidade** (Creator Dashboard → seu jogo → Maturity & Compliance), o que provavelmente vai aumentar a classificação etária. Não use marcas reais de bebida.
