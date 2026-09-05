import { yearBooks, worldBooks } from '../data/books'
import { Book } from './Book'
import { CrystalBall, Hourglass, Inkwell, Lantern, PotionVials, ScrollStack } from './ShelfProps'

type Props = {
  busy: boolean
  activeId: string | null
  onOpen: (id: string, el: HTMLButtonElement) => void
}

function Candle({ className }: { className: string }) {
  return (
    <span className={`taper ${className}`} aria-hidden="true">
      <span className="taper-stick" />
      <span className="taper-drip" />
      <span className="taper-wick" />
      <span className="taper-flame" />
      <span className="taper-halo" />
    </span>
  )
}

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

        <div className="sconce left">
          <Candle className="sconce-a" />
          <Candle className="sconce-b" />
        </div>
        <div className="sconce right">
          <Candle className="sconce-a" />
          <Candle className="sconce-b" />
        </div>
        <Candle className="on-mid left" />
        <Candle className="on-mid right" />
        <Candle className="on-bot left" />
        <Candle className="on-bot right" />

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
