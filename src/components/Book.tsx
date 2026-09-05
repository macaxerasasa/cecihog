import type { CSSProperties, KeyboardEvent } from 'react'
import type { BookData } from '../types'

type Props = {
  book: BookData
  disabled: boolean
  ghost: boolean
  onOpen: (el: HTMLButtonElement) => void
}

export function Book({ book, disabled, ghost, onOpen }: Props) {
  const style = {
    '--leather': book.palette.leather,
    '--leather-dark': book.palette.leatherDark,
    '--leather-light': book.palette.leatherLight,
    '--gold-ink': book.palette.gold,
  } as CSSProperties

  const onKey = (e: KeyboardEvent<HTMLButtonElement>) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault()
      onOpen(e.currentTarget)
    }
  }

  return (
    <button
      type="button"
      className={`book-btn ${book.size} ${ghost ? 'is-ghost' : ''}`}
      style={style}
      disabled={disabled}
      aria-label={`Abrir o tomo ${book.title}`}
      aria-haspopup="dialog"
      onClick={(e) => onOpen(e.currentTarget)}
      onKeyDown={onKey}
    >
      <span className="book-mesh" aria-hidden="true">
        <span className="book-face book-spine">
          <span className="spine-rib head" />
          <span className="gold-band t" />
          <span className="spine-rib r1" />
          <span className="spine-title">{book.spineLabel}</span>
          <span className="spine-rib r2" />
          <span className="gold-band b" />
          <span className="spine-emblem">{book.category === 'year' ? book.shortTitle : '✦'}</span>
          <span className="spine-rib foot" />
          <span className="wear-mark" style={{ opacity: book.wear }} />
        </span>
        <span className="cover-panel">
          <span className="cover-crest" />
        </span>
        <span className="back-panel" />
        <span className="page-edge" />
        <span className="top-edge" />
      </span>
    </button>
  )
}
