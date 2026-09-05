import type { ReactNode } from 'react'
import { getBook } from '../data/books'
import { Book } from './Book'

type Props = {
  busy: boolean
  activeId: string | null
  onOpen: (id: string, el: HTMLButtonElement) => void
}

function Candle() {
  return (
    <span className="taper">
      <span className="taper-stick" />
      <span className="taper-drip" />
      <span className="taper-wick" />
      <span className="taper-flame" />
      <span className="taper-halo" />
    </span>
  )
}

function Candelabra({ side }: { side: 'left' | 'right' }) {
  return (
    <span className={`candelabra ${side}`} aria-hidden="true">
      <span className="candelabra-base" />
      <span className="candelabra-arm a">
        <Candle />
      </span>
      <span className="candelabra-arm b">
        <Candle />
      </span>
      <span className="candelabra-arm c">
        <Candle />
      </span>
    </span>
  )
}

function Filler({
  color,
  dark = '#140c08',
  light,
  w = 18,
  h = 72,
  tilt = 0,
  stacked = false,
  gilt = true,
}: {
  color: string
  dark?: string
  light?: string
  w?: number
  h?: number
  tilt?: number
  stacked?: boolean
  gilt?: boolean
}) {
  return (
    <span
      className={`filler-book ${stacked ? 'is-stack' : ''} ${gilt ? 'has-gilt' : ''}`}
      style={{
        ['--leather' as string]: color,
        ['--leather-dark' as string]: dark,
        ['--leather-light' as string]: light ?? color,
        width: `${w}px`,
        height: `${h}%`,
        transform: `rotate(${tilt}deg)`,
      }}
      aria-hidden="true"
    >
      <span className="filler-head" />
      <span className="filler-rib a" />
      <span className="filler-rib b" />
      <span className="filler-rib c" />
      <span className="filler-foot" />
      <span className="filler-pages" />
    </span>
  )
}

function Tome({
  id,
  busy,
  activeId,
  onOpen,
}: {
  id: string
  busy: boolean
  activeId: string | null
  onOpen: Props['onOpen']
}) {
  const book = getBook(id)
  if (!book) return null
  return (
    <Book
      book={book}
      disabled={busy}
      ghost={activeId === book.id}
      onOpen={(el) => onOpen(book.id, el)}
    />
  )
}

function Shelf({ children, glow }: { children: ReactNode; glow?: boolean }) {
  return (
    <div className={`ornate-shelf ${glow ? 'has-glow' : ''}`}>
      <div className="shelf-back" />
      <div className="shelf-hollow">{children}</div>
      <div className="shelf-board">
        <span className="shelf-lip" />
      </div>
    </div>
  )
}

