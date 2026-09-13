import { Fragment, memo, type ReactNode } from 'react'
import { yearBooks, worldBooks } from '../data/books'
import { Book } from './Book'
import { CrystalBall, FlatStack, Hourglass, Inkwell, Lantern, PotionVials, ScrollStack } from './ShelfProps'
import { Candelabra } from './Candle'
import { DecoBook } from './DecorBooks'

type Props = {
  busy: boolean
  activeId: string | null
  onOpen: (id: string, el: HTMLButtonElement) => void
}

/* Filler volumes slipped between the readable books so the rows read as one packed shelf. */
const UPPER_BETWEEN: Record<number, ReactNode> = {
  0: <DecoBook leather="umber" w={2.6} h={84} />,
  1: <DecoBook leather="slate" w={2.4} h={82} bands={1} />,
}
const LOWER_BETWEEN: Record<number, ReactNode> = {
  2: <DecoBook leather="tan" w={2.2} h={78} bands={1} />,
}

export const Bookshelf = memo(function Bookshelf({ busy, activeId, onOpen }: Props) {
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
          <Candelabra className="crown-candelabra left" />
          <Candelabra className="crown-candelabra right" />
        </div>

        <div className="shelf-recess upper" aria-label="Andar superior — tomos do mundo">
          <ScrollStack />
          <DecoBook leather="navy" w={3.4} h={84} title="Astronomia" bands={3} mobile />
          {worldBooks.map((book, i) => (
            <Fragment key={book.id}>
              <Book book={book} disabled={busy} ghost={activeId === book.id} onOpen={onOpen} />
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
              <Book book={book} disabled={busy} ghost={activeId === book.id} onOpen={onOpen} />
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
})
