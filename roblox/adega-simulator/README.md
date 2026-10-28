# Adega Simulator (Roblox)

Simulador de adega brasileira no estilo *Restaurant Tycoon*. Você monta a sua adega móvel por móvel e atende os clientes (ou contrata quem atenda): anota pedidos, prepara cerveja, copão e caipirinha, entrega nas mesas, pega o dinheiro e limpa a bagunça. Com o tempo, sobe de nível, libera estações e decorações, aumenta o terreno e monta uma equipe.

Tudo é criado pelos scripts: o mundo, a rua, os prédios, os móveis, os avatares e a interface. Não é preciso modelar nada.

## Como jogar

| Tecla | O que faz |
| --- | --- |
| **E** | Interagir: anotar pedido, preparar bebida (segure), entregar, pegar dinheiro, limpar mesa (segure) |
| **F** | Pegar os pedidos prontos que a equipe deixou no balcão |
| **B** | Modo construção |
| **R / Q** | No modo construção: girar / cancelar |
| **G / M** | Abrir Equipe / Cardápio |

No celular, tudo tem botão na tela.

### O ciclo de uma mesa

1. Um grupo de 1 a 4 pessoas chega pela calçada e procura uma mesa livre.
2. Lê o cardápio (📖) e chama (❗). Vá até a mesa e aperte **E** para anotar.
3. Cada pessoa pede um produto. Vá até a estação certa e segure **E** para preparar. O item vai para a sua bandeja, que comporta 4 itens.
4. Leve a bandeja até a mesa e aperte **E** para entregar.
5. O grupo bebe e pode pedir outra rodada. Quando vai embora, deixa o dinheiro (💵) e a sujeira na mesa.
6. Pegue o dinheiro e limpe a mesa (segure **E**) para ela ficar livre de novo.

Quem compra no **balcão** entra na fila, pede, recebe e paga na hora.

Clientes têm paciência: a barra no balão vai do verde ao vermelho. Se ninguém atender a tempo, vão embora bravos e deixam uma avaliação ruim. Atendimento rápido, decoração bonita (✨ ambiente) e seguranças dão mais estrelas. Mais estrelas trazem mais gente e mais gorjeta.

### Progresso

- **Nível:** cada real faturado vira XP. Os níveis liberam móveis, estações, produtos, funções da equipe e vagas de funcionário.
- **Cardápio:** cada estação do modo construção libera produtos. Ao todo são 12: cerveja, long neck, dose, energético, caipirinha, copão, chopp, espetinho, gin tônica, balde, batata frita e copão premium.
- **Equipe:**
  - garçom (anota, entrega e recolhe o dinheiro);
  - bartender (prepara as bebidas);
  - faxineiro (limpa as mesas);
  - atendente de balcão;
  - segurança e DJ (melhoram a avaliação e o movimento).

  Cada funcionário pode ser treinado até 5 estrelas, ficando mais rápido.
- **Terreno:** começa com 36 x 36 e chega a 84 x 84.
- **Estilo:** 6 pisos e 8 cores de parede.
- **Dia e noite:** um dia dura 14 minutos. Das 18h às 2h é o horário nobre, com 50% mais clientes e o neon aceso. Às 6h aparece o resumo do dia.
- **Missões:** 18 missões em sequência ensinam o jogo e pagam recompensas.

### Modo construção

São 50 móveis em 5 categorias: Mesas, Bar, Paredes, Decoração e Luzes e som. O catálogo mostra uma miniatura 3D de cada um.
- **Colocar:** clique num móvel do catálogo e mova a prévia pela grade. Verde quer dizer que dá para colocar e vermelho que não dá.
- **Editar:** clique num móvel já colocado para mover, girar ou vender (devolve 60% do preço).
- **Paredes:** ficam transparentes enquanto você constrói.
- **Caminho livre:** deixe sempre um caminho da calçada até as mesas e estações, senão os clientes não chegam. Use **Porta de enrolar** ou **Vão aberto** para fazer entradas.

## Instalar

### Opção 1: abrir o arquivo pronto (recomendado)

1. Baixe o arquivo [`AdegaSimulator.rbxlx`](AdegaSimulator.rbxlx). No GitHub, abra o arquivo e clique em **Download raw file**.
2. No Roblox Studio: **File → Open from File…** e escolha o arquivo.
3. Aperte **Play**. No Output (**View → Output**) deve aparecer `[Adega] 6 terrenos criados`.

Para publicar: **File → Publish to Roblox**. Para o salvamento funcionar no Studio, ative também **Game Settings → Security → Enable Studio Access to API Services**.

São 6 adegas por servidor, então coloque o máximo de jogadores em 6 (**Game Settings → Places**) ou mude `PlotCount` em `Config`.

> Se você usou uma versão antiga deste jogo num lugar seu, não misture: abra o arquivo novo. Os scripts antigos (`AdegaConfig`, `AdegaServer`, `AdegaHUD`) não funcionam com esta versão.

### Opção 2: Rojo

```bash
rojo serve roblox/adega-simulator/default.project.json
```

### Gerar o arquivo de novo depois de mexer no código

```bash
python3 roblox/adega-simulator/tools/build_place.py
```

## Onde fica cada coisa

```
src/
├── ReplicatedStorage/AdegaShared/     (Folder, usado pelo servidor e pelo cliente)
│   ├── Config.luau                    números do jogo, cardápio, equipe, estilos, missões, avaliações
│   ├── Catalog.luau                   os 50 móveis e o desenho 3D de cada um
│   └── Util.luau                      formatação e a adega inicial
├── ServerScriptService/AdegaServer/   (Script)
│   ├── init.server.luau               mundo, iluminação, jogadores, economia, missões, ações
│   ├── Plot.luau                      terreno, grade, móveis, expansão, estilo
│   ├── Restaurant.luau                clientes, pedidos, preparo, entrega, pagamento, avaliações
│   ├── Staff.luau                     inteligência dos funcionários
│   ├── Rig.luau                       avatares R15 animados e caminhos (PathfindingService)
│   ├── Props.luau                     bebidas 3D, bandeja, dinheiro, sujeira, balões, efeitos
│   └── Data.luau                      salvamento
└── StarterPlayer/StarterPlayerScripts/AdegaClient/   (LocalScript)
    ├── init.client.luau               liga tudo e recebe o estado do servidor
    ├── UI.luau                        tema e componentes
    ├── Hud.luau                       interface da tela
    ├── Panels.luau                    janelas de Equipe, Cardápio, Avaliações, Expandir e Estilo
    └── Build.luau                     modo construção
```

## Ajustar o jogo

- **Preços, tempos e ritmo:** `Config.luau`. Por exemplo `StartingCash`, `Customer.baseGroupsPerMinute`, a paciência dos clientes, o preço e o tempo de preparo de cada produto, o custo de contratar, o tamanho dos terrenos e a curva de XP (`xpForLevel`).
- **Móveis novos:** `Catalog.luau`. Copie um item parecido e mude `id`, `name`, `price`, `level`, `size` e a função `build`.
- **Adega inicial:** `Util.StarterLayout`.

## Publicar

O jogo mostra bebidas alcoólicas: declare isso no **questionário de maturidade** (Creator Dashboard → seu jogo → Maturity & Compliance). Isso provavelmente vai aumentar a classificação etária. Não use marcas reais de bebida.
