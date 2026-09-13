import raw from './spells.json'
import type { ContentBlock, Spell, Spread } from '../types'

export const spells = raw as Spell[]

export const YEAR_BOOK_IDS = [
  'primeiro-ano',
  'segundo-ano',
  'terceiro-ano',
  'quarto-ano',
  'quinto-ano',
  'sexto-ano',
  'setimo-ano',
] as const

export const YEAR_NAMES = ['Primeiro', 'Segundo', 'Terceiro', 'Quarto', 'Quinto', 'Sexto', 'Sétimo'] as const
export const YEAR_ROMAN = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'] as const

export const bookIdOfYear = (year: number) => YEAR_BOOK_IDS[year - 1]

export const spellsOfYear = (year: number) => spells.filter((s) => s.year === year)

const byId = new Map(spells.map((s) => [s.id, s]))
export const getSpell = (id: string) => byId.get(id)

/** Accent- and case-insensitive key for matching. */
export function normalize(s: string) {
  return s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
}

/** What one leaf of an entry holds, in reading order. */
export type SpellChunk = { kind: 'effect'; text: string } | { kind: 'upgrade'; index: number }

/*
 * Characters a leaf comfortably holds at the desktop reading size: the first
 * leaf also carries the name and the ledger, later ones only a running head.
 */
const FIRST_LEAF = 620
const NEXT_LEAF = 820
const UPGRADE_COST = 90

function splitSentences(text: string, budget: number): [string, string] | null {
  const parts = text.match(/[^.!?;]+[.!?;]+["”)]?(\s+|$)/g)
  if (!parts || parts.length < 2) return null
  let acc = ''
  for (const p of parts) {
    if (acc.length + p.length > budget) break
    acc += p
  }
  if (acc.length < 160 || text.length - acc.length < 80) return null
  return [acc.trim(), text.slice(acc.length).trim()]
}

const pages = new Map<string, SpellChunk[][]>()

/**
 * Breaks an entry into leaves. Paragraphs and upgrades are packed in order;
 * a paragraph that cannot fit the space left is split at a sentence when
 * enough room remains, otherwise it starts the next leaf.
 */
export function paginateSpell(s: Spell): SpellChunk[][] {
  const cached = pages.get(s.id)
  if (cached) return cached
  const queue: SpellChunk[] = [
    ...s.effect.map((text) => ({ kind: 'effect', text }) as SpellChunk),
    ...s.upgrades.map((_, index) => ({ kind: 'upgrade', index }) as SpellChunk),
  ]
  const leaves: SpellChunk[][] = [[]]
  let room = FIRST_LEAF
  const cost = (c: SpellChunk) => (c.kind === 'effect' ? c.text.length : s.upgrades[c.index].text.length + UPGRADE_COST)
  while (queue.length) {
    const c = queue.shift() as SpellChunk
    const leaf = leaves[leaves.length - 1]
    const need = cost(c)
    if (need <= room) {
      leaf.push(c)
      room -= need + 40
      continue
    }
    if (c.kind === 'effect' && room > 260) {
      const cut = splitSentences(c.text, room)
      if (cut) {
        leaf.push({ kind: 'effect', text: cut[0] })
        queue.unshift({ kind: 'effect', text: cut[1] })
        leaves.push([])
        room = NEXT_LEAF
        continue
      }
    }
    if (leaf.length === 0) {
      leaf.push(c)
      room = 0
      continue
    }
    leaves.push([])
    room = NEXT_LEAF
    queue.unshift(c)
  }
  pages.set(s.id, leaves)
  return leaves
}

type Layout = { spreads: Spread[]; pageOf: Map<string, number> }
const layouts = new Map<number, Layout>()

/**
 * Lays the spells of a year out as book leaves: one leaf per entry, two for
 * long ones, paired into spreads after the opening spread (`front`).
 */
export function layoutYear(year: number, front: Spread, closing: ContentBlock[]): Spread[] {
  const list = spellsOfYear(year)
  const leaves: ContentBlock[][] = []
  const leafOf = new Map<string, number>()
  for (const s of list) {
    leafOf.set(s.id, leaves.length)
    const parts = paginateSpell(s).length
    for (let part = 0; part < parts; part++) leaves.push([{ type: 'spell', id: s.id, part, parts }])
  }
  if (leaves.length % 2) leaves.push(closing)
  const spreads: Spread[] = [front]
  for (let i = 0; i < leaves.length; i += 2) spreads.push({ left: leaves[i], right: leaves[i + 1] ?? [] })
  const pageOf = new Map<string, number>()
  leafOf.forEach((leaf, id) => pageOf.set(id, 1 + Math.floor(leaf / 2)))
  layouts.set(year, { spreads, pageOf })
  return spreads
}

/** Spread index of a spell inside its tome (0 is the opening spread). */
export function spreadOfSpell(id: string) {
  const s = byId.get(id)
  if (!s) return 0
  return layouts.get(s.year)?.pageOf.get(id) ?? 0
}

export type SpellHit = { spell: Spell; score: number; where: 'name' | 'alias' | 'meta' | 'effect' }

const LIGHT_NONE = /^(nao ha|nao possui)$/

/**
 * Ranks every spell against a query: names first, then aliases, then the
 * light / classification / wand-movement fields, then the body text.
 */
export function searchSpells(query: string): SpellHit[] {
  const q = normalize(query)
  if (q.length < 2) return []
  const words = q.split(/\s+/).filter(Boolean)
  const hits: SpellHit[] = []
  for (const s of spells) {
    const name = normalize(s.name)
    const aliases = s.aliases.map(normalize)
    let score = 0
    let where: SpellHit['where'] | null = null
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
      const meta = normalize(`${s.classification} ${s.movement} ${LIGHT_NONE.test(normalize(s.light)) ? '' : s.light} ${s.tag ?? ''} ${s.requirement ?? ''}`)
      if (words.every((w) => meta.includes(w))) {
        score = 50
        where = 'meta'
      } else {
        const body = normalize(`${s.effect.join(' ')} ${s.upgrades.map((u) => u.text).join(' ')}`)
        if (words.every((w) => body.includes(w))) {
          score = 20
          where = 'effect'
        }
      }
    }
    if (where) hits.push({ spell: s, score, where })
  }
  return hits.sort((a, b) => b.score - a.score || a.spell.year - b.spell.year || a.spell.name.localeCompare(b.spell.name))
}

/** Hex swatch for the wand-light colour named in the document. */
export function lightColor(light: string): string | null {
  const l = normalize(light)
  if (LIGHT_NONE.test(l) || l.includes('conjurador') || l === 'transparente') return null
  const table: [RegExp, string][] = [
    [/escarlate|vermelh/, '#c8322a'],
    [/laranja/, '#e8842a'],
    [/amarel|dourad|ouro/, '#e6c04a'],
    [/verde/, '#4a9a52'],
    [/azul claro|anil/, '#5aa6e8'],
    [/azul/, '#3a5fc2'],
    [/rox/, '#7a3fa8'],
    [/rosa/, '#e07aa8'],
    [/branc/, '#f4f0e4'],
    [/prata|cinza/, '#b8bcc4'],
    [/pret/, '#1c1a1e'],
    [/marrom/, '#7a4a28'],
  ]
  for (const [re, hex] of table) if (re.test(l)) return hex
  return null
}