export function Bookshelf({ busy, activeId, onOpen }: Props) {
  const tome = (id: string) => (
    <Tome id={id} busy={busy} activeId={activeId} onOpen={onOpen} />
  )

  return (
    <div className="bookshelf-fit">
      <div className="bookshelf ornate">
        <div className="cabinet-shadow" />
        <div className="frame-wood" />
        <div className="crown">
          <div className="crown-dentil" />
          <div className="crown-mold" />
          <div className="arch a" />
          <div className="arch b">
            <span className="gold-flourish">❧</span>
            <span className="script-title">Orchideous</span>
            <span className="gold-flourish">❧</span>
          </div>
          <div className="arch c" />
        </div>

        <div className="cabinet-body">
          <div className="side-stile left-stile" />

          <div className="bay left-bay">
            <Shelf glow>
              <Candelabra side="left" />
              <Filler color="#5a241c" dark="#2a100c" light="#7a3a2c" w={15} h={70} />
              <Filler color="#1e3a28" dark="#0c1810" light="#2e5040" w={21} h={84} />
              <Filler color="#3a2418" dark="#160e08" light="#5a3a24" w={13} h={62} tilt={-5} />
              <Filler color="#1a1424" dark="#0a0810" light="#2a2438" w={18} h={76} />
              <Filler color="#4a3020" dark="#1c120c" w={11} h={58} />
              <Filler color="#6b1d1d" dark="#2a0c0c" light="#8a3228" w={16} h={80} />
            </Shelf>
            <Shelf>
              {tome('ambientacao')}
              <Filler color="#3a2a18" dark="#161008" w={14} h={68} />
              <Filler color="#5c1820" dark="#24080c" light="#7a2830" w={19} h={86} />
              <Filler color="#243028" dark="#0c1410" w={12} h={64} tilt={4} />
              <Filler color="#2c2018" dark="#120c08" w={17} h={74} />
              <Filler color="#1c2430" dark="#0c1018" w={15} h={71} />
            </Shelf>
            <Shelf>
              {tome('primeiro-ano')}
              {tome('segundo-ano')}
              <Filler color="#2c2018" dark="#100c08" w={16} h={72} />
              <Filler color="#4a3020" dark="#1a120c" w={12} h={54} stacked />
              <Filler color="#3a2418" dark="#140e08" w={12} h={44} stacked />
              <Filler color="#1a281c" dark="#081208" w={14} h={66} />
            </Shelf>
            <Shelf>
              <Filler color="#1a2218" dark="#0a1008" w={20} h={80} />
              <Filler color="#5c2418" dark="#240c08" w={15} h={66} />
              <span className="prop owl" aria-hidden="true" />
              <Filler color="#2a201c" dark="#120e0c" w={17} h={74} />
              <Filler color="#402818" dark="#180e08" w={13} h={61} tilt={-3} />
            </Shelf>
          </div>

          <div className="pillar">
            <span className="cap" />
            <span className="neck" />
            <span className="flute" />
            <span className="base" />
          </div>

          <div className="bay mid-bay">
            <Shelf glow>
              <Filler color="#4a1818" dark="#200808" w={17} h={74} />
              <Filler color="#2a2820" dark="#10100c" w={14} h={63} />
              <Filler color="#4a3818" dark="#1c1408" light="#6a5028" w={21} h={84} />
              <Filler color="#1c1824" dark="#0c0810" w={13} h={60} tilt={-4} />
              <Filler color="#3a2018" dark="#160c08" w={16} h={71} />
              <span className="prop candle-nub" aria-hidden="true">
                <Candle />
              </span>
            </Shelf>
            <Shelf>
              {tome('habilidades')}
              {tome('racas')}
              <Filler color="#302018" dark="#140c08" w={13} h={68} />
              <Filler color="#1e2a22" dark="#0c1410" w={18} h={78} />
              <Filler color="#5a2018" dark="#240c08" w={12} h={58} tilt={5} />
            </Shelf>
            <Shelf>
              <Filler color="#241818" dark="#100808" w={15} h={70} />
              <span className="prop snitch-rest" aria-hidden="true" />
              <span className="prop goblet" aria-hidden="true" />
              <Filler color="#3a3028" dark="#181410" w={18} h={77} />
              <Filler color="#1c2430" dark="#0c1018" w={14} h={65} />
            </Shelf>
            <Shelf>
              {tome('terceiro-ano')}
              {tome('quarto-ano')}
              <Filler color="#2c2418" dark="#120e08" w={13} h={62} />
              <Filler color="#501818" dark="#200808" w={16} h={82} />
              <Filler color="#243024" dark="#0c140c" w={12} h={58} />
            </Shelf>
          </div>

          <div className="pillar">
            <span className="cap" />
            <span className="neck" />
            <span className="flute" />
            <span className="base" />
          </div>

          <div className="bay right-bay">
            <Shelf glow>
              <Filler color="#2a2018" dark="#100c08" w={14} h={66} />
              <Filler color="#3a2818" dark="#160e08" w={19} h={81} />
              <Filler color="#1a1820" dark="#0a0810" w={13} h={61} />
              <Filler color="#5a241c" dark="#240c08" w={16} h={74} />
              <Filler color="#1e3a28" dark="#0c1810" w={12} h={58} />
              <Candelabra side="right" />
            </Shelf>
            <Shelf>
              {tome('quinto-ano')}
              {tome('sexto-ano')}
              <Filler color="#402818" dark="#180e08" w={15} h={73} />
              <Filler color="#1c2030" dark="#0c1018" w={18} h={80} />
              <Filler color="#4a2018" dark="#1c0c08" w={12} h={60} tilt={-4} />
            </Shelf>
            <Shelf>
              {tome('setimo-ano')}
              <Filler color="#2c1818" dark="#140808" w={17} h={76} />
              <Filler color="#243024" dark="#0c140c" w={12} h={64} tilt={4} />
              <Filler color="#3a2c20" dark="#161008" w={20} h={83} />
              <Filler color="#1a1824" dark="#0a0810" w={14} h={68} />
            </Shelf>
            <Shelf>
              <Filler color="#1c1410" dark="#0c0806" w={16} h={70} />
              <span className="prop chest" aria-hidden="true" />
              <Filler color="#4a2018" dark="#1c0c08" w={14} h={68} />
              <Filler color="#2a2420" dark="#100e0c" w={18} h={78} />
              <Filler color="#3a2818" dark="#160e08" w={13} h={62} />
            </Shelf>
          </div>

          <div className="side-stile right-stile" />
        </div>

        <div className="plinth">
          <span className="plinth-gold" />
        </div>
      </div>
    </div>
  )
}
