import type { BookData } from '../types'
import { books } from './books'

/*
 * Where every tome lives on the castle plan. Boxes are given in the two map
 * frames the plan is drawn in: `l` for the landscape sheet (1600 × 1000) and
 * `p` for the portrait sheet phones unfold (1000 × 1600).
 */
export type Box = { x: number; y: number; w: number; h: number }

export type PlaceKind = 'hall' | 'wing' | 'room'

export type Place = {
  id: string
  /** Name lettered on the banner below the room. */
  name: string
  /** Second line of the banner, in small italics. */
  note: string
  kind: PlaceKind
  /** Ink engraving drawn inside the room (file stem under public/art/ink-*.webp). */
  art: string
  /** Roman numeral for the seven classrooms. */
  numeral?: string
  l: Box
  p: Box
  book: BookData
}

const bookOf = (id: string) => {
  const b = books.find((x) => x.id === id)
  if (!b) throw new Error(`unknown tome ${id}`)
  return b
}

const YEAR_ART = ['owl', 'diary', 'timeturner', 'goblet', 'orb', 'locket', 'phoenix']
const YEAR_NUMERAL = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII']
const YEAR_IDS = ['primeiro-ano', 'segundo-ano', 'terceiro-ano', 'quarto-ano', 'quinto-ano', 'sexto-ano', 'setimo-ano']
const YEAR_NOTES = [
  'Os primeiros gestos',
  'Azarações de corredor',
  'Ventos, água e criaturas',
  'Duelo e escudo',
  'Mente, corda e clima',
  'Proteções maiores',
  'Escudos absolutos',
]

/* The seven classrooms line the long corridor at the foot of the sheet. */
const yearRooms: Place[] = YEAR_IDS.map((id, i) => {
  const col = i % 2
  const row = Math.floor(i / 2)
  const portrait: Box =
    i === 6
      ? { x: 300, y: 1410, w: 400, h: 116 }
      : { x: col === 0 ? 70 : 530, y: 852 + row * 186, w: 400, h: 116 }
  return {
    id,
    name: `Sala ${YEAR_NUMERAL[i]}`,
    note: YEAR_NOTES[i],
    kind: 'room',
    art: YEAR_ART[i],
    numeral: YEAR_NUMERAL[i],
    l: { x: 118 + i * 197, y: 626, w: 172, h: 150 },
    p: portrait,
    book: bookOf(id),
  }
})

export const places: Place[] = [
  {
    id: 'ambientacao',
    name: 'Salão Principal',
    note: 'Hogwarts — o castelo e o mundo mágico',
    kind: 'hall',
    art: 'castle',
    l: { x: 590, y: 208, w: 420, h: 268 },
    p: { x: 230, y: 236, w: 540, h: 260 },
    book: bookOf('ambientacao'),
  },
  {
    id: 'habilidades',
    name: 'Sala de Feitiços',
    note: 'Matérias — as artes ensinadas',
    kind: 'wing',
    art: 'wand',
    l: { x: 128, y: 236, w: 330, h: 212 },
    p: { x: 70, y: 596, w: 400, h: 172 },
    book: bookOf('habilidades'),
  },
  {
    id: 'racas',
    name: 'Salas Comunais',
    note: 'Casas — quatro fundadores',
    kind: 'wing',
    art: 'hat',
    l: { x: 1142, y: 236, w: 330, h: 212 },
    p: { x: 530, y: 596, w: 400, h: 172 },
    book: bookOf('racas'),
  },
  ...yearRooms,
]

export const placeOf = (id: string) => places.find((p) => p.id === id)

export const FRAME = {
  l: { w: 1600, h: 1000 },
  p: { w: 1000, h: 1660 },
} as const

export type Frame = keyof typeof FRAME

/** Centre of a box. */
export const centre = (b: Box) => ({ x: b.x + b.w / 2, y: b.y + b.h / 2 })

/*
 * Corridors: hand-laid polylines in each frame. Footprints wander along the
 * first ones; all of them are inked as double dashed lines.
 */
export const corridors: Record<Frame, string[]> = {
  l: [
    // the long corridor along the classrooms, with its stair up to the hall
    'M 118 560 H 1482',
    'M 600 476 V 560',
    // the wings reach the hall through short galleries, and the corridor by a stair
    'M 458 342 H 590',
    'M 1010 342 H 1142',
    'M 293 448 V 560',
    'M 1307 448 V 560',
    // stairs from each classroom up to the corridor
    ...Array.from({ length: 7 }, (_, i) => `M ${204 + i * 197} 626 V 560`),
  ],
  p: [
    // the hall's stair meets a gallery that serves both wings
    'M 500 496 V 1410',
    'M 270 596 V 572 H 730 V 596',
    // side doors of the six classrooms
    'M 470 910 H 530',
    'M 470 1096 H 530',
    'M 470 1282 H 530',
  ],
}

/*
 * Who roams the corridors, and how. Each walker lays one print per step
 * along a route (SVG path syntax, there and back): `stride` is the distance
 * between prints in map units, `cadence` the time between steps in ms, and
 * `rest` the chance per step of stopping for a moment.
 */
export type Gait = 'foot' | 'paw'
export type Walk = {
  name: string
  path: string
  gait: Gait
  stride: number
  cadence: [min: number, max: number]
  rest: number
  /* a poltergeist does not keep to the line: sideways scatter and turn jitter */
  restless?: boolean
}

const filch = (path: string): Walk => ({
  name: 'Argo Filch',
  path,
  gait: 'foot',
  stride: 28,
  cadence: [520, 640],
  rest: 0.045,
})
const norra = (path: string): Walk => ({
  name: 'Madame Nor-r-a',
  path,
  gait: 'paw',
  stride: 14,
  cadence: [250, 330],
  rest: 0.05,
})
const peeves = (path: string): Walk => ({
  name: 'Pirraça',
  path,
  gait: 'foot',
  stride: 34,
  cadence: [280, 620],
  rest: 0.03,
  restless: true,
})

export const walks: Record<Frame, Walk[]> = {
  l: [
    // the caretaker paces the whole corridor and back
    filch('M 150 560 H 1450 L 150 560'),
    // the cat keeps to the east half, down the wing's stair and along
    norra('M 1307 456 V 560 H 930 L 1307 560 V 456'),
    // the poltergeist comes down one wing and up the other
    peeves('M 293 456 V 560 H 600 V 480 L 600 560 H 293 V 456'),
  ],
  p: [filch('M 500 520 V 1400 L 500 520'), norra('M 270 596 V 572 H 730 V 596 L 730 572 H 270 V 596')],
}
