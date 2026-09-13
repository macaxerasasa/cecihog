import { useEffect, useRef, useState, type CSSProperties } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { neighborIds } from '../data/books'
import { getSpreads } from '../data/content'
import { bookIdOfYear, getSpell, spreadOfSpell } from '../data/spells'
import { clearBookmark, setBookmark } from '../lib/bookmark'
import type { BookData, LibraryPhase, OriginRect } from '../types'
import { BookNavContext, type BookNav } from './BookNavContext'
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
  if (mobile) {
    // One page at a time: fill the width, leave room for the seal and the nav row.
    const w = Math.min(380, window.innerWidth - 32)
    const h = Math.min(620, window.innerHeight - 190, w * 1.45)
    // never squarer than 1.3: the painted border is drawn for a tall leaf
    return { w: Math.round(Math.min(w, h / 1.3)), h: Math.round(h) }
  }
  const w = Math.min(460, (window.innerWidth - 140) / 2, window.innerWidth * 0.32)
  const h = Math.min(660, window.innerHeight * 0.74, w * 1.45)
  return { w: Math.round(Math.min(w, h / 1.3)), h: Math.round(h) }
}

function poseFrom(phase: LibraryPhase): BookPose {
  if (phase === 'opening') return 'opening'
  if (phase === 'open') return 'opened'
  if (phase === 'closing') return 'closing'
  return 'closed'
}

export default function BookModal({
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
  const spreads = getSpreads(book.id)
  const pages = usePageFlip(spreads.length, reduced, book.id)
  const nav: BookNav = {
    bookId: book.id,
    goTo: pages.goTo,
    openSpell: (id) => {
      const spell = getSpell(id)
      if (!spell) return
      const target = bookIdOfYear(spell.year)
      const spread = spreadOfSpell(id)
      if (target === book.id) {
        pages.goTo(spread)
        return
      }
      setBookmark(target, spread)
      onNavigate(target)
    },
  }

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
      clearBookmark(book.id)
      if (pages.turning) pages.onFlipEnd()
      else pages.cancelTurn()
    }
  }, [phase, book.id, pages.cancelTurn, pages.onFlipEnd, pages.turning])

  useEffect(() => {
    if (phase !== 'open') return
    const onKey = (e: KeyboardEvent) => {
      const el = e.target as HTMLElement | null
      if (el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA')) return
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
  /*
   * Flight path: the tome is first drawn straight out of the shelf (a short
   * pull towards the viewer with a slight tilt), then swoops up in an arc to
   * the reading position. The return plays the same path backwards.
   */
  const lift = Math.min(90, origin.height * 0.55)
  const pulled = {
    x: start.x + origin.width * 0.9,
    y: start.y - lift * 0.35,
    scale: start.scale * 1.32,
    rotateY: 44,
    rotateX: 10,
  }
  const arc = {
    x: start.x + (cx - start.x) * 0.55,
    y: Math.min(start.y, cy) - lift,
    scale: start.scale + (1 - start.scale) * 0.6,
    rotateY: 18,
    rotateX: -4,
  }
  const path = (from: typeof start, ...steps: (typeof start)[]) => {
    const all = [from, ...steps]
    return {
      x: all.map((p) => p.x),
      y: all.map((p) => p.y),
      scale: all.map((p) => p.scale),
      rotateY: all.map((p) => p.rotateY),
      rotateX: all.map((p) => p.rotateX),
    }
  }
  const animateTo = reduced
    ? returning
      ? start
      : center
    : returning
      ? path(center, arc, pulled, start)
      : inFlight
        ? path(start, pulled, arc, center)
        : center
  const duration = reduced ? 0.001 : inFlight ? 1.15 : 0.01
  const times = returning ? [0, 0.45, 0.78, 1] : [0, 0.26, 0.6, 1]

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
          transition={
            inFlight && !reduced
              ? { duration, times, ease: ['easeOut', 'easeInOut', [0.22, 0.8, 0.28, 1]] }
              : { duration, ease: [0.22, 0.8, 0.28, 1] }
          }
          onAnimationComplete={() => {
            if (phase === 'toCenter') onOpened()
            if (phase === 'toShelf') onClosed()
          }}
        >
          <div
            className={`held-stage ${phase === 'open' && !pages.turning ? 'is-flat' : ''}`}
            style={{ width: dim.w, height: dim.h }}
            onClick={(e) => e.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="book-dialog-title"
          >
            <h2 id="book-dialog-title" className="sr-only">
              {book.title}
            </h2>
            <BookNavContext.Provider value={nav}>
              <BookVolume
                book={book}
                spreads={spreads}
                pose={pose}
                reduced={reduced}
                spread={pages.spread}
                turning={pages.turning}
                onTurn={pages.onTurn}
                onFlipEnd={pages.onFlipEnd}
              />
            </BookNavContext.Provider>
          </div>
        </motion.div>
      </div>

      <AnimatePresence>
        {showUi ? (
          <motion.div
            className="ritual-ui"
            style={{ '--book-w': `${dim.w}px` } as CSSProperties}
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
                  {spreads.map((_, i) => (
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
                <span className="tab-hide">Tomo </span>anterior
              </button>
              {book.category === 'year' ? (
                <button
                  type="button"
                  className="nav-tab"
                  disabled={pages.spread === 0 || !!pages.turning}
                  onClick={() => pages.goTo(0)}
                >
                  Índice
                </button>
              ) : null}
              <button type="button" className="nav-tab" onClick={onRequestClose}>
                Estante
              </button>
              <button
                type="button"
                className="nav-tab"
                disabled={!neighbors.next}
                onClick={() => neighbors.next && onNavigate(neighbors.next)}
              >
                Próximo<span className="tab-hide"> tomo</span>
              </button>
            </div>
          </motion.div>
        ) : null}
      </AnimatePresence>
    </>
  )
}
