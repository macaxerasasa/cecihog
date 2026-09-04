import type { CSSProperties, KeyboardEvent } from 'react'
import type { BookData } from '../types'

type Props = {
  book: BookData
  disabled: boolean
  ghost: boolean
  onOpen: (el: HTMLButtonElement) => void
}

export function Book({ book, disabled, ghost, onOpen }: Props) {
  const depth = book.size === 'grand' ? 150 : 118
  const spine = book.size === 'grand' ? 58 : 42

  const style = {
    '--leather': book.palette.leather,
    '--leather-dark': book.palette.leatherDark,
    '--gold-ink': book.palette.gold,
    '--depth': `${depth}px`,
    '--spine': `${spine}px`,
    height: `calc(${book.size === 'grand' ? 232 : 196}px + ${book.heightNudge}px)`,
    transform: `rotate(${book.tilt}deg)`,
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
          <span className="gold-band t" />
          <span className="spine-title">{book.spineLabel}</span>
          <span className="gold-band b" />
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
