import { memo, type CSSProperties, type KeyboardEvent } from 'react'
import type { BookData } from '../types'

type Props = {
  book: BookData
  disabled: boolean
  ghost: boolean
  onOpen: (id: string, el: HTMLButtonElement) => void
}

/* Memoised: the whole hall re-renders on every phase change of the reader,
   and 21 three-dimensional spines are the bulk of that work. */
export const Book = memo(function Book({ book, disabled, ghost, onOpen }: Props) {
  const style = {
    '--leather': book.palette.leather,
    '--leather-dark': book.palette.leatherDark,
    '--leather-light': book.palette.leatherLight,
    '--gold-ink': book.palette.gold,
    '--chars': Math.max(4, book.spineLabel.replace(/\s+/g, '').length),
  } as CSSProperties

  const onKey = (e: KeyboardEvent<HTMLButtonElement>) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault()
      onOpen(book.id, e.currentTarget)
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
      onClick={(e) => onOpen(book.id, e.currentTarget)}
      onKeyDown={onKey}
    >
      <span className="book-mesh" aria-hidden="true">
        <span className="book-face book-spine">
          <span className="spine-tool head" />
          <span className="gold-band t" />
          <span className="spine-label">
            <span className="spine-title">{book.spineLabel}</span>
          </span>
          <span className="spine-medallion" />
          <span className="gold-band b" />
          <span className="spine-emblem">
            {book.category === 'year' ? (
              <>
                <small>ano</small>
                <b>{book.shortTitle}</b>
              </>
            ) : (
              <b className="star">✦</b>
            )}
          </span>
          <span className="spine-tool foot" />
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
})
