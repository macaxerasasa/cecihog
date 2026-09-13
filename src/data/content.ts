import type { ContentBlock, Spread } from '../types'
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
  habilidades: [
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
        {
          type: 'reserved',
          label: 'Matérias — Currículo geral',
          hint: 'Espaço para o horário das aulas, professores e salas (torre, masmorras, estufas).',
        },
        {
          type: 'reserved',
          label: 'Professores',
          hint: 'Retratos, salas e peculiaridades de cada cátedra.',
        },
      ],
    },
    ],
  racas: [
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
