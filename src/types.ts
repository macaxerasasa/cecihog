export type ContentBlock =
  | { type: 'heading'; text: string }
  | { type: 'subheading'; text: string }
  | { type: 'ornament' }
  | { type: 'paragraph'; text: string }
  | { type: 'list'; items: string[] }
  | { type: 'entries'; items: { title: string; text: string }[] }
  | { type: 'reserved'; label: string; hint: string }

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
  spreads: Spread[]
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
