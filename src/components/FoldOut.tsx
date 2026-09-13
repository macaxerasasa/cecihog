import { useCallback, useEffect, useLayoutEffect, useRef, useState, type CSSProperties } from 'react'
import { neighborIds } from '../data/books'
import { getSpreads } from '../data/content'
import { placeOf } from '../data/map'
import { spreadOfGift } from '../data/gifts'
import { bookIdOfYear, getSpell, spreadOfSpell } from '../data/spells'
import { clearBookmark, peekBookmark, setBookmark } from '../lib/bookmark'
import type { OriginRect } from '../types'
import { BookNavContext, type BookNav } from './BookNavContext'
import { RETURN_MS, UNFOLD_MS, type FoldPhase } from './foldTiming'
import { MapBlocks } from './MapBlocks'

type Props = {
  placeId: string
  origin: OriginRect
  phase: FoldPhase
  reduced: boolean
  compact: boolean
  onUnfolded: () => void
  onFolded: () => void
  onRequestClose: () => void
  onNavigate: (id: string) => void
}

const TURN_MS = 300

/*
 * A sheet of the map lifted off its room and unfolded to read. Both halves
 * swing open around the crease; turning a fold closes them onto the crease
 * and opens the next spread.
 */
export default function FoldOut({
  placeId,
  origin,
  phase,
  reduced,
  compact,
  onUnfolded,
  onFolded,
  onRequestClose,
  onNavigate,
}: Props) {
  const place = placeOf(placeId)
  const book = place?.book
  const spreads = getSpreads(placeId)
  const max = Math.max(0, spreads.length - 1)
  const [spread, setSpread] = useState(() => Math.min(max, peekBookmark(placeId)))
  const [turn, setTurn] = useState<'out' | 'in' | null>(null)
  const turnLock = useRef(false)
  const sheetRef = useRef<HTMLDivElement>(null)
  const closeRef = useRef<HTMLButtonElement>(null)
  const timers = useRef<number[]>([])
  const later = useCallback((ms: number, fn: () => void) => {
    timers.current.push(window.setTimeout(fn, ms))
  }, [])

  useEffect(() => () => timers.current.forEach((t) => window.clearTimeout(t)), [])

  /* the fold flies out of its room: measure once and hand the offsets to CSS */
  const [vars, setVars] = useState<CSSProperties>({})
  useLayoutEffect(() => {
    const el = sheetRef.current
    if (!el) return
    const measure = () => {
      const r = el.getBoundingClientRect()
      const cx = origin.x + origin.width / 2
      const cy = origin.y + origin.height / 2
      setVars({
        '--dx': `${(cx - (r.left + r.width / 2)).toFixed(1)}px`,
        '--dy': `${(cy - (r.top + r.height / 2)).toFixed(1)}px`,
        '--sx': Math.max(0.04, origin.width / Math.max(1, r.width)).toFixed(3),
        '--sy': Math.max(0.04, origin.height / Math.max(1, r.height)).toFixed(3),
      } as CSSProperties)
    }
    measure()
  }, [origin])

  /* the phase clock: the parent drives phases, we report when the sheet is flat */
  useEffect(() => {
    if (phase === 'unfolding') later(reduced ? 0 : UNFOLD_MS, onUnfolded)
    if (phase === 'returning') later(reduced ? 0 : RETURN_MS, onFolded)
  }, [phase, reduced, later, onUnfolded, onFolded])

  useEffect(() => {
    if (phase === 'open') closeRef.current?.focus({ preventScroll: true })
    if (phase === 'folding' || phase === 'returning') clearBookmark(placeId)
  }, [phase, placeId])

  const goTo = useCallback(
    (index: number) => {
      const target = Math.max(0, Math.min(max, index))
      if (target === spread || turnLock.current) return
      if (reduced) {
        setSpread(target)
        return
      }
      turnLock.current = true
      setTurn('out')
      later(TURN_MS, () => {
        setSpread(target)
        setTurn('in')
        later(TURN_MS + 40, () => {
          setTurn(null)
          turnLock.current = false
        })
      })
    },
    [max, spread, reduced, later],
  )

  const nav: BookNav = {
    bookId: placeId,
    goTo,
    openSpell: (id) => {
      const spell = getSpell(id)
      if (!spell) return
      const target = bookIdOfYear(spell.year)
      const at = spreadOfSpell(id)
      if (target === placeId) {
        goTo(at)
        return
      }
      setBookmark(target, at)
      onNavigate(target)
    },
    openGift: (id) => goTo(spreadOfGift(id)),
  }

  useEffect(() => {
    if (phase !== 'open') return
    const onKey = (e: KeyboardEvent) => {
      const el = e.target as HTMLElement | null
      if (el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA')) return
      if (e.key === 'ArrowRight') {
        e.preventDefault()
        goTo(spread + 1)
      }
      if (e.key === 'ArrowLeft') {
        e.preventDefault()
        goTo(spread - 1)
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [phase, goTo, spread])

  if (!place || !book) return null
  const current = spreads[spread] ?? spreads[0] ?? { left: [], right: [] }
  const { prev, next } = neighborIds(placeId)
  const prevPlace = prev ? placeOf(prev) : null
  const nextPlace = next ? placeOf(next) : null
  const interactive = phase === 'open'

  return (
    <div className={`foldout is-${phase} ${compact ? 'is-compact' : ''} ${turn ? `is-turn-${turn}` : ''}`}>
      <button
        type="button"
        className="foldout-veil"
        aria-label="Dobrar a folha e voltar ao mapa"
        tabIndex={-1}
        onClick={() => interactive && onRequestClose()}
      />
      <div
        ref={sheetRef}
        className="sheet"
        style={vars}
        role="dialog"
        aria-modal="true"
        aria-labelledby="sheet-title"
        onClick={(e) => e.stopPropagation()}
      >
        <header className="sheet-head">
          <div className="sheet-banner">
            <span className="sheet-kicker">{place.name}</span>
            <h2 id="sheet-title">{book.title}</h2>
            <p className="sheet-sub">{book.subtitle}</p>
          </div>
          <p className="sheet-motto">“{book.motto}”</p>
          <button
            ref={closeRef}
            type="button"
            className="sheet-close"
            onClick={onRequestClose}
            disabled={!interactive}
            aria-label="Dobrar a folha e voltar ao mapa"
          >
            <span aria-hidden="true">✕</span>
            <small>dobrar</small>
          </button>
        </header>

        <BookNavContext.Provider value={nav}>
          <div className="sheet-body">
            <section className="half left" key={`l-${spread}`}>
              <div className="half-inner">
                <MapBlocks blocks={current.left} />
              </div>
            </section>
            <div className="crease" aria-hidden="true" />
            <section className="half right" key={`r-${spread}`}>
              <div className="half-inner">
                <MapBlocks blocks={current.right} />
              </div>
            </section>
          </div>
        </BookNavContext.Provider>

        <footer className="sheet-foot">
          <button
            type="button"
            className="foot-btn room-btn"
            disabled={!interactive || !prevPlace}
            onClick={() => prevPlace && onNavigate(prevPlace.id)}
            title={prevPlace ? prevPlace.book.title : undefined}
          >
            <span aria-hidden="true">◂</span> {prevPlace ? prevPlace.name : 'Início do mapa'}
          </button>
          <div className="sheet-pager">
            <button type="button" className="foot-btn" disabled={!interactive || spread <= 0} onClick={() => goTo(spread - 1)}>
              <span aria-hidden="true">‹</span> dobra anterior
            </button>
            <span className="pager-count">
              dobra <b>{spread + 1}</b> de {spreads.length}
            </span>
            <button type="button" className="foot-btn" disabled={!interactive || spread >= max} onClick={() => goTo(spread + 1)}>
              próxima dobra <span aria-hidden="true">›</span>
            </button>
          </div>
          <button
            type="button"
            className="foot-btn room-btn"
            disabled={!interactive || !nextPlace}
            onClick={() => nextPlace && onNavigate(nextPlace.id)}
            title={nextPlace ? nextPlace.book.title : undefined}
          >
            {nextPlace ? nextPlace.name : 'Fim do mapa'} <span aria-hidden="true">▸</span>
          </button>
        </footer>
      </div>
    </div>
  )
}
