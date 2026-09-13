import { lazy, Suspense, useCallback, useEffect, useRef, useState } from 'react'
import { books, getBook } from '../data/books'
import { usePrefersReducedMotion } from '../hooks/usePrefersReducedMotion'
import { preloadHallArt } from '../lib/preload'
import { readRoute, syncRoute } from '../lib/route'
import type { LibraryPhase, OriginRect } from '../types'
import { Bookshelf } from './Bookshelf'
import { HouseCorners } from './HouseCorners'
import { LibraryEnvironment } from './LibraryEnvironment'
import { Lighting } from './Lighting'
import { WallSconces } from './WallSconces'
import { Particles } from './Particles'
import { WandGate } from './WandGate'

/*
 * The reader (pages, spells, flight animation) is its own chunk: the hall
 * loads without it and fetches it while the visitor is still at the gate or
 * looking at the shelf.
 */
const loadReader = () => import('./BookModal')
const BookModal = lazy(loadReader)

const OPEN_COVER_MS = 1280
const CLOSE_COVER_MS = 1280
const FLY_MS = 1180
const BOOT_MS = 160

export function Library() {
  const reduced = usePrefersReducedMotion()
  // `?aberto` skips the wand gate during development so the hall can be inspected directly
  const [unlocked, setUnlocked] = useState(
    () => import.meta.env.DEV && new URLSearchParams(window.location.search).has('aberto'),
  )
  const [awake, setAwake] = useState(false)
  const [phase, setPhase] = useState<LibraryPhase>('boot')
  const [activeId, setActiveId] = useState<string | null>(null)
  const [origin, setOrigin] = useState<OriginRect | null>(null)
  const [status, setStatus] = useState('A estante revela-se.')
  const timers = useRef<number[]>([])
  const phaseRef = useRef(phase)
  const queueRef = useRef<string | null>(null)
  const origins = useRef<Record<string, OriginRect>>({})
  const requestCloseRef = useRef<() => void>(() => {})
  const activeIdRef = useRef<string | null>(null)
  activeIdRef.current = activeId

  useEffect(() => {
    phaseRef.current = phase
  }, [phase])

  const clearTimers = () => {
    for (const t of timers.current) window.clearTimeout(t)
    timers.current = []
  }

  const later = (ms: number, fn: () => void) => {
    const id = window.setTimeout(fn, reduced ? 0 : ms)
    timers.current.push(id)
  }

  useEffect(() => {
    if (!unlocked) return
    const t = window.setTimeout(() => {
      setAwake(true)
      setPhase('idle')
    }, reduced ? 0 : BOOT_MS)
    return () => window.clearTimeout(t)
  }, [reduced, unlocked])

  useEffect(() => () => clearTimers(), [])

  useEffect(() => {
    preloadHallArt()
  }, [])

  useEffect(() => {
    if (!unlocked) return
    const w = window as Window & { requestIdleCallback?: (cb: () => void, opts?: { timeout: number }) => number }
    if (w.requestIdleCallback) w.requestIdleCallback(() => void loadReader(), { timeout: 2500 })
    else window.setTimeout(() => void loadReader(), 1200)
  }, [unlocked])

  const remember = (id: string, el: HTMLElement) => {
    const r = el.getBoundingClientRect()
    const rect = { x: r.left, y: r.top, width: r.width, height: r.height }
    origins.current[id] = rect
    return rect
  }

  const beginOpen = useCallback(
    (id: string, el?: HTMLElement) => {
      if (el) remember(id, el)
      if (phaseRef.current === 'open') {
        if (id === activeIdRef.current) return
        queueRef.current = id
        requestCloseRef.current()
        return
      }
      if (phaseRef.current !== 'idle' && phaseRef.current !== 'boot') return
      const book = getBook(id)
      if (!book) return
      const rect = origins.current[id]
      if (!rect) return
      clearTimers()
      void loadReader()
      syncRoute(id)
      document.title = `${book.title} — Biblioteca de Hogwarts`
      setActiveId(id)
      setOrigin(rect)
      setStatus(`Abrindo o tomo ${book.title}.`)
      if (reduced) {
        setPhase('open')
        return
      }
      setPhase('toCenter')
      later(FLY_MS, () => {
        if (phaseRef.current === 'toCenter') {
          setPhase('opening')
          later(OPEN_COVER_MS, () => {
            if (phaseRef.current === 'opening') setPhase('open')
          })
        }
      })
    },
    [reduced],
  )

  const handleOpened = () => {
    if (phaseRef.current !== 'toCenter') return
    setPhase('opening')
    later(OPEN_COVER_MS, () => {
      if (phaseRef.current === 'opening') setPhase('open')
    })
  }

  const finishClose = useCallback(() => {
    const queued = queueRef.current
    queueRef.current = null
    setActiveId(null)
    setOrigin(null)
    setPhase('idle')
    setStatus('De volta à estante.')
    if (!queued) {
      syncRoute(null, true)
      document.title = 'Hogwarts — Biblioteca'
    }
    if (queued) {
      later(40, () => {
        const slot = document.querySelector<HTMLButtonElement>(`button[aria-label="Abrir o tomo ${getBook(queued)?.title}"]`)
        beginOpen(queued, slot ?? undefined)
      })
    }
  }, [beginOpen])

  const handleClosed = () => {
    if (phaseRef.current !== 'toShelf') return
    finishClose()
  }

  const requestClose = useCallback(() => {
    if (phaseRef.current !== 'open') return
    clearTimers()
    setStatus('Fechando o tomo.')
    // a plain close steps back to the hall's entry, so the history stays clean
    if (!queueRef.current && window.history.state?.book === activeIdRef.current && readRoute()) {
      window.history.back()
    }
    if (reduced) {
      finishClose()
      return
    }
    setPhase('closing')
    later(CLOSE_COVER_MS, () => {
      if (phaseRef.current === 'closing') {
        setPhase('toShelf')
        later(FLY_MS, () => {
          if (phaseRef.current === 'toShelf') finishClose()
        })
      }
    })
  }, [finishClose, reduced])

  requestCloseRef.current = requestClose

  const navigateTo = (id: string) => {
    if (phaseRef.current !== 'open') return
    queueRef.current = id
    requestClose()
  }

  const shelfSlot = (id: string) =>
    document.querySelector<HTMLButtonElement>(`button[aria-label="Abrir o tomo ${getBook(id)?.title}"]`) ?? undefined

  /* Back / forward: the address decides which tome is open. */
  useEffect(() => {
    const onPop = () => {
      const id = readRoute()
      if (id && getBook(id)) {
        if (id !== activeIdRef.current) beginOpen(id, shelfSlot(id))
      } else if (phaseRef.current === 'open') {
        requestClose()
      }
    }
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [beginOpen, requestClose])

  /* Arriving on a tome's address: pull it from the shelf once the hall is up. */
  const deepLinked = useRef(false)
  useEffect(() => {
    if (!awake || phase !== 'idle' || deepLinked.current) return
    deepLinked.current = true
    const id = readRoute()
    if (!id || !getBook(id)) return
    const t = window.setTimeout(() => beginOpen(id, shelfSlot(id)), reduced ? 0 : 500)
    return () => window.clearTimeout(t)
  }, [awake, phase, beginOpen, reduced])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') requestClose()
      if (phaseRef.current !== 'idle') return
      const i = books.findIndex((b) => document.activeElement?.getAttribute('aria-label') === `Abrir o tomo ${b.title}`)
      if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
        const next = books[(Math.max(0, i) + 1) % books.length]
        document.querySelector<HTMLButtonElement>(`button[aria-label="Abrir o tomo ${next.title}"]`)?.focus()
      }
      if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
        const prev = books[(i <= 0 ? books.length : i) - 1]
        document.querySelector<HTMLButtonElement>(`button[aria-label="Abrir o tomo ${prev.title}"]`)?.focus()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [requestClose])

  const book = activeId ? getBook(activeId) : null
  const busy = phase !== 'idle' && phase !== 'boot' && phase !== 'open'

  if (!unlocked) {
    return (
      <div className="library is-gated">
        <WandGate reduced={reduced} onUnlocked={() => setUnlocked(true)} />
      </div>
    )
  }

  return (
    <LibraryEnvironment
      awake={awake}
      busy={busy}
      reading={phase === 'open'}
      holding={phase === 'toCenter' || phase === 'opening' || phase === 'open' || phase === 'closing'}
    >
      <Lighting />
      <WallSconces />
      <HouseCorners />
      <Particles active={awake} />
      <header className="masthead">
        <h1>Hogwarts</h1>
        <p>Biblioteca · Seção Restrita</p>
      </header>
      <div className="stage-wrap">
        <Bookshelf
          busy={busy}
          activeId={activeId}
          onOpen={(id, el) => beginOpen(id, el)}
        />
      </div>
      <p className="hint">
        Toque um tomo<span className="hint-more"> para retirá-lo da estante</span>
      </p>
      <div className="sr-only" aria-live="polite">
        {status}
      </div>
      {book && origin ? (
        <Suspense fallback={null}>
          <BookModal
            key={book.id}
            book={book}
            origin={origin}
            phase={phase}
            reduced={reduced}
            onOpened={handleOpened}
            onClosed={handleClosed}
            onRequestClose={requestClose}
            onNavigate={navigateTo}
          />
        </Suspense>
      ) : null}
    </LibraryEnvironment>
  )
}
