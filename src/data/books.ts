import type { BookData, Spread } from '../types'

const reservedMaterias = (ano: string) => ({
  type: 'reserved' as const,
  label: `Matérias — ${ano}`,
  hint: 'Espaço para o horário das aulas, professores e salas (torre, masmorras, estufas).',
})

const reservedFeiticos = (ano: string) => ({
  type: 'reserved' as const,
  label: `Feitiços — ${ano}`,
  hint: 'Catálogo ainda por preencher: nome, movimento de varinha, encantamento e efeito.',
})

const reservedNotas = (ano: string) => ({
  type: 'reserved' as const,
  label: 'Anotações da aula',
  hint: `Pergaminho em branco para deveres, pontos das casas e observações do ${ano.toLowerCase()}.`,
})

type Plate = { art: string; caption: string }

const plate = (p: Plate, large = false) => ({ type: 'plate' as const, art: p.art, caption: p.caption, large })

function yearSpreads(
  title: string,
  subtitle: string,
  intro: string,
  subjects: string[],
  plates: [Plate, Plate?],
): Spread[] {
  const [frontis, second] = plates
  return [
    {
      left: [
        { type: 'heading', text: title },
        { type: 'subheading', text: subtitle },
        { type: 'ornament' },
        plate(frontis, true),
        { type: 'paragraph', text: intro },
      ],
      right: [
        reservedMaterias(title),
        { type: 'list', items: subjects },
      ],
    },
    {
      left: second ? [reservedFeiticos(title), plate(second, true)] : [reservedFeiticos(title)],
      right: [reservedNotas(title)],
    },
  ]
}

