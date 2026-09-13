import { lazy, Suspense, useCallback, useEffect, useRef, useState } from 'react'
import { getBook } from '../data/books'
import { places } from '../data/map'
import { useMediaQuery } from '../hooks/useMediaQuery'
import { usePrefersReducedMotion } from '../hooks/usePrefersReducedMotion'
import { preloadSheetArt } from '../lib/preload'
import { readRoute, syncRoute } from '../lib/route'
import type { OriginRect } from '../types'
import { CastleMap } from './CastleMap'
import { FOLD_MS, LIFT_MS, type FoldPhase } from './foldTiming'
import { Oath } from './Oath'
import { YourSteps } from './YourSteps'

const loadFoldOut = () => import('./FoldOut')
const FoldOut = lazy(loadFoldOut)

type Phase = 'idle' | FoldPhase

const DRAW_MS = 2800

export function MaraudersMap() {
  const reduced = usePrefersReducedMotion()
  const portrait = useMediaQuery('(max-aspect-ratio: 5/6)')
  const compact = useMediaQuery('(max-width: 740px)')
  const lite = useMediaQuery('(max-width: 740px), (pointer: coarse)')
  const frame = portrait ? 'p' : 'l'

  const [sworn, setSworn] = useState(() => {
    if (typeof window === 'undefined') return false
    // `?aberto` only in `npm run dev`, so shots and local work can skip the gate
    return import.meta.env.DEV && new URLSearchParams(window.location.search).has('aberto')
  })
  const [drawn, setDrawn] = useState(false)
  const [fading, setFading] = useState(false)
  const [phase, setPhase] = useState<Phase>('idle')
  const [activeId, setActiveId] = useState<string | null>(null)
  const [origin, setOrigin] = useState<OriginRect | null>(null)
  const [status, setStatus] = useState('O mapa aguarda o juramento.')

  const phaseRef = useRef(phase)
  phaseRef.current = phase
  const activeRef = useRef(activeId)
  activeRef.current = activeId
  const queued = useRef<string | null>(null)
  const timers = useRef<number[]>([])
  const closeRef = useRef<() => void>(() => {})
  const lastRoom = useRef<SVGGraphicsElement | null>(null)

  const clearTimers = () => {
    timers.current.forEach((t) => window.clearTimeout(t))
    timers.current = []
  }
  const later = (ms: number, fn: () => void) => {
    timers.current.push(window.setTimeout(fn, reduced ? 0 : ms))
  }
  useEffect(() => () => clearTimers(), [])

  /* the plan draws itself once the oath is spoken */
  useEffect(() => {
    if (!sworn) {
      setDrawn(false)
      return
    }
    const t = window.setTimeout(() => setDrawn(true), reduced ? 0 : DRAW_MS)
    return () => window.clearTimeout(t)
  }, [sworn, reduced])

  useEffect(() => {
    if (!sworn) return
    const warm = () => {
      void loadFoldOut()
      preloadSheetArt()
    }
    const w = window as Window & { requestIdleCallback?: (cb: () => void, o?: { timeout: number }) => number }
    if (w.requestIdleCallback) w.requestIdleCallback(warm, { timeout: 2500 })
    else window.setTimeout(warm, 1200)
  }, [sworn])

  const roomEl = (id: string) => document.querySelector<SVGGraphicsElement>(`.place[data-id="${id}"]`)

  const beginOpen = useCallback(
    (id: string, el?: SVGGraphicsElement | null) => {
      const book = getBook(id)
      if (!book) return
      if (phaseRef.current === 'open') {
        if (id === activeRef.current) return
        queued.current = id
        closeRef.current()
        return
      }
      if (phaseRef.current !== 'idle') return
      const target = el ?? roomEl(id)
      if (!target) return
      lastRoom.current = target
      const r = target.getBoundingClientRect()
      clearTimers()
      void loadFoldOut()
      syncRoute(id)
      document.title = `${book.title} — Mapa do Maroto`
      setActiveId(id)
      setOrigin({ x: r.left, y: r.top, width: r.width, height: r.height })
      setStatus(`Desdobrando ${book.title}.`)
      if (reduced) {
        setPhase('open')
        return
      }
      setPhase('lifting')
      later(LIFT_MS, () => {
        if (phaseRef.current === 'lifting') setPhase('unfolding')
      })
    },
    [reduced],
  )

  const handleUnfolded = useCallback(() => {
    if (phaseRef.current === 'unfolding') setPhase('open')
  }, [])

  const finishClose = useCallback(() => {
    const next = queued.current
    queued.current = null
    setActiveId(null)
    setOrigin(null)
    setPhase('idle')
    setStatus('De volta ao mapa.')
    if (!next) {
      syncRoute(null, true)
      document.title = 'Mapa do Maroto — Hogwarts'
      lastRoom.current?.focus({ preventScroll: true })
    } else {
      later(40, () => beginOpen(next, roomEl(next)))
    }
  }, [beginOpen])

  const handleFolded = useCallback(() => {
    if (phaseRef.current === 'returning') finishClose()
  }, [finishClose])

  const requestClose = useCallback(() => {
    if (phaseRef.current !== 'open') return
    clearTimers()
    setStatus('Dobrando a folha.')
    if (!queued.current && window.history.state?.book === activeRef.current && readRoute()) {
      window.history.back()
    }
    if (reduced) {
      finishClose()
      return
    }
    setPhase('folding')
    later(FOLD_MS, () => {
      if (phaseRef.current === 'folding') setPhase('returning')
    })
  }, [finishClose, reduced])
  closeRef.current = requestClose

  const navigateTo = (id: string) => {
    if (phaseRef.current !== 'open') return
    queued.current = id
    requestClose()
  }

  /* back / forward: the address names the open room */
  useEffect(() => {
    const onPop = () => {
      const id = readRoute()
      if (id && getBook(id)) {
        if (id !== activeRef.current) beginOpen(id, roomEl(id))
      } else if (phaseRef.current === 'open') {
        requestClose()
      }
    }
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [beginOpen, requestClose])

  /* arriving on a room's address: unfold it once the plan is drawn */
  const deepLinked = useRef(false)
  useEffect(() => {
    if (!drawn || deepLinked.current) return
    deepLinked.current = true
    const id = readRoute()
    if (!id || !getBook(id)) return
    const t = window.setTimeout(() => beginOpen(id, roomEl(id)), reduced ? 0 : 350)
    return () => window.clearTimeout(t)
  }, [drawn, beginOpen, reduced])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') requestClose()
      if (phaseRef.current !== 'idle') return
      const ids = places.map((p) => p.id)
      const focused = document.activeElement as HTMLElement | null
      const cur = ids.indexOf(focused?.getAttribute('data-id') ?? '')
      if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
        roomEl(ids[(Math.max(0, cur) + 1) % ids.length])?.focus()
      }
      if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
        roomEl(ids[(cur <= 0 ? ids.length : cur) - 1])?.focus()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [requestClose])

  const swear = () => {
    setSworn(true)
    setStatus('O mapa revela-se.')
  }

  const mischief = () => {
    if (phaseRef.current !== 'idle') return
    setFading(true)
    setStatus('Travessura feita.')
    later(820, () => {
      setFading(false)
      setSworn(false)
      syncRoute(null, true)
      document.title = 'Mapa do Maroto — Hogwarts'
    })
  }

  const holding = phase !== 'idle'
  const book = activeId ? getBook(activeId) : null

  if (!sworn) {
    return (
      <main className="maroto is-gated">
        <Oath reduced={reduced} onSworn={swear} />
        <div className="candlelight" aria-hidden="true" />
        <div className="sr-only" aria-live="polite">
          {status}
        </div>
      </main>
    )
  }

  return (
    <main
      className={`maroto frame-${frame} ${drawn ? 'is-drawn' : 'is-drawing'} ${holding ? 'is-holding' : ''} ${fading ? 'is-fading' : ''} ${lite ? 'is-lite' : ''}`}
    >
      <header className="masthead">
        <p className="masthead-kicker">
          Os senhores Aluado, Rabicho, Almofadinhas e Pontas têm a honra de apresentar
        </p>
        <h1 className="masthead-title">
          <span>O Mapa do Maroto</span>
        </h1>
        <p className="masthead-sub">Escola de Magia e Bruxaria de Hogwarts · planta dos andares e sumário de feitiços</p>
      </header>

      <div className="plan">
        <CastleMap frame={frame} lite={lite} activeId={activeId} busy={holding} onOpen={beginOpen} />
      </div>

      <footer className="map-foot">
        <p className="map-hint">
          Toque uma sala para desdobrar as suas páginas
          <span className="hint-more"> · setas para percorrer, Esc para dobrar</span>
        </p>
        <button type="button" className="mischief" onClick={mischief} disabled={holding}>
          Travessura feita
        </button>
      </footer>

      <div className="candlelight" aria-hidden="true" />
      {!lite ? <YourSteps paused={holding || !drawn} /> : null}

      <div className="sr-only" aria-live="polite">
        {status}
      </div>

      {book && origin && phase !== 'idle' ? (
        <Suspense fallback={null}>
          <FoldOut
            key={book.id}
            placeId={book.id}
            origin={origin}
            phase={phase}
            reduced={reduced}
            compact={compact}
            onUnfolded={handleUnfolded}
            onFolded={handleFolded}
            onRequestClose={requestClose}
            onNavigate={navigateTo}
          />
        </Suspense>
      ) : null}
    </main>
  )
}
