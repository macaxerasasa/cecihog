import type { ContentBlock, Spread } from '../types'

export type GiftKind = 'skill' | 'race'

export type Gift = {
  id: string
  kind: GiftKind
  name: string
  aliases: string[]
  tag: string
  rarity: string
  requirement?: string
  text: string[]
  art: string
  caption: string
}

export const gifts: Gift[] = [
  {
    id: 'legilimencia',
    kind: 'skill',
    name: 'Legilimência',
    aliases: ['Legilimens', 'invasão mental'],
    tag: 'Arte mental',
    rarity: 'Treinável',
    requirement: 'Feitiço Legilimens, contato visual e concentração',
    art: 'mind',
    caption: 'Prancha — O olhar que atravessa',
    text: [
      'Habilidade de invasão mental que exige a conjuração do feitiço Legilimens, geralmente acompanhada de contato visual direto e forte concentração, para que o personagem force a entrada nos pensamentos, memórias e emoções superficiais de um alvo.',
      'Quanto mais profunda ou protegida for a informação buscada, mais difícil e desgastante se torna a invasão. O alvo pode perceber a intrusão e reagir com dor de cabeça, sangramento nasal ou até dano psíquico, caso a diferença de poder entre os dois seja grande.',
      'Sem o feitiço devidamente conjurado — seja por interrupção, falha na concentração ou ausência de contato visual — a habilidade simplesmente não se ativa. Alvos com Oclumência bem treinada tornam a invasão extremamente arriscada, podendo até reverter o ataque contra o próprio legilimente.',
    ],
  },
  {
    id: 'oclumencia',
    kind: 'skill',
    name: 'Oclumência',
    aliases: ['blindagem mental', 'Occlumens'],
    tag: 'Arte mental',
    rarity: 'Treinável',
    requirement: 'Barreiras mentais construídas com o tempo',
    art: 'occlumency',
    caption: 'Prancha — A fortaleza da mente',
    text: [
      'A contraparte defensiva da Legilimência: uma blindagem mental que o personagem constrói ao longo do tempo para organizar, esconder ou selar memórias e pensamentos específicos atrás de barreiras bem treinadas.',
      'Quem domina essa arte resiste com muito mais facilidade a invasões mentais e tranca informações escolhidas de forma quase impenetrável, mesmo sob ataque.',
      'Em estágios avançados, pode implantar memórias falsas para enganar quem tenta invadir a mente, e ganha resistência natural contra efeitos de controle mental, maldições como o Imperius e ilusões baseadas em manipulação psíquica.',
    ],
  },
  {
    id: 'ofidioglossia',
    kind: 'skill',
    name: 'Ofidioglossia',
    aliases: ['parsél', 'língua das cobras'],
    tag: 'Dom de sangue',
    rarity: 'Inato · linhagem Gaunt',
    requirement: 'Descendência dos Gaunt, herdeiros de Salazar Slytherin',
    art: 'serpent',
    caption: 'Prancha — A língua das cobras',
    text: [
      'A capacidade de falar e compreender a língua das cobras (parsél), um dom raro que só existe naturalmente em quem descende da linhagem dos Gaunt, os últimos herdeiros diretos de Salazar Slytherin.',
      'Quem possui esse sangue comunica-se livremente com serpentes reais, criaturas serpentiformes e mecanismos, portas ou feitiços antigos que só respondem a esse idioma. É ferramenta valiosa tanto socialmente — informações através de cobras, enigmas ligados à Sonserina — quanto em combate: criaturas ofídicas tendem a tratar o personagem como aliado, ou ao menos evitam atacá-lo.',
      'Ainda assim, carrega um peso social forte: é vista com desconfiança e associada a magia sombria pela maior parte do mundo bruxo.',
    ],
  },
  {
    id: 'ocultismo',
    kind: 'skill',
    name: 'Ocultismo',
    aliases: ['afinidade elemental', 'magias elementais'],
    tag: 'Afinidade',
    rarity: 'Treinável',
    requirement: 'Estudo aprofundado dos elementos',
    art: 'elements',
    caption: 'Prancha — Fogo, água, terra e ar',
    text: [
      'Afinidade profunda com o estudo das magias elementais — fogo, água, terra, ar e variações como gelo e raio — que torna qualquer feitiço elemental lançado pelo personagem visivelmente mais forte, seja em poder de dano, alcance ou duração do efeito.',
      'Quem domina o Ocultismo sente muito menos o desgaste físico e mágico de conjurar feitiços elementais repetidamente, consegue combinar dois elementos em conjurações compostas mais avançadas (como transformar fogo e água em vapor abrasivo) e desenvolve uma resistência natural ao próprio tipo de elemento em que se especializou.',
    ],
  },
  {
    id: 'metamorfomagia',
    kind: 'skill',
    name: 'Metamorfomagia',
    aliases: ['metamorfomago', 'mudança de forma'],
    tag: 'Dom inato',
    rarity: 'Inato · raro',
    requirement: 'Nascido com o dom — sem varinha, poção ou feitiço',
    art: 'metamorph',
    caption: 'Prancha — O rosto que muda',
    text: [
      'A habilidade rara e inata de alterar a própria aparência física à vontade, sem depender de varinha, poções ou feitiços: cor e formato de cabelo, olhos, nariz, altura, peso e traços faciais mudam conforme a vontade do personagem.',
      'Funciona como um disfarce quase perfeito, permitindo passar-se por outra pessoa, escapar de reconhecimento ou mudar rapidamente de aparência em situações tensas para confundir quem está por perto.',
      'Tem limites claros: não altera cicatrizes mágicas fixas nem lesões permanentes, e sustentar mudanças muito drásticas por longos períodos exige concentração constante.',
    ],
  },
  {
    id: 'clarividencia',
    kind: 'skill',
    name: 'Clarividência',
    aliases: ['visões', 'profecia', 'vidência'],
    tag: 'Dom inato',
    rarity: 'Inato · incontrolável',
    requirement: 'As visões vêm quando querem — não quando se pede',
    art: 'clairvoyance',
    caption: 'Prancha — Fragmentos do que ainda não foi',
    text: [
      'O dom de enxergar fragmentos do futuro ou eventos distantes através de visões, transes ou sonhos proféticos que surgem de forma incontrolável e simbólica.',
      'Essas visões podem revelar pistas veladas sobre acontecimentos futuros, avisar sobre perigos iminentes com antecedência suficiente para uma reação mais preparada, ou apontar caminhos para resolver mistérios complexos.',
      'A natureza fragmentada e simbólica impede que sejam usadas como previsões exatas e confiáveis: o personagem não controla quando as visões surgem nem o que vai enxergar, e pode sair delas física ou mentalmente abalado quando são muito intensas.',
    ],
  },
  {
    id: 'animagia',
    kind: 'skill',
    name: 'Animagia',
    aliases: ['animago', 'forma animal'],
    tag: 'Arte ensinada',
    rarity: 'Treinável · anos de estudo',
    requirement: 'Anos de treino — ou, em casos raros, talento natural',
    art: 'animagus',
    caption: 'Prancha — A forma fixa',
    text: [
      'A capacidade, conquistada após anos de treinamento (ou, em casos raros, como talento natural), de se transformar completamente em um animal específico e fixo, mantendo a consciência e a personalidade humanas mesmo dentro da forma animal.',
      'Ao se transformar, o personagem passa a ter todos os atributos físicos, sentidos e habilidades naturais daquele animal — velocidade, voo, faro apurado, camuflagem ou porte de combate, dependendo da espécie — mas perde o acesso à magia com varinha e à fala humana enquanto estiver transformado.',
      'É extremamente útil para infiltração, fuga e reconhecimento. Reverter a transformação sob estresse extremo é bem mais difícil, com risco real de ficar preso na forma animal se a concentração falhar num momento crítico.',
    ],
  },
  {
    id: 'meio-gigante',
    kind: 'race',
    name: 'Meio gigante',
    aliases: ['meio-gigante', 'sangue de gigante'],
    tag: 'Linhagem',
    rarity: 'Nascido',
    requirement: 'Um dos pais é gigante',
    art: 'giant',
    caption: 'Prancha — O porte que não cabe na porta',
    text: [
      'Descendente direto de um gigante e um humano ou bruxo. Traz um porte físico muito acima da média — geralmente entre 2,5 e 3,5 metros — com força bruta, resistência física e capacidade de carregar peso ou quebrar obstáculos muito além do que qualquer outra raça conseguiria, além de uma resistência natural a venenos e a certos efeitos de controle mental, por conta de uma fisiologia mais rústica.',
      'Em troca, tem dificuldade natural com magia refinada e feitiços que exigem muita precisão, já que a magia dos gigantes é naturalmente mais bruta. Enfrenta problemas práticos para usar equipamentos feitos para humanos sem adaptação, e carrega um forte preconceito social, sendo tratado com desconfiança ou medo pela maior parte da sociedade bruxa.',
    ],
  },
  {
    id: 'lobisomem',
    kind: 'race',
    name: 'Lobisomem',
    aliases: ['licantropia', 'lobo'],
    tag: 'Maldição',
    rarity: 'Infectado',
    requirement: 'Mordida ou arranhão de lobisomem · lua cheia',
    art: 'werewolf',
    caption: 'Prancha — Sob a lua cheia',
    text: [
      'Humano infectado pela licantropia, que se transforma completamente e de forma involuntária em um lobo feroz nas noites de lua cheia, perdendo o controle consciente e atacando qualquer criatura viva ao alcance — incluindo aliados — a menos que tome a Poção Mata-Cão ou esteja devidamente contido antes da transformação.',
      'Fora das noites de lua cheia, carrega força, velocidade, resistência física, faro e audição muito acima do humano comum, além de uma regeneração levemente acelerada.',
      'Paga um preço alto em preconceito social, dificuldades de convívio e restrições legais no mundo bruxo, somado a uma vulnerabilidade maior a dano de prata e a magias criadas especificamente contra lobisomens.',
    ],
  },
  {
    id: 'veela',
    kind: 'race',
    name: 'Descendente de veela',
    aliases: ['veela', 'sangue de veela'],
    tag: 'Linhagem',
    rarity: 'Nascido',
    requirement: 'Fração da herança mágica das veelas',
    art: 'veela',
    caption: 'Prancha — Fogo e encanto',
    text: [
      'Carrega no sangue uma fração da herança mágica das veelas, criaturas de beleza sobrenatural e magia ligada ao fogo e ao encantamento. Essa herança dá ao personagem um carisma natural muito acima da média, capaz de encantar, seduzir ou intimidar praticamente sem esforço, além de uma resistência natural contra encantos e tentativas de charme vindas de outras pessoas.',
      'Em momentos de forte emoção — raiva intensa, medo extremo ou paixão — o personagem pode manifestar parcialmente a forma veela, ganhando acesso a rajadas de fogo mágico e um aumento temporário de força e agressividade, mas perdendo parte do controle racional e da precisão mágica enquanto esse estado dura, e voltando ao normal com um cansaço significativo assim que a transformação passa.',
    ],
  },
]

