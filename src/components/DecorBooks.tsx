import type { CSSProperties } from 'react'

/*
 * Non-interactive tomes that fill the shelves around the real books.
 * They share the spine styling of `Book` but stay muted so the ten
 * readable volumes remain the obvious targets.
 */

type Leather = { leather: string; dark: string; light: string; gold: string }

const LEATHERS: Record<string, Leather> = {
  umber: { leather: '#4a2c18', dark: '#1e100a', light: '#6b432a', gold: '#b8985a' },
  navy: { leather: '#1e2a44', dark: '#0b111f', light: '#324569', gold: '#a9975e' },
  plum: { leather: '#3d1f3a', dark: '#180b17', light: '#5b3458', gold: '#b39a62' },
  olive: { leather: '#3a4224', dark: '#171b0d', light: '#56613a', gold: '#b0a066' },
  oxblood: { leather: '#4a1a14', dark: '#1c0806', light: '#6e2c24', gold: '#bf9c5c' },
  forest: { leather: '#1f3a2a', dark: '#0b1610', light: '#33553f', gold: '#a89a60' },
  charcoal: { leather: '#2a2622', dark: '#100e0c', light: '#413b35', gold: '#a3925e' },
  tan: { leather: '#7a5a34', dark: '#3a2814', light: '#9d7a4c', gold: '#e0c07a' },
  slate: { leather: '#2f3a44', dark: '#131a20', light: '#485763', gold: '#a8a06a' },
  rust: { leather: '#6a3a1c', dark: '#2d170a', light: '#8c522c', gold: '#d3ad66' },
}

export type DecoSpec = {
  leather: keyof typeof LEATHERS
  /** spine width, in vw before clamping */
  w: number
  /** height as % of the shelf recess */
  h: number
  title?: string
  lean?: 'l' | 'r'
  /** keep this one on small screens */
  mobile?: boolean
  bands?: 1 | 2 | 3
}

export function DecoBook({ leather, w, h, title, lean, mobile, bands = 2 }: DecoSpec) {
  const p = LEATHERS[leather]
  const style = {
    '--leather': p.leather,
    '--leather-dark': p.dark,
    '--leather-light': p.light,
    '--gold-ink': p.gold,
    '--w': w,
    '--h': h,
    '--chars': Math.max(4, (title ?? '').replace(/\s+/g, '').length),
  } as CSSProperties

  return (
    <span
      className={`book-btn deco ${lean ? `lean-${lean}` : ''} ${mobile ? 'keep-mobile' : ''} bands-${bands}`}
      style={style}
      aria-hidden="true"
    >
      <span className="book-mesh">
        <span className="book-face book-spine">
          <span className="spine-tool head" />
          <span className="gold-band t" />
          {title ? (
            <span className="spine-label">
              <span className="spine-title">{title}</span>
            </span>
          ) : (
            <span className="spine-medallion" />
          )}
          <span className="gold-band b" />
          <span className="spine-tool foot" />
        </span>
        <span className="cover-panel" />
        <span className="back-panel" />
        <span className="page-edge" />
        <span className="top-edge" />
      </span>
    </span>
  )
}
