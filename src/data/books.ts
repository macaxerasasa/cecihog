import type { BookData } from '../types'

const reservedMaterias = (ano: string): { type: 'reserved'; label: string; hint: string } => ({
  type: 'reserved',
  label: `Matérias — ${ano}`,
  hint: 'Espaço reservado para o currículo, mestres e horas de estudo deste ciclo. Adicione aqui as disciplinas oficiais quando o grimório for preenchido.',
})

const reservedFeiticos = (ano: string): { type: 'reserved'; label: string; hint: string } => ({
  type: 'reserved',
  label: `Feitiços — ${ano}`,
  hint: 'Catálogo ainda selado. Cada entrada poderá receber nome, círculo, componentes, duração e transcrição da fórmula.',
})

const reservedNotas = (ano: string): { type: 'reserved'; label: string; hint: string } => ({
  type: 'reserved',
  label: `Anotações do ciclo`,
  hint: `Folhas em branco para crônicas, advertências da reitoria e observações de campo do ${ano.toLowerCase()}.`,
})

export const books: BookData[] = [
  {
    id: 'ambientacao',
    title: 'Ambientação',
    shortTitle: 'Mundo',
    category: 'world',
    subtitle: 'Sobre este mundo',
    motto: 'Onde a cinza ainda guarda o nome das estrelas.',
    spineLabel: 'AMBIENTAÇÃO',
    size: 'grand',
    wear: 0.72,
    tilt: -1.4,
    heightNudge: 8,
    palette: {
      leather: '#5a1e24',
      leatherDark: '#2a0c11',
      leatherLight: '#8a3a3f',
      spine: '#4a181d',
      gold: '#c8a15a',
      pageTint: '#efe2c4',
      ribbon: '#7a1f2b',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Ambientação' },
          { type: 'subheading', text: 'Sobre este mundo' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'Além das Montanhas de Vidro-Fumê jaz o vale de Cinderis, último recinto onde a língua antiga ainda é ensinada em voz baixa. A Academia não se anuncia: revela-se a quem já esqueceu o caminho de volta.',
          },
          {
            type: 'paragraph',
            text: 'Este tomo descreve o palco — céus, leis, ruínas e o pacto que impede o inverno de fechar as portas da biblioteca. Não é um mapa. É uma memória que insiste em permanecer.',
          },
        ],
        right: [
          { type: 'subheading', text: 'O Ateneu de Cinderis' },
          {
            type: 'paragraph',
            text: 'Erguido sobre as fundações de um mosteiro anterior ao Primeiro Silêncio, o Ateneu guarda sete claustros, um observatório cego e a Estante-Mãe — de onde estes volumes nunca deveriam ser retirados.',
          },
          {
            type: 'entries',
            items: [
              {
                title: 'Clima e céu',
                text: 'Outonos longos. Auroras baixas. A chuva cheira a tinta e resina.',
              },
              {
                title: 'Moeda e pacto',
                text: 'Troca-se em cinzas medidas, favores selados e nomes verdadeiros.',
              },
              {
                title: 'Fora dos muros',
                text: 'Bosques de carvalho-negro, vilas de lanternas e a Estrada que Recua.',
              },
            ],
          },
          {
            type: 'reserved',
            label: 'Cartografia',
            hint: 'Espaço para mapas, selos de regiões e cronologias do mundo.',
          },
        ],
      },
      {
        left: [
          { type: 'heading', text: 'Leis do vale' },
          { type: 'ornament' },
          {
            type: 'list',
            items: [
              'Nenhum fogo aberto junto aos pergaminhos vivos.',
              'Nomes verdadeiros não se escrevem na primeira pessoa.',
              'O sino das nove marca o fim das evocações menores.',
              'Visitantes dormem no claustro oeste, jamais na cripta.',
            ],
          },
        ],
        right: [
          { type: 'subheading', text: 'História breve' },
          {
            type: 'paragraph',
            text: 'Três eras marcam Cinderis: a Fundação, o Silêncio, e a Reabertura. Os detalhes da segunda foram deliberadamente apagados. Os espaços em branco abaixo aguardam o retorno dessas páginas.',
          },
          {
            type: 'reserved',
            label: 'Linha do tempo',
            hint: 'Insira dinastias, catástrofes e tratados. Cada era pode ganhar um spread próprio.',
          },
        ],
      },
    ],
  },
  {
    id: 'habilidades',
    title: 'Habilidades',
    shortTitle: 'Artes',
    category: 'world',
    subtitle: 'As artes que o corpo e a vontade aprendem',
    motto: 'A mão lembra o que a boca ainda teme pronunciar.',
    spineLabel: 'HABILIDADES',
    size: 'grand',
    wear: 0.48,
    tilt: 0.8,
    heightNudge: 0,
    palette: {
      leather: '#1f3d32',
      leatherDark: '#0c1c17',
      leatherLight: '#3d6a56',
      spine: '#17352c',
      gold: '#d0b36a',
      pageTint: '#eadcc0',
      ribbon: '#2e6b4f',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Habilidades' },
          { type: 'subheading', text: 'Categorias da prática' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'No Ateneu, talento não é dom: é disciplina. As artes se agrupam em quatro colunas, e cada coluna exige um voto diferente. Este volume organiza o vocabulário comum — não as fórmulas.',
          },
        ],
        right: [
          {
            type: 'entries',
            items: [
              {
                title: 'Voz e Verbo',
                text: 'Entoação, nomes, silêncios ritmados. A palavra como instrumento.',
              },
              {
                title: 'Gesto e Selo',
                text: 'Mudras, caligrafia no ar, geometria das mãos.',
              },
              {
                title: 'Matéria e Vaso',
                text: 'Ervas, metais, cinzas, sangue de tinta. O mundo como tinta.',
              },
              {
                title: 'Olhar e Sombra',
                text: 'Percepção, discrição, leitura de auras e mentiras.',
              },
            ],
          },
        ],
      },
      {
        left: [
          { type: 'subheading', text: 'Medidas de mestria' },
          {
            type: 'list',
            items: [
              'Noviço — reproduz, não inventa.',
              'Adepto — combina duas colunas sem fenda.',
              'Lente — ensina sem revelar o nome da arte.',
              'Arquivista — altera a própria categoria.',
            ],
          },
        ],
        right: [
          reservedMaterias('Habilidades Gerais'),
          {
            type: 'reserved',
            label: 'Tabelas de progresso',
            hint: 'Espaço para custos, pré-requisitos e marcas de excelência.',
          },
        ],
      },
    ],
  },
  {
    id: 'racas',
    title: 'Raças',
    shortTitle: 'Povos',
    category: 'world',
    subtitle: 'Quem habita a margem do saber',
    motto: 'Sangue é só outra tinta, se souberes o solvente.',
    spineLabel: 'RAÇAS',
    size: 'grand',
    wear: 0.61,
    tilt: 1.6,
    heightNudge: 4,
    palette: {
      leather: '#1c2a4a',
      leatherDark: '#0b1224',
      leatherLight: '#3a4e7a',
      spine: '#16233f',
      gold: '#c9a45a',
      pageTint: '#f0e4c9',
      ribbon: '#3d4f86',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Raças' },
          { type: 'subheading', text: 'Povos do vale e além' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'O Ateneu admite quem atravessa o umbral com um nome e uma pergunta. As linhagens abaixo são as mais recorrentes nos registros — não as únicas possíveis.',
          },
        ],
        right: [
          {
            type: 'entries',
            items: [
              {
                title: 'Humanos de Cinderis',
                text: 'Memória curta, ambição longa. Dominam a caligrafia administrativa.',
              },
              {
                title: 'Velho-Sangue',
                text: 'Orelhas em lua, pulso frio. Enxergam tinta invisível à luz do dia.',
              },
              {
                title: 'Cinzentos da Rocha',
                text: 'Pele mineral, voz de poço. Guardas naturais da cripta.',
              },
              {
                title: 'Nascidos da Bruma',
                text: 'Raros. Sua sombra chega um passo antes do corpo.',
              },
            ],
          },
        ],
      },
      {
        left: [
          { type: 'subheading', text: 'Espaço para linhagens' },
          {
            type: 'paragraph',
            text: 'Cada povo deverá receber origem, temperamento, dons herdados e tabus. As páginas seguintes estão pautadas e aguardam iluminura.',
          },
          {
            type: 'reserved',
            label: 'Retratos',
            hint: 'Insira iluminuras, brasões e amostras de caligrafia nativa.',
          },
        ],
        right: [
          {
            type: 'reserved',
            label: 'Relações entre povos',
            hint: 'Tabelas de alianças, preconceitos acadêmicos e pactos de sangue.',
          },
          {
            type: 'reserved',
            label: 'Notas de campo',
            hint: 'Observações de mestres viajantes e contradições entre crônicas.',
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
    subtitle: 'O umbral e a lamparina',
    motto: 'Aprende a ver o escuro antes de acender qualquer chama.',
    spineLabel: 'I  ·  PRIMEIRO ANO',
    size: 'tome',
    wear: 0.3,
    tilt: -0.8,
    heightNudge: -6,
    palette: {
      leather: '#6b3e22',
      leatherDark: '#2d170c',
      leatherLight: '#a0663a',
      spine: '#5a321b',
      gold: '#e0c37a',
      pageTint: '#f2e6c8',
      ribbon: '#b4532a',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Primeiro Ano' },
          { type: 'subheading', text: 'O umbral e a lamparina' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'O noviço chega com as mãos limpas e a boca cheia de perguntas erradas. O primeiro ciclo não ensina a dobrar o mundo — ensina a não se perder nele. Aqui se aprende a copiar, a calar, a nomear o óbvio com precisão.',
          },
        ],
        right: [
          reservedMaterias('Primeiro Ano'),
          {
            type: 'list',
            items: [
              'Caligrafia de umbral (placeholder)',
              'História breve do Silêncio (placeholder)',
              'Cuidado de lamparinas e tintas (placeholder)',
            ],
          },
        ],
      },
      {
        left: [reservedFeiticos('Primeiro Ano')],
        right: [reservedNotas('Primeiro Ano')],
      },
    ],
  },
  {
    id: 'segundo-ano',
    title: 'Segundo Ano',
    shortTitle: 'II',
    category: 'year',
    year: 2,
    subtitle: 'A tinta aprende a andar',
    motto: 'Toda linha reta é uma mentira útil.',
    spineLabel: 'II  ·  SEGUNDO ANO',
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
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Segundo Ano' },
          { type: 'subheading', text: 'A tinta aprende a andar' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'No segundo ciclo, o copista torna-se aprendiz de forma. Geometrias simples, primeiros selos e a ética de não escrever o que não se pode desfazer. As matérias ganham peso; as noites, também.',
          },
        ],
        right: [
          reservedMaterias('Segundo Ano'),
          {
            type: 'list',
            items: [
              'Geometria dos selos menores (placeholder)',
              'Botânica de claustro (placeholder)',
              'Ética da transcrição (placeholder)',
            ],
          },
        ],
      },
      {
        left: [reservedFeiticos('Segundo Ano')],
        right: [reservedNotas('Segundo Ano')],
      },
    ],
  },
  {
    id: 'terceiro-ano',
    title: 'Terceiro Ano',
    shortTitle: 'III',
    category: 'year',
    year: 3,
    subtitle: 'Voz, vaso e vigília',
    motto: 'O que se pronuncia passa a dever-te uma resposta.',
    spineLabel: 'III  ·  TERCEIRO ANO',
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
      ribbon: '#6b7333',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Terceiro Ano' },
          { type: 'subheading', text: 'Voz, vaso e vigília' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'Aqui a prática deixa o caderno e toca o ar. Entoações controladas, primeiros vasos e a vigília das nove. Erros deixam de ser borracha: passam a ser cicatriz acadêmica.',
          },
        ],
        right: [
          reservedMaterias('Terceiro Ano'),
          {
            type: 'list',
            items: [
              'Entoação menor (placeholder)',
              'Alquimia de vaso frio (placeholder)',
              'Vigília e guarda de limiares (placeholder)',
            ],
          },
        ],
      },
      {
        left: [reservedFeiticos('Terceiro Ano')],
        right: [reservedNotas('Terceiro Ano')],
      },
    ],
  },
  {
    id: 'quarto-ano',
    title: 'Quarto Ano',
    shortTitle: 'IV',
    category: 'year',
    year: 4,
    subtitle: 'O meio da escada',
    motto: 'Quem olha para trás neste degrau vê o tamanho da queda.',
    spineLabel: 'IV  ·  QUARTO ANO',
    size: 'tome',
    wear: 0.52,
    tilt: 0.4,
    heightNudge: -3,
    palette: {
      leather: '#2c3d55',
      leatherDark: '#101826',
      leatherLight: '#4d6788',
      spine: '#243448',
      gold: '#d4b56a',
      pageTint: '#efe3c6',
      ribbon: '#3e5a7a',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Quarto Ano' },
          { type: 'subheading', text: 'O meio da escada' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'O quarto ciclo é o estreito. Muitos abandonam. Os que ficam aprendem a unir duas colunas de habilidade e a escrever para um leitor que ainda não nasceu. É também o ano das primeiras saídas vigiadas.',
          },
        ],
        right: [
          reservedMaterias('Quarto Ano'),
          {
            type: 'list',
            items: [
              'Correspondência de colunas (placeholder)',
              'Cartografia de limiares (placeholder)',
              'Prática de campo vigiada (placeholder)',
            ],
          },
        ],
      },
      {
        left: [reservedFeiticos('Quarto Ano')],
        right: [reservedNotas('Quarto Ano')],
      },
    ],
  },
  {
    id: 'quinto-ano',
    title: 'Quinto Ano',
    shortTitle: 'V',
    category: 'year',
    year: 5,
    subtitle: 'A autoridade da sombra',
    motto: 'Luz demais é só outra forma de cegueira.',
    spineLabel: 'V  ·  QUINTO ANO',
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
      ribbon: '#6e3d73',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Quinto Ano' },
          { type: 'subheading', text: 'A autoridade da sombra' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'Neste volume, o estudante deixa de ser protegido da própria obra. Trabalha-se com ausência, eco e o que a biblioteca recusa catalogar. As matérias avançadas exigem testemunha e lacre.',
          },
        ],
        right: [
          reservedMaterias('Quinto Ano'),
          {
            type: 'list',
            items: [
              'Teoria da ausência (placeholder)',
              'Selos de lacre duplo (placeholder)',
              'Leitura de ecos (placeholder)',
            ],
          },
        ],
      },
      {
        left: [reservedFeiticos('Quinto Ano')],
        right: [reservedNotas('Quinto Ano')],
      },
    ],
  },
  {
    id: 'sexto-ano',
    title: 'Sexto Ano',
    shortTitle: 'VI',
    category: 'year',
    year: 6,
    subtitle: 'Ofício e herança',
    motto: 'Ensinar é a prova de que compreendeste o perigo.',
    spineLabel: 'VI  ·  SEXTO ANO',
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
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Sexto Ano' },
          { type: 'subheading', text: 'Ofício e herança' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'O sexto ciclo aproxima o estudante da cátedra. Restaura-se um volume danificado, orienta-se um noviço, e defende-se uma tese diante de três lentes. O orgulho é considerado uma falha de copista.',
          },
        ],
        right: [
          reservedMaterias('Sexto Ano'),
          {
            type: 'list',
            items: [
              'Restauro de grimórios (placeholder)',
              'Pedagogia do umbral (placeholder)',
              'Tese menor (placeholder)',
            ],
          },
        ],
      },
      {
        left: [reservedFeiticos('Sexto Ano')],
        right: [reservedNotas('Sexto Ano')],
      },
    ],
  },
  {
    id: 'setimo-ano',
    title: 'Sétimo Ano',
    shortTitle: 'VII',
    category: 'year',
    year: 7,
    subtitle: 'O nome que não se lê em voz alta',
    motto: 'Fecha o livro. O mundo continuará a escrever-te.',
    spineLabel: 'VII  ·  SÉTIMO ANO',
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
      ribbon: '#a07a2c',
    },
    spreads: [
      {
        left: [
          { type: 'heading', text: 'Sétimo Ano' },
          { type: 'subheading', text: 'O nome que não se lê em voz alta' },
          { type: 'ornament' },
          {
            type: 'paragraph',
            text: 'Último tomo do ciclo. Não há currículo público — apenas um percurso, um silêncio e uma escolha. Quem conclui não “se forma”: é inscrito na margem da Estante-Mãe. As páginas seguintes estão quase vazias de propósito.',
          },
        ],
        right: [
          reservedMaterias('Sétimo Ano'),
          {
            type: 'reserved',
            label: 'Prova final',
            hint: 'Estrutura reservada para o rito, as testemunhas e o lacre de conclusão.',
          },
        ],
      },
      {
        left: [reservedFeiticos('Sétimo Ano')],
        right: [reservedNotas('Sétimo Ano')],
      },
    ],
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
