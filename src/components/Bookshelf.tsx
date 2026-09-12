import { Fragment, type CSSProperties, type ReactNode } from 'react'
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

/*
 * Candlesticks standing on the painted crown. `top` is the measured height of
 * the crown's edge at that column (in % of the case) so each one rests on wood.
 */
const CROWN_CANDLES = [
  { left: 6, top: 5.7, burn: 0.3, delay: 0 },
  { left: 16.5, top: 6.6, burn: 0.15, delay: -0.7 },
  { left: 26, top: 6.3, burn: 0.4, delay: -1.3 },
  { left: 74, top: 6.3, burn: 0.35, delay: -0.4 },
  { left: 83.5, top: 6.6, burn: 0.1, delay: -1.1 },
  { left: 94, top: 5.7, burn: 0.25, delay: -1.8 },
]

/* Filler volumes slipped between the readable books so the rows read as one packed shelf. */
const UPPER_BETWEEN: Record<number, ReactNode> = {
  0: <DecoBook leather="umber" w={2.6} h={62} />,
  1: <DecoBook leather="slate" w={2.4} h={58} bands={1} />,
}
const LOWER_BETWEEN: Record<number, ReactNode> = {
  2: <DecoBook leather="tan" w={2.2} h={58} bands={1} />,
}

export function Bookshelf({ busy, activeId, onOpen }: Props) {
  return (
    <div className="bookshelf-fit">
      <div className="bookshelf">
        <div className="case-halo" aria-hidden="true" />
        <div className="case" aria-hidden="true" />
        <div className="pediment">
          <span className="plaque">
            <span className="plaque-crest">H</span>
            <span className="plaque-text">Seção Restrita</span>
          </span>
        </div>

        <div className="crown-candles" aria-hidden="true">
          {CROWN_CANDLES.map((c) => (
            <Candle
              key={c.left}
              holder
              burn={c.burn}
              className="crown-candle"
              style={{ left: `${c.left}%`, '--top': c.top, '--flicker-delay': `${c.delay}s` } as CSSProperties}
            />
          ))}
        </div>

        <div className="shelf-recess upper" aria-label="Andar superior — tomos do mundo">
          <ScrollStack />
          <DecoBook leather="navy" w={3.4} h={78} title="Astronomia" bands={3} mobile />
          {worldBooks.map((book, i) => (
            <Fragment key={book.id}>
              <Book
                book={book}
                disabled={busy}
                ghost={activeId === book.id}
                onOpen={(el) => onOpen(book.id, el)}
              />
              {UPPER_BETWEEN[i]}
            </Fragment>
          ))}
          <DecoBook leather="forest" w={3} h={70} title="Herbarium" mobile />
          <DecoBook leather="oxblood" w={3.4} h={80} title="Bestiarium" lean="l" mobile />
          <span className="stack-pedestal">
            <Hourglass />
            <BookStack leathers={['charcoal', 'rust']} />
          </span>
          <CrystalBall />
          <DecoBook leather="slate" w={2.8} h={64} title="Runae" mobile />
          <Inkwell />
        </div>

        <div className="shelf-recess lower" aria-label="Andar inferior — anos de estudo">
          <PotionVials />
          <DecoBook leather="olive" w={3} h={72} title="Alchimia" mobile />
          {yearBooks.map((book, i) => (
            <Fragment key={book.id}>
              <Book
                book={book}
                disabled={busy}
                ghost={activeId === book.id}
                onOpen={(el) => onOpen(book.id, el)}
              />
              {LOWER_BETWEEN[i]}
            </Fragment>
          ))}
          <DecoBook leather="navy" w={3.2} h={78} title="Historia" lean="l" />
          <DecoBook leather="oxblood" w={3} h={82} title="Venena" mobile />
          <DecoBook leather="slate" w={2.8} h={70} title="Arcana" />
          <Lantern />
        </div>
      </div>
    </div>
  )
}
