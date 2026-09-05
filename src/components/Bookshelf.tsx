import type { CSSProperties } from 'react'
import { yearBooks, worldBooks } from '../data/books'
import { Book } from './Book'
import { CrystalBall, Hourglass, Inkwell, Lantern, PotionVials, ScrollStack } from './ShelfProps'
import { Candle } from './Candle'

type Props = {
  busy: boolean
  activeId: string | null
  onOpen: (id: string, el: HTMLButtonElement) => void
}

/* Candlesticks standing on the crown moulding, mirrored around the plaque. */
const CROWN_CANDLES = [
  { left: 5.5, burn: 0.3, delay: 0 },
  { left: 13, burn: 0.15, delay: -0.7 },
  { left: 20.5, burn: 0.4, delay: -1.3 },
  { left: 79.5, burn: 0.35, delay: -0.4 },
  { left: 87, burn: 0.1, delay: -1.1 },
  { left: 94.5, burn: 0.25, delay: -1.8 },
]

export function Bookshelf({ busy, activeId, onOpen }: Props) {
  return (
    <div className="bookshelf-fit">
      <div className="bookshelf">
        <div className="case-halo" aria-hidden="true" />
        <div className="case" />
        <div className="case-wood" />
        <div className="case-wear" />
        <div className="crown-mold" aria-hidden="true">
          <span className="dentils" />
        </div>
        <div className="brass-corner tl" />
        <div className="brass-corner tr" />
        <div className="brass-corner bl" />
        <div className="brass-corner br" />
        <div className="pediment">
          <span className="pediment-wing left" />
          <span className="plaque">
            <span className="plaque-crest">H</span>
            <span className="plaque-text">Seção Restrita</span>
          </span>
          <span className="pediment-wing right" />
        </div>
        <div className="cobweb left" />
        <div className="cobweb right" />
        <div className="ornament-col left" />
        <div className="ornament-col right" />
        <div className="rail top">
          <span className="rail-lip" />
        </div>
        <div className="rail mid">
          <span className="rail-lip" />
        </div>
        <div className="rail bot">
          <span className="rail-lip" />
        </div>
        <div className="shelf-light upper" />
        <div className="shelf-light lower" />

        <div className="crown-candles" aria-hidden="true">
          {CROWN_CANDLES.map((c) => (
            <Candle
              key={c.left}
              holder
              burn={c.burn}
              className="crown-candle"
              style={{ left: `${c.left}%`, '--flicker-delay': `${c.delay}s` } as CSSProperties}
            />
          ))}
        </div>

        <div className="shelf-recess upper" aria-label="Andar superior — tomos do mundo">
          <ScrollStack />
          <Hourglass />
          {worldBooks.map((book) => (
            <Book
              key={book.id}
              book={book}
              disabled={busy}
              ghost={activeId === book.id}
              onOpen={(el) => onOpen(book.id, el)}
            />
          ))}
          <CrystalBall />
          <Inkwell />
        </div>

        <div className="shelf-recess lower" aria-label="Andar inferior — anos de estudo">
          <PotionVials />
          {yearBooks.map((book) => (
            <Book
              key={book.id}
              book={book}
              disabled={busy}
              ghost={activeId === book.id}
              onOpen={(el) => onOpen(book.id, el)}
            />
          ))}
          <Lantern />
        </div>
      </div>
    </div>
  )
}
