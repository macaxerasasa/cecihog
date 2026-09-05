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
  { x: 22, y: 9, depth: 0.8, burn: 0.2, drift: 9.5, delay: -2 },
  { x: 30, y: 16, depth: 0.6, burn: 0.45, drift: 11, delay: -5 },
  { x: 70, y: 15, depth: 0.62, burn: 0.3, drift: 10.2, delay: -1.2 },
  { x: 78, y: 8, depth: 0.82, burn: 0.1, drift: 9.1, delay: -7 },
  { x: 37, y: 5, depth: 0.42, burn: 0.5, drift: 12.5, delay: -3.4 },
  { x: 63, y: 4, depth: 0.4, burn: 0.35, drift: 12, delay: -8.2 },
  { x: 3.5, y: 24, depth: 1, burn: 0.2, drift: 8.6, delay: -4.4 },
  { x: 96.5, y: 22, depth: 1, burn: 0.3, drift: 8.9, delay: -0.6 },
  { x: 5, y: 58, depth: 0.7, burn: 0.55, drift: 10.6, delay: -6.1 },
  { x: 95, y: 60, depth: 0.72, burn: 0.15, drift: 10, delay: -2.8 },
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