export const books: BookData[] = [
  {
    id: 'ambientacao',
    title: 'Hogwarts',
    shortTitle: 'Castelo',
    category: 'world',
    subtitle: 'O castelo e o mundo mágico',
    motto: 'Draco dormiens nunquam titillandus.',
    spineLabel: 'HOGWARTS',
    size: 'grand',
    wear: 0.72,
    tilt: -1.4,
    heightNudge: 8,
    palette: {
      leather: '#6b1d1d',
      leatherDark: '#2a0c0c',
      leatherLight: '#9a3a32',
      spine: '#541616',
      gold: '#d4b056',
      pageTint: '#efe2c4',
      ribbon: '#ae0001',
    },
    spreads: [
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
  },
  {
    id: 'habilidades',
    title: 'Matérias',
    shortTitle: 'Aulas',
    category: 'world',
    subtitle: 'As artes ensinadas em Hogwarts',
    motto: 'A varinha escolhe o bruxo.',
    spineLabel: 'MATÉRIAS',
    size: 'grand',
    wear: 0.48,
    tilt: 0.8,
    heightNudge: 0,
    palette: {
      leather: '#1b4d2e',
      leatherDark: '#0c2416',
      leatherLight: '#2f7a48',
      spine: '#163d26',
      gold: '#d0b36a',
      pageTint: '#eadcc0',
      ribbon: '#2a623d',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Matérias' },
          { type: 'subheading', text: 'O currículo de Hogwarts' },
          { type: 'ornament' },
          plate({ art: 'wand', caption: 'Prancha I — A varinha escolhe o bruxo' }, true),
          {
            type: 'paragraph',
            text: 'Sete anos, dezenas de salas e um horário que desafia a lógica das escadas. As matérias obrigatórias moldam o bruxo; as opcionais — Runicas, Aritmancia, Trato das Criaturas, Alquimia — revelam a vocação.',
          },
        ],
        right: [
          {
            type: 'entries',
            items: [
              { title: 'Feitiços', text: 'Encantamentos, precisão do gesto e a palavra certa. Torre de Ravenclaw, em geral.' },
              { title: 'Transfiguração', text: 'A mais elegante e a mais implacável. McGonagall não tolera sapos a meio caminho.' },
              { title: 'Poções', text: 'Masmorras, caldeirões e a diferença entre infusão e explosão.' },
              { title: 'Defesa Contra as Artes das Trevas', text: 'O posto que ninguém consegue manter por muito tempo.' },
              { title: 'Herbologia', text: 'Estufas, mandrágoras e luvas de dragão.' },
              { title: 'Astronomia', text: 'Torre mais alta, à meia-noite, com telescópio.' },
            ],
          },
        ],
      },
      {
        left: [
          { type: 'subheading', text: 'Exames' },
          plate({ art: 'mandrake', caption: 'Prancha II — Mandrágora jovem, Estufa Três' }),
          {
            type: 'list',
            items: [
              'N.O.M.s — quinto ano, a base de tudo.',
              'N.I.E.M.s — sétimo ano, especialização.',
              'Quadribol não conta para o quadro — mas conta para a alma.',
            ],
          },
        ],
        right: [
          reservedMaterias('Currículo geral'),
          {
            type: 'reserved',
            label: 'Professores',
            hint: 'Retratos, salas e peculiaridades de cada cátedra.',
          },
        ],
      },
    ],
  },
  {
    id: 'racas',
    title: 'Casas',
    shortTitle: 'Casas',
    category: 'world',
    subtitle: 'As quatro casas de Hogwarts',
    motto: 'O Chapéu Seletor ainda está a pensar.',
    spineLabel: 'CASAS',
    size: 'grand',
    wear: 0.61,
    tilt: 1.6,
    heightNudge: 4,
    palette: {
      leather: '#1a365c',
      leatherDark: '#0b1a30',
      leatherLight: '#2e5a8f',
      spine: '#142c4c',
      gold: '#c9a45a',
      pageTint: '#f0e4c9',
      ribbon: '#0e1a40',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Casas' },
          { type: 'subheading', text: 'Quatro fundadores, quatro temperamentos' },
          { type: 'ornament' },
          plate({ art: 'hat', caption: 'Prancha I — O Chapéu Seletor' }, true),
          {
            type: 'paragraph',
            text: 'Toda a vida em Hogwarts parte da Seleção. O Chapéu lê o que se é — e o que se pode vir a ser. Os pontos no relógio do Salão Principal não medem só vitórias de Quadribol: medem escolhas.',
          },
        ],
        right: [
          {
            type: 'entries',
            items: [
              { title: 'Grifinória', text: 'Coragem, ousadia, cavalheirismo. Escarlate e ouro. Elos de leão e a torre da Grifinória.' },
              { title: 'Sonserina', text: 'Ambição, astúcia, sangue-frio. Verde e prata. A masmorra no lago e o basilisco dos rumores.' },
              { title: 'Corvinal', text: 'Inteligência, criatividade, saber. Azul e bronze. O enigma da águia na entrada da torre.' },
              { title: 'Lufa-Lufa', text: 'Lealdade, paciência, trabalho honesto. Amarelo e negro. A sala perto das cozinhas.' },
            ],
          },
        ],
      },
      {
        left: [
          { type: 'subheading', text: 'Fantasmas e relíquias' },
          plate({ art: 'sword', caption: 'Prancha II — A espada de Godric Gryffindor' }),
          {
            type: 'paragraph',
            text: 'Nick Quase Sem Cabeça, o Barão Sangrento, a Dama Cinzenta e o Frei Gorducho percorrem os corredores. Cada casa guarda também um objeto dos fundadores — páginas reservadas para esses relatos.',
          },
          {
            type: 'reserved',
            label: 'Brasões',
            hint: 'Iluminuras dos quatro brasões e das salas comunais.',
          },
        ],
        right: [
          {
            type: 'reserved',
            label: 'Quadro de pontos',
            hint: 'Registro anual da Taça das Casas.',
          },
          {
            type: 'reserved',
            label: 'Prefetos e R.P.M.',
            hint: 'Lista de cargos, insígnias e o crachá de Rony… quando couber.',
          },
        ],
      },
    ],
  },
  {
    id: 'primeiro-ano',
    title: 'Primeiro Ano',
    shortTitle: 'I',
    category: 'year',
    year: 1,
    subtitle: 'Cartas, barcos e o Chapéu Seletor',
    motto: 'Nem sempre o que queremos é o que o Chapéu vê.',
    spineLabel: 'PRIMEIRO',
    size: 'tome',
    wear: 0.3,
    tilt: -0.8,
    heightNudge: -6,
    palette: {
      leather: '#7a4a1e',
      leatherDark: '#2d170c',
      leatherLight: '#b56a30',
      spine: '#5a321b',
      gold: '#e0c37a',
      pageTint: '#f2e6c8',
      ribbon: '#ae0001',
    },
    spreads: yearSpreads(
      'Primeiro Ano',
      'Cartas, barcos e o Chapéu Seletor',
      'A carta chega por coruja. O Expresso parte, os barcos cruzam o lago e o Chapéu canta. No primeiro ano aprendem-se os gestos básicos — Lumos, Wingardium Leviosa — e a arte de não se perder a caminho das Poções.',
      ['Feitiços (placeholder)', 'Transfiguração (placeholder)', 'Poções (placeholder)', 'Voo com vassoura (placeholder)'],
      [{ art: 'owl', caption: 'Prancha I — A coruja e a carta' }, { art: 'broom', caption: 'Prancha II — Primeira aula de voo' }],
    ),
  },
  {
    id: 'segundo-ano',
    title: 'Segundo Ano',
    shortTitle: 'II',
    category: 'year',
    year: 2,
    subtitle: 'Diários, elmos e sussurros na parede',
    motto: 'A herança de Slytherin não se discute no jantar.',
    spineLabel: 'SEGUNDO',
    size: 'tome',
    wear: 0.38,
    tilt: 1.1,
    heightNudge: 2,
    palette: {
      leather: '#7a2430',
      leatherDark: '#330d14',
      leatherLight: '#a84852',
      spine: '#621c28',
      gold: '#d7b56a',
      pageTint: '#ecddc0',
      ribbon: '#8d2433',
    },
    spreads: yearSpreads(
      'Segundo Ano',
      'Diários, elmos e sussurros na parede',
      'Os alunos já conhecem os corredores. Mandrágoras choram nas estufas e rumores de uma câmara antiga voltam a circular. Espaço reservado para o diário, a herdeira e os elfos que ninguém vê.',
      ['Herbologia (placeholder)', 'História da Magia (placeholder)', 'Defesa Contra as Artes das Trevas (placeholder)'],
      [{ art: 'diary', caption: 'Prancha I — O diário e o dente de basilisco' }, { art: 'cauldron', caption: 'Prancha II — Poção Polissuco, banheiro do segundo andar' }],
    ),
  },
  {
    id: 'terceiro-ano',
    title: 'Terceiro Ano',
    shortTitle: 'III',
    category: 'year',
    year: 3,
    subtitle: 'O Expresso, o hipogrifo e o tempo',
    motto: 'Um simples vira-tempo já basta para complicar o horário.',
    spineLabel: 'TERCEIRO',
    size: 'tome',
    wear: 0.44,
    tilt: -1.2,
    heightNudge: 7,
    palette: {
      leather: '#3f4a22',
      leatherDark: '#171c0c',
      leatherLight: '#6a7540',
      spine: '#323a1b',
      gold: '#cbb56a',
      pageTint: '#e8d9b6',
      ribbon: '#2a623d',
    },
    spreads: yearSpreads(
      'Terceiro Ano',
      'O Expresso, o hipogrifo e o tempo',
      'Hogsmeade abre as portas a quem tem autorização. Adivinhação na torre, Trato das Criaturas Magníficas no parque e o professor que ninguém espera. Guarde aqui o hipogrifo, o mapa e as voltas no tempo.',
      ['Adivinhação (placeholder)', 'Trato das Criaturas (placeholder)', 'Aritmância (placeholder)'],
      [{ art: 'timeturner', caption: 'Prancha I — O Vira-Tempo' }, { art: 'snitch', caption: 'Prancha II — A Firebolt e o pomo' }],
    ),
  },
  {
    id: 'quarto-ano',
    title: 'Quarto Ano',
    shortTitle: 'IV',
    category: 'year',
    year: 4,
    subtitle: 'O Cálice e as três tarefas',
    motto: 'Nascido para isso, ou apenas o Cálice achou que sim.',
    spineLabel: 'QUARTO',
    size: 'tome',
    wear: 0.52,
    tilt: 0.4,
    heightNudge: -3,
    palette: {
      leather: '#243a68',
      leatherDark: '#101826',
      leatherLight: '#3d5a9a',
      spine: '#1c2e54',
      gold: '#d4b56a',
      pageTint: '#efe3c6',
      ribbon: '#0e1a40',
    },
    spreads: yearSpreads(
      'Quarto Ano',
      'O Cálice e as três tarefas',
      'Anos de Torneio são raros: dragões, o lago, o labirinto. Visitantes de Beauxbatons e Durmstrang sentam-se no Salão. Estas páginas aguardam as tarefas, os pactos e o que o Cálice não deveria ter feito.',
      ['Torneio Tribruxo (placeholder)', 'Etiqueta mágica (placeholder)', 'Feitiços avançados (placeholder)'],
      [{ art: 'goblet', caption: 'Prancha I — O Cálice de Fogo' }, { art: 'hourglass', caption: 'Prancha II — As três tarefas, contra o tempo' }],
    ),
  },
  {
    id: 'quinto-ano',
    title: 'Quinto Ano',
    shortTitle: 'V',
    category: 'year',
    year: 5,
    subtitle: 'N.O.M.s e a Ordem',
    motto: 'A inquisidora nunca está tão longe quanto parece.',
    spineLabel: 'QUINTO',
    size: 'tome',
    wear: 0.58,
    tilt: 1.8,
    heightNudge: 5,
    palette: {
      leather: '#4a2a4e',
      leatherDark: '#1c0f20',
      leatherLight: '#734778',
      spine: '#3c2140',
      gold: '#ddc07a',
      pageTint: '#ead9b8',
      ribbon: '#5d2d6e',
    },
    spreads: yearSpreads(
      'Quinto Ano',
      'N.O.M.s e a Ordem',
      'O ano dos exames que decidem o resto da vida bruxa. Defesa torna-se política, a Sala Precisa ensina o que o decreto proíbe, e a Armada de Dumbledore cabe neste espaço — quando quiserem preenchê-lo.',
      ['N.O.M.s (placeholder)', 'Oclumência (placeholder)', 'Sala Precisa (placeholder)'],
      [{ art: 'orb', caption: 'Prancha I — A profecia, Departamento de Mistérios' }, { art: 'quill', caption: 'Prancha II — Pena e tinteiro dos N.O.M.s' }],
    ),
  },
  {
    id: 'sexto-ano',
    title: 'Sexto Ano',
    shortTitle: 'VI',
    category: 'year',
    year: 6,
    subtitle: 'N.I.E.M.s, poções do príncipe e horcruxes',
    motto: 'O príncipe não assinou com o nome que usava na sala.',
    spineLabel: 'SEXTO',
    size: 'tome',
    wear: 0.66,
    tilt: -0.5,
    heightNudge: 1,
    palette: {
      leather: '#3a332c',
      leatherDark: '#161310',
      leatherLight: '#5c5348',
      spine: '#2f2923',
      gold: '#e6c97a',
      pageTint: '#f1e4c4',
      ribbon: '#8a6a32',
    },
    spreads: yearSpreads(
      'Sexto Ano',
      'Poções do príncipe e horcruxes',
      'Apenas quem passou nos N.O.M.s segue nas matérias avançadas: Aparatação, poções de nível N.I.E.M. e aulas particulares fora do horário. Reserve estas folhas para o livro anotado e as memórias.',
      ['Aparatação (placeholder)', 'Poções N.I.E.M. (placeholder)', 'Aulas particulares (placeholder)'],
      [{ art: 'locket', caption: 'Prancha I — O medalhão de Slytherin' }],
    ),
  },
  {
    id: 'setimo-ano',
    title: 'Sétimo Ano',
    shortTitle: 'VII',
    category: 'year',
    year: 7,
    subtitle: 'A batalha e o que vem depois',
    motto: 'Hogwarts não se entrega.',
    spineLabel: 'SÉTIMO',
    size: 'tome',
    wear: 0.84,
    tilt: 0.9,
    heightNudge: 10,
    palette: {
      leather: '#1a1412',
      leatherDark: '#070605',
      leatherLight: '#3a302c',
      spine: '#14100e',
      gold: '#f0d78a',
      pageTint: '#e8d7b0',
      ribbon: '#ae0001',
    },
    spreads: yearSpreads(
      'Sétimo Ano',
      'A batalha e o que vem depois',
      'O último ano deveria ser só N.I.E.M.s. Em certos tempos, a escola torna-se fortaleza. Estas páginas guardam espaço para a batalha, os que voltaram e o silêncio do Salão quando a guerra acaba.',
      ['N.I.E.M.s (placeholder)', 'A Batalha de Hogwarts (placeholder)', 'O que se ensina depois (placeholder)'],
      [{ art: 'phoenix', caption: 'Prancha I — A fênix, depois da batalha' }],
    ),
  },
]

export const worldBooks = books.filter((b) => b.category === 'world')
export const yearBooks = books.filter((b) => b.category === 'year')

export function getBook(id: string) {
  return books.find((b) => b.id === id)
}

export function neighborIds(id: string) {
  const i = books.findIndex((b) => b.id === id)
  return {
    prev: i > 0 ? books[i - 1].id : null,
    next: i >= 0 && i < books.length - 1 ? books[i + 1].id : null,
  }
}
