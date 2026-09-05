import type { CSSProperties } from 'react'
import { Candle } from './Candle'

type Floater = {
  x: number
  y: number
  /** 1 = nearest / largest, smaller = farther back, dimmer and softer */
  depth: number
  burn: number
  drift: number
  delay: number
}

/*
 * Great Hall candles hovering in the room. Positions avoid the masthead
 * (top centre), the shelf (centre) and the house crests (corners).
 */
const FLOATERS: Floater[] = [
  // side corridors between the crests and the case (first two survive on mobile)
  { x: 3.5, y: 24, depth: 1, burn: 0.2, drift: 8.6, delay: -4.4 },
  { x: 96.5, y: 22, depth: 1, burn: 0.3, drift: 8.9, delay: -0.6 },
  { x: 1.5, y: 34, depth: 0.5, burn: 0.4, drift: 11.4, delay: -2 },
  { x: 98.5, y: 36, depth: 0.5, burn: 0.25, drift: 11.8, delay: -5.3 },
  { x: 5, y: 58, depth: 0.7, burn: 0.55, drift: 10.6, delay: -6.1 },
  { x: 95, y: 60, depth: 0.72, burn: 0.15, drift: 10, delay: -2.8 },
  // high in the vault, above the crown candlesticks and clear of the title
  { x: 26, y: 2, depth: 0.5, burn: 0.45, drift: 12.5, delay: -3.4 },
  { x: 36, y: 3, depth: 0.42, burn: 0.5, drift: 13, delay: -7 },
  { x: 64, y: 2.5, depth: 0.4, burn: 0.35, drift: 12, delay: -8.2 },
  { x: 74, y: 2, depth: 0.52, burn: 0.1, drift: 12.8, delay: -1.2 },
]

export function FloatingCandles() {
  return (
    <div className="floating-candles" aria-hidden="true">
      {FLOATERS.map((f, i) => (
        <Candle
          key={i}
          burn={f.burn}
          className="floating-candle"
          style={
            {
              left: `${f.x}%`,
              top: `${f.y}%`,
              '--depth': f.depth,
              '--drift': `${f.drift}s`,
              '--flicker-delay': `${f.delay}s`,
            } as CSSProperties
          }
        />
      ))}
    </div>
  )
}
