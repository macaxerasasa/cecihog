/* ==========================================================================
   CONTEÚDO DO SITE
   Tudo o que aparece escrito no site vem daqui. Para trocar um texto, edite
   só este arquivo. Parágrafos aceitam <b>negrito</b>, <i>itálico</i> e <br>.
   Os textos abaixo são PROVISÓRIOS.
   ========================================================================== */

const LOREM = [
  "Texto provisório. Aqui entra o parágrafo real desta seção — o layout já está pronto para receber textos longos, com <b>destaques em negrito</b> e <i>itálico</i> quando necessário.",
  "Segundo parágrafo de exemplo. Serve para mostrar o espaçamento entre blocos de leitura e como o texto se comporta em várias linhas, tanto no computador quanto no celular.",
  "Terceiro parágrafo de exemplo, um pouco mais curto, fechando a seção."
];

window.SITE_DATA = {
  meta: {
    name: "Era Maldita",
    fullName: "Jujutsu Kaisen: Era Maldita",
    place: "Japão, 2024",
    status: "Inabitável",
    quote: "Há uma ordem natural para todas as coisas: os fracos tendem a cair, os fortes tendem a prevalecer.",
    footer: "Jujutsu Kaisen: Era Maldita — projeto de RPG."
  },

  /* Ordem e nomes do menu */
  nav: [
    { path: "/arsenal",    label: "Arsenal",    kanji: "兵器庫", blurb: "Armas e objetos amaldiçoados catalogados." },
    { path: "/classes",    label: "Classes",    kanji: "役割",   blurb: "Os estilos de luta dos feiticeiros." },
    { path: "/cronologia", label: "Cronologia", kanji: "年表",   blurb: "Os eventos que moldaram este mundo." },
    { path: "/familias",   label: "Famílias",   kanji: "呪遺産", blurb: "As linhagens e suas técnicas herdadas." },
    { path: "/sistemas",   label: "Sistemas",   kanji: "規則",   blurb: "Regras, atributos e combate." },
    { path: "/tecnicas",   label: "Técnicas",   kanji: "呪術",   blurb: "Central de técnicas amaldiçoadas." },
    { path: "/vantagens",  label: "Vantagens",  kanji: "利点",   blurb: "Talentos e aptidões especiais." }
  ],

  /* ---------------------------------------------------------------- */
  arsenal: {
    title: "Armas Amaldiçoadas",
    intro: [
      "Ao longo da história, muitas foram as armas, objetos e ferramentas catalogadas pelo coletivo jujutsu, tudo em prol de preservar, conscientizar e equipar seus feiticeiros com o que há de melhor ao longo do mundo, principalmente pela crescente ameaça de <b>Usuários de Maldição</b> e pelos raros perigos de um humano especialmente astuto aparecer.",
      "Existem armas lendárias, épicas e simplesmente raras, outras perdidas, outras esquecidas pelo tempo, algumas estão enterradas nos sarcófagos de feiticeiros poderosos, algumas foram destruídas para todo sempre por uma magia mais poderosa, algumas simplesmente foram seladas pelo seu poder imenso, que as impedia de ser destruída.",
      "Para qualquer que seja o caso, todas as relevantes e conhecidas foram relatadas nesta aba, podendo ou não serem adquiridas ao longo do projeto pelos jogadores."
    ],
    /* grade (classificação): "Esp.", "Um", "Dois", "Três" ou "Quatro" */
    items: [
      {
        title: "Pesadelo Desperto", grade: "Dois", owner: "Desconhecido",
        paragraphs: [
          "Forjada por um antigo ferreiro que de conhecimentos mágicos gozava, Pesadelo Desperto é uma lâmina pouco conhecida, considerada como lendária. É dito que ela absorve a energia negativa de seus alvos, sejam maldições ou humanos, e toma para si os aspectos do medo e do temor.",
          "Quando empunhada, não brilha nem mesmo no maior dos clarões, negra como ébano, e pode canalizar a essência do medo presente em sua composição. Cada corte gera feridas que causam não somente dano físico mas também espiritual e psicológico, paralisando um inimigo que seja suscetível a emoções por um turno através de um bombardeio de visões horríveis."
        ]
      },
      {
        title: "Liberdade", grade: "Um", owner: "Desconhecido",
        paragraphs: [
          "Durante os tumultuados anos da Guerra Civil Americana, um grupo de escravos rebeldes invocou poderes ancestrais para criar a Liberdade. Isaak, que veio da embarcação Hamburg, livrou a si e seus iguais, livrando-os das garras dos Confederados. Sua manifestação desencadeia a força de vontade daqueles que outrora empunharam a mesma lâmina, preenchendo todo o fio com uma camada de ar comprimido que fortalece suas investidas, ultrapassando a grande maioria das defesas. Além disso, é incapaz de ser afetado por ilusões ou qualquer outro tipo de subjugação mental, preservando seu livre-arbítrio."
        ]
      },
      {
        title: "Remington Model 1875", grade: "Três", owner: "Desconhecido",
        paragraphs: [
          "Com a aparência de um revólver simples, original dos turbulentos tempos do Velho Oeste americano, a arma foi manipulada por um feiticeiro nativo de alta longevidade que, após a intensa temporada de caça às bruxas, viu a necessidade de ocultar seus poderes. Funciona como um trabuco de energia amaldiçoada, mas tudo o que é disparado consome parte das reservas de seu usuário – o que conta como se estivesse utilizando uma técnica.",
          "Diferente das armas comuns, que ocasionalmente não podem perfurar feiticeiros mais poderosos, é capaz de atingir mesmo os que utilizam da energia amaldiçoada como escudo."
        ]
      },
      {
        title: "Excalibur", grade: "Um", owner: "Brandon Cromwell",
        paragraphs: [
          "A arma histórica das Lendas Arturianas, foi criada pelo feiticeiro medieval Merlim, um exorcista jujutsu de grau especial em seu campo. Além de seu fio ser aperfeiçoado ao máximo, também é capaz de remover-se da mão de seu utilizador, lutando por ele ao uso de técnicas misteriosas de levitação e esgrima avançada, essa que um dia foi usada pelo jujutsu-shi Rei Arthur. Possui o histórico de centenas de guerras, batalhas e duelos travados, sendo uma arma conhecida até mesmo por humanos que nada sabem sobre jujutsu e que, erroneamente, a associam com uma espécie de magia rudimentar."
        ]
      },
      {
        title: "Claymore", grade: "Um", owner: "Desconhecido",
        paragraphs: [
          "Conhecida por ter sido empunhada por William Wallace durante as batalhas do povo escocês em busca da independência do país. A importante espada sumiu depois da morte de Wallace, não aparecendo em nenhum registro histórico até 1825. Nesse ano, ela foi enviada para reformas na Torre de Londres e, depois da recuperação e da sua identificação, foi recuperada pelo governo escocês em 1888. Hoje em dia, ela se encontra no Monumento Wallace, localizado em Stirling."
        ]
      },
      {
        title: "Cólera Solar", grade: "Dois", owner: "Desconhecido",
        paragraphs: [
          "Traçada sua origem das civilizações mesoamericanas pré-colombo, trata-se de um grande machado de uma face, tendo sua lâmina forjada inteiramente em obsidiana, assumindo uma coloração escura e concomitantemente reflexiva em seu fio. Utilizado ao longo das eras como uma ferramenta altamente destrutiva em virtude da natureza cortante do seu material, difere-se de armamentos comuns em dois aspectos: a resistência inatural do seu fio, usualmente quebradiço em outras criações, e na capacidade de canalizar raios solares diretamente.",
          "Erguido aos céus pelas mãos do usuário pelo período de um turno, é instaurada a fúria do deus-herói Kinich-ahau, que lança um dos seus raios de sol em direção ao artefato, que pode tanto absorvê-lo para se fortalecer e incandescer seus golpes, ou redirecioná-lo de maneira direta contra seus oponentes."
        ]
      },
      {
        title: "Inushakk", grade: "Esp.", owner: "Desconhecido",
        paragraphs: [
          "Um crânio de touro vermelho, marcado por quatro chifres negros e um único buraco cabível para um glóbulo ocular em seu centro, evidenciando a natureza anômala da criatura do qual um dia pertenceu a caveira. Sua única função até então descoberta pelos corajosos o suficiente para segurá-lo diretamente em suas mãos é a capacidade excêntrica de conceder desejos, dentro de um limiar do plausível extremamente tênue e, na maioria dos casos, de execução questionável e ambígua.",
          "Por conta da misticidade envolvendo o artefato, lendas especulam acerca da sua natureza como canal de comunicação com o Jujutsu em si, e embora nada confirme o boato, o preço cobrado na maioria dos casos relatados justifica essa suspeita: uma subtração permanente das reservas de energia amaldiçoada do usuário, não esclarecidas em momento algum durante o pedido a cobrança que será feita, podendo muito bem resultar em mortes acidentais e súbitas."
        ]
      },
      {
        title: "Agulhas de Powaqa", grade: "Dois", owner: "Família King",
        paragraphs: [
          "Figurada pela forma de uma corrente metálica, a propedêutica das Agulhas de Powaqa se instala na capacidade do disparo de projéteis laminados e pontiagudos, muito similares a pequeninas agulhas, visíveis tão somente por feiticeiros de bons reflexos quando atiradas. Sua funcionalidade gira em torno da restrição da energia amaldiçoada de um alvo: cada agulha censura uma reserva de cinco técnicas daquele que é espetado com – ou seja, se um inimigo pode usar vinte técnicas em um combate, ao ser acertado por uma delas, seu número cai para quinze, e assim em diante –, mas assim que retiradas, seu fluxo de energia retorna ao normal de maneira imediata. Contando com cinco delas em seu arsenal, é possível catalogá-la como uma arma de suporte extremamente poderosa, de origem nativa americana."
        ]
      },
      {
        title: "Lança da Purificação", grade: "Dois", owner: "Desconhecido",
        paragraphs: [
          "Criada por monges xamãs em uma época de guerra entre clãs rivais, a Lança da Purificação foi concebida como uma ferramenta para restaurar o equilíbrio espiritual em meio ao caos. Diz-se que foi forjada a partir dos fragmentos de uma estrela cadente, carregando consigo uma aura cósmica. A lança é capaz de absorver e neutralizar energias negativas ao seu redor, convertendo-as em positivas. Quando empunhada por um usuário habilidoso, pode ser lançada para perfurar maldições ou usada como um foco para canalizar uma explosão de energia positiva dentro do corpo de um espírito amaldiçoado, exterminando-o de imediato caso sua resistência não seja extraordinária."
        ]
      },
      {
        title: "Lum e Oros", grade: "Esp.", owner: "Desconhecido",
        paragraphs: [
          "Lum e Oros, como nomeadas foram por Mitena, formam um par de foices de pequeno porte, bem semelhantes ao instrumento Kama oriental. Sem apresentar qualquer tipo de dificuldade em seu manuseio – a não ser que seu usuário não saiba como lutar com um armamento desse formato –, parece ser muito simples, mesmo que produzida por uma feiticeira milenar e grandiosamente respeitada por todo o Mundo da Feitiçaria Americana. Seu trunfo surge quando um adversário é talhado pelas duas lâminas; num passe de mágica, a projeção de uma corrente interliga os cabos de ambas, e por se desenvolver espiritualmente, não é tangível. Dessa forma, pode prender um inimigo até que decida o livrar, já que é impossível que ele se liberte manualmente – algumas suposições dizem que o único meio de afetá-las é com uma energia negativa monstruosa, onde poderá desmembrar os elos da corrente. Não há nada que comprove a efetividade deste método."
        ]
      },
      {
        title: "Nonagésimo Soldado da Legião do Sol Vermelho: Projeção Espiritual Defensiva Lendária", grade: "Dois", owner: "Desconhecido",
        paragraphs: [
          "Projetado na antiguidade no formato de um anel dourado, contendo gravuras que simbolizam Thyreós – um significado latino –, foi empunhado por um feiticeiro durante o período da Roma Antiga. O usuário, responsável por sua criação, faleceu durante a Segunda Guerra Púnica contra o exército de Aníbal, ainda que seu grupo tenha alcançado a vitória no fim. Apesar de não ter sido transformado em um espírito amaldiçoado, tornou-se hospedeiro do artefato, e aquele que em seu dedo tê-lo, será capaz de convocá-lo, reproduzindo uma postura defensiva que o protegerá durante dois turnos incansavelmente. Seu tempo de espera para ser utilizado outra vez é de seis turnos."
        ]
      },
      {
        title: "Sibilar Trovejante", grade: "Um", owner: "Desconhecido",
        paragraphs: [
          "Um arco longo, tingido estranhamente de azul — um pigmento extremamente raro de se encontrar naturalmente em qualquer lugar — e inscrito em gravuras brancas por toda sua extensão, assumindo uma proposta estranhamente ritualística igualada à sua versatilidade em combate, apresentada no seu fio capaz de manifestar flechas elétricas que, embora não dependam da energia amaldiçoada do seu usuário para existirem, são grandemente fomentadas por essa, especialmente no caso de indivíduos capazes de gerar eletricidade a partir das suas reservas amaldiçoadas, os quais são mais aptos a controlar a direção dos disparos, também.",
          "Por conta do som evidente produzido pelas suas flechas ilimitadas, é ligada a utilização desse objeto com a origem dos mitos de Thunderbirds na América do Norte, com o Sibilar Trovejante muitas vezes lançando a sombra de pássaros gigantes quando seus projéteis atingiam as nuvens carregadas, espantando hordas inteiras de rivais das tribos que conseguiam colocar suas mãos no armamento de uma só vez."
        ]
      },
      {
        title: "Ominosa Moringa dos Lamentos Proibidos", grade: "Esp.", owner: "Desconhecido",
        paragraphs: [
          "Manifestando a agonia e a lamúria de dezenas de milhares de almas perdidas ao longo dos anos, a moringa reflete a forma de um mero jarro de barro, ainda que goze de uma composição indestrutível mesmo contra os meios da feitiçaria. Sua utilização é misteriosa e parece apresentar mais de uma função, com a única delas sendo conhecida por ser uma configuração não-letal, já que através de um assobio, toda a miséria, deploração e lástima daqueles que em seu interior sofrem ecoa, limitando os sentidos de todos em um raio de seis por seis quadrados. O conto existe pois aqueles que um dia a enfrentaram conseguiram fugir, mas nunca mais foram os mesmos – se não por eles, o conhecimento acerca da relíquia seria nulo."
        ]
      },
      {
        title: "Pacificador", grade: "Um", owner: "Desconhecido",
        paragraphs: [
          "Diferente de outros tomahawks existentes, o Pacificador se trata de um armamento mais longo, podendo ser utilizado tanto por ambas as mãos quanto por uma única, e demasiadamente mecanizado para um artefato amaldiçoado, contando com diversos anexos metálicos e ornamentais que induzem ao erro quanto a origem de sua função secundária: a de espalhar nuvens de fumaça de até 4x4 com o apertar de um botão em seu cabo, que surgem da traseira da lâmina no seu topo e podem ser controladas pelos movimentos da arma na mão de seu usuário, causando efeitos nocivos como queimaduras superficiais e dificuldade de respiração naqueles que não mantém contato direto com seu cabo, eventualmente induzindo um desmaio naqueles menos resistentes aos seus efeitos.",
          "Por conta da capacidade de expelir fumaça, um terceiro uso mais recreacional fora descoberto: a capacidade de inalar pequenas quantias do fumo exaurido para fins não combativos."
        ]
      },
      {
        title: "Augúrio", grade: "Um", owner: "Desconhecido",
        paragraphs: [
          "De punho branco e lâmina negra como um véu noturno, Augúrio é uma arma baseada nos corvos de Odin. Onde outrora visualizaram todo o mundo em suas viagens, visualizando e constatando todos seus detalhes e nuances, dão uma capacidade símile ao utilizador, que pode antecipar um ataque com o espaço de oito turnos entre cada utilização de antecipação, tornando-se uma figura formidável em combate que pode, efetivamente, bloquear ou se esquivar da maioria dos golpes. Além disso, só de ser o portador atual o feiticeiro é capaz de ter vislumbres ocasionais do futuro, tendo acessos de coisas que hão de acontecer."
        ]
      }
    ]
  },

  /* ---------------------------------------------------------------- */
  /* Cada classe: paragraphs (texto de abertura), perksIntro (frase antes da
     lista, opcional), perks (lista numerada; "effect" é a linha de Efeito)
     e outro (parágrafos depois da lista). */
  classes: {
    title: "Classes de Feiticeiros",
    intro: [
      "Os feiticeiros, chamados assim quando formados, treinados e admitidos por uma das duas universidades de Jujutsu nos Estados Unidos — <b>Universidade de Feitiçaria da América (Campus Nova Iorque)</b> ou a <b>Universidade de Feitiçaria da América (Campus Los Angeles)</b> —, são seres humanos com plenas capacidades mágicas, capacitados a extrair sua força a partir da própria energia amaldiçoada e, com isso, convertê-la em encantamentos ou habilidades específicas que demonstram seu real valor no combate contra espíritos amaldiçoados. A bem dizer, são a única, primeira e última defesa da humanidade contra os espíritos do mal, que tentam, todos os dias, destruir os não-mágicos ou não-feiticeiros de maneiras diferentes.",
      "Inseridos neste contexto onde o estilo de luta individual pode lhe colocar acima ou abaixo num combate contra feiticeiros malignos ou espíritos amaldiçoados, é mais do que óbvio que todos esses feiticeiros seriam e são divididos em certas categorias de feiticeiro, que servem para etiquetar de maneira geral a sua forma de combate, por mais exótica ou distinta que seja, ainda haverá uma categoria que lhe englobe. É necessário frisar que, compondo uma espécie de técnica única, ela deve girar em torno de seu estilo de luta, ou seja, seu tipo de classe.",
      "Apesar disso, o fator de maior peso em toda e qualquer batalha Jujutsu é a energia amaldiçoada que um indivíduo possui, aliada com a técnica do usuário em mantê-la uniforme e concentrada, já que essa é a diferença entre um usuário inexperiente que sequer pode se defender para um feiticeiro de grau um ou grau especial que consegue derrotar ondas de maldições."
    ],
    items: [
      {
        name: "Lutadores", kanji: "拳", image: "https://i.imgur.com/RK3qv2U.png",
        paragraphs: [
          "Feiticeiros que usam a energia amaldiçoada em seu corpo principalmente em prol da luta física, abastecendo seus punhos e derme com o poder inato para tornar-se muito mais forte e resistente do que o feiticeiro médio ou o não-feiticeiro habitual. Por conta disso, demonstram certa inabilidade ou quase desuso no quesito de encantamentos, dificilmente dominando uma <b>Expansão de Domínio</b> e optando, no lugar, por um <b>Domínio Simples</b>. Ademais, suas técnicas de <b>Amplificação de Domínio</b> podem encontrar vasta utilidade no combate corpo a corpo, uma vez que giram em torno de aplicar a técnica inata do usuário com seu conhecimento de domínio, aplicando uma força maior e localizada, mesmo que não chegue perto das proporções de uma Expansão de Domínio total."
        ],
        perksIntro: "Como a sua energia amaldiçoada tem uma relação intrínseca com o corpo, todos os lutadores possuem o seguinte:",
        perks: [
          {
            title: "Força Sobre-Humana",
            paragraphs: ["Numa interação direta com os músculos, os lutadores possuem o dobro de força que a média normal de feiticeiros e, acima de tudo, humanos comuns. Eles são capazes de superar diversas provações de força conforme os anos progridem, evoluindo suas habilidades para conseguir feitos cada vez mais absurdos."],
            effect: "Lutadores recebem um ponto de atributo extra em <b>Força</b>."
          },
          {
            title: "Velocidade Sobre-Humana",
            paragraphs: ["Deixando conceitos como velocistas humanos para trás, você é literalmente capaz de manter um pique muito mais veloz e por muito mais tempo que um humano comum, ou seja, atestando ainda mais seus dotes na área. Aliado com o vigor sobre-humano, essa classe se torna apta a acompanhar grandes demonstrações de velocidade ou cerrar distâncias com ligeireza."],
            effect: "Lutadores recebem um ponto de atributo extra em <b>Velocidade</b>."
          },
          {
            title: "Reflexos Sobre-Humanos",
            paragraphs: ["Sua percepção acerca do mundo é muito mais apurada, além de tudo, seu corpo é plenamente capaz de escapar de perigos variados. Unindo seu físico hercúleo ao seu conhecimento de combate, é possível defender-se de ataques que não seriam vistos por feiticeiros fora da sua área, ou esquivar-se de investidas que venham de ângulos dificílimos."],
            effect: "Uma vez por combate, Lutadores <b>podem esquivar duas vezes seguidas</b>."
          },
          {
            title: "Resistência Sobre-Humana",
            paragraphs: ["É aqui que sua força se sobressai ainda mais; a sua energia flui sobre o seu corpo num sentido de aperfeiçoamento completo, tornando-o uma titânide de resistência em termos humanos e primorosamente capaz mesmo em quesitos de feiticeiros. Lutadores, por conta disso, sobrevivem muito mais contra espíritos amaldiçoados, resistindo — e não tornando-se invulnerável — a perfurações, ataques contundentes, golpes superpoderosos e todo o tipo de coisa."],
            effect: "Lutadores recebem um ponto de atributo extra em <b>Resistência</b>."
          },
          {
            title: "Vigor Sobre-Humano",
            paragraphs: ["Pode fazer qualquer tipo de tarefa ou trabalho manual pelo triplo de um humano comum, correndo, batalhando, usando técnicas básicas, aplicando golpes manuais com a inserção de energia amaldiçoada e derivados com o dobro de efetividade e tempo."],
            effect: "Lutadores <b>podem permanecer em combate por muito mais tempo que um feiticeiro comum</b>."
          },
          {
            title: "Escolhidos Pelo Raio",
            paragraphs: ["Na rolagem de dado para o <b>Raio Negro</b>, Lutadores possuem um dado crítico versátil de 19-20, permitindo-os alcançar o fenômeno sem propriamente atingir o crítico natural. Além dessa predisposição nativa para acertar seu oponente, Lutadores também podem iniciar a <b>Sequência de Kokusen</b>, o que significa que após o primeiro acerto, eles podem rolar outro imediatamente, repetindo o efeito caso consigam, mais uma vez, o Raio Negro."],
            effect: "Lutadores <b>possuem uma margem de acerto crítico maior e possuem acesso exclusivo ao efeito de “Sequência de Kokusen”</b>, podendo rolar o dado do Raio Negro contanto que sigam acertando."
          },
          {
            title: "Mestres de Combate",
            paragraphs: ["Além de receberem a vantagem <b>Mestre Combatente</b>, lutadores também possuem a aptidão de aprender, através de registros e passagens temporais, artes marciais novas, misturando-as com seu estilo de combate para se tornar um oponente ainda mais perigoso. Além disso, ao invés de receber duas cargas de esquiva sequenciais, os lutadores recebem a oportunidade de, <b>a cada três turnos, atacar duas vezes</b>."],
            effect: "Lutadores recebem a vantagem <b>Mestre Combatente</b> e uma facilidade superior para aprender outras artes marciais. Além disso, o efeito ativo da vantagem os <b>concede a oportunidade de atacar duas vezes seguidas com um intervalo de três turnos entre cada uso</b>."
          }
        ],
        outro: [
          "É válido ressaltar que todos os feiticeiros jujutsu são super-humanos, capazes de suportar quedas gigantescas, atravessar paredes de concreto com o próprio corpo e até erguer objetos pesadíssimos que nenhum outro humano suportaria, independente de sua classe. O que diferencia os Lutadores dos demais é justamente sua perícia em combate desarmado e físico, sendo este, muitas vezes, o critério de desempate numa batalha acirrada entre duas partes.",
          "Além disso, após alcançar o <b>Raio Negro</b> pela primeira vez, o feiticeiro em questão <b>recebe um ponto de atributo extra na categoria Técnica</b> e aumenta a margem do rolamento crítico para <b>18-20</b>, aumentando as chances de acertar."
        ]
      },
      {
        name: "Encantadores", kanji: "呪", image: "https://i.imgur.com/VY6tvQp.png",
        paragraphs: [
          "Feiticeiros que nascem com um grau ainda maior de energia amaldiçoada e que compreendem, com mais facilidade, como essa transmissão de poder funciona para sair do abstrato ao físico e palpável. Sua energia amaldiçoada pode ser usada tanto de maneira bruta e rudimentar; visto que os encantadores dominam por completo esse tipo de magia, como de maneira mais complexa, que se enquadra na categoria de encantamentos e podem ser etiquetadas como <b>Técnicas de Maldição</b> — todo e qualquer efeito complexo, herdado ou não, isolado ou não, que tenha um uso específico —, dispondo disso, seu arsenal primoroso para combate e suporte."
        ],
        perksIntro: "Todos os encantadores, desde o nascimento, são dispostos das seguintes idiossincrasias:",
        perks: [
          {
            title: "Energia Amaldiçoada Superior",
            paragraphs: ["Se diferenciando da população comum de feiticeiros, os encantadores, desde o nascimento, possuem uma taxa maior de energia amaldiçoada em seu corpo, o que torna suas técnicas mais poderosas e, além de tudo, os dá uma reserva maior para que operem."],
            effect: "<b>Encantadores recebem um ponto de Atributo extra na categoria Energia Amaldiçoada</b>."
          },
          {
            title: "Capacidades Físicas Melhoradas",
            paragraphs: ["Apesar de não chegarem no nível dos lutadores, os encantadores estão acima da média humana de força, velocidade, agilidade, resistência e vigor. Seguindo a regra de proporcionalidade presente mesmo na obra, encantadores que possuem um alto volume de energia amaldiçoada também são monstros no quesito físico, mesmo que a vantagem final seja daqueles que centram-se totalmente no combate desarmado e na proficiência do corpo."],
            effect: "<b>Seguem passivamente a Lei de Proporcionalidade, mas de modo ativo, podem aumentar todos os atributos físicos em um ponto por seis turnos, como um doping de energia amaldiçoada</b>."
          },
          {
            title: "Proficiência em Técnicas Amaldiçoadas",
            paragraphs: ["Diferentemente do restante, encantadores possuem uma afinidade inegável com Técnicas de Barreira, Técnicas Herdadas e Técnicas Inatas, tornando-os plenamente capazes de atingir altos níveis de ranqueamento mesmo no início. Com o passar dos anos, melhora ainda mais seu uso."],
            effect: "<b>Encantadores recebem dois pontos de atributo extra na categoria Técnica</b>."
          },
          {
            title: "Proficiência em Expansão de Domínio",
            paragraphs: ["Possui mais facilidade do que boa parte das outras classes de feiticeiro para criar e executar a primeira <b>Expansão de Domínio</b>, desbravando os conceitos mais iniciais da arte, mesmo que fiquem atrás dos <b>Mestres de Barreira</b>. Podem, com toda certeza, estabelecer o efeito de <b>Acerto Garantido</b> e criar um domínio sólido com condições equilibradas."],
            effect: "<b>Encantadores recebem um ponto de atributo extra na categoria Expansão de Domínio</b>."
          },
          {
            title: "Afinidade com a Técnica de Maldição Reversa",
            paragraphs: ["Provando ainda mais seu diferencial do restante no que se trata de técnicas amaldiçoadas, os feiticeiros dessa classe possuem uma predisposição para dominarem a <b>Técnica de Maldição Reversa</b>, técnica que consiste em utilizar a energia positiva produzida pelo cérebro para curarem a si mesmo e outros."],
            effect: "<b>Feiticeiros da classe encantador possuem uma predisposição para descobrir a Técnica de Maldição Reversa</b>, que pode ser alcançada através de uma situação de quase morte, um estado de clareza mental absoluta ou algum entendimento superior através dos estudos."
          },
          {
            title: "Condições de Contrato Aprimoradas",
            paragraphs: ["Seus votos e contratos, de alguma maneira, são mais efetivos em cumprir o seu propósito, mas em troca, cobram muito mais de você que o normal. Por exemplo, uma Restrição Celestial que envolve a troca de sua saúde física por um volume maior de Energia Amaldiçoada lhe retiraria um braço e uma perna, ou algo que siga essa mesma proporção. Um Voto de Ligação te permite cobrar e restringir mais a outra parte ou aumentar os ganhos, mas a consequência para a quebra é duplamente perigosa."],
            effect: "<b>Encantadores podem firmar Votos de Ligação desde o início</b>, enquanto as Restrições Celestiais estão reservadas para o nível dois e ao número limitado de vagas imposto pela organização."
          }
        ],
        outro: [
          "Além disso, após alcançar o Raio Negro pela primeira vez, o feiticeiro em questão <b>recebe um ponto de atributo extra na categoria Técnica</b>."
        ]
      },
      {
        name: "Mestres de Armas", kanji: "刃", image: "https://i.imgur.com/pE3ZgXI.png",
        paragraphs: [
          "Nessa classe não se enquadram feiticeiros que nasceram com um dote específico ou coisa do tipo, muito pelo contrário; essa é, de longe, a classe com mais feiticeiros que se categorizam por uma fraca ou inexistente taxa de <b>Energia Amaldiçoada</b> dentro do corpo, tornando dificultosa, por si só, a utilização de técnicas amaldiçoadas. O que não acontece, entretanto, com <b>Armas Amaldiçoadas</b>, parte central do estilo dos etiquetados com essa classe e que, definitivamente, se provou uma das mais complexas e técnicas de todos os tempos, mesmo sem usuários notáveis no campo de encantamentos."
        ],
        perksIntro: "Sendo ou não abençoado com altos níveis de <b>Energia Amaldiçoada</b> em seu corpo, todos os feiticeiros deste tipo possuem:",
        perks: [
          {
            title: "Especialista em Armas Amaldiçoadas",
            paragraphs: ["Estudando essa área, você é plenamente capaz de utilizar qualquer Arma Amaldiçoada que seja colocada em sua mão, manobrando-a com excelência diretamente relacionada ao seu nível."],
            effect: "<b>Mestres de Armas podem ignorar o requisito de treinamento para usar uma Arma Amaldiçoada</b>."
          },
          {
            title: "Conhecimento do Mundo Jujutsu",
            paragraphs: ["De longe, por causa desse ofício, todos os Mestres de Armas são capazes de reconhecer Objetos Amaldiçoados e Armas Amaldiçoadas, distinguindo-as com uma facilidade estranhíssima."],
            effect: "<b>Mestres de Armas podem requisitar aos narradores uma das três informações quando encontrarem um Objeto Amaldiçoado ou Arma Amaldiçoada</b>: sua função, seu nome ou sua idade."
          },
          {
            title: "Proficiência em Armamentos",
            paragraphs: ["Espada, lança, maça, chakram, adaga, naginata, kama; nada disso está fora da sua alçada. Amaldiçoadas ou não, todos os instrumentos bélicos caem como uma luva em suas mãos, o que te torna um excelente e perigoso combatente, independente de qual arma prefira usar."],
            effect: "<b>Mestres de Armas possuem a vantagem “Versatilidade Armada” naturalmente</b>. Além disso, recebem um ponto de atributo extra que pode ser colocado em Força, Velocidade ou Resistência, à escolha do jogador."
          },
          {
            title: "Perícia em Domínio Simples",
            paragraphs: ["Diferentemente dos encantadores e lutadores, a afinidade de um Mestre de Armas com Domínios Simples é bem mais apurada que o comum, o que os torna peritos em técnicas deste tipo."],
            effect: "<b>Mestres de Armas recebem um ponto de atributo extra na categoria Técnica</b>."
          },
          {
            title: "Reflexos Sobre-Humanos",
            paragraphs: ["Devido ao seu treinamento, você se torna uma máquina no quesito de reflexos de todo tipo, seja para esquivar, parar projéteis ou reagir numa mudança repentina de curso do seu oponente, igualado ou até superior aos Lutadores neste quesito pelo uso de armas no combate."],
            effect: "<b>Uma vez por combate, Mestres de Armas podem esquivar duas vezes seguidas</b>."
          },
          {
            title: "Controle de Energia Amaldiçoada Avançado",
            paragraphs: ["Mais uma vez, exercendo suas plenas capacidades de energia amaldiçoada, se prova capaz de ter um controle dela muito melhor que o restante, mantendo um fluxo constante por todo o corpo e até pela arma, quase inigualável nesse quesito se treinar o suficiente."],
            effect: "<b>Mestres de Armas recebem um ponto de atributo extra na categoria Energia Amaldiçoada</b>."
          }
        ],
        outro: [
          "Usuários de Armas Amaldiçoadas possuem maior facilidade em firmarem uma <b>Restrição Celestial</b> que apaga por completo sua Energia Amaldiçoada em troca de maior bonificação física. Além disso, após alcançar o Raio Negro pela primeira vez, o feiticeiro em questão <b>recebe um ponto de atributo extra na categoria Técnica</b>."
        ]
      },
      {
        name: "Invocadores de Shikigami", kanji: "式", image: "https://i.imgur.com/Lv2uBq4.png",
        paragraphs: [
          "Seja por falta de talento, por falta de sorte para ter uma técnica inata poderosa — ou uma técnica inata em si —, várias razões podem levar um feiticeiro a recorrer ao auxílio de <b>invocações</b>, nome que é dado, fora do espectro japonês, aos <b>shikigami</b> da <b>Terra do Sol Nascente</b>. É dito que no gênesis da feitiçaria, feiticeiros aprenderam não só a exterminar maldições, mas também a domesticá-las e atuar ao seu lado, criando uma formação simbiótica de batalha.",
          "Invocadores de Shikigami abraçam todo tipo de feiticeiro de todo grau de competência. Um feiticeiro perfeitamente capaz de lutar por conta própria pode querer aumentar a desvantagem de seus inimigos ao se aliar com uma invocação, assim como feiticeiros nas circunstâncias supracitadas podem utilizá-las para se tornarem úteis."
        ],
        perksIntro: "Tendo ou não técnicas poderosas, os invocadores possuem o seguinte:",
        perks: [
          {
            title: "Especialista em Maldições",
            paragraphs: ["Lidando com criaturas amaldiçoadas vinte e quatro horas por dia, o feiticeiro é capaz de, mais rápido que outros, descobrir a fraqueza de maldições especialmente melindrosas, encontrando aberturas e oportunidades que podem ser aproveitadas por eles e seus aliados."],
            effect: "<b>Invocadores de Shikigami podem requisitar aos narradores uma fraqueza</b> — se houver uma — para ser aproveitada contra um oponente que é um espírito amaldiçoado."
          },
          {
            title: "Conhecimento do Mundo Jujutsu",
            paragraphs: ["De longe, por causa desse ofício, todos os Invocadores de Shikigami são capazes de reconhecer Objetos Amaldiçoados e Armas Amaldiçoadas, distinguindo-as com uma facilidade estranhíssima."],
            effect: "<b>Invocadores de Shikigami podem requisitar aos narradores uma das três informações quando encontrarem um Objeto Amaldiçoado ou Talismãs Amaldiçoados</b>: sua função, seu nome, sua idade ou o que está dentro dele."
          },
          {
            title: "Proficiência em Combate Armado ou Desarmado",
            paragraphs: ["Espada, lança, maça, chakram, adaga, naginata, kama; nada disso está fora da sua alçada. Amaldiçoadas ou não, todos os instrumentos bélicos caem como uma luva em suas mãos, o que te torna um excelente e perigoso combatente, independente de qual arma prefira usar. Caso não opte por nenhuma arma branca, funciona bem como um combatente corpo a corpo, sagrando-se um guerreiro versado em duas artes marciais humanas."],
            effect: "<b>Invocadores de Shikigami devem escolher se terão proficiência em combate desarmado ou armado</b>. Se escolherem a rota das armas, receberão a vantagem “Versatilidade Armado”, se escolherem a rota dos punhos, receberão “Mestre Combatente”."
          },
          {
            title: "Proficiência em Técnicas Amaldiçoadas",
            paragraphs: ["Invocadores de Shikigami possuem uma afinidade inegável com Técnicas Herdadas e Técnicas Inatas, tornando-os plenamente capazes de atingir altos níveis de ranqueamento mesmo no início. Com o passar dos anos, melhora ainda mais seu uso."],
            effect: "<b>Invocadores de Shikigami recebem um ponto de atributo extra na categoria Técnica</b>, se não possuírem técnica, recebem um ponto extra em Expansão de Domínio para Domínios Simples ou Vazios."
          },
          {
            title: "Proficiência em Talismãs",
            paragraphs: [
              "Parte essencial do ofício, talismãs são o fator intermediário entre o usuário e o familiar, podendo conjurá-los através de talismãs inscritos com selamentos práticos que preservam as criaturas em seu interior. Os Invocadores de Shikigami precisam, como obrigatoriedade, dominar essa área, já que seu estilo principal de combate depende da utilização prática de talismãs e do confeccionar competente de shikigami.",
              "Talismãs podem ser criados através de papéis cerimoniais, na forma de tarjas verticais, postos no corpo do conjurador na forma de tatuagens ou através de algum meio, possivelmente através da técnica, para invocar seus companheiros."
            ],
            effect: "<b>Invocadores de Shikigami recebem três pontos de atributo extras na categoria Invocação de Shikigami</b>."
          }
        ],
        outro: [
          "Além disso, após alcançar o Raio Negro pela primeira vez, o feiticeiro em questão <b>recebe um ponto de atributo extra na categoria Técnica</b>."
        ]
      },
      {
        name: "Mestres de Barreiras", kanji: "帳", image: "https://i.imgur.com/OC8YSyR.png",
        paragraphs: [
          "Indivíduos dedicados ao funcionamento de barreiras, aprofundam-se o quanto é possível na área para criar as melhores barreiras e domínios dos feiticeiros em geral. Especializados na criação de domínios simples, expansões de domínio, cortinas e outras técnicas de território. Esses são os estudantes que, antes dos demais, aprendem a fundir sua técnica inata com uma técnica de barreira para criar a fundação de sua expansão de domínio.",
          "Além disso, Mestres de Barreiras são os únicos que podem alcançar a habilidade de executar <b>Barreiras Puras</b> ou <b>Barreiras Bon</b>, versões mais poderosas e largas das barreiras convencionais."
        ],
        perksIntro: "",
        perks: [
          {
            title: "Especialista em Barreiras",
            paragraphs: ["O pilar de todos os estudos, o conceito inicial de barreira é aprimorado o bastante para que o estudante consiga se aventurar em Cortinas, Domínios Simples, Expansão de Domínio e Barreiras Vazias, criando territórios com especificações ou propriedades complexas, trabalhando os valores de um modo muito mais competente e sólido."],
            effect: "<b>Mestres de Barreira podem definir as propriedades de suas barreiras de acordo com sua vontade</b>, seguindo as regras dos números inversamente proporcionais. Ao contrário de outros estudantes, raramente falham."
          },
          {
            title: "Proficiência em Domínio Simples",
            paragraphs: ["Ao invés de utilizar uma Expansão de Domínio completa, os Mestres de Barreiras podem utilizar Domínios Simples para lidar com ameaças imediatas ou estabelecer zonas de até 3x3 quadrados em que vão atacar tudo que entrar nessa área imediatamente, podendo golpear alguém mesmo fora de seu turno."],
            effect: "Sem ter de sacrificar a dedicação em um para aprender o outro, <b>Mestres de Barreira podem utilizar o Domínio Simples de acordo com sua necessidade</b>, mesmo que os custos de Energia Amaldiçoada não se alterem."
          },
          {
            title: "Proficiência em Expansão de Domínio",
            paragraphs: ["A Expansão de Domínio completa de um Mestre de Barreira é evidentemente mais bem estruturada do que a de um feiticeiro comum, algo que torna-se visível a partir das complexidades que eles podem injetar em seus territórios absolutos. É possível criar efeitos complexos, como julgamentos em um tribunal de justiça, com perdas e ganhos, ou efeitos de sorte, como uma slot machine. Além disso, é possível criar condições especiais para a entrada e saída de inimigos."],
            effect: "<b>Mais oportunidades e condições para a Expansão de Domínio</b>, podendo criar efeitos demasiadamente complexos para servir um propósito específico, guiando-se a partir do que é aceito pelo bom senso."
          },
          {
            title: "Proficiência em Cortinas",
            paragraphs: ["Mestres de Barreira são competentes o bastante em seu ofício para nunca falharem na criação de uma Cortina, além de dispensarem o componente verbal que é geralmente recitado para criar a camada negra. Podem usar as definições de entrada e saída mais apuradas que existem, como impedir um único indivíduo em específico de entrar ou sair, mas deixar qualquer outro entrar ou sair, quando lidando com alvos prioritários."],
            effect: "<b>Mestres de Barreira recebem um ponto de atributo extra na categoria Expansão de Domínio</b>."
          },
          {
            title: "Proficiência em Técnicas Amaldiçoadas",
            paragraphs: ["Mestres de Barreira possuem uma afinidade inegável com Técnicas Herdadas e Técnicas Inatas, tornando-os plenamente capazes de atingir altos níveis de ranqueamento mesmo no início. Com o passar dos anos, melhora ainda mais seu uso."],
            effect: "<b>Mestres de Barreira recebem um ponto de atributo extra na categoria Técnica</b>."
          }
        ],
        outro: [
          "Além disso, após alcançar o Raio Negro pela primeira vez, o feiticeiro em questão <b>recebe um ponto de atributo extra na categoria Técnica</b>."
        ]
      }
    ]
  },

  /* ---------------------------------------------------------------- */
  /* Cada período: date (texto da data), aka (opcional, o nome depois de
     "Também conhecido como") e body. No body, cada texto é um parágrafo;
     { list: [...] } vira uma lista destacada. */
  cronologia: {
    title: "Linha do Tempo",
    intro: [],
    events: [
      {
        date: "Ano 1185",
        body: [
          "Nasce <b>Tahoma “Trovão Invencível” Blaska</b>, o primeiro feiticeiro norte-americano e conhecido como o <b>Príncipe Prometido</b>; fruto de duas tribos diferentes que, até então, guerreavam. Uma vez aliados, o fim das hostilidades fizeram-nos perceber que a criança que viera ao mundo era muito mais do que só um deles; Tahoma era capaz de controlar o clima, e tinha uma compreensão superior acerca do mundo e suas mudanças.",
          "Ele, ao contrário de muitos outros charlatões, era realmente capaz de ver as “mazelas” do mundo, e compreender suas origens, assim como o que o modificava e o impulsionava para frente. Blaska foi não só um guerreiro formidável, mas também um estudioso sem par e um indígena norte-americano verdadeiramente formidável.",
          "Recebeu seu nome pela sua genuína invencibilidade, já que nenhum espírito amaldiçoado, nem feiticeiros jujutsu que surgiram depois dele, foram capazes de vencê-lo em batalha. Blaska acolheu seus aprendizes e os tornou eruditas como ele."
        ]
      },
      {
        date: "Ano 1235",
        body: [
          "As tribos de Blaska foram unificadas em uma só, representando o grupo étnico dos benelutes, que passaram, anos depois, por tantas transformações que perderam sua etiqueta identitária dentre os muitos grupos de nativos-americanos na América do Norte.",
          "Dispensável dizer, a mera existência de Tahoma tornou sua tribo igualmente imbatível em qualquer tipo de disputa por terreno e, um após o outro, os demais grupos indígenas foram sendo dominados, anexados ou aniquilados, por vezes escravizados, por seus rivais. O país beirou um grande desequilíbrio naquele momento, o que fez o jujutsu, como força abstrata, mas consciente, balancear as disputas e criar novos feiticeiros e espíritos amaldiçoados, estes que surgiam diariamente devido a violência generalizada.",
          "Blaska seguiu imperando acima dos demais, matando a oposição e preservando sua própria tribo e família, que não parava de crescer. Naquele período, consolidou-se como o definitivo “Trovão Invencível”."
        ]
      },
      {
        date: "Ano 1250",
        body: [
          "Quinze anos depois, Trovão Invencível resolve peregrinar pelo restante de sua terra, conhecendo as demais culturas que habitavam o mundo enquanto aproveitava o fim de sua vida, já aos setenta anos de idade, bem velho, mas muitíssimo sábio. Blaska refletiu e reconheceu que seu comportamento no passado foi condicionado pelas circunstâncias de seu crescimento, e percebeu que não deveria ter atuado como o tirano que foi, mas não mostrou arrependimento, já que essa foi a razão pela qual seu povo e as pessoas que amava puderam prosperar e viver.",
          "Tahoma aproveitou seus anos finais de vida para tomar cinco esposas e tornar-se o chefe de tribo de cinco grupos distintos, com cada uma, teve um filho, e cada filho, representou as raízes muitíssimo embrionárias do que seria, futuramente, as cinco famílias principais do jujutsu americano.",
          "O legado que deixou para trás, cinco anos depois, quando finalmente morreu, foi a ideia de que seus descendentes deveriam buscar a iluminação espiritual, a paz da mente e o equilíbrio da natureza, trabalhando em comunhão para salvar os inocentes dos espíritos amaldiçoados; as pragas criadas pelos pensamentos negativos e perversos dos homens."
        ]
      },
      {
        date: "Entre os Anos 1260 e 1350", aka: "O Período de Paz",
        body: [
          "Acumula-se um grande período de paz no país ao longo de noventa anos, as tribos trabalharam juntas, intercedendo quando necessário em conflitos de não feiticeiros e preservando o balanço universal dentro de seu continente, ao menos onde era possível e onde sua influência era capaz de alcançar. Os indígenas norte-americanos desenvolveram-se mais rápido do que os outros em questões como barreiras, disciplinas jujutsu e outras formas de exorcismo, ficando para trás, tão somente, da África e do Japão, que já estava bem distante do gênese da feitiçaria.",
          "Xamãs poderosos apareceram naquele período, marcando a história como ancestrais de figuras, ainda hoje, importantes para o Mundo Jujutsu, ao menos no ocidente. São eles:",
          { list: [
            "<b>Wanikiya, o Sábio</b>, uma figura de grande importância na diplomacia entre as tribos. Tornou-se famoso pela sua técnica inata, a Força da Lua, que extraía capacidades super-humanas das fases lunares que regiam as celebrações e festas das tribos. Foi uma figura de grande importância e influência para a história das tribos norte-americanas, tendo em vista que uniu todo o Očhéthi Šakówiŋ, também chamado de Sete Chamas do Conselho, posições de chefia que seus sete filhos e filhas, posteriormente, ocuparam. Formou a fundamental aliança entre sete outros grupos que posteriormente daria início para a organização mais simétrica do jujutsu, englobando os Bdewákaŋthuŋwaŋ, Waȟpéthuŋwaŋ, Waȟpékhute, e os Sisíthuŋwaŋ, além dos Thítȟuŋwaŋ e os Iháŋkthuŋwaŋ e Iháŋkthuŋwaŋna, partícipes de diferentes partes do que hoje é conhecido como Dakota. Era forte como um touro e alto como uma sombra, sendo o ancestral secundário dos Pilestedt.",
            "<b>Mitena, a Artesã</b>, ficou conhecida como Senhora da Guerra, detentora de não só esse, mas outros títulos, como a Inquebrável ou o Espírito de Destruição, que muitas tribos liam como uma encarnação viva da guerra, figura de imponência e poder para destruir, mas também para criar, algo que era refletido diretamente em seus poderes. Parte dos cheyennes, chamados de “Povo Belo”, ela revolucionou o conhecimento comum do que era visto nas guerras dos povos, sendo a mais violenta dos filhos de Tahoma, mas pregadora da virtude de que tudo que fazia era “necessário”. É a ancestral secundária dos Browning;",
            "<b>Apisi, Urso-Búfalo dos Pés Negros</b>, dentre os filhos de Tahoma, possui uma herança especialmente grandiosa. Foi o primeiro feiticeiro do mundo a firmar uma Restrição Celestial, que lhe concedeu um corpo divino. Foi responsável por reunir os Siksika — sua tribo de origem — e os Kainai, encerrando o conflito entre os Aapátohsipikáni (habitantes do norte) e os Aamsskáápipikani (habitantes do sul) seus descendentes tornaram-se orgulhosos membros do coletivo, e chamam-se de Niitsítapi, referidos por vezes dentro do termo guarda-chuva de Blackfoot, ou Pés Negros. É o ancestral secundário dos Holloway, uma família menor que possui parentesco com os Grace, seus ascendentes terciários, que eventualmente casaram para dentro da cultura norte-americana.",
            "<b>Sokanon, a Falcão do Sol</b>, ganhou fama como a guerreira dos algonquinos, figura de maior importância dentro de sua própria tribo e, praticamente, uma chefe de estado. Conciliou todas as tribos localizadas ao nordeste dos Estados Unidos, cumprindo as vontades de seu pai e pregando pela paz acima de tudo, mesmo que tenha sido, após a sua morte, vista como uma figura que gerava angústia e medo aos corações dos que um dia seguiram-na. É a ancestral secundária dos Conway.",
            "<b>Cetanwakuwa, o Totem das Grandes Planícies</b>, era um feiticeiro capacitado em três áreas de expertise simultaneamente e, assim como seus irmãos e irmãs, gozou de grande prestígio ao longo de sua vida. Tornou-se famoso pela sua força inigualável, superada somente por Apisi, o Urso-Búfalo. Cetanwakuwa era um inimigo perigoso pela sua Técnica Amaldiçoada, Multiplicação, que criava réplicas físicas em perfeita exatidão entre si. Com isso, ele criava exércitos indígenas inteiros e era capaz de lidar com qualquer tipo de ameaça. Seus poderes refletiam-se diretamente nas suas reservas abissais de energia amaldiçoada, que permitiam-no se clonar indefinidamente. É o ancestral secundário dos Wayne, família que herdou sua capacidade de clonagem e depois se casaram com os Wolfe, que ingressaram na cultura norte-americana."
          ] }
        ]
      },
      {
        date: "Entre os Anos 1380 e 1440", aka: "O Período de Conflito",
        body: [
          "O legado de Tahoma começou a se desfazer quando a ambição do homem cresceu dentro daqueles que herdaram sua vontade, não pela influência de seus líderes, mas sim pela inquietação de seus membros, que cada vez mais capazes em jujutsu, começaram a refletir acerca da dinâmica de poder entre as tribos e a teoria sempre presente de que o mais forte toma o que o fraco não é capaz de manter. O reflexo instintivo começou a, em um efeito manada, se revirar dentro do âmago de todo homem e mulher capacitado a executar jujutsu, e logo o xamanismo se tornou uma ferramenta de interferência humana, e não um acessório para a manutenção do equilíbrio.",
          "Disputas e rivalidades passaram a surgir com cada vez mais frequência dentro das tribos, e assim como em todos os aspectos do jujutsu, os Cinco Virtuosos foram sucedidos pelos Cinco Viciosos, renovando o ciclo de grandiosidade entre as tribos que não mais buscariam harmonia e paz, mas sim escavaram as raízes mais profundas de suas origens e reviveram a ferocidade de Tahoma Blaska, descartando o erudita e usando a vontade do Trovão Invencível, que varreu as Grandes Planícies com sua ira e poder.",
          "De pouco conhecimento dos nativos naquele momento, os exploradores do outro lado do oceano preparavam-se para, ainda naquele século, iniciar suas viagens através do globo. A catástrofe se iniciou pelas mãos dos próprios habitantes da América do Norte, e ela viria, após isso, pelas mãos dos europeus.",
          "Na Grande Guerra das Cinco Tribos surgiram os seguintes usuários de maldição:",
          { list: [
            "<b>Hinto, a Fera Carmesim</b>, detentor de uma técnica amaldiçoada que invertia os valores de qualquer conceito aplicável, podendo alterar em menor escala aspectos como velocidade, gravidade, massa ou tempo. Era uma técnica simples, mas forte. Ele tornou-se famoso por, em suas palavras, ser a encarnação viva de Mitena, mesmo que não tenha sido o caso.",
            "<b>Ayita, o Espectro dos Lagos</b>, poderosa usuária de maldição que distorceu a promessa de paz feita por seus pais, era capaz de utilizar enfermidades e agouros para incapacitar e neutralizar seus oponentes. Tantos foram os mortos por ela que o sangue que escoou dos cadáveres na batalha do Cume da Sombra Estrelada foi capaz de formar um lago vermelho e vívido, fonte de muitos dos espíritos amaldiçoados que surgiram naquela época.",
            "<b>Kanti, a Loba do Sol</b>, maquinadora do crime mais hediondo entre as tribos, Kanti foi a primeira filha de Sokanon, que antecipou o início dos conflitos e tentou pará-los, mas foi assassinada pela sua própria cria, uma feiticeira que treinou e ensinou da maneira que pode. A Loba do Sol é uma figura tão viciosa que matou sua genitora sem utilizar jujutsu, forçando-a a reencarnar como um Espírito Vingativo de Grau Especial para assombrar o povo algonquino.",
            "<b>Pana, dos Ossos Negros</b>, primeira utilizadora da herança das Dez Sombras, fora concebida pelo filho de Apisi, herdando parte de seu título, mas nem metade de sua honra. Pana nasceu com uma deficiência corporal temível, sendo relegada a passar todo o seu tempo abaixo das Cachoeiras da Reflexão, onde toda mazela era curada. Suas invocações foram criadas a partir das sombras de sua própria mente, que deu vazão para todo tipo de pensamento maligno e temível; ela foi morta ao tentar domar a última e mais poderosa sombra, falhando no processo de exorcismo ao fim de sua vida, mas não sem deixar uma trilha de corpos e descendentes para trás.",
            "<b>Kohana, a Sombra do Fogo</b>, é a primeira exceção humana a possuir duas técnicas inatas ao mesmo tempo, mesmo que isso tenha custado mais da metade de seu tempo de vida e quase toda sua sanidade. Kohana era um nativo-americano adoecido pelos pensamentos violentos e viciosos, sua vida é marcada não por feitos virtuosos ou honrados, mas sim por crimes hediondos contra a saúde e a inocência de outros. Seu Exército de um Homem Só não auxiliava ou batalhava por uma causa, mas sim para tomar, matar, depredar, destruir, por dentro e por fora."
          ] }
        ]
      },
      {
        date: "Entre os Anos 1493 e 1583",
        body: [
          "Nasce <b>Nikan Yansa</b>, um menino indígena comum, feiticeiro de grande capacidade e potencial, ascendente de Tahoma Blaska. A história de Yansa começa em tom de tragédia, ainda no começo das explorações européias no solo americano, também início do genocídio em massa pelas mãos dos homens brancos, que estavam dispostos a devastar tudo em seu caminho para cumprir o seu propósito final.",
          "Nikan saiu do ventre de uma mulher morta pela varíola, e um Filho dos Mortos é, por si só, sinal de mau agouro. Foi acolhido pelo chefe da tribo da época, que o levou, ao lado de parte de seus familiares, para o oeste, onde os exploradores ainda não haviam chegado e as tropas vindas do sul estavam muito, muito distante de alcançar. A guerra prosseguiu no leste, mas boa parte das forças indígenas foi eliminada pelas doenças que seus assassinos trouxeram, que aliadas ao potencial ofensivo de suas armas de pólvora e espadas de aço, terminaram de dizimar o restante do povo resistente.",
          "O <b>Rei das Maldições</b> tornou-se uma figura controversa a partir de sua adolescência, já iniciado dentro da feitiçaria e sendo conhecido como seu praticante mais formidável, superando até mesmo Tahoma Blaska em seu auge; sua força ultrapassava qualquer tipo de escala posta, sua resistência era divina, sua velocidade não encontrava limites, assim como suas reservas de energia amaldiçoada, que quando aliadas com sua técnica irrevogavelmente perfeita, tornavam-se uma fonte praticamente infinita para amaldiçoar e lutar contra todo tipo de inimigo. Dominou a Expansão de Domínio antes de fazer vinte anos, e foi em seu aniversário de vinte e dois que tornou-se um chefe de guerra.",
          "Yansa conteve o avanço dos homens brancos —não feiticeiros e feiticeiros europeus — sozinho; sua prática era inigualável, o que o fez ser reconhecido como o Demônio dos Agoureiros, que sempre circulavam pelo território de Yansa, junto com os corvos e os abutres que alimentavam-se das carcaças de seus inimigos. Os cadáveres dos inimigos mortos de Nikan geraram mais espíritos amaldiçoados, estes que se voltaram contra os europeus não por vontade própria, mas sim por terem sido condicionados a fazê-lo, o que gerou parte dos mitos contados pelos colonizadores ao leste.",
          "A cruzada de Nikan Yansa, o Rei das Maldições, perdurou até o fim de sua vida, com noventa anos, com todos os seus estudos e avanços sendo guardados dentro de seu corpo. Em sua batalha final, ele praticamente não parecia humano: possuía dez olhos em sua cabeça e, ao uso de sua Técnica Amaldiçoada, era a combinação quimérica de ao menos oito espécies animais diferentes, mitológicos ou não, em um só corpo.",
          "Após sua morte, os feiticeiros brancos tentaram eliminá-lo de uma vez por todas, mas a sua energia era tão grandiosa que a única alternativa restante foi selá-lo a partir de seus dez olhos, separando-os em diferentes partes do país, cada uma com um guardião diferente, para que fosse preservado e Nikan não reencarnasse, liberando mais uma vez sua onda de destruição."
        ]
      },
      {
        date: "Entre os Anos 1583 e 1670", aka: "O Período da Reestruturação",
        body: [
          "Após a morte de Yansa, os exploradores e feiticeiros europeus conquistaram uma nova esperança de continuar seus trabalhos ao longo do país. Já haviam se estabelecido com menos resistência ao leste, e as primeiras colônias já estavam prosperando e ganhando mais habitantes, assim fortalecendo suas raízes e aumentando sua própria força. O povo americano nascido em solo estadunidense mostrou-se capaz de manifestar jujutsu, mesmo que não tivessem, em totalidade, sangue europeu, o que significava que aquele território já estava maculado pela força consciente do jujutsu.",
          "Os xamãs reuniram-se e se separaram, cada um com um olho, nas múltiplas colônias britânicas existentes no leste. As indígenas sequestradas, seja através do casamento voluntário ou de práticas mais nocivas, geraram filhos miscigenados de sangue nativo e europeu, que foi a fundação para as Cinco Famílias do Jujutsu na América do Norte.",
          "Por volta dessa época, os colonizadores criaram famílias menores, ainda famosas dentro da esfera de xamãs americanos, para utilizarem suas próprias disciplinas e repassarem seus próprios ensinamentos, buscando estabelecer uma espécie de hierarquia própria, alheia ao funcionamento do jujutsu europeu, dentro do Novo Mundo.",
          "De lá, surgiram as seguintes famílias:",
          { list: [
            "<b>Holloway</b>, herdeiros das Dez Sombras;",
            "<b>Wayne</b>, herdeiros da Multiplicação;",
            "<b>Barnett</b>, herdeiros da Energia Amaldiçoada Bruta;",
            "<b>Danvers</b>, herdeiros da Técnica do Boneco de Palha;",
            "<b>Iverson</b>, herdeiros da Técnica de Proporção;",
            "<b>McGinnis</b>, herdeiros da Fúria Estelar;",
            "<b>Weyland</b>, herdeiros da Invocação das Bestas Auspiciosas."
          ], compact: true }
        ]
      },
      {
        date: "Entre os Anos 1692 e 1693", aka: "As Bruxas de Salém",
        body: [
          "Durante esse período, a comunidade jujutsu norte-americana quase foi exposta aos não feiticeiros. A época colonial foi revolucionada pela presença de feiticeiras jujutsu ganhando uma maior relevância dentro da sociedade, isso considerando que elas eram grandes antes, ficaram menores após algum tempo e então cresceram outra vez, ganhando uma notoriedade negativa que, combinada com a intolerância religiosa, gerou a morte de pelo menos dezessete não feiticeiros, mais os que foram mortos “ilegalmente” sem um julgamento por parte do conselho.",
          "Os verdadeiros feiticeiros jujutsu eram competentes o bastante para simplesmente não serem pegos nas artimanhas dos humanos, mas algumas poucas crianças mulheres, duas delas, foram julgadas e enforcadas, utilizando seus poderes sem saber que eles eram vistos como uma influência de Satã, o inimigo de Deus na fé cristã.",
          "Por mais que a maior parte das baixas tenha sido contra os não feiticeiros, a quase exposição da comunidade jujutsu forçou aos feiticeiros mais experientes a tomarem alguma iniciativa; as colônias na costa leste foram varridas durante uma noite específica por um agrupamento de jujutsu-shi, que exterminaram os humanos responsáveis pelo julgamento e roubaram seus documentos. O evento ficou conhecido como a <b>Praga Misteriosa de Massachusetts</b>, e precedeu a Constitucionalização do Jujutsu, que veio sete anos depois."
        ]
      },
      {
        date: "Entre os Anos 1700 e 1770", aka: "A Constitucionalização do Jujutsu",
        body: [
          "Nasce a <b>Irmandade Americana de Feiticeiros</b>, um clube secreto composto majoritariamente por homens feiticeiros que se uniram para constitucionalizar a feitiçaria americana, buscando torná-la mais estruturada, organizada e próspera. A motivação de seus atos veio justamente do evento das Bruxas de Salém, quando os feiticeiros, pela primeira vez, correram o risco de serem expostos; distantes da influência e ajuda do Vaticano — que por si só contém uma parcela de feiticeiros poderosos — as novas facetas do cristianismo poderiam prejudicar o funcionamento da comunidade de exorcistas, gerando consequências duradouras que poderiam acarretar em uma guerra contra os humanos.",
          "Distanciando-se da perspectiva de dizimar toda uma espécie, regras foram estabelecidas. Criou-se as primeiras academias de jujutsu dos Estados Unidos, com um colégio em Boston, um na Virgínia, outro na Geórgia e o último na Flórida, com o ato sendo espelhado pelos ocupantes espanhóis que criaram seus próprios colegiados e instituições de ensino.",
          "Foram estabelecidas três regras principais que formaram o pilar que todos os feiticeiros americanos deveriam seguir:",
          { list: [
            "<b>I. Exposição da espécie significa traição</b> — sob hipótese alguma o jujutsu deveria ser revelado aos humanos, e todos aqueles que fizessem algo que pudesse colocar o anonimato em risco, deveriam ser sumariamente executados ou aprisionados o quanto antes;",
            "<b>II. O conhecimento nos serve, não o contrário</b> — no mundo há um tipo de ambição que ultrapassa todas as outras, e desse tipo de ambição surge o mais perigoso dos homens, aquele que não possui meio ou freio de eliminar os demais para alcançar seu objetivo. Qualquer um que colocasse o indivíduo acima do coletivo, deveria ser visto como um inimigo;",
            "<b>III. Exorcistas não se envolvem em conflitos humanos</b> — os agentes do jujutsu reconheceram que a interferência dos feiticeiros nos conflitos humanos poderia acarretar em consequências catastróficas para todos da espécie, mesmo que, visto de uma perspectiva posterior, talvez os primeiros membros da Irmandade Americana de Feiticeiros simplesmente não queriam se envolver em assuntos controversos, como a escravidão ou o genocídio humano contra os outros."
          ] },
          "Todo o sistema foi abrangentemente aceito pela sociedade jujutsu como um todo, sem muitas oposições, senão exceções que surgiam em áreas específicas e não ganhavam muita força. Ao longo dos setenta anos em que ela foi estabelecida até cinco anos antes da Guerra da Independência, os jujutsu-shi embarcaram em uma cruzada de pacificação para eliminar todos os Usuários de Maldição e estabelecer a paz.",
          "<b>Salazar Wayne</b> recebeu a maioria dos méritos por todo o trabalho feito na constitucionalização do jujutsu, e se tornou um dos mais célebres e prósperos eruditas de toda a feitiçaria norte-americana; há uma estátua sua em quase todas as instituições de ensino, para que seus descendentes observem seu grandioso legado, manchado, nos dias de hoje, pela rispidez de Sor Salazar quanto a acessibilidade das mulheres ao ensino de jujutsu."
        ]
      },
      {
        date: "Entre os Anos 1775 e 1783", aka: "A Guerra de Independência",
        body: [
          "Com a vinda da Guerra de Independência Americana, os feiticeiros acabaram por colidir uma vez mais, expondo seus interesses contrários em uma reunião não muito frutífera que acarretou na criação de rivalidades afiadas que perduram até os dias atuais. Os membros do colegiado entraram em conflito com seus colegas de classe europeus, e o contrário também se tornou realidade; mestiços americanos e filhos de colonizadores viram-se diante de uma guerra generalizada que afetou ambos os mundos, isso enquanto a violência desenfreada gerava um desbalanço na produção de espíritos amaldiçoados que permeavam quase todo o país durante a guerra.",
          "O exército de George Washington contava com um corpo de vinte e nove feiticeiros naturais americanos, enquanto o outro lado, o europeu, tinha um número bem mais positivo em suas escalas, contando com quarenta e sete feiticeiros europeus ingleses, um deles, o portador da <b>Excalibur</b>, a arma amaldiçoada suprema, utilizada anteriormente por Carlos Magno.",
          "Os maiores conflitos de feiticeiros se deram no Cerco de Boston e na Campanha de Nova Iorque e Nova Jérsei, respectivamente. O conflito dos dois exércitos resultou em perdas grandiosas para ambos os esquadrões de exorcistas, com os americanos levando vantagem na primeira batalha, mas os europeus conquistando a maior parte dos abates na segunda luta.",
          "A terceira colisão entre os dois grupos de jujutsu-shi ocorreu na Batalha do Tribunal de Guilford, em que as forças de Cornwallis foram responsáveis por derrubar o exército numerosamente maior dos americanos em um conflito árduo e especialmente disputado. <b>Ben Cromwell</b>, em posse da Excalibur, utilizou sua arma para eliminar os últimos três feiticeiros da corporação adversária, cortando a cabeça de Harold Green, Oswald Wayne e Edward Wayne, um trio especialmente poderoso. Após isso, a Europa removeu seus guerreiros do continente e a guerra progrediu normalmente até o seu fim, com o tratado assinado pelos envolvidos."
        ]
      },
      {
        date: "Entre os Anos 1812 e 1815", aka: "A Guerra Anglo-Americana",
        body: [
          "Após alguns anos de relativa paz mas grande animosidade entre as famílias de jujutsu americano e britânico, os feiticeiros finalmente tiveram seu impasse resolvido — ou a possibilidade de fazê-lo — quando a guerra Anglo-Americana aconteceu, contando com a participação de outras famílias de feiticeiros que foram responsáveis por fomentar o início da guerra.",
          "As árduas restrições da Marinha Real junto com a disputa ególatra e pendências não resolvidas geraram uma Batalha de Feiticeiros que ocorreu durante o período, com a comunidade dividindo-se entre aqueles que queriam encerrar a guerra ao lado dos não feiticeiros e aqueles que estavam dispostos a batalhar até o fim, ou até onde fosse necessário, para recuperar sua glória. Ben Cromwell retornou ao continente com as honrarias que eram devidas a ele, e dedicou-se a resolver sua pendência final com outro Wayne, exceto pelo fato que agora era uma menina.",
          "A sociedade de exorcistas mostrou-se menos egoísta e centrou seus esforços para o extermínio de espíritos amaldiçoados, liquidando algumas maldições de classe especial que alimentavam-se da amargura humana desde o conflito anterior, e agora tinham ficado ainda mais forte, ficando conhecidas como as <b>Seis da Costa Leste</b>, onde centravam-se seus respectivos territórios. Na história do jujutsu americano, estas seis maldições foram uma das primeiras completamente conscientes, e diziam ser reencarnações de soldados caídos que se recusaram a morrer.",
          "Batalhas navais e terrestres mancharam o continente e o oceano com sangue de feiticeiros e não feiticeiros e, com o fim da guerra, as coisas finalmente puderam se acertar. Benjamin Cromwell foi derrotado por <b>Elspeth Wayne</b>, que mesmo sem um treinamento formal, desenvolveu-se na arte da feitiçaria com seu autodidatismo, usando suas réplicas para acelerar seu processo de aprendizado e evoluir mais rápido que os demais.",
          "Por conta de seus feitos, Elspeth introduziu um pedido formal para que as mulheres americanas fossem educadas dentro das instituições de ensino jujutsu, assim como os rapazes eram. Após uma avaliação breve da Irmandade de Feiticeiros da América a requisição foi aceita e formalizada, com a igualdade da possibilidade de ensino sendo distribuída tanto para rapazes quanto para moças. Nessa época, houve uma grande prosperidade e fortalecimento de relações entre as famílias, já que agora os herdeiros e herdeiras de suas respectivas famílias poderiam formar laços desde muito cedo."
        ]
      },
      {
        date: "Entre os Anos 1850 e 1890", aka: "O Velho Oeste e o Jujutsu",
        body: [
          "Pouco é documentado acerca da Guerra de Secessão e o período do Velho Oeste, mas os Weyland surgiram durante esse período de muitos conflitos e intrigas dentro da sociedade jujutsu e um grande ponto de importância na história dos Estados Unidos."
        ]
      },
      {
        date: "Entre os Anos 1917 e 1918", aka: "A Primeira Guerra Mundial",
        body: [
          "Reduzindo o impacto de todas as outras guerras anteriores até aquele momento, a Primeira Guerra Mundial é o reflexo exato do que o grande desbalanço de energia negativa pode gerar no mundo inteiro. Quando os conflitos se iniciaram, o índice de surgimento de maldições foi alavancado e ascendeu de forma astronômica, produzindo inimigos de classe especial que infestaram os campos de batalha, os vilarejos, as cidades atingidas e as pessoas que, na cidade, remoeram a própria alma com angústia, tristeza e raiva.",
          "O dormente <b>Conselho Mundial de Jujutsu</b> teve de convocar uma reunião emergencial, atraindo todos os feiticeiros de todos os países para que todo o coletivo pudesse dedicar seus esforços para Europa, já que o conflito “poderia gerar consequências catastróficas, talvez apocalípticas, caso nada seja feito com velocidade”. Dito e feito, com a interferência ou não dos não feiticeiros, os exorcistas moveram-se até o continente necessitado e iniciaram uma outra versão da Grande Guerra, a <b>Grande Guerra das Maldições</b>.",
          "A guerra uniu os Pilestedt, os Browning, os Conway, os McGinnis — que ganharam ainda mais notoriedade nos anos seguintes — os King, Weyland, Barnett, Danvers, Holloway e mesmo antigos rivais, como os Cromwell e os Wayne, que lutaram no front ocidental. Além disso, outras famílias de valioso destaque são os Tomarchio, os Puro e os Montesano, com o segundo sendo a família criada pelo classe especial Tiberio Rocco, o Touro de Bronze e a última família sendo da casta real de Valeria Della Croce, a Duquesa da Itália e classe especial.",
          "Da África, Mossam Shadid enviou suas duas filhas, Dalia e Yasmin, para a batalha, enquanto o primo das duas, Akabu Langenhoven, ia para a batalha com o Chicote de Mil Laços, subjugando os adversários da humanidade com a Técnica de Vínculo.",
          "Os russos também não deixaram de contribuir, enviando os rivais Ivan Arseniyv e Alexander “Sasha” Kondrati, o último com a infame Técnica do Pesadelo, que o permitia transformar em realidade tudo que sonhava, de objetos materializados até horrores além da imaginação humana, uma técnica que coube bem com sua memória eidética, ganha através da genética."
        ]
      },
      {
        date: "Ano 1933",
        body: [
          "No ápice da Grande Depressão, os Estados Unidos encararam seu primeiro grande desafio do mundo jujutsu, que fugiu tanto de controle que era uma tarefa praticamente impossível exorcizar todas as maldições que estavam surgindo diariamente sem chamar a atenção dos humanos, então os feiticeiros tiveram de, pela primeira vez, formar uma aliança temporária com o governo do Estados Unidos para conseguirem operar com tranquilidade e certos de que não sofreriam uma represália inesperada por parte dos exércitos.",
          "Recebendo a identificação de agentes federais ou a força policial, os feiticeiros puderam começar o <b>Festival de Dez Noites</b>, que começou em quatorze de maio de 1933 e perdurou até vinte e quatro de maio de 1933, uma batalha longa e duradoura que se concentrou nas maiores capitais do país até que todas as maldições fossem definitivamente exterminadas. O governo evacuou as localidades com antecedência, gerando a discrição necessária aos feiticeiros, que começaram seu trabalho de exorcismo generalizado.",
          "Grandes feiticeiros morreram durante o conflito, mas muitos outros ascenderam ao status de grande prestígio no processo, afamando-se ao longo dos Estados Unidos e recebendo honrarias do próprio governo. Para se ter uma ideia do quão grandiosa foi a luta, os números das maldições superaram, por cidade, mil espíritos amaldiçoados para um grupo seleto de feiticeiros combater."
        ]
      },
      {
        date: "Entre os Anos 1941 e 1945", aka: "A Segunda Guerra Mundial",
        body: [
          "A Grande Guerra, agora chamada de Primeira Guerra Mundial, empalideceu uma vez mais, como se fosse outro conflito qualquer, diante da maior batalha travada por humanos desde os tempos antigos, com exércitos de várias nações colidindo diariamente em trincheiras e campos de batalha sangrentos e cheio de revoluções tecnológicas, mas também lotado de espíritos amaldiçoados que surgiam da imundície, do medo e do ódio. Mais uma vez, os efeitos da guerra anterior reverberaram com mais força na segunda, gerando as ditas consequências catastróficas que não puderam ser remediadas em totalidade graças ao conflito difundido mesmo entre feiticeiros.",
          "O Japão destruiu Pearl Harbor e, com isso, os Estados Unidos entraram na Segunda Guerra Mundial, influenciando seu curso pelo restante do conflito; Adolf Hitler buscava seu espaço vital na Europa, virando-se contra a Rússia, seu aliado inicial, para tomar seu território, uma decisão crucial que se resumiu em um erro crasso, uma vitória para a humanidade e uma árdua derrota para o Terceiro Reich.",
          "A ingressão do país no conflito quase gerou uma guerra em larga escala contra o Japão, que continha alguns dos feiticeiros mais poderosos do mundo sob seu comando na época, mesmo que os Estados Unidos também possuísse um contingente bastante poderoso, o resultado da batalha era imprevisível e arriscado, o que forçou a interferência do Conselho Mundial de Jujutsu, que reconheceu que não poderia perder seus guerreiros mais poderosos em uma briga egoísta e que não teve influência direta dos feiticeiros.",
          "Por outro lado, Hitler utilizou os feiticeiros alemães e patrocinou sua entrada no chamado <b>Esquadrão Eixo de Feitiçaria</b>, que contava com alguns nomes perigosos. As dez famílias alemãs aliadas ao Terceiro Reich naquele período eram:",
          { list: [
            "<b>Família Bluhm</b>, com quatro membros, duas meninas e dois meninos. O herdeiro era Friedrich Bluhm, com a técnica de manipular a radiação;",
            "<b>Família Hohenstein</b>, com oito membros, Griselda e Klaus Hohenstein eram matriarca e patriarca, com seis filhos ao todo. O herdeiro era Lionel “Lio” Hohenstein, com a técnica de regulagem de densidade;",
            "<b>Família Möhring</b>, com três membros, Walrus e Freya Möhring, dois não feiticeiros com um filho da Juventude Hitlerista, que ficou conhecido como o prodígio da geração alemã, Klaus Möhring, com a técnica de controlar fótons;",
            "<b>Família Von Braun</b>, com cinco membros, quatro deles nunca foram revelados e vivem em anonimato, mas a herdeira tinha o nome de Anne Marie Von Braun, com a técnica de acessar o poder espiritual do que ela chamava de “dimensão jujutsu”, de onde vinha o poder de todos os xamãs;",
            "<b>Família Wolfe</b>, com três membros, Hermann Wolfe era o chefe da família e um dos membros mais fortes do Esquadrão Eixo. Também foi o traidor da corporação alemã, eliminando todas as outras nove famílias durante uma reunião em um bunker escondido. Tinha a técnica de criocinese;"
          ] },
          "Além das cinco, as outras de menor renome eram os Bierwirth, os Steinhauer, os Lindemann, Walbaum e Loeb. Suas habilidades nunca foram dissecadas, mas acredita-se que eram, sim, tão poderosas quanto os demais, só menos famosas. A Segunda Guerra Mundial gerou a <b>Segunda Grande Guerra das Maldições</b>, um evento apoteótico que gerou uma separação ideológica e política de muitas famílias que aliaram-se — ou não — com seus respectivos tiranos ou líderes de guerra. Os italianos permaneceram omissos diante do chamado de Mussolini, reconhecendo sua causa perdida; os japoneses não atuaram em nome de Hirohito, mas participaram da defesa de suas fronteiras para evitar um ataque catastrófico de dentro, ciente da força dos feiticeiros chineses.",
          "Quanto ao leste europeu, a grande lenda do Baba Yaga ganhou uma fama vultosa que injetou o mais puro medo nos homens que participaram da Operação Barbarossa. O veterano de guerra, <b>Sasha Kondrati, o Homem-Pesadelo</b>, utilizou suas habilidades para defender, sozinho, a Rússia de qualquer invasão por terra que fora tecida pelas forças alemãs. Muitos boatos cercaram o Mundo Jujutsu após essa situação em específico, já que suas respectivas sociedades e instituições perceberam que, diante todas aquelas guerras, era questão de tempo até que os países não mais levantassem armas uns contra os outros, mas sim feiticeiros jujutsu.",
          "Quando um soldado alemão, também feiticeiro, foi questionado acerca do confronto com Alexander Kondrati ele respondeu algo como: “Nunca em minha vida eu vou encontrar algo tão aterrorizante quanto ele. Fomos dizimados, criaturas de outro mundo, vindas do lado mais obscuro da mente do Baba Yaga, devoraram todos nós como se fossemos crianças.”.",
          "Para todos os efeitos, essa afirmação foi um dos pilares para a posterior Guerra Fria Jujutsu, que alteraria os polos de poder e reafirmaria a presença dos xamãs dentro de seus respectivos países e os confrontos que eles poderiam encontrar."
        ]
      },
      {
        date: "Entre os Anos 1947 e 1989", aka: "A Guerra Fria Jujutsu",
        body: [
          "Dois anos após o fim da Segunda Guerra Mundial, os Estados Unidos trouxeram cientistas, geneticistas, estudiosos e feiticeiros alemães para seu país, acolhendo-os e trocando a segurança oferecida pelas informações e os estudos em progresso que seriam direcionados às armas usadas contra os Aliados. A tensão geopolítica estava chegando em seu ápice com o desenvolvimento tecnológico, envolvendo a disputa armamentista e a corrida espacial que ganhava uma força crescente, mesmo que a URSS estivesse dando passos largos na direção do progresso, a América também teve seus avanços marcantes.",
          "O Conselho Mundial de Jujutsu interferiu outra vez, agora buscando aliviar a tensão política entre os Estados Unidos e a União Soviética, tendo em vista que o Império do Japão foi dissolvido e entrou em desgraça, mesmo que seus feiticeiros estivessem em uma boa fase que não foi afetada nem atrasada pelas mazelas que atingiu o público comum, senão o óbvio obstáculo de agora lidarem com a crise econômica, que gerava danos emocionais tão contundentes que os espíritos amaldiçoados começaram a se proliferar como baratas.",
          "Uma série de conflitos e brigas menores se espalharam em diversos pontos do globo, principalmente nas guerras financiadas pelos dois países em disputa; a ameaça nuclear era quase tão grande quanto a ameaça de feiticeiros jujutsu, considerando que alguns de classe especial são capazes de varrer uma cidade sozinhos, e eles eram bem, bem numerosos. Não havia defesa para uma barreira, tampouco uma defesa para as habilidades absurdas que os jujutsu-shi manejavam.",
          "Logo, eles se tornaram exatamente o que fora previsto: instrumentos de guerra, elementos dissuasivos que impediam uma nação de exterminar a outra na busca pelo poder. Enquanto o homem via somente a camada superficial da corrida da Guerra Fria, os governos e seus respectivos feiticeiros passavam por um grande período de guerras localizadas, troca de maldições e muitas batalhas de feiticeiros. Felizmente, nada de muito grandioso ocorreu."
        ]
      },
      {
        date: "Entre os Anos 1990 e 2015", aka: "O Período de Renovação",
        body: [
          "Assim como em muitos outros países, o jujutsu deixou de ser uma constituição a parte e segregada somente ao conhecimento de feiticeiros, passando a atuar com os líderes políticos da nação sob o segredo de estado geral, evitando uma histeria da população americana — ou de qualquer outro lugar —, o que forneceu um período prolongado de paz que não era visto há muitos anos. As instituições de jujutsu foram criadas e receberam grandes territórios para a formação de seus alunos, que eram instruídos acerca da necessidade do anonimato e para não apelarem ao desejo de notoriedade.",
          "O <b>Conselho Superior de Feitiçaria dos Estados Unidos</b> finalmente foi oficializado e ganhou uma cadeira e representação geral dentro do congresso, com as decisões sendo avaliadas e remediadas pelos feiticeiros, que averiguavam os riscos e as possíveis represálias que uma atitude específica poderia gerar dentro da sociedade.",
          "Aos feiticeiros que faziam parte do corpo de trabalho de exorcismo foi criada a <b>Associação de Feiticeiros da América</b>, com compensações monetárias, planos de carreira, férias e outros benefícios entregues aos trabalhadores formados ou não pelas universidades espalhadas pelo país; ser um feiticeiro jujutsu tornou-se um trabalho integral e oficial, um avanço que ainda não era presente em outras nações, mas que foi aplicado, primeiro, dentro dos Estados Unidos.",
          "Para os feiticeiros mais jovens e para o corpo de estudantes, foi criada a <b>Universidade de Feiticeiros da América</b>, uma instituição multilocalizada com filiais acessíveis e planos de estudo gratuitos, com bolsas que contemplavam todo tipo de situação social. Para além disso, os agentes da AFA que se comprometeram com a tarefa de ensino eram remunerados com o salário de jornada dupla, conseguindo mais alguns benefícios credenciados pelo governo.",
          "O Período de Renovação do jujutsu na América do Norte foi um dos mais bem-sucedidos de todo o mundo, gerando profissionais competentes e exorcistas de grande renome no ocidente, em que o jujutsu estadunidense era definitivamente um dos mais poderosos, disputando frequentemente com o Brasil pelo primeiro lugar dentre as nações das Américas."
        ]
      },
      {
        date: "Ano 2023", aka: "A Colheita de Sangue",
        body: [
          "O fim da trágica <b>Colheita de Sangue</b> culminou na destruição completa do Japão, que se encontra preenchido por mais maldições do que se é possível contar. Prédios destruídos estão por todos os lados, e a terra abatida abaixo dos pés dos feiticeiros está cheia de sangue, dor e sofrimento. A morte de muitos feiticeiros japoneses foi espalhada pelo Mundo Jujutsu, já que o país recebia intercambistas de outras nações em seu período letivo.",
          { list: [
            "<b>Ryuma Tsurayaba</b> foi um dos mortos, reconhecido como o Feiticeiro Mais Poderoso do Japão, desapareceu sob circunstâncias misteriosas;",
            "<b>Gö Mochizuki</b> desapareceu do solo japonês e seu paradeiro é desconhecido. É reconhecido pelas outras nações como um Usuário de Maldição de Classe Especial;",
            "<b>Senko Ren</b> padeceu durante a explosão do centro de Tóquio, seu corpo foi encontrado ao lado do que acreditava ser a reencarnação física de Araki Kensuke;",
            "<b>Gecho</b> foi caçado por alguns feiticeiros estrangeiros franceses, matou uma dezena destes antes de ser finalmente abatido, morto pela Excalibur;",
            "<b>Senko Jun’ichirou, Tsuzuki Matabei, Kitagawa Gen’ichi e Dakaki Kikirika</b> foram mortos, apesar dos últimos, conhecidos como Dark King e O Devorador, terem concluído seus planos;",
            "<b>Mori Kaishin e Nishikawa Mei</b> foram caçados pelo governo chinês e abatidos durante sua fuga. O filho dos dois foi, para propósitos profissionais, morto ainda jovem;",
            "<b>Katsuragi Yuno</b>, responsável por boa parte dos mortos-vivos caminhantes pelo solo japonês também morreu. Foi encontrada, já sem vida, dentro de uma cachoeira no interior do Japão. Não se sabe o que ocorreu;",
            "<b>Dio Bernolli</b>, anteriormente conhecido como Ogaya Gonjuro, foi morto e seu corpo foi devolvido para a Itália, onde ele foi enterrado ao lado de outros feiticeiros intercambistas;",
            "<b>Asakawa Minako e Kotaro Arashi</b> fugiram do território japonês, a primeira não teve muita sorte. O Semideus descarregou sua ira em seus adversários como seu último ato, desaparecendo para alguma região no ocidente;",
            "<b>Wakura Shoichi, Wakayama Yusa e Kaji Haruo</b> foram assassinados por feiticeiros brasileiros, respectivamente: Michel Cunha, Gabriel Perroni e Paulo Bragança, que retornaram para casa após o resgate de Iberê Cayubi, que delatou a localização dos outros feiticeiros japoneses;",
            "<b>Akagi Ryota e Ishikawa Misaki</b> foram aprisionados e depois executados pelas forças britânicas que foram limpar o país — Kurohara Take foi morto após alguns dias de fuga e duelo, e sua morte culminou no abate, também, de Hoshimiya Boichi;",
            "<b>Takahashi Asami</b> foi levada sob custódia para os Estados Unidos, onde foi inquirida acerca de sua participação no ato terrorista japonês e sua contribuição para a Escola Técnica de Feitiçaria, que foi reconhecida como um séquito de terroristas;",
            "<b>Ishida Ayako</b>, em um grupo com Hiroyuki Ito e Akihiko Oda, foram capturados pelos feiticeiros italianos que competiram no Torneio Mundial. A estratégia de Quasimodo Patalano em conjunto com Silva Tomarchio demonstrou-se mais uma vez invencível, superando a Cópia e a habilidade física dos outros dois;",
            "<b>Nakamura Haruki</b> foi responsável por fugir até a China ao lado de Kurohane Sora, ambos estão sob custódia do governo do país. Yoshida Yoru foi morto pelas forças africanas que participaram do coletivo de limpeza;",
            "<b>Sanjou Nori</b> foi resguardado pelos seus companheiros de outros países, que ofereceram asilo para o ferreiro em troca de colaboração nas investigações e um serviço para a produção de ferramentas amaldiçoadas. Para preservar o legado de sua família e seu ofício, Nori aceitou a oportunidade e atualmente se localiza em Londres;",
            "Para evitar o nascimento de outras aberrações da natureza, o <b>clã Fukuda</b> foi rastreado e eliminado por completo, encerrando a herança do Azul, do Vermelho e do Infinito. Campanário, maldição de Classe Especial, foi morta ainda durante os eventos da Colheita de Sangue."
          ] },
          "<b>Príncipe Asahito</b> foi um dos últimos a morrer, batalhando ao longo de dias pela glória de seu país ao uso das Três Ferramentas Celestiais. Ele deixou o legado de resiliência que é seguido pelos descendentes japoneses ou fugitivos ainda não encontrados de que a vontade da Terra do Sol Nascente ainda vive. O resultado catastrófico da Colheita de Sangue eliminou dois países."
        ]
      },
      {
        date: "Ano 2024", aka: "A Herança Maldita",
        body: [
          "Quase um ano depois do Fim do Japão, o mundo ainda se recupera das mazelas e lacunas que foram deixadas pelo conflito. Muitos feiticeiros visitantes do Torneio Mundial foram mortos no processo, e praticamente toda a população do Japão foi exterminada ou transformada em maldições irracionais, que vagueiam pela Terra de Ninguém em busca de algum humano para amaldiçoar. Praticamente todos os jujutsu-shi da nação estão presos, mortos ou desapareceram misteriosamente, deixando uma pulga atrás da orelha da maioria das nações, já que eles sabiam que muitos feiticeiros japoneses eram bem poderosos.",
          "Com a morte de Gö Ryosuke, o Feiticeiro Mais Poderoso e do segundo candidato ao posto, Senko Jun’ichirou, o balanço de poder foi descentralizado, e o Japão já não tem mais condição alguma de disputar pelo pódio com as demais nações, que se aproveitaram de seu estado fragilizado e resolveram cortar o mal pela raiz. A Índia foi dizimada por uma bomba espiritual, reduzindo a população mundial para um pouco mais de 6.425.876.183 (seis bilhões, quatrocentos e vinte e cinco milhões, oitocentos e setenta e seis mil, cento e oitenta e três) habitantes. Diversos grupos terroristas e rebeldes surgiram com a dizimação dos dois países, além da revolta de outros países que não necessariamente concordaram com o posicionamento do Conselho Mundial de Jujutsu.",
          "Além disso, o jujutsu foi derradeiramente exposto ao mundo não feiticeiro, sem qualquer oportunidade de esconder o que aconteceu no Japão. Com a revelação chocante, todo o público humano ainda trabalha em processar o fato de que uma outra espécie com super-poderes coexistia ao lado deles, e o governo nunca se importou em explicar ou revelar a situação aos seus habitantes. O governo americano passa por mais processos do que pode contar, e motins e manifestações se espalham ao longo de todo o mundo, junto com o início de uma onda de ataques terroristas que deve ser neutralizada o quanto antes para evitar que toda a coisa tome proporções maiores.",
          "Com isso, surge a pergunta do que a nova geração de jujutsu será capaz de fazer, tendo em vista que eles, mais do que qualquer outra geração, lidarão com a exposição de seu ofício e a mistura de suas vidas profissionais e acadêmicas com a vida social; a tão sonhada notoriedade que alguns desejavam chegou, e disrupção de duas raças distintas finalmente se encontrando terminará em admiração ou violência.",
          "Por essa razão, os anciões do conselho jujutsu alegam que o Japão deixou, para o mundo inteiro, uma <b>Herança Maldita</b>."
        ]
      }
    ]
  },

  /* ---------------------------------------------------------------- */
  /* A página é dividida em grupos. O primeiro grupo usa o título e a intro
     do topo da página. Cada família: name, crest (kanji decorativo),
     paragraphs, receives (linhas "Recebe…"), holders (opcional, lista de
     portadores) e technique { name, paragraphs }. */
  familias: {
    title: "Os Cinco Grandes",
    intro: [
      "Além do Japão, mesmo que não sigam os exatos dogmas e costumes, formaram-se famílias que preservaram dentro de seus âmbitos parentais os segredos da feitiçaria. Essas famílias tornaram-se grandemente influentes em função de seus poderes geralmente absurdos, o que os colocava no topo da categoria de caçadores de maldições, ofício que tornou-se surpreendentemente estimado e requisitado nos Estados Unidos.",
      "A troca da balança de poder e a grande influência de impactos globais no Mundo Jujutsu criou um movimento político completamente novo, em que os Estados Unidos, o Reino Unido, a Coreia do Sul e o Brasil disputavam entre si o posto de país mais relevante, influente e poderoso no jujutsu.",
      "São <b>cinco</b> as famílias de feiticeiros dentro dos <b>Estados Unidos</b>, todas possuindo uma ascendência em comum com <b>Tahoma “Trovão Invencível” Blaska</b>, nativo-americano miscigenado, fruto de duas tribos diferentes, que peregrinou ao longo do país muito antes da colonização americana. Seu sangue foi passado ao longo de gerações, até que fosse mesclado ao dos homens brancos, que utilizaram seus poderes não como meios de alcançar valor espiritual, mas para exorcizar as maldições que surgiam ao longo dos séculos."
    ],
    groups: [
      {
        title: "",
        intro: [],
        items: [
          {
            name: "Família Pilestedt", crest: "幻",
            paragraphs: [
              "A <b>família Pilestedt</b> é conhecida por manejar as situações por debaixo dos panos. A técnica de seus usuários é herdada através de uma maldição ocular, entregando-lhes olhos caleidoscópicos que induzem aos seus oponentes ilusões diversas. A família é conhecida por nunca ter entrado em uma guerra justamente por essa razão; seus conflitos se encerram antes mesmo de começar, já que dificilmente alguém consegue constatar que está sob o efeito de uma ilusão do clã.",
              "Possuem grande influência dentro do <b>Conselho Superior de Feitiçaria dos Estados Unidos</b>, palpitando na entrada de estudantes dentro do campus, assim como sua permanência. Seus membros geralmente trabalham como professores ou seguranças, pela sua capacidade inigualável de conter sujeitos antes mesmo que eles agridam alguém.",
              "Atualmente o herdeiro da família é <b>Carl Pilestedt</b>, o <b>Observador Venerável</b>, <b>Agente de Classe Especial</b> da <b>Universidade de Feiticeiros da América</b>. Ele é responsável por ajudar novos agentes em campo, cuidando de seus assuntos."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Ilusão Amaldiçoada",
              paragraphs: [
                "Uma técnica complexa de tom ocular que interfere diretamente no fluxo de <b>Energia Amaldiçoada</b> do adversário, criando uma disrupção cerebral que o afunda em miragens ilusórias de caráter profundo e denso. A duração das ilusões está diretamente associada com as reservas do feiticeiro, tornando-o capaz de manter alguém preso de acordo com a robustez de suas capacitações.",
                "Muitos inimigos acreditam estar lutando ferrenhamente contra os feiticeiros da família, apenas para descobrirem que foram, eventualmente, derrotados por eles antes mesmo do combate começar. As ilusões causam dano direto no corpo do indivíduo, criando um ciclo simbiótico em que nada genuinamente acontece, reduzindo as casualidades e a destruição, muitas vezes, para zero.",
                "Apesar de extremamente poderosa, <b>Ilusão Amaldiçoada</b> só funciona contra inimigos que possuam <b>Energia Amaldiçoada</b>, já que ela é necessária para a interferência ser criada dentro do cérebro do inimigo, limitando-o ao espaço teórico e abstrato em que ele acredita estar lutando. Oponentes que não <b>possuam Energia Amaldiçoada ou possuam valores demasiadamente baixos não são afetados</b>."
              ]
            }
          },
          {
            name: "Família Grace", crest: "磁",
            paragraphs: [
              "A família Grace possui raízes britânicas e, desde que eles se declararam como naturais americanos, isso criou uma intriga entre os dois países, que disputam constantemente pelo mérito de ter os Grace como seus feiticeiros. Os poderes da família são, para dizer o mínimo, absurdos. As capacitações de seus membros tornam-os geralmente grandiosos em seus ofícios, e eles transformam-se em caçadores cada vez mais competentes.",
              "A razão disso é que o mundo está cada vez mais moderno, e isso afeta diretamente a utilização de suas habilidades. Os Grace possuem tanta influência quanto os Pilestedt, mesmo que tenham sido enganados em períodos distintos pelos seus competidores diretos. O atual feiticeiro mais forte dos <b>Estados Unidos</b> é <b>Robert Grace</b>, o <b>Apóstata de Ferro</b>, atuando em nome da <b>Associação de Feiticeiros da América</b>, conhecida como <b>AFA</b>.",
              "Seu filho, ingressou recentemente na <b>UFA</b> como calouro, e a instituição como um todo, assim como os colegas, depositam grande expectativa sobre a criança, que dizem que será capaz de obter um controle ainda mais refinado sobre os metais."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Magnetismo Amaldiçoado",
              paragraphs: [
                "Ao criar, com a energia amaldiçoada, perturbações eletromagnéticas em campos amplos, eles são capazes de dominar, dobrar, mover e moldar ligas metálicas magnetizadas de acordo com sua própria vontade. Isso é especialmente útil em combate, abrindo um vasto leque de possibilidades que traduzem-se em técnicas defensivas e ofensivas de acordo com a vontade do usuário.",
                "Ao controlar campos eletromagnéticos, os Grace são um dos poucos capazes de voar com total liberdade, sem o apoio de qualquer objeto, ao simplesmente repelir a força de atração da Terra para colocar-se em posições vantajosas.",
                "A técnica suprema dos Grace é o <b>Óbolo de Aço</b>, em que eles juntam todo material metálico magnetizado em uma esfera maciça e revestida de energia amaldiçoada, que serve para ser propulsionada ou atirada na direção de um inimigo na intenção de esmagá-lo por completo."
              ]
            }
          },
          {
            name: "Família Browning", crest: "鍛",
            paragraphs: [
              "A família Browning tornou-se famosa pela sua capacidade de criar armas de acordo com sua necessidade em campo. O grupo possui uma familiaridade e até certo grau de parentesco com os produtores humanos de armamentos do grupo Browning, mesmo que a empresa seja liderada pelos membros que não possuem qualquer tipo de feitiçaria, já que os líderes não acreditam ser prudente misturar <b>trabalho com jujutsu</b>.",
              "Sua participação em guerras é a mais acentuada, já que eles, pessoalmente, levam vantagem com isso, além de serem guerreiros formidáveis que demonstram aptidão para lutar de longe e de perto. Junto com as outras quatro, é parte do <b>Conselho Superior de Feitiçaria dos Estados Unidos</b>, a <b>CSFEU</b>.",
              "A estudante da <b>UFA</b>, <b>Melinoe Browning</b> é a atual representante da família nas classes mais jovens, demonstrando as maiores notas de sua sala, mesmo que não seja reconhecida, em especial, por sua força. Ela é, em ocasiões especiais, a instrutora de combate da instituição."
            ],
            receives: ["Recebe <b>Energia Amaldiçoada</b> de <b>Ranque 3</b>.", "Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Criação de Armas Amaldiçoadas",
              paragraphs: [
                "Ao tocar um objeto, um feiticeiro Browning é capaz de alterar sua composição material e utilizar toda a matéria-prima encontrada no dito objeto para produzir uma arma desejada; pode ser um rifle de assalto, uma carabina, uma espingarda, pistola ou qualquer outro tipo de arma de fogo. É possível moldar espadas a partir de placas de sinalização ou canhões explosivos a partir de postes encontrados na rua. Quanto maior o objeto, maior o gasto de energia amaldiçoada, que se correlaciona diretamente com o que é investido pelo usuário.",
                "Além de dominarem armas brancas e de fogo, os Browning também possuem uma <b>Expansão de Domínio</b> padronizada que é repassada aos membros, que os autoriza a acomodar o cenário ao redor dentro do domínio e transformar qualquer coisa em uma arma, que passa a funcionar de modo autônomo, sem gasto de energia amaldiçoada.",
                "A técnica especial dos Browning é a <b>Junção Absoluta</b>, em que cinco ou mais objetos são acomodados em um único canhão de braço, que se forma ao redor do feiticeiro. No cano, uma esfera de energia amaldiçoada é formada ao drenar as reservas do utilizador, criando uma esfera de destruição que contempla até <b>dez quadrados</b>, decimando tudo ao seu alcance."
              ]
            }
          },
          {
            name: "Família Conway", crest: "時",
            paragraphs: [
              "Os Conway são, discutivelmente, a família de feiticeiros mais poderosa do Ocidente, esbanjando a capacidade de dobrar o próprio tempo de acordo com suas vontades. A família consegue controlar vários aspectos físicos a partir de sua cronocinese, podendo acelerar ou desacelerar objetos, pessoas e maldições de acordo com sua vontade, além de solidificar o espaço ao seu redor ao torná-lo extremamente lento, assim como hiperacelerar os próprios ataques, tornando-os mais destrutivos.",
              "Os Conway possuem laços com as famílias coreanas, e um de seus membros mais recentes, que inclusive participou do <b>Torneio Mundial</b> e é dito ter interferido nos assuntos do <b>Japão</b>, foi criado a partir de uma troca de culturas e técnicas entre as famílias <b>Conway</b> e os <b>Park</b>, de Seoul. Eles possuem uma grande influência dentro do conselho americano, esbanjando uma cadeira na <b>CSFEU</b>, mesmo que seu interesse maior esteja voltado ao escopo internacional.",
              "O herdeiro da família é o atual <b>Agente de Classe Especial</b> mais poderoso da universidade, <b>Zachary Conway</b>, que executou seu meio-irmão coreano pela sua colaboração com os feiticeiros japoneses na <b>Colheita de Sangue</b>."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Paradoxo",
              paragraphs: [
                "A habilidade principal dos Conway é o <b>Paradoxo</b>, que permite controlar o conceito do tempo em todos os seus aspectos acessíveis. Acelerar o tempo e desacelerar o tempo são as utilizações principais, já que modificá-lo pode acarretar em consequências cruéis. Em face a isso, os próprios mandantes da família injetam proibições através do jujutsu, proibindo terminantemente todos os seus membros de exercerem qualquer tipo de modificação temporal através de suas habilidades, ao custo de sua própria vida, caso o façam.",
                "<b>Fast Forward</b> é a utilização mais ofensiva da habilidade de Paradoxo, significando que pode criar uma hiperaceleração temporal para aumentar a massa de um objeto ou parte do corpo, traduzindo-se em ataques poderosos. Além disso, Fast Forward pode ser utilizado no próprio corpo, criando translocações instantâneas ou travessias extremamente velozes, tornando um Conway competente no feiticeiro mais veloz vivo.",
                "<b>Reverse</b> demonstra um uso mais defensivo da habilidade, podendo tornar objetos, pessoas e inimigos mais lentos de acordo com a necessidade do usuário. Ao utilizá-la, pode tornar alguém lento o bastante para dar a impressão de que a pessoa está mergulhando em âmbar viscoso, se movendo em câmera lenta. É possível retroceder o estado temporal de objetos, além de congelá-los completamente por alguns segundos.",
                "A técnica suprema da família Conway é o <b>Time Lapse</b>, que cria uma disrupção paradoxal em um ataque específico, replicando-o um número infinito de vezes, ou seja, executando um único golpe, mas obrigando seu adversário a recebê-lo um número indeterminado de vezes, definido pelo nexo causal do espaço-tempo que criará um fim obrigatório para o paradoxo, resolvendo-o eventualmente."
              ]
            }
          },
          {
            name: "Família Wolfe", crest: "氷",
            paragraphs: [
              "A última família dentro do comando central do conselho americano, os Wolfe escalaram até o topo da montanha com sua extrema consciência e capacidade. Esbanjando uma técnica teoricamente simples mas extremamente poderosa, eles demonstram-se usuários elementais páreos para os <b>Takahashi</b> do Japão, que são conhecidos por dominarem todos os quatro elementos em simultaneidade.",
              "A família ganhou fama depois de sair da Alemanha ao fim da Segunda Guerra Mundial, originalmente partícipes do <b>Esquadrão Eixo</b>, um destacamento de feiticeiros que operava pelo Terceiro Reich, algo que permaneceu fora dos olhos da população não-feiticeira. Os Estados Unidos, que teceram uma série de alianças com cientistas e militares alemães e os trouxeram fora dos arquivos para suas terras, fizeram a mesma coisa com os Wolfe, que traíram Adolf Hitler e outras três famílias de Jujutsu alemão, indo para o lado dos aliados.",
              "Eles são respeitados até hoje, mesmo que haja certo grau de desconfiança, que está sendo abandonado por completo, em reconhecimento mútuo ao fato de que muito tempo já se passou. O líder da família é <b>Eustacius Wolfe</b>, o <b>Auroque de Gelo</b>."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>.", "Recebe <b>Expansão de Domínio</b> de <b>Ranque 3</b>."],
            technique: {
              name: "Absolute Kälte",
              paragraphs: [
                "A técnica herdada dos Wolfe é <b>Absolute Kälte</b>, nomeado deste modo ainda na Alemanha mas que, em tradução direta, lê-se Frio Absoluto. A técnica se escora nos conceitos abstratos da interação cinética entre a energia amaldiçoada de um indivíduo com os elementos presentes no mundo. Os Wolfe em uma relação simbiótica com o frio, conseguem reduzir a temperatura de locais específicos e criar gelo espontaneamente.",
                "A técnica pode ser usada tanto ofensiva quanto defensivamente, cumprindo uma multiplicidade de papéis para se encaixar nas necessidades do feiticeiro jujutsu. É possível erguer construções de gelo que estão diretamente atreladas com as reservas de energia amaldiçoada do utilizador, tornando-o, nas condições certas, plenamente capaz de moldar objetos, formas, ou guiar os seus ataques com a turbulência elemental.",
                "Assim como os Browning, os Wolfe possuem uma <b>Expansão de Domínio</b> “padronizada” ao uso de seus membros, conhecida comumente como <b>Inferno Congelado</b>. Nele, tudo transforma-se em gelo, e a utilização do elemento não é mais associada com a energia amaldiçoada. Tudo desce para um valor abaixo de cem graus centígrados, tornando-a inóspita para a maioria dos adversários."
              ]
            }
          }
        ]
      },

      {
        title: "Os Primeiros",
        intro: [],
        items: [
          {
            name: "Do “Desmantelar e Partir”", crest: "解",
            paragraphs: [
              "Um feiticeiro comum com uma grande técnica, você é capaz de criar cortes físicos ao seu redor, utilizando dois parâmetros bem definidos para as duas variações da habilidade. Com grande dinamicidade e capacidade de adaptação, o feiticeiro pode utilizar os golpes de longe, de perto ou de média distância, utilizando-os de acordo com a conveniência dentro da batalha."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 3</b>.", "Recebe <b>Energia Amaldiçoada</b> de <b>Ranque 3</b>."],
            holders: { label: "Os Primeiros", names: ["Sato Isamu", "Alexander Kang"] },
            technique: {
              name: "Utilização da Técnica",
              paragraphs: [
                "O cerne de Desmantelar e Partir consiste em utilizar a energia amaldiçoada para criar efeitos de corte diversos no sentido desejado pelo usuário contra objetos, pessoas ou maldições. A técnica como um todo é extremamente simples, o que não a torna menos poderosa. Ela cobre distâncias curtas, médias e longas, já que os cortes só são desfeitos quando são aplicados, o que significa que precisam de uma superfície para atingir, ao menos no caso do Desmantelar.",
                "<b>Desmantelar</b> é a utilização a distância, que toma como alvo objetos inanimados, desprovidos de energia amaldiçoada. É especialmente útil para cortar projéteis, carros, partes de construção que sejam jogados no usuário, que também pode utilizar essa técnica para executar cortes na direção de seus adversários que, se entrarem em contato com o Desmantelar, serão cortados, ou até divididos no meio, dependendo de sua resistência física.",
                "<b>Partir/Clivar</b> é a segunda utilização da técnica, que só pode ser aplicada ao contato físico com um adversário. Ao toque, é possível expandir uma rede de cortes contra uma parte específica do corpo do oponente, que utiliza a energia amaldiçoada do conjurador para se configurar contra os valores de resistência e os valores de energia amaldiçoada do inimigo, conseguindo machucá-lo.",
                "A primeira utilização da técnica exige movimentos de mão para ser aplicada, a segunda, como exige toque, dispensa a ideia de “sentido associado com a mão”, sendo executada assim que o usuário deseja."
              ]
            }
          },
          {
            name: "Da “Transfiguração Ociosa”", crest: "魂",
            paragraphs: [
              "Após o seu nascimento e infância, o feiticeiro se descobriu detentor de uma técnica que desafiava as normas naturais. Ao tocar alguma pessoa ou maldição, pode moldar sua alma de acordo com as próprias vontades, criando precipitações corporais que traduzem-se em deformações que podem matar, debilitar ou curar um alvo permanentemente, de modo que supera, em momentos, a Técnica de Maldição Reversa."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 4</b>.", "Recebe <b>Energia Amaldiçoada</b> de <b>Ranque 3</b>."],
            holders: { label: "O Primeiro", names: ["Vazio"] },
            technique: {
              name: "Utilização da Técnica",
              paragraphs: [
                "A técnica principal da <b>Transfiguração Ociosa</b> leva exatamente esse nome, já que as variações são, em suma, utilizações dos dotes principais. A base da técnica permite que o usuário modifique o corpo de outros para uma série de efeitos, assim como é possível modificar o próprio para se curar, criar deformações específicas ou alterações dinâmicas para auxiliá-lo em combate. É importante ter em mente que todas essas alterações precisam estar em conformidade com a anatomia humana, já que o feiticeiro é incapaz de se modificar de acordo com as próprias vontades como uma maldição.",
                "<b>Multiplicidade de Almas</b> consiste em unir duas almas com uma alta taxa de rejeição — o comum para a maioria delas — e criar um corpo deformado que pode cumprir um propósito específico. O resultado é um pequeno totem de tonalidade marrom e distorcido, bem sólido ao toque. Pode ser jogado como um explosivo, detonando em espinhos longos, pequenos ou projéteis; também pode ser expandido de última hora para criar uma prisão grudenta ou qualquer outro tipo de criação que surja na mente do usuário.",
                "<b>Rejeição Física Espontânea</b> é o resultado de estimular um objeto com alta taxa de rejeição criado pela Multiplicidade de Almas com a energia amaldiçoada, gerando um crescimento espontâneo e progressivo na forma de uma minhoca ou um verme, que pode ter um tamanho diretamente relacionado com a quantidade de energia amaldiçoada depositada nele."
              ]
            }
          },
          {
            name: "O Segundo das “Chamas Amaldiçoadas”", crest: "炎",
            paragraphs: [
              "O “poder de fogo absoluto” fora visto pela última vez em 2017, no Japão, nas mãos de um estudante já morto. Através das misteriosas obras do jujutsu, outro usuário foi reencarnado com aquele poder depois de passar anos sem demonstrar qualquer tipo de técnica inata. O usuário agora descobre a si mesmo como um feiticeiro jujutsu, sem qualquer tipo de conhecimento prévio acerca desse mundo insano de extermínio de maldições e tramas políticas."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            holders: { label: "O Segundo", names: ["Franz Patton"] },
            technique: {
              name: "Utilização da Técnica",
              paragraphs: [
                "<b>Chamas Amaldiçoadas</b> é um poder extremamente danoso se não for controlado, tendo em vista que a mera presença do usuário em uma área com não-feiticeiros pode fazê-los entrar em combustão espontânea pela aura chamejante que o reveste. Além de poder controlar o fogo livremente e gerá-lo a partir de qualquer lugar dentro da área de 10x10 quadrados por padrão, o usuário pode criar ferramentas mais ambiciosas ao uso de seu poder, como <b>Esferas Vulcânicas</b> que podem carbonizar um alvo ou gerar uma detonação magmática de incrível poder de fogo.",
                "Uma manifestação única dessa habilidade é, aparentemente, um “presente” do usuário japonês morto, já que agora o usuário atual pode conjurar <b>Insetos de Chama</b>, insetos de fogo que explodem ao contato e podem usar seu nariz afiado para injetar-se no corpo de algum alvo e detonar à queima-roupa.",
                "A técnica suprema das Chamas Amaldiçoadas é a <b>Liberação Máxima: Meteoro</b>, que cria um meteoro de fogo e matéria vulcânica que despenca a partir da conjuração do usuário até um alvo específico, transformando tudo que toque em cinzas. Em seu pico — considerando os 100% — pode destruir por completo uma larga porção de um bairro como Shibuya."
              ]
            }
          },
          {
            name: "Da “Maré Amaldiçoada”", crest: "潮",
            paragraphs: [
              "Por razões inexplicáveis, o feiticeiro sente uma conexão com outros dois feiticeiros que ele ainda desconhece, mas que receberam seus poderes a partir de uma catástrofe que ocorreu no Japão. Todo feiticeiro minimamente instruído sabe que o jujutsu — lido como conceito abstrato ou não — possui consciência, e desde a destruição da Terra do Sol Nascente e a criação espontânea da população humana convertida em maldições, a natureza da feitiçaria compensou o lado oposto com três usuários de técnicas inatas poderosas."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            holders: { label: "O Primeiro", names: ["Marek Domachesky"] },
            technique: {
              name: "Utilização da Técnica",
              paragraphs: [
                "A <b>Maré Amaldiçoada</b> pode ser lida, também, como a capacidade singular de gerar grandes volumes de água a partir do nada. Ao converter energia amaldiçoada na interação elemental, o usuário é capaz de enviar enxurradas de ondas em todas as direções, preenchendo até mesmo uma estação de trem.",
                "Assim como o usuário das Chamas Amaldiçoadas, o usuário da Maré Amaldiçoada possui shikigami que podem surgir através dos grandes ambientes aquáticos formados, sendo utilizados para ataque ou defesa, de acordo com sua vantagem. Inicialmente, são peixes pequenos que podem aplicar mordidas ou imobilizações táticas, mas com o passar do tempo e a evolução do feiticeiro, suas capacidades inatas torná-lo-ão em alguém capaz de conjurar verdadeiros leviatãs marítimos."
              ]
            }
          },
          {
            name: "Da “Flora Amaldiçoada”", crest: "樹",
            paragraphs: [
              "Após as águas e o fogo, o último usuário possui uma conexão sobrenatural com a terra e as plantas, mesmo que não controle as plantas convencionais. Sua energia amaldiçoada infecta o “solo” e autoriza a criação de plantas amaldiçoadas de todo tipo, mesmo que a utilização principal seja através de madeira. Seus poderes de criação espontânea são assustadores, podendo manejar grandes formações naturais que desafiam a concepção comum."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 4</b>.", "Recebe <b>Energia Amaldiçoada</b> de <b>Ranque 4</b>."],
            holders: { label: "O Primeiro", names: ["Awinita Chapawee"] },
            technique: {
              name: "Utilização da Técnica",
              paragraphs: [
                "A forma principal da <b>Flora Amaldiçoada</b> gira em torno da formação espontânea de raízes, criando formas sólidas com base em madeira que podem ser usadas para atacar, dar formas a objetos, criaturas de madeira ou construções diversas. Esse uso principal trabalha com valores proporcionalmente inversos, e o usuário pode escolher quantidade em troca de velocidade e poder destrutivo, ou sacrificar essas duas coisas em troca de mais raízes. Elas podem ser desfeitas instantaneamente, o que significa que adversários que tenham sido postos muito acima do chão podem entrar em queda livre.",
                "<b>Brotos Amaldiçoados</b> são pequenas protuberâncias com bocas e dentes que emergem a partir de raízes ou outras flores criadas pela Flora Amaldiçoada; eles mordiscam feiticeiros e permanecem fixados neles até que sejam retirados, e quanto mais técnicas ou energia amaldiçoada eles usarem, mais os brotos se fortalecem.",
                "<b>Campo de Flores</b> é uma formação espontânea de flora inofensiva e bonita, que hipnotiza os usuários de menor capacidade mental e de raciocínio, pegando-os desprevenidos. Essa técnica aplica uma maldição nos oponentes que remove sua vontade de lutar. Ela não funciona, especificamente, contra um Pilestedt."
              ]
            }
          }
        ]
      },

      {
        title: "Famílias Menores",
        intro: [
          "Assim como as grandes famílias, existe uma circulação frequente e constante de casas menores que batalham pela oportunidade de chegar ao topo ou, de algum modo, estiveram lá e foram destituídos de sua posição pelas querelas e conflitos do tempo. Não há uma margem ou diferenciação real entre cada um deles; a vitória cabe ao mais forte, e o mais forte nem sempre pode ser encontrado dentro da elite. Feiticeiros mais fortes já estavam dentre os ranques das famílias “menores”, um jeito de dizer que elas não estão, tão somente, dentro da casta principal de cinco clãs.",
          "Seus membros possuem técnicas herdadas ou inatas, já que o nome por si só demonstra um valor acentuado dentro da comunidade de Jujutsu americana. Os praticantes de famílias menores possuem, assim que concluem dezesseis anos de idade, uma carteirinha garantida pela associação que os identifica como parte do trabalho, do mesmo jeito que é feito com os estudantes das cinco casas principais.",
          "Apesar de possuírem grande influência política e certa relevância no meio, as famílias menores raramente participam das decisões formais do Conselho Superior de Feitiçaria dos Estados Unidos, que possui cadeiras limitadas e muitos nomes para a nomeação. Caso alguma das cinco famílias caia em desgraça ou se torne incapaz de participar, ela será substituída, primeiro, por um dos contendores desse rol."
        ],
        items: [
          {
            name: "Família Holloway", crest: "影",
            paragraphs: [
              "Ascendentes diretos de Apisi dos Blackfoot e parte dos verdadeiros feiticeiros de sangue americano, os Holloway herdaram a capacidade misteriosa de comandar e utilizar dez shikigami feitos a partir de sombras que eles também controlam livremente. A habilidade surgiu no início do jujutsu norte-americano, dando seus primeiros indícios ao longo das nações quando seus usuários iniciais muniram-se de todo o poder oferecido pela técnica para cumprir e auxiliar seus empreendimentos. A técnica se tornou, por si só, extremamente perigosa.",
              "Sua primeira usuária foi Pana, dos Ossos Negros, seguida de Iiniwa, o Sombrio, que utilizava suas sombras como uma ferramenta de armazenamento e transporte, locomovendo-se pelo campo de batalha. Por perto do fim de sua vida, descobriu a utilidade de suas invocações e conseguiu exorcizar quatro dos dez shikigami. Seus descendentes seguiram despertando a Técnica das Dez Sombras, transformando-as em armas.",
              "Após os eventos da chegada dos Grace, os Holloway decidiram, por conta própria, se afastar de suas responsabilidades dentro do conselho superior, deixando sua cadeira aos seus novos aliados matrimoniais e parentes de sangue, unindo ambas as casas e dando uma oportunidade dos britânicos de entrarem dentro do jujutsu americano.",
              "Atualmente, seu membro mais proeminente é <b>Levi Holloway</b>, estudante da Universidade de Feitiçaria do campus de Nova Iorque, que se tornou famoso pela sua prodigalidade e capacidade de combate acentuada, sendo um dos mais fortes do colegiado."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Técnica das Dez Sombras",
              paragraphs: [
                "A técnica herdada pelos Holloway é a <b>Técnica das Dez Sombras</b>, uma ferramenta para invocar shinigami especiais e também utilizar as funcionalidades mais primitivas do que é tido como umbracinese. Seus usuários podem invocar dez poderosas sombras que precisam ser exorcizadas antes que possam finalmente ser utilizadas, o que cria uma relação mestre-servo imprescritível até a morte do usuário, onde a técnica será repassada para outro feiticeiro em sua linhagem.",
                "A Técnica das Dez Sombras possui nomes poderosos, e acredita-se que pouquíssimos feiticeiros foram capazes de preencher todas as lacunas de exorcismo dentro de sua própria habilidade. O mais habilidoso foi um jujutsu-shi da era colonial americana, que exorcizou nove das dez.",
                "Mesmo que muito temida, pouquíssimo se sabe, da ótica de outras famílias, todas as capacidades completas das sombras. Aqueles que conhecem-nas provavelmente morrem pouco após isso, e não há histórico ou registro sólido que comente acerca das sombras mais perigosas, que vão da sétima até a décima."
              ]
            }
          },
          {
            name: "Família Wayne", crest: "分",
            paragraphs: [
              "Os descendentes de Cetanwakuwa, os Wayne ganharam grande prestígio ao longo dos séculos por terem preservado os costumes mais centrais de seu ofício. São feiticeiros essencialmente competentes e perigosos, conhecedores de sua própria linha de trabalho e grandes contribuidores para o Mundo Jujutsu como um todo; por mais que não possuam uma cadeira no CSFEU, os Wayne manejam alguns dos acontecimentos ao usarem de sua influência.",
              "Além de tremendamente ricos, seu histórico é lotado de ovações e méritos distintos que sagraram-nos como um dos pilares do jujutsu americano. Seus primeiros membros surgiram na América colonial, e o primeiro membro, Sor Salazar Wayne, teve uma importância fundamental na constitucionalização do jujutsu e na sua solidificação.",
              "Ganharam fama posterior pela sua participação fulcral nas guerras, interferindo nas querelas humanas dos não feiticeiros para encerrá-las de modo ligeiro e direcionado aos interesses gerais da população de xamãs. Dois homens e uma mulher Wayne foram eleitos membros da Royal Society."
            ],
            receives: ["Recebe <b>Energia Amaldiçoada</b> de <b>Ranque 3</b>.", "Recebe <b>Técnica</b> de <b>Ranque 3</b>."],
            technique: {
              name: "Multiplicação",
              paragraphs: [
                "Assim como seu ancestral, os Wayne receberam a dádiva da <b>Multiplicação</b>, uma técnica poderosa que os permite se multiplicar um número indeterminado de vezes para um propósito diverso. Todos os clones possuem tangibilidade física e não devem ser confundidos com ilusões, já que partilham, com o usuário original, parte de sua energia amaldiçoada e atuam de acordo com o fluxo de abastecimento.",
                "Os clones podem reter informações e repassar dados valiosos para o usuário original, transformando-se em versões capacitadas do original para a conclusão de operações ou trabalhos intelectuais, além de terem primorosa serventia para serviços de espionagem ou assassinato. É difícil e praticamente impossível distinguir um corpo original do verdadeiro, que pode trocar de lugar com qualquer uma de suas réplicas assim que ver a necessidade de fazê-lo.",
                "Os Wayne não possuem uma técnica suprema, ou ao menos ela não foi desenvolvida, ainda. O uso prático de seus poderes tornou a função de um domínio obsoleta, razão pela qual muitos se contentam em utilizar um domínio simples e recorrer ao uso das técnicas convencionais para superar seus oponentes com números e forças iguais."
              ]
            }
          },
          {
            name: "Família Barnett", crest: "棘",
            paragraphs: [
              "Os Barnett, apesar de não possuírem nenhum tipo de técnica específica a ser herdada, possuem um valor acentuado de energia amaldiçoada, que deturpou-se ao longo do tempo de vida do usuário e se tornou “afiada e espinhosa”, como se o feiticeiro fosse, de fato, um porco-espinho. O poder de ataque dos Barnett não é só acompanhado pela força natural de seus ataques, como também é complementada pelo que é chamado de <b>Energia Amaldiçoada Bruta</b>, um meio praticamente indefensável de ataque.",
              "Por fora, a família soa exatamente como os caipiras americanos, possui origem no Texas, mas possuem casas e galhos de parentesco em lugares como Oklahoma e Kentucky, além de existir um único membro com moradia em Nova Iorque.",
              "Um de seus últimos familiares foi William “Bill” Barnett, que se envolveu nos conflitos jujutsu do Japão e morreu no processo, o que piorou as relações da família com os feiticeiros asiáticos, que foram culpados, em coletivo, pela morte do parente. Até o momento, não se sabe quais são os planos de retaliação dos Barnett, mas seu ódio é plenamente conhecido."
            ],
            receives: ["Recebe <b>Energia Amaldiçoada</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Energia Amaldiçoada Bruta",
              paragraphs: [
                "Todos os Barnett demonstraram, a partir dos seis anos, um volume satisfatório de energia amaldiçoada que era acompanhado por uma propriedade específica em sua utilização. Ao contrário da energia amaldiçoada convencional — que por si só já serve para atacar e defender —, a dos texanos se mostra um pouco mais perigosa. Mesmo que um inimigo bloqueie o ataque de um Barnett, ele ainda receberá danos visíveis e cortantes, como se estivesse entrando em contato com um taco de beisebol farpado.",
                "Isso, aliado com uma técnica inata nativa de seus membros, mostra-se uma combinação imprevisível e perigosa de atributos, já que os Barnett possuem a capacidade de se sobressair em um duelo de encantamentos e, também, em um duelo físico. Ao amaldiçoar seus inimigos, os jujutsu-shi da árvore Barnett possuem a fama de serem impiedosamente brutais e cruéis."
              ]
            }
          },
          {
            name: "Família Danvers", crest: "藁",
            paragraphs: [
              "Os Danvers ganharam fama pelas suas raízes, tornando-se usuários práticos de bonecos de vodu, uma área do jujutsu africano, e adaptando-a para cumprir suas vontades nos estados unidos, o que gerou a técnica do <b>Boneco de Palha</b>, que seria repassada aos usuários futuros para se revelar uma forma dinâmica e exótica de ataque.",
              "A família se formou com a união de filhos de colonizadores com africanos escravizados, quando o último filho da família original se apaixonou por uma mulher negra, a libertou e a levou consigo mesmo para algum lugar dos Estados Unidos. O caso de amor foi amplamente divulgado dentro da esfera do jujutsu, e os perseguidores que ousaram empregar perseguição, principalmente os não feiticeiros, foram cruelmente assassinados pelo casal que ganhou certa fama criminosa em face da sociedade predominantemente racista e conivente.",
              "O resultado do matrimônio foram os primeiros Danvers, que mudaram de nome e conseguiram um casarão na Luisiana, utilizando dos conhecimentos do jujutsu africano e europeu para solidificar sua própria técnica."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Boneco de Palha",
              paragraphs: [
                "A técnica do <b>Boneco de Palha</b> funciona como uma retransmissão de danos; ao juntar uma efígie física, de palha ou não, com alguma parte do corpo do adversário, o feiticeiro é capaz de aplicar e amplificar os danos causados em seu adversário. Em relação ao totem que representaria a silhueta do inimigo, um prego pode causar o mesmo dano de uma estaca gigante, ou de uma espada. Além disso, cada projétil ou ferramenta utilizada para causar o dano pode ter sua emissão de energia amaldiçoada acentuada individualmente, criando a possibilidade de causar dano posterior ao longo da mesma batalha.",
                "Os Danvers eram, no passado, assassinos especialmente eficazes, já que eram capazes de usar o mínimo do indivíduo alvo para, com sua técnica, matá-lo a distância. Os não feiticeiros que perseguiram o primeiro casal foram mortos exatamente assim; pegos por ataques cardíacos misteriosos, sufocados por danos pulmonares súbitos, mazelas que abateram seus corpos e todo tipo de coisa."
              ]
            }
          },
          {
            name: "Família King", crest: "比",
            paragraphs: [
              "Os executores do Mundo Jujutsu, os King são os carcereiros e os carrascos dos condenados pelo CSFEU, trabalhando como assassinos que recebem contratos e pagamentos igualmente grandiosos. Os King são uma das poucas famílias americanas que alcançou prestígio o suficiente para se tornarem um dos “menores”, mesmo que não possuam nenhuma relação direta com Tahoma Blaska ou tenham se casado com alguma das famílias que possui.",
              "Seus membros são tidos como reservados e metódicos, e dentro da família, a técnica amaldiçoada herdada é a <b>Técnica de Proporção</b>, que é bastante conveniente para seu ofício. Eles sempre são capazes de encontrar um ponto fraco porque sua habilidade obriga que um seja formado, traduzindo-se em assassinatos rápidos e eficazes que acabam no mesmo instante em que começam.",
              "Todas as famílias possuem, ao menos, algum grau de contato com a Família King, que destila medo em seus adversários e animosidade em seus aliados, que também não conseguem escapar da “aura de morte”, que cerca os indivíduos do clã."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Técnica de Proporção",
              paragraphs: [
                "A técnica herdada e repassada dentro dos King é a <b>Técnica de Proporção</b>, uma técnica amaldiçoada que divide um alvo em uma quantidade estabelecida de pontos e o delimita em separações específicas que, quando atingidas, causam um dano crítico natural, aumentando todo dano já existente e criando feiticeiros que são capazes de causar dano consistente e bruto sem intervalos.",
                "Em combinação com o <b>Raio Negro</b>, acertar um ponto crítico dentro de um inimigo é praticamente um abate certo, já que o dano é praticamente duplicado e, em certas situações, quadruplicado. Apesar de poderem utilizar os seus punhos, os King satisfazem-se com o uso de armas brancas em seus empreendimentos, com o objetivo final de aumentar ainda mais os danos catastróficos que são capazes de causar."
              ]
            }
          },
          {
            name: "Família McGinnis", crest: "星",
            paragraphs: [
              "A família McGinnis é tida como um dos trunfos dos Estados Unidos, detentores de uma técnica única e extremamente poderosa em todos os seus parâmetros. Eles ganharam fama durante a época da Grande Depressão, em que foram responsáveis por varrer Manhattan de seus espíritos amaldiçoados por conta própria, mesmo que a ocasião tenha quase gerado um acidente trágico. A família possui relações extraoficiais com a China e a França, e um de seus membros teve, até mesmo, um filho chinês.",
              "Mesmo em comparação com as Cinco Famílias principais, a força dos McGinnis não empalidece nem um pouco, sendo, inclusive, temida por alguns membros do Conselho Superior, que ficam especialmente agitados por perto de seus membros. Após os eventos do Cataclisma de Tóquio terem sido esquecidos pelo tempo, os McGinnis nunca se casaram com uma família chinesa, ao menos não ainda.",
              "Seu membro mais famoso atualmente é o agente <b>Patrick McGinnis</b>, o <b>Espírito de Destruição</b>, que herdou merecidamente a vontade e crueldade de Mitena, tornando-se conhecido pela sua capacidade quase inigualável de destruir completamente os seus adversários."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 5</b>."],
            technique: {
              name: "Fúria Estelar",
              paragraphs: [
                "A técnica herdada dos McGinnis é a <b>Fúria Estelar</b>, que é capaz de adicionar massa virtual ou imaginária ao usuário ou a uma invocação que tenha sido criada com essa atribuição de técnica. Dispensável dizer, a quantidade de massa fica ao cargo do usuário, podendo escalar ao infinito, mas caso isso aconteça, acidentes de proporções catastróficas e imprevisíveis podem recair sobre o feiticeiro e os seus arredores.",
                "Em questão de força bruta, não há um único feiticeiro do mundo que possa, em termos iguais, disputar com um McGinnis diretamente, já que suas habilidades não possuem um limite estabelecido em termos lógicos. Não existe, na natureza, algo que consiga aderir massa imaginária, tampouco massa imaginária em padrões desejados ou alterados ao bel prazer do usuário. Sua força, mesmo de início, pode ser titânica.",
                "As consequências da Fúria Estelar são praticamente nulas, a não ser que a habilidade seja utilizada de modo descuidado e desleixado ou com extrema ambição; adicionar muita massa imaginária ao próprio corpo ou um objeto causará o esperado: a matéria recairá sobre o corpo do próprio feiticeiro e o tecido do universo entrará em colapso, criando um buraco negro que consumirá tudo ao seu redor e, junto, o planeta."
              ]
            }
          },
          {
            name: "Família Weyland", crest: "獣",
            paragraphs: [
              "Uma família com uma grande técnica e grandes membros, os Weyland tornaram-se famosos pela sua consistência em entregar resultados positivos em suas missões. Apesar de não possuírem uma habilidade extremamente fora de série, sua competência e tradição mantiveram, dentro do clã, membros competentes e poderosos que podem não demonstrar subitamente um alto nível, mas que são evidentemente eficazes.",
              "Surgiram no período do Velho Oeste, calcando a Técnica das Bestas Auspiciosas com base em animais existentes na fauna americana da época, algo que os deixou especialmente conhecidos. Os búfalos, os touros e as víboras do deserto tinham uma grande conexão com as tribos indígenas, com um forte sangue nativo-americano que até hoje é presente nos Weyland, que possuem semelhanças físicas e até mesmo culturais com os povos mais primitivos.",
              "Desde então, os Weyland possuem seu lugar guardado dentro das famílias menores, carregando prestígio, riqueza e influência dentro do jujutsu americano. Seu membro mais proeminente é <b>Isabelle “Isa” Weyland</b>, a <b>Serpente</b>."
            ],
            receives: ["Recebe <b>Técnica</b> de <b>Ranque 4</b>.", "Recebe <b>Expansão de Domínio</b> de <b>Ranque 3</b>."],
            technique: {
              name: "Técnica das Bestas Auspiciosas",
              paragraphs: [
                "A técnica herdada dos Weyland é a <b>Técnica das Bestas Auspiciosas</b>, uma técnica que consiste em esconder o próprio rosto e, através de um processo refinado com a energia amaldiçoada, o usuário se torna um médium espiritual que conecta o mundo físico com o mundo astral. Isso dá acesso ao Weyland em questão quatro invocações distintas que são, justamente, as bestas."
              ]
            }
          }
        ]
      }
    ]
  },

  /* ---------------------------------------------------------------- */
  /* O TEXTO de Sistemas fica em assets/js/sistemas-texto.js */
  sistemas: {
    title: "Sistemas"
  },

  /* ---------------------------------------------------------------- */
  /* O TEXTO das técnicas fica em assets/js/tecnicas-texto.js.
     Aqui ficam só as etiquetas de cada técnica (pelo nome exato):
     owner = família dona, category = grupo usado nos filtros,
     symbol = kanji do selo da técnica.
     Técnicas sem category aparecem no grupo "Outras". */
  tecnicas: {
    title: "Central de Técnicas",
    tags: {
      "Ilusão Amaldiçoada":                  { symbol: "幻", owner: "Pilestedt", category: "Herdadas" },
      "Magnetismo Amaldiçoado":              { symbol: "磁", owner: "Grace",     category: "Herdadas" },
      "Criação de Armas Amaldiçoadas":       { symbol: "鍛", owner: "Browning",  category: "Herdadas" },
      "Paradoxo":                            { symbol: "時", owner: "Conway",    category: "Herdadas" },
      "Absolute Kälte":                      { symbol: "氷", owner: "Wolfe",     category: "Herdadas" },
      "Multiplicação":                       { symbol: "分", owner: "Wayne",     category: "Herdadas" },
      "Técnica do Boneco de Palha":          { symbol: "藁", owner: "Danvers",   category: "Herdadas" },
      "Técnica de Proporção":                { symbol: "比", owner: "King",      category: "Herdadas" },
      "Fúria Estelar":                       { symbol: "星", owner: "McGinnis",  category: "Herdadas" },
      "Invocação das Bestas Auspiciosas":    { symbol: "獣", owner: "Weyland",   category: "Herdadas" },
      "Energia Amaldiçoada Bruta":           { symbol: "棘", owner: "Barnett",   category: "Herdadas" },
      "Desmantelar e Partir":                { symbol: "解", category: "Os Primeiros" },
      "Transfiguração Ociosa":               { symbol: "魂", category: "Os Primeiros" },
      "Chamas Amaldiçoadas":                 { symbol: "炎", category: "Os Primeiros" },
      "Maré Amaldiçoada":                    { symbol: "潮", category: "Os Primeiros" },
      "Flora Amaldiçoada":                   { symbol: "樹", category: "Os Primeiros" },
      "Técnica de Projeção":                 { symbol: "映" },
      "Energia Amaldiçoada Elemental: Raio": { symbol: "雷" },
      "Cópia Amaldiçoada":                   { symbol: "写" },
      "Fala Amaldiçoada":                    { symbol: "言" },
      "Construção Amaldiçoada":              { symbol: "築" },
      "Manipulação de Sangue":               { symbol: "血" }
    }
  },

  /* ---------------------------------------------------------------- */
  /* O TEXTO de Vantagens fica em assets/js/vantagens-texto.js */
  vantagens: {
    title: "Vantagens"
  }
};
