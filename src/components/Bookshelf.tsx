import type { CSSProperties } from 'react'
import { yearBooks, worldBooks } from '../data/books'
import { Book } from './Book'
import { CrystalBall, Hourglass, Inkwell, Lantern, PotionVials, ScrollStack } from './ShelfProps'
import { Candle } from './Candle'
import { BookStack, DecoBook } from './DecorBooks'

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
          <DecoBook leather="navy" w={3.4} h={78} title="Astronomia" bands={3} />
          <DecoBook leather="plum" w={2.8} h={66} lean="r" />
          {worldBooks.map((book) => (
            <Book
              key={book.id}
              book={book}
              disabled={busy}
              ghost={activeId === book.id}
              onOpen={(el) => onOpen(book.id, el)}
            />
          ))}
          <DecoBook leather="forest" w={3} h={70} title="Herbarium" mobile />
          <DecoBook leather="tan" w={2.4} h={58} bands={1} />
          <DecoBook leather="oxblood" w={3.4} h={80} title="Bestiarium" lean="l" />
          <span className="stack-pedestal">
            <Hourglass />
            <BookStack leathers={['charcoal', 'rust']} />
          </span>
          <CrystalBall />
          <DecoBook leather="slate" w={2.8} h={64} title="Runae" />
          <Inkwell />
        </div>

        <div className="shelf-recess lower" aria-label="Andar inferior — anos de estudo">
          <PotionVials />
          <DecoBook leather="olive" w={3} h={64} title="Alchimia" mobile />
          <DecoBook leather="umber" w={2.4} h={56} bands={1} />
          {yearBooks.map((book) => (
            <Book
              key={book.id}
              book={book}
              disabled={busy}
              ghost={activeId === book.id}
              onOpen={(el) => onOpen(book.id, el)}
            />
          ))}
          <DecoBook leather="navy" w={3.2} h={70} title="Historia" lean="l" />
          <DecoBook leather="plum" w={2.6} h={60} />
          <DecoBook leather="charcoal" w={3} h={66} title="Codex" mobile />
          <BookStack leathers={['tan', 'oxblood', 'forest']} />
          <Lantern />
        </div>
      </div>
    </div>
  )
}
