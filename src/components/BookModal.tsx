import { useEffect, useRef, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { neighborIds } from '../data/books'
import type { BookData, LibraryPhase, OriginRect } from '../types'
import { BookCover } from './BookCover'
import { BookPages } from './BookPages'

type Props = {
  book: BookData
  origin: OriginRect
  phase: LibraryPhase
  reduced: boolean
  onOpened: () => void
  onClosed: () => void
  onRequestClose: () => void
  onNavigate: (id: string) => void
}

function sizes() {
  const mobile = window.innerWidth < 740
  const w = Math.min(mobile ? 300 : 400, window.innerWidth * (mobile ? 0.44 : 0.36))
  const h = Math.min(mobile ? 440 : 530, window.innerHeight * (mobile ? 0.58 : 0.68))
  return { w, h }
}

export function BookModal({
  book,
  origin,
  phase,
  reduced,
  onOpened,
  onClosed,
  onRequestClose,
  onNavigate,
}: Props) {
  const [spread, setSpread] = useState(0)
  const [dim, setDim] = useState(sizes)
  const closeRef = useRef<HTMLButtonElement>(null)
  const neighbors = neighborIds(book.id)
  const opened = phase === 'opening' || phase === 'open'
  const showUi = phase === 'open'
  const returning = phase === 'toShelf'
  const inFlight = phase === 'toCenter' || returning

  useEffect(() => {
    const onResize = () => setDim(sizes())
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

  useEffect(() => {
    if (phase === 'open') closeRef.current?.focus()
  }, [phase, book.id])

  const cx = window.innerWidth / 2
  const cy = window.innerHeight / 2 + 6
  const start = {
    x: origin.x + origin.width / 2,
    y: origin.y + origin.height / 2,
    scale: Math.max(0.1, origin.height / dim.h),
    rotateY: 78,
  }
  const center = { x: cx, y: cy, scale: 1, rotateY: 0 }
  const animateTo = returning ? start : center
  const duration = reduced ? 0.001 : inFlight ? 0.92 : 0.2
  const spreadData = book.spreads[spread] ?? book.spreads[0]
  const maxSpread = book.spreads.length - 1

  return (
    <>
      <motion.button
        type="button"
        className="veil"
        aria-label="Fechar o livro"
        initial={{ opacity: 0 }}
        animate={{ opacity: returning ? 0 : 1 }}
        transition={{ duration: reduced ? 0.05 : 0.55 }}
        onClick={() => {
          if (phase === 'open') onRequestClose()
        }}
      />

      <div className="flyer-root">
        <motion.div
          style={{
            position: 'absolute',
            width: dim.w,
            height: dim.h,
            transformStyle: 'preserve-3d',
            marginLeft: -dim.w / 2,
            marginTop: -dim.h / 2,
            pointerEvents: phase === 'open' ? 'auto' : 'none',
          }}
          initial={reduced ? center : start}
          animate={animateTo}
          transition={{ duration, ease: [0.22, 0.8, 0.28, 1] }}
          onAnimationComplete={() => {
            if (phase === 'toCenter') onOpened()
            if (phase === 'toShelf') onClosed()
          }}
        >
          <div
            className={`held-book ${opened ? 'is-opened' : 'is-closed'}`}
            role="dialog"
            aria-modal="true"
            aria-labelledby="book-dialog-title"
            style={{
              width: dim.w,
              height: dim.h,
              ['--leather' as string]: book.palette.leather,
              ['--leather-dark' as string]: book.palette.leatherDark,
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <h2 id="book-dialog-title" className="sr-only">
              {book.title}
            </h2>
            <div className="volume">
              <div className="cover-block">
                <div className="cover-swing">
                  <div className="cover-outer">
                    <div className="cover-frame" />
                    <BookCover book={book} />
                  </div>
                  <div className="page-sheet left-face">
                    <div className="page-grain" />
                    <div className="page-inner">
                      {spreadData ? <BookPages blocks={spreadData.left} /> : null}
                    </div>
                  </div>
                </div>
              </div>
              <div className="page-block">
                <div className="cover-outer back-skin" />
                <div className="page-sheet">
                  <div className="page-grain" />
                  <div className="page-inner">
                    {spreadData ? <BookPages blocks={spreadData.right} /> : null}
                  </div>
                </div>
              </div>
            </div>
            <div className="spine-hinge" />
          </div>
        </motion.div>
      </div>

      <AnimatePresence>
        {showUi ? (
          <motion.div
            className="ritual-ui"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <button
              ref={closeRef}
              type="button"
              className="close-seal"
              aria-label="Fechar o livro e voltar à estante"
              onClick={onRequestClose}
            >
              ✕<span>fechar</span>
            </button>

            {maxSpread > 0 ? (
              <>
                <button
                  type="button"
                  className="page-turn prev"
                  aria-label="Página anterior"
                  disabled={spread === 0}
                  onClick={() => setSpread((s) => Math.max(0, s - 1))}
                >
                  ‹
                </button>
                <button
                  type="button"
                  className="page-turn next"
                  aria-label="Próxima página"
                  disabled={spread === maxSpread}
                  onClick={() => setSpread((s) => Math.min(maxSpread, s + 1))}
                >
                  ›
                </button>
                <div className="spread-dots" role="tablist" aria-label="Cadernos deste tomo">
                  {book.spreads.map((_, i) => (
                    <button
                      key={i}
                      type="button"
                      className={i === spread ? 'is-on' : ''}
                      aria-label={`Abrir caderno ${i + 1}`}
                      onClick={() => setSpread(i)}
                    />
                  ))}
                </div>
              </>
            ) : null}

            <div className="nav-row">
              <button
                type="button"
                className="nav-tab"
                disabled={!neighbors.prev}
                onClick={() => neighbors.prev && onNavigate(neighbors.prev)}
              >
                Tomo anterior
              </button>
              <button type="button" className="nav-tab" onClick={onRequestClose}>
                Estante
              </button>
              <button
                type="button"
                className="nav-tab"
                disabled={!neighbors.next}
                onClick={() => neighbors.next && onNavigate(neighbors.next)}
              >
                Próximo tomo
              </button>
            </div>
          </motion.div>
        ) : null}
      </AnimatePresence>
    </>
  )
}
