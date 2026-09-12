import { Fragment, type CSSProperties, type ReactNode } from 'react'
import { yearBooks, worldBooks } from '../data/books'
import { Book } from './Book'
import { CrystalBall, FlatStack, Hourglass, Inkwell, Lantern, PotionVials, ScrollStack } from './ShelfProps'
import { Candle, type CandleVariant } from './Candle'
import { DecoBook } from './DecorBooks'

type Props = {
  busy: boolean
  activeId: string | null
  onOpen: (id: string, el: HTMLButtonElement) => void
}

/*
 * Candlesticks standing on the painted crown. `top` is the measured height of
 * the crown's edge at that column (in % of the case) so each one rests on wood;
 * tall and half-burned sticks alternate so the row does not read as a stamp.
 */
const CROWN_CANDLES: { left: number; top: number; variant: CandleVariant; delay: number }[] = [
  { left: 6, top: 5.7, variant: 'a', delay: 0 },
  { left: 16.5, top: 6.6, variant: 'b', delay: -0.7 },
  { left: 26, top: 6.3, variant: 'a', delay: -1.3 },
  { left: 74, top: 6.3, variant: 'a', delay: -0.4 },
  { left: 83.5, top: 6.6, variant: 'b', delay: -1.1 },
  { left: 94, top: 5.7, variant: 'a', delay: -1.8 },
]

/* Filler volumes slipped between the readable books so the rows read as one packed shelf. */
const UPPER_BETWEEN: Record<number, ReactNode> = {
  0: <DecoBook leather="umber" w={2.6} h={84} />,
  1: <DecoBook leather="slate" w={2.4} h={82} bands={1} />,
}
const LOWER_BETWEEN: Record<number, ReactNode> = {
  2: <DecoBook leather="tan" w={2.2} h={78} bands={1} />,
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
              variant={c.variant}
              className="crown-candle"
              style={{ left: `${c.left}%`, '--top': c.top, '--flicker-delay': `${c.delay}s` } as CSSProperties}
            />
          ))}
        </div>

        <div className="shelf-recess upper" aria-label="Andar superior — tomos do mundo">
          <ScrollStack />
          <DecoBook leather="navy" w={3.4} h={84} title="Astronomia" bands={3} mobile />
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
          <DecoBook leather="forest" w={3} h={84} title="Herbarium" mobile />
          <DecoBook leather="oxblood" w={3.4} h={84} title="Bestiarium" mobile />
          <span className="stack-pedestal">
            <Hourglass />
            <FlatStack />
          </span>
          <CrystalBall />
          <DecoBook leather="slate" w={2.8} h={84} title="Runae" mobile />
          <Inkwell />
        </div>

        <div className="shelf-recess lower" aria-label="Andar inferior — anos de estudo">
          <PotionVials />
          <DecoBook leather="olive" w={3} h={80} title="Alchimia" mobile />
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
          <DecoBook leather="navy" w={3.2} h={80} title="Historia" />
          <DecoBook leather="oxblood" w={3} h={80} title="Venena" mobile />
          <DecoBook leather="slate" w={2.8} h={80} title="Arcana" />
          <Lantern />
        </div>
      </div>
    </div>
  )
}
