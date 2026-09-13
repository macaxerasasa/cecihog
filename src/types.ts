export type ContentBlock =
  | { type: 'heading'; text: string }
  | { type: 'subheading'; text: string }
  | { type: 'ornament' }
  | { type: 'paragraph'; text: string }
  | { type: 'list'; items: string[] }
  | { type: 'entries'; items: { title: string; text: string }[] }
  | { type: 'reserved'; label: string; hint: string }
  /** Engraved ink plate: `art` is the file stem under public/art/ink-*.webp */
  | { type: 'plate'; art: string; caption: string; large?: boolean }
  /**
   * One spell of the grimoire. Long entries run over several leaves: `part`
   * is the leaf index (0 carries the name and the ledger), `parts` the total.
   */
  | { type: 'spell'; id: string; part?: number; parts?: number }
  /** Search field + index of every spell in this tome (and the other tomes). */
  | { type: 'spell-search'; year: number }
  /** One verbete of Habilidades e Raças. */
  | { type: 'gift'; id: string }
  /** Search field + index of every skill and race in that sheet. */
  | { type: 'gift-search' }

export type SpellUpgrade = { label: string; locked: boolean; text: string }

export type Spell = {
  id: string
  year: number
  name: string
  aliases: string[]
  tag?: string
  effect: string[]
  light: string
  classification: string
  movement: string
  requirement?: string
  upgrades: SpellUpgrade[]
}

export type Spread = {
  left: ContentBlock[]
  right: ContentBlock[]
}

export type BookCategory = 'world' | 'year'

export type BookPalette = {
  leather: string
  leatherDark: string
  leatherLight: string
  spine: string
  gold: string
  pageTint: string
  ribbon: string
}

export type BookData = {
  id: string
  title: string
  shortTitle: string
  category: BookCategory
  year?: number
  subtitle: string
  motto: string
  spineLabel: string
  palette: BookPalette
  size: 'grand' | 'tome'
  wear: number
  tilt: number
  heightNudge: number
}

export type LibraryPhase =
  | 'boot'
  | 'idle'
  | 'toCenter'
  | 'opening'
  | 'open'
  | 'closing'
  | 'toShelf'

export type OriginRect = {
  x: number
  y: number
  width: number
  height: number
}
