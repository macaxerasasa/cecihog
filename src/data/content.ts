import type { ContentBlock, Spread } from '../types'
import { layoutGifts } from './gifts'
import { layoutYear, spellsOfYear } from './spells'

type Plate = { art: string; caption: string }

const plate = (p: Plate, large = false) => ({ type: 'plate' as const, art: p.art, caption: p.caption, large })

/**
 * A year tome opens on its frontispiece and the spell finder; every leaf
 * after that is one entry of the grimoire (long entries take two leaves).
 */
function yearSpreads(
  year: number,
  title: string,
  subtitle: string,
  intro: string,
  plates: [Plate, Plate?],
): Spread[] {
  const [frontis, second] = plates
  const count = spellsOfYear(year).length
  const front: Spread = {
    left: [
      { type: 'heading', text: title },
      { type: 'subheading', text: subtitle },
      { type: 'ornament' },
      plate(frontis),
      { type: 'paragraph', text: intro },
    ],
    right: [{ type: 'spell-search', year }],
  }
  const closing: ContentBlock[] = [
    { type: 'subheading', text: 'Fim do sumário' },
    { type: 'ornament' },
    ...(second ? [plate(second, true)] : []),
    {
      type: 'paragraph',
      text: `Aqui se encerram os ${count} feitiços ensinados no ${title.toLowerCase()}. Os aprimoramentos marcados como bloqueados aguardam autorização do corpo docente.`,
    },
  ]
  return layoutYear(year, front, closing)
}

/*
 * Page contents of every tome, keyed by book id. This module is only pulled
 * in with the reader, so the shelf itself stays light.
 */