export const skills = gifts.filter((g) => g.kind === 'skill')
export const races = gifts.filter((g) => g.kind === 'race')

const byId = new Map(gifts.map((g) => [g.id, g]))
export const getGift = (id: string) => byId.get(id)

export function normalize(s: string) {
  return s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
}

export type GiftHit = { gift: Gift; score: number; where: 'name' | 'alias' | 'meta' | 'body' }

export function searchGifts(query: string): GiftHit[] {
  const q = normalize(query)
  if (q.length < 2) return []
  const words = q.split(/\s+/).filter(Boolean)
  const hits: GiftHit[] = []
  for (const g of gifts) {
    const name = normalize(g.name)
    const aliases = g.aliases.map(normalize)
    let score = 0
    let where: GiftHit['where'] | null = null
    if (name.startsWith(q)) {
      score = 100
      where = 'name'
    } else if (name.includes(q)) {
      score = 80
      where = 'name'
    } else if (aliases.some((a) => a.includes(q))) {
      score = 70
      where = 'alias'
    } else {
      const meta = normalize(`${g.tag} ${g.rarity} ${g.kind === 'skill' ? 'habilidade' : 'raca'} ${g.requirement ?? ''}`)
      if (words.every((w) => meta.includes(w))) {
        score = 50
        where = 'meta'
      } else if (words.every((w) => normalize(g.text.join(' ')).includes(w))) {
        score = 20
        where = 'body'
      }
    }
    if (where) hits.push({ gift: g, score, where })
  }
  return hits.sort((a, b) => b.score - a.score || a.gift.name.localeCompare(b.gift.name, 'pt'))
}

const pageOf = new Map<string, number>()

/**
 * Opening spread (frontispiece + index), then one leaf per gift, paired
 * into folds. Long entries stay on a single leaf: the plate lives with
 * the name, the text fills what remains.
 */
export function layoutGifts(front: Spread): Spread[] {
  const leaves: ContentBlock[][] = gifts.map((g) => [{ type: 'gift', id: g.id }])
  const spreads: Spread[] = [front]
  for (let i = 0; i < leaves.length; i += 2) {
    spreads.push({ left: leaves[i], right: leaves[i + 1] ?? [] })
  }
  pageOf.clear()
  gifts.forEach((g, i) => pageOf.set(g.id, 1 + Math.floor(i / 2)))
  return spreads
}

export function spreadOfGift(id: string) {
  return pageOf.get(id) ?? 0
}
