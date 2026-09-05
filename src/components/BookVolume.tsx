import { useCallback, useEffect, useRef, useState } from 'react'
import type { BookData, Spread } from '../types'
import { BookCover } from './BookCover'
import { BookPages } from './BookPages'

export type BookPose = 'closed' | 'opening' | 'opened' | 'closing'

type Props = {
  book: BookData
  pose: BookPose
  reduced: boolean
  spread: number
  turning: 'next' | 'prev' | null
  onTurn: (dir: 'next' | 'prev') => void
  onFlipEnd: () => void
}

function Parchment({
  spread,
  side,
}: {
  spread: Spread
  side: 'left' | 'right'
}) {
  return (
    <div className={`parchment ${side}`}>
      <div className="page-grain" />
      <div className="gutter-shade" />
      <div className="page-inner">
        <BookPages blocks={side === 'left' ? spread.left : spread.right} />
      </div>
    </div>
  )
}

export function BookVolume({
  book,
  pose,
  spread,
  turning,
  onTurn,
  onFlipEnd,
}: Props) {
  const max = book.spreads.length - 1
  const current = book.spreads[spread] ?? book.spreads[0]
  const nextSpread = book.spreads[Math.min(max, spread + 1)]
  const prevSpread = book.spreads[Math.max(0, spread - 1)]

  const leftSpread = turning === 'prev' ? (prevSpread ?? current) : current
  const rightSpread = turning === 'next' ? (nextSpread ?? current) : current
  const incoming = turning === 'next' ? nextSpread : prevSpread

  const canPrev = spread > 0 && !turning && pose === 'opened'
  const canNext = spread < max && !turning && pose === 'opened'

  return (
    <div
      className={`held-book is-${pose} ${turning ? `is-turning-${turning}` : ''}`}
      style={{
        ['--leather' as string]: book.palette.leather,
        ['--leather-dark' as string]: book.palette.leatherDark,
        ['--gold' as string]: book.palette.gold,
      }}
    >
      <div className="volume">
        <div className="cover-swing">
          <div className="board front">
            <div className="cover-frame" />
            <BookCover book={book} />
            <div className="board-sheen" />
          </div>
          <div className="board inside">
            <div className="endpaper" />
            <div className="cover-verso">
              {leftSpread ? <Parchment spread={leftSpread} side="left" /> : null}
            </div>
          </div>
        </div>

        <div className="left-board">
          <div className="left-page-rest">
            {leftSpread ? <Parchment spread={leftSpread} side="left" /> : null}
            {canPrev ? (
              <button
                type="button"
                className="corner-curl prev"
                aria-label="Página anterior"
                onClick={() => onTurn('prev')}
              />
            ) : null}
          </div>
        </div>

        <div className="page-slab">
          <div className="slab-face">
            <span className="ribbon" style={{ ['--ribbon' as string]: book.palette.ribbon }} aria-hidden="true" />
            {rightSpread ? <Parchment spread={rightSpread} side="right" /> : null}
            {canNext ? (
              <button type="button" className="corner-curl next" aria-label="Virar a página" onClick={() => onTurn('next')} />
            ) : null}
          </div>
        </div>

        {turning && current && incoming ? (
          <div
            key={`${turning}-${spread}`}
            className={`flip-leaf turn-${turning}`}
            onAnimationEnd={(e) => {
              if (e.target !== e.currentTarget) return
              const name = e.animationName || ''
              if (!name.toLowerCase().includes('pageflip')) return
              onFlipEnd()
            }}
          >
            <div className="flip-face front">
              <Parchment spread={turning === 'next' ? current : incoming} side="right" />
            </div>
            <div className="flip-face back">
              <Parchment spread={turning === 'next' ? incoming : current} side="left" />
            </div>
          </div>
        ) : null}

        <div className="spine-cap" />
      </div>
    </div>
  )
}

export function usePageFlip(spreadCount: number, reduced: boolean, bookId?: string) {
  const [spread, setSpread] = useState(0)
  const [turning, setTurning] = useState<'next' | 'prev' | null>(null)
  const lock = useRef(false)
  const turningRef = useRef(turning)
  turningRef.current = turning
  const max = Math.max(0, spreadCount - 1)

  useEffect(() => {
    setSpread(0)
    setTurning(null)
    turningRef.current = null
    lock.current = false
  }, [bookId])

  const onTurn = (dir: 'next' | 'prev') => {
    if (lock.current) return
    if (dir === 'next' && spread >= max) return
    if (dir === 'prev' && spread <= 0) return
    if (reduced) {
      setSpread((s) => (dir === 'next' ? Math.min(max, s + 1) : Math.max(0, s - 1)))
      return
    }
    lock.current = true
    setTurning(dir)
  }

  const onFlipEnd = useCallback(() => {
    const dir = turningRef.current
    if (!dir) return
    turningRef.current = null
    setSpread((s) => (dir === 'next' ? Math.min(max, s + 1) : Math.max(0, s - 1)))
    setTurning(null)
    lock.current = false
  }, [max])

  const cancelTurn = useCallback(() => {
    turningRef.current = null
    setTurning(null)
    lock.current = false
  }, [])

  useEffect(() => {
    if (!turning) return
    const t = window.setTimeout(onFlipEnd, 980)
    return () => window.clearTimeout(t)
  }, [turning, onFlipEnd])

  const goTo = (index: number) => {
    if (index === spread || lock.current) return
    if (Math.abs(index - spread) !== 1) {
      setSpread(index)
      return
    }
    onTurn(index > spread ? 'next' : 'prev')
  }

  return { spread, turning, onTurn, onFlipEnd, goTo, cancelTurn, max }
}