const contents: Record<string, Spread[]> = {
  ambientacao: [
    {
      left: [
        { type: 'heading', text: 'Hogwarts' },
        { type: 'subheading', text: 'Escola de Magia e Bruxaria' },
        { type: 'ornament' },
        plate({ art: 'castle', caption: 'Prancha I — O castelo visto do Lago Negro' }, true),
        {
          type: 'paragraph',
          text: 'Erguida em terra escocesa por Godric Gryffindor, Helga Hufflepuff, Rowena Ravenclaw e Salazar Slytherin, Hogwarts esconde-se dos olhos trouxas por encantamentos antigos. Torres, escadas que mudam de ideia e retratos tagarelas guardam mil anos de ensino.',
        },
      ],
      right: [
        { type: 'subheading', text: 'O castelo' },
        {
          type: 'entries',
          items: [
            {
              title: 'Salão Principal',
              text: 'Teto encantado, quatro mesas das casas e a mesa dos professores. O Chapéu Seletor canta aqui.',
            },
            {
              title: 'Escadas e corredores',
              text: 'Trechos que se movem às terças. Atrás de tapeçarias há atalhos — e, às vezes, o Chapeleiro Tonto.',
            },
            {
              title: 'Terrenos',
              text: 'Lago Negro, Floresta Proibida, estufas da professora Sprout e a cabana de Hagrid.',
            },
          ],
        },
        {
          type: 'reserved',
          label: 'Mapa do castelo',
          hint: 'Espaço para andares, torres, masmorras e o Mapa do Maroto.',
        },
      ],
    },
    {
      left: [
        { type: 'heading', text: 'Leis da escola' },
        { type: 'ornament' },
        plate({ art: 'key', caption: 'Prancha II — Chave alada, corredor do terceiro andar' }),
        {
          type: 'list',
          items: [
            'É proibido feitiços dentro dos corredores entre as aulas.',
            'A Floresta Proibida continua proibida.',
            'A seção restrita exige permissão assinada.',
            'O Terceiro Andar do lado direito é, em certos anos, igualmente proibido.',
          ],
        },
      ],
      right: [
        { type: 'subheading', text: 'O mundo além' },
        {
          type: 'paragraph',
          text: 'Londres mágico começa no Beco Diagonal. O Expresso de Hogwarts parte de King’s Cross, plataforma 9¾. O Ministério, as casas de campo e os vilarejos de Hogsmeade completam o mapa — páginas à espera de crônicas.',
        },
        {
          type: 'paragraph',
          text: 'Esta estante pertence à biblioteca. Madame Pince não aprovaria que os tomos saíssem da prateleira — mas a magia da seção restrita às vezes faz o contrário.',
        },
        {
          type: 'reserved',
          label: 'Cronologia',
          hint: 'Linha do tempo da escola, diretores e conflitos do mundo bruxo.',
        },
      ],
    },
    ],
  habilidades: layoutGifts({
    left: [
      { type: 'heading', text: 'Habilidades e Raças' },
      { type: 'subheading', text: 'Dons da mente, do sangue e da forma' },
      { type: 'ornament' },
      plate({ art: 'mind', caption: 'Prancha I — O olhar que atravessa' }, true),
      {
        type: 'paragraph',
        text: 'Nem todo poder se ensina numa sala de aula. Alguns nascem no sangue — a língua das cobras, o rosto que muda, a herança das veelas. Outros pedem anos de treino: a mente que invade, a mente que se fecha, o corpo que escolhe um animal e não larga mais. Esta dobra cataloga sete habilidades e três raças, cada uma com o que exige, o que oferece e o preço que cobra.',
      },
    ],
    right: [{ type: 'gift-search' }],
  }),
  racas: [
    {
      left: [
        { type: 'heading', text: 'Sistemas e Regras' },
        { type: 'subheading', text: 'Conjuração e o duelo formal' },
        { type: 'ornament' },
        plate({ art: 'duel', caption: 'Prancha I — A reverência no tablado' }, true),
        {
          type: 'paragraph',
          text: 'Duas artes sustentam o jogo: a conjuração completa de um feitiço e o duelo no tablado. A primeira pede que a ação traga tudo o que a magia exige. A segunda, que o confronto tenha ritmo, senso e um anfitrião.',
        },
      ],
      right: [
        {
          type: 'toc',
          heading: 'Índice dos sistemas',
          items: [
            { label: 'Como realizar um Feitiço', note: 'Os quatro elementos da conjuração', spread: 1 },
            { label: 'Duelo formal', note: 'Definição, método e senso', spread: 2 },
            { label: 'Regras do tablado', note: 'Método Feitiço, Feitiço-Desvio', spread: 3 },
            { label: 'Ações combativas', note: 'O mínimo que a ação deve trazer', spread: 4 },
            { label: 'Senso', note: 'Coerência do personagem no combate', spread: 5 },
            { label: 'Falta de senso', note: 'O que quebra a interpretação', spread: 6 },
            { label: 'Defendendo e desviando', note: 'Protego, desvio e o intervalo', spread: 7 },
            { label: 'Desvios impossíveis', note: 'Distância, lado e efeito', spread: 8 },
          ],
        },
      ],
    },
    {
      left: [
        { type: 'heading', text: 'Como realizar um Feitiço?' },
        { type: 'ornament' },
        plate({ art: 'cast', caption: 'Prancha II — O gesto, a palavra e a luz' }),
        {
          type: 'paragraph',
          text: 'Para que um Feitiço seja realizado corretamente, o jogador deverá descrever em sua ação todos os elementos necessários para a conjuração. A ação deve conter:',
        },
      ],
      right: [
        {
          type: 'entries',
          items: [
            {
              title: 'Movimento da Varinha',
              text: 'Descreva o movimento realizado com a varinha durante a conjuração.',
            },
            {
              title: 'Pronúncia',
              text: 'O nome do Feitiço deve ser pronunciado corretamente.',
            },
            {
              title: 'Cor do Lampejo',
              text: 'Caso o Feitiço possua um lampejo ou manifestação visual, sua cor deve ser descrita.',
            },
            {
              title: 'Efeito',
              text: 'Descreva o efeito causado pelo Feitiço após sua conjuração.',
            },
          ],
        },
        {
          type: 'paragraph',
          text: 'A ausência de um desses elementos poderá fazer com que o Feitiço seja considerado incompleto ou não seja realizado corretamente.',
        },
      ],
    },
    {
      left: [
        { type: 'heading', text: 'Duelo formal' },
        { type: 'subheading', text: 'Definição' },
        { type: 'ornament' },
        plate({ art: 'duel', caption: 'Prancha III — Doze passos por três' }),
        {
          type: 'paragraph',
          text: 'É um combate formal entre dois bruxos em que apenas magia pode ser usada. Tradicionalmente, os oponentes fazem uma reverência, aguardam uma contagem até três e então começam. Como prática organizada — esportiva ou didática — segue regras rigorosas sobre quais feitiços são permitidos. Embora alguns duelos históricos tenham terminado em morte, o duelo também é ensinado de modo controlado, inclusive em Hogwarts.',
        },
      ],
      right: [
        { type: 'subheading', text: 'Sistemas' },
        {
          type: 'paragraph',
          text: 'Ao longo dos séculos, a prática dos duelos em Hogwarts evoluiu de confrontos informais entre bruxos impulsivos para um sistema rigorosamente estruturado e repleto de tradição. Inicialmente, os duelos eram marcados por espontaneidade e rivalidades pessoais, muitas vezes sem regras claras.',
        },
        {
          type: 'paragraph',
          text: 'Com o tempo, professores e especialistas em Feitiços e Defesa Contra as Artes das Trevas perceberam a necessidade de criar um método que preservasse a segurança dos participantes e, ao mesmo tempo, mantivesse o caráter competitivo e didático da arte de duelar.',
        },
      ],
    },
    {
      left: [
        { type: 'subheading', text: 'Método duelístico' },
        {
          type: 'paragraph',
          text: 'FEITIÇO, FEITIÇO-DESVIO — ação, desvio-ação ⇋ desvio-ação, ação.',
        },
        {
          type: 'paragraph',
          text: 'A área do tablado é semelhante à sugerida por Chris Columbus em Harry Potter e a Câmara Secreta: um tablado de 12 × 3, doze passos para frente e três para os lados. Em cada ação, os jogadores devem indicar para qual direção se moveram; na ausência dessa informação, o anfitrião considera que a movimentação ocorreu em linha reta.',
        },
        {
          type: 'paragraph',
          text: 'Para manter a ordem e a coerência do RPG, as regras devem ser explícitas, aplicadas com consistência e respeitadas por todos. Violações geram punições proporcionais à gravidade da infração.',
        },
      ],
      right: [
        { type: 'subheading', text: 'Regras' },
        {
          type: 'list',
          items: [
            'Apenas uma habilidade ou feitiço pode ser utilizado por turno.',
            'O jogador deve manter a coerência ao escolher seus feitiços e agir de acordo com o nível de habilidade exigido. Um primeiranista não lança Scarlatum Duo nem evolui dons inatos de forma súbita e inexplicável no meio do duelo.',
            'Em duelos realizados no tablado, é expressamente proibida qualquer interferência externa. Em duelos informais ou conflituosos, a covardia é permitida.',
            'Todo duelo formal deve ter um anfitrião, responsável por controlar e intermediar as ações. Suas decisões são inquestionáveis e devem ser respeitadas.',
            'Não é permitido movimentar-se no mesmo turno em que for executado o Protego.',
            'A movimentação é limitada a um metro por turno, e o jogador deve indicar claramente a direção em que se deslocou.',
            'É possível cair do tablado ao ultrapassar o limite de três metros de largura. Duas esquivas consecutivas para a direita, por exemplo, levam à borda: quem sai, perde.',
          ],
        },
      ],
    },
    {
      left: [
        { type: 'subheading', text: 'Ações combativas' },
        {
          type: 'paragraph',
          text: 'Para o uso dos feitiços, a liberdade criativa do jogador é incentivada. Em duelos formais, porém, divide-se o espaço com outros jogadores com o mesmo propósito: duelar. Não se deve demorar excessivamente para responder. O ideal é uma ação simples, contendo:',
        },
        {
          type: 'entries',
          items: [
            { title: 'Feitiço!', text: 'Fora da ação — o nome pronunciado.' },
            { title: 'Cor do lampejo', text: 'A manifestação visual, quando houver.' },
            { title: 'Alvo', text: 'Onde o feitiço mira.' },
            { title: 'Efeito', text: 'O que se pretende causar.' },
          ],
        },
        {
          type: 'paragraph',
          text: 'Visando a praticidade — e o efeito roteirizado da movimentação, como acenos ou giros horário e anti-horário — a descrição gestual da varinha não é obrigatória no duelo. O jogador concentra-se na ação, sem precisar justificar a lógica de cada movimento.',
        },
      ],
      right: [
        { type: 'subheading', text: 'Exemplos' },
        {
          type: 'entries',
          items: [
            {
              title: 'Estupefaça!',
              text: 'Um jorro de luz incolor parte da varinha, mirando o peito de Oswald com a intenção de estuporá-lo.',
            },
            {
              title: 'Scarlatum!',
              text: 'Um lampejo escarlate dispara em direção ao estômago de Oswald, com a intenção de impactá-lo.',
            },
          ],
        },
        {
          type: 'paragraph',
          text: 'Os exemplos podem ser adaptados livremente. O jogador descreve as ações como preferir, desde que sejam dinâmicas e tragam o mínimo exigido acima.',
        },
      ],
    },
    {
      left: [
        { type: 'subheading', text: 'Senso' },
        {
          type: 'paragraph',
          text: 'Não se pode exigir que um jogador novo, ou pouco familiarizado com o mundo bruxo e seus métodos de roleplay, tenha o mesmo senso interpretativo que um jogador experiente. Por isso, oferece-se ao menos uma explicação mínima sobre o senso e sobre como segui-lo.',
        },
        {
          type: 'paragraph',
          text: 'Antes de ser intersubjetiva, a interpretação de senso é relativa e pertence ao intermediador, segundo seus próprios critérios: conhecimento, exigência, aplicação e estilo. Não faz sentido exigir que o anfitrião, num duelo de interpretações, não possa também interpretar e tenha de seguir um roteiro pronto e engessado.',
        },
      ],
      right: [
        {
          type: 'paragraph',
          text: 'Quando se duela — ainda que num ambiente competitivo — é fundamental manter a personalidade do personagem. Personagens medrosos não se tornam símbolos de coragem no tablado, nem arrogantes duelam como covardes, acuados diante de qualquer feitiço.',
        },
        {
          type: 'paragraph',
          text: 'Entenda quem é o seu personagem e interprete-o com coerência: reconheça suas limitações e vulnerabilidades. Às vezes, simplesmente não se está à altura do oponente, e tudo bem. Isso também faz parte do jogo.',
        },
      ],
    },
    {
      left: [
        { type: 'subheading', text: 'Exemplos de falta de senso' },
        {
          type: 'entries',
          items: [
            {
              title: 'Dos pés à testa',
              text: 'Desfazer-se de um feitiço lançado aos pés e, logo em seguida, defender um lampejo direcionado à testa. Há dificuldade evidente em alternar movimentos de varinha tão distintos em sequência imediata.',
            },
            {
              title: 'Labaredas de fogo',
              text: 'Labaredas são esparsas, como jatos de uma mangueira em chamas — quem se move dentro do raio de propagação, queima-se. Ainda assim, é preferível tentar desviar a simplesmente recebê-las, mas o desvio deve ser bem descrito e coerente, e não pretexto para um contra-ataque abusivo.',
            },
            {
              title: 'Roupas e sapatos',
              text: 'Movimentar objetos muito atrelados ao corpo do alvo — roupas, sapatos ou acessórios de cabeça — é inviável com maestria. Óculos podem ser afetados, pois pedem menos precisão. Um objeto sob o regime da física clássica conta como parte do corpo: a força que mantém o bruxo em pé é maior do que a varinha consegue fazer para arrastar-lhe o sapato.',
            },
          ],
        },
      ],
      right: [
        {
          type: 'entries',
          items: [
            {
              title: 'Acessórios do avatar',
              text: 'Evitar acessórios também é recomendável porque interferem no duelo conforme a aparência visual. É muito mais fácil livrar-se de um tênis sem cadarços do que de uma bota militar — o que afeta a coerência da ação.',
            },
            {
              title: 'Contra-ataques inesperados',
              text: 'Num duelo, espera-se que o próprio feitiço produza efeito. Quando ele falha — um Desequilibrum que não acerta as pernas — e o adversário reage na hora, é coerente surpreender-se e ter dificuldade para se defender. O mesmo vale quando o feitiço acerta sem efeito ofensivo — um Corandio — e o oponente aceita o impacto só para contra-atacar no mesmo turno: isso quebra o senso.',
            },
          ],
        },
      ],
    },
    {
      left: [
        { type: 'subheading', text: 'Defendendo' },
        plate({ art: 'shield', caption: 'Prancha IV — A barreira no sítio certo' }),
        {
          type: 'paragraph',
          text: 'Para que um duelo não se torne infinito, é necessário que existam brechas. Um bom roleplay vive de narrativa, mas também de tentativa, erro e falta de atenção. A defesa é simples: ao conjurar a barreira translúcida (Protego), proteja a área correta do corpo. Se o adversário ataca o joelho, um Protego genérico ou no peito não serve. A ausência de informação ou a incoerência na descrição resulta em acerto automático.',
        },
        {
          type: 'paragraph',
          text: 'O Protego não rebate o feitiço para onde se quiser — não ricocheteia como o Impedimenta. E o Feitiço-Escudo não defende contra elementos da natureza. Chamas, ventos, raios ou água não são bloqueados por ele: use o bom senso, e talvez outro elemento em contrapartida.',
        },
      ],
      right: [
        { type: 'subheading', text: 'Desviando' },
        {
          type: 'paragraph',
          text: 'O uso do Feitiço-Escudo (Protego) não permite o contra-ataque, e é justamente por isso que os desvios trazem dinamismo ao duelo. Seguindo a ordem Feitiço → Feitiço → Desvio, o desvio torna-se uma ferramenta estratégica que exige timing e cautela.',
        },
        {
          type: 'paragraph',
          text: 'Sempre que se realizar um desvio, deve-se aguardar dois turnos antes de desviar novamente. Durante esse intervalo, é permitido o uso do Protego. Dominar o ritmo das habilidades é o que distingue um bom duelista: quem entende o combate, entende também quando agir, quando se proteger e quando aceitar a derrota.',
        },
      ],
    },
    {
      left: [
        { type: 'subheading', text: 'Desvios impossíveis' },
        {
          type: 'paragraph',
          text: 'A fé cega no sistema transformaria o roleplay em algo completamente roteirizado, o que sufocaria a narrativa. Por isso o termo “desvios impossíveis”: situações em que só o desvio ou o Protego não bastam — e, sinceramente, não vão salvar.',
        },
        {
          type: 'entries',
          items: [
            {
              title: 'Pela distância',
              text: 'A três metros ou menos, torna-se impossível esquivar-se de lampejos. A reação humana não é rápida o bastante. O Protego ainda pode ser usado: é a única defesa viável.',
            },
            {
              title: 'Pela movimentação',
              text: 'Mentalize a própria posição e a do adversário ao esquivar na diagonal. O tablado mede 12 × 3. Se Oswald, já na extremidade direita, lança um lampejo também pela direita, Isolde — mesmo no centro — não consegue esquivar para o mesmo lado nem na direção de origem do lampejo. O intermediador considera acerto automático. Se os bruxos estiverem perfeitamente alinhados, a regra não se aplica.',
            },
          ],
        },
      ],
      right: [
        {
          type: 'entries',
          items: [
            {
              title: 'Pelo efeito',
              text: 'Nem todo feitiço é um lampejo. Alguns elementais — e apenas suas versões aprimoradas — têm efeitos distintos conforme a intenção do conjurador. Detalhe o turno de ataque. O alcance padrão dos feitiços mais recorrentes é de três metros. Elementais, em geral, anulam-se por elementais de natureza oposta.',
            },
            {
              title: 'Petrus Pontus e Ventus',
              text: 'Oswald lança três pedras pontiagudas em sequência. Um Protego não bloqueia impactos físicos desse tipo: as pedras acertam. Um Ventus, que cria uma lufada de vento, pode dissipá-las antes que atinjam. No fim, o duelo por efeitos é criatividade — e interpretação do intermediador, que equilibra coerência e liberdade.',
            },
          ],
        },
        {
          type: 'paragraph',
          text: 'Este guia foi adaptado para o Discord a partir de documentos de roleplays distintos. A diferenciação visual dos hotéis cede lugar à mentalização e à descrição assertiva da distância — essencial e inevitável.',
        },
      ],
    },
  ],
  'primeiro-ano': yearSpreads(
    1,
    'Primeiro Ano',
    'Os primeiros gestos de varinha',
    'Quinze feitiços abrem o caminho de todo bruxo: a luz de Lumos, o escudo de Protego, a leveza de Wingardium Leviosa. Cada verbete traz o efeito, a luz, a classificação e o movimento de varinha — e, quando houver, o aprimoramento que se desbloqueia com a prática.',
    [{ art: 'owl', caption: 'Prancha I — A coruja e a carta' }, { art: 'broom', caption: 'Prancha II — Primeira aula de voo' }],
    ),
  'segundo-ano': yearSpreads(
    2,
    'Segundo Ano',
    'Transfigurações e azarações de corredor',
    'O segundo ano alarga o repertório: Incendio e Immobulus, as primeiras transfigurações em aves e ratos, e azarações que pedem cuidado — e um contrafeitiço à mão. Vinte e nove verbetes, cada um com seus aprimoramentos.',
    [{ art: 'diary', caption: 'Prancha I — O diário e o dente de basilisco' }, { art: 'cauldron', caption: 'Prancha II — Poção Polissuco, banheiro do segundo andar' }],
    ),
  'terceiro-ano': yearSpreads(
    3,
    'Terceiro Ano',
    'Ventos, água e criaturas conjuradas',
    'Trinta e quatro feitiços: Depulso e Ventus movem o campo, Aguamenti e Eletricus trazem os elementos, Avis enche o ar de pássaros. Parte deles evolui em vários aprimoramentos, catalogados na ordem em que se desbloqueiam.',
    [{ art: 'timeturner', caption: 'Prancha I — O Vira-Tempo' }, { art: 'snitch', caption: 'Prancha II — A Firebolt e o pomo' }],
    ),
  'quarto-ano': yearSpreads(
    4,
    'Quarto Ano',
    'Duelo, escudo e maldições menores',
    'O ano em que a varinha vira arma: Estupefaça, Expulso, Bombarda e Reducto, ao lado de curas como Ferula e Episkey. Trinta e cinco verbetes, com os feitiços de Pacote das Artes das Trevas devidamente assinalados.',
    [{ art: 'goblet', caption: 'Prancha I — O Cálice de Fogo' }, { art: 'hourglass', caption: 'Prancha II — As três tarefas, contra o tempo' }],
    ),
  'quinto-ano': yearSpreads(
    5,
    'Quinto Ano',
    'Mente, corda e clima',
    'Vinte e quatro feitiços de N.O.M.: Incarcerous e Erecto, Geminio e Evanesco, Animus Novandi e Animus Pensandi. Aqui o Estupefaça revela a forma que o tornou célebre, e o tempo passa a obedecer a Meteolojinx.',
    [{ art: 'orb', caption: 'Prancha I — A profecia, Departamento de Mistérios' }, { art: 'quill', caption: 'Prancha II — Pena e tinteiro dos N.O.M.s' }],
    ),
  'sexto-ano': yearSpreads(
    6,
    'Sexto Ano',
    'Segredos, revelações e proteções maiores',
    'Catorze feitiços de nível N.I.E.M.: Fidelius e Cave Inimicum guardam lugares, Homenum Revelio encontra quem se esconde, Capacious Extremis dobra o espaço. Feitiços de longa conjuração, para bruxos pacientes.',
    [{ art: 'locket', caption: 'Prancha I — O medalhão de Slytherin' }],
    ),
  'setimo-ano': yearSpreads(
    7,
    'Sétimo Ano',
    'Escudos absolutos e as Maldições Imperdoáveis',
    'Doze feitiços encerram o sumário: Protego Maxima, Salvio Hexia e Piertotum Locomotor de um lado; do outro, Fogomaldito, Crucio e Avada Kedavra, registrados para que se saiba reconhecê-los. Só quem tem Pacote pode conjurá-los.',
    [{ art: 'phoenix', caption: 'Prancha I — A fênix, depois da batalha' }],
    ),
}

export function getSpreads(id: string): Spread[] {
  return contents[id] ?? []
}
