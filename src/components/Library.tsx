import { useCallback, useEffect, useRef, useState } from 'react'
import { books, getBook } from '../data/books'
import { usePrefersReducedMotion } from '../hooks/usePrefersReducedMotion'
import type { LibraryPhase, OriginRect } from '../types'
import { BookModal } from './BookModal'
import { Bookshelf } from './Bookshelf'
import { LibraryEnvironment } from './LibraryEnvironment'
import { Lighting } from './Lighting'
import { Particles } from './Particles'
import { WandGate } from './WandGate'

const OPEN_COVER_MS = 1280
const CLOSE_COVER_MS = 1100
const BOOT_MS = 160

export function Library() {
  const reduced = usePrefersReducedMotion()
  const [unlocked, setUnlocked] = useState(false)
  const [awake, setAwake] = useState(false)
  const [phase, setPhase] = useState<LibraryPhase>('boot')
  const [activeId, setActiveId] = useState<string | null>(null)
  const [origin, setOrigin] = useState<OriginRect | null>(null)
  const [status, setStatus] = useState('A estante revela-se.')
  const timers = useRef<number[]>([])
  const phaseRef = useRef(phase)
  const queueRef = useRef<string | null>(null)
  const origins = useRef<Record<string, OriginRect>>({})

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

  const remember = (id: string, el: HTMLElement) => {
    const r = el.getBoundingClientRect()
    const rect = { x: r.left, y: r.top, width: r.width, height: r.height }
    origins.current[id] = rect
    return rect
  }

  const beginOpen = useCallback(
    (id: string, el?: HTMLElement) => {
      if (phaseRef.current !== 'idle' && phaseRef.current !== 'boot') return
      const book = getBook(id)
      if (!book) return
      const rect = el ? remember(id, el) : origins.current[id]
      if (!rect) return
      clearTimers()
      setActiveId(id)
      setOrigin(rect)
      setStatus(`Abrindo o tomo ${book.title}.`)
      if (reduced) {
        setPhase('open')
        return
      }
      setPhase('toCenter')
      later(980, () => {
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
    if (reduced) {
      finishClose()
      return
    }
    setPhase('closing')
    later(CLOSE_COVER_MS, () => {
      if (phaseRef.current === 'closing') {
        setPhase('toShelf')
        later(980, () => {
          if (phaseRef.current === 'toShelf') finishClose()
        })
      }
    })
  }, [finishClose, reduced])

  const navigateTo = (id: string) => {
    if (phaseRef.current !== 'open') return
    queueRef.current = id
    requestClose()
  }

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
    <LibraryEnvironment awake={awake} busy={busy}>
      <Lighting />
      <Particles active={awake} />
      <header className="masthead">
        <h1>Hogwarts</h1>
        <p>Biblioteca · Seção Restrita</p>
      </header>
      <div className="stage-wrap">
        <Bookshelf
          busy={phase !== 'idle'}
          activeId={activeId}
          onOpen={(id, el) => beginOpen(id, el)}
        />
      </div>
      <p className="hint">Toque um tomo para retirá-lo da estante</p>
      <div className="sr-only" aria-live="polite">
        {status}
      </div>
      {book && origin ? (
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
      ) : null}
    </LibraryEnvironment>
  )
}
