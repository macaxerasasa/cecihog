import { useEffect, useRef, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { neighborIds } from '../data/books'
import type { BookData, LibraryPhase, OriginRect } from '../types'
import { BookVolume, usePageFlip, type BookPose } from './BookVolume'

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
  const gutter = mobile ? 28 : 108
  const w = Math.min(
    mobile ? 268 : 372,
    (window.innerWidth - gutter) / 2,
    window.innerWidth * (mobile ? 0.45 : 0.31),
  )
  const h = Math.min(mobile ? 400 : 528, window.innerHeight * (mobile ? 0.54 : 0.68))
  return { w: Math.round(w), h: Math.round(h) }
}

function poseFrom(phase: LibraryPhase): BookPose {
  if (phase === 'opening') return 'opening'
  if (phase === 'open') return 'opened'
  if (phase === 'closing') return 'closing'
  return 'closed'
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
  const [dim, setDim] = useState(sizes)
  const closeRef = useRef<HTMLButtonElement>(null)
  const neighbors = neighborIds(book.id)
  const pose = poseFrom(phase)
  const showUi = phase === 'open'
  const returning = phase === 'toShelf'
  const inFlight = phase === 'toCenter' || returning
  const pages = usePageFlip(book.spreads.length, reduced, book.id)

  useEffect(() => {
    const onResize = () => setDim(sizes())
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

  useEffect(() => {
    if (phase === 'open') closeRef.current?.focus()
  }, [phase, book.id])

  useEffect(() => {
    if (phase === 'closing' || phase === 'toShelf') {
      if (pages.turning) pages.onFlipEnd()
      else pages.cancelTurn()
    }
  }, [phase, pages.cancelTurn, pages.onFlipEnd, pages.turning])

  useEffect(() => {
    if (phase !== 'open') return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight') {
        e.preventDefault()
        pages.onTurn('next')
      }
      if (e.key === 'ArrowLeft') {
        e.preventDefault()
        pages.onTurn('prev')
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [phase, pages.onTurn])

  const cx = window.innerWidth / 2
  const cy = window.innerHeight / 2 + 6
  const start = {
    x: origin.x + origin.width / 2,
    y: origin.y + origin.height / 2,
    scale: Math.max(0.12, origin.height / dim.h),
    rotateY: 28,
    rotateX: 8,
  }
  const center = { x: cx, y: cy, scale: 1, rotateY: 0, rotateX: 0 }
  const animateTo = returning ? start : center
  const duration = reduced ? 0.001 : inFlight ? 0.92 : 0.01

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
          className="flyer-orbit"
          style={{
            width: dim.w,
            height: dim.h,
            marginLeft: -dim.w / 2,
            marginTop: -dim.h / 2,
            pointerEvents: phase === 'open' ? 'auto' : 'none',
            overflow: 'visible',
            transformStyle: 'preserve-3d',
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
            className="held-stage"
            style={{ width: dim.w, height: dim.h }}
            onClick={(e) => e.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="book-dialog-title"
          >
            <h2 id="book-dialog-title" className="sr-only">
              {book.title}
            </h2>
            <BookVolume
              book={book}
              pose={pose}
              reduced={reduced}
              spread={pages.spread}
              turning={pages.turning}
              onTurn={pages.onTurn}
              onFlipEnd={pages.onFlipEnd}
            />
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

            {pages.max > 0 ? (
              <>
                <button
                  type="button"
                  className="page-turn prev"
                  aria-label="Página anterior"
                  disabled={pages.spread === 0 || !!pages.turning}
                  onClick={() => pages.onTurn('prev')}
                >
                  ‹
                </button>
                <button
                  type="button"
                  className="page-turn next"
                  aria-label="Virar a página"
                  disabled={pages.spread === pages.max || !!pages.turning}
                  onClick={() => pages.onTurn('next')}
                >
                  ›
                </button>
                <div className="spread-dots" role="tablist" aria-label="Cadernos deste tomo">
                  {book.spreads.map((_, i) => (
                    <button
                      key={i}
                      type="button"
                      className={i === pages.spread && !pages.turning ? 'is-on' : ''}
                      aria-label={`Abrir caderno ${i + 1}`}
                      onClick={() => pages.goTo(i)}
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
