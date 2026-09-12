import { useId, type CSSProperties } from 'react'
import { asset } from '../lib/asset'

/*
 * Painted candles. The body is a cut-out photograph-style render (brass
 * candlestick, beeswax taper); only the flame is drawn live, as an SVG sitting
 * on the wick, so it can lick and breathe. Wick positions were measured on the
 * artwork (x, y in % of the image; k scales the flame to the candle's girth).
 */
const VARIANTS = {
  a: { art: 'prop-candle-a.webp', ratio: '137 / 560', x: 49.8, y: 2.7, k: 0.85 },
  b: { art: 'prop-candle-b.webp', ratio: '164 / 480', x: 50.2, y: 3.7, k: 0.98 },
  sconce: { art: 'prop-sconce.webp', ratio: '301 / 420', x: 15.5, y: 3.9, k: 0.34 },
} as const

export type CandleVariant = keyof typeof VARIANTS

type CandleProps = {
  variant?: CandleVariant
  className?: string
  style?: CSSProperties
}

export function Flame({ className = '' }: { className?: string }) {
  // Gradient ids must be unique per instance: Chrome will not resolve a paint
  // server that lives inside a display:none subtree (the wall sconces on
  // phones), and every flame would otherwise share the first one in the DOM.
  const uid = useId().replace(/:/g, '')
  const gid = (name: string) => `${name}-${uid}`
  return (
    <svg className={`flame-svg ${className}`} viewBox="0 0 60 60" aria-hidden="true">
      <defs>
        <radialGradient id={gid('fl-halo')} cx="0.5" cy="0.5" r="0.5">
          <stop offset="0" stopColor="#ffd88a" stopOpacity="0.6" />
          <stop offset="0.35" stopColor="#ff9a3c" stopOpacity="0.22" />
          <stop offset="1" stopColor="#ff7a1a" stopOpacity="0" />
        </radialGradient>
        <linearGradient id={gid('fl-outer')} x1="0" y1="1" x2="0" y2="0">
          <stop offset="0" stopColor="#ff5a12" stopOpacity="0.85" />
          <stop offset="0.45" stopColor="#ff9a2e" />
          <stop offset="0.85" stopColor="#ffd35c" />
          <stop offset="1" stopColor="#ffe9a8" stopOpacity="0.2" />
        </linearGradient>
        <linearGradient id={gid('fl-inner')} x1="0" y1="1" x2="0" y2="0">
          <stop offset="0" stopColor="#ffb44a" />
          <stop offset="0.5" stopColor="#fff1b8" />
          <stop offset="1" stopColor="#ffffff" />
        </linearGradient>
        <radialGradient id={gid('fl-blue')} cx="0.5" cy="0.7" r="0.5">
          <stop offset="0" stopColor="#7fc4ff" stopOpacity="0.95" />
          <stop offset="1" stopColor="#3b6bff" stopOpacity="0" />
        </radialGradient>
        <filter id={gid('fl-soft')} x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="1.4" />
        </filter>
        <filter id={gid('fl-wide')} x="-60%" y="-60%" width="220%" height="220%">
          <feGaussianBlur stdDeviation="5" />
        </filter>
      </defs>
      <g className="candle-halo">
        <circle cx="30" cy="40" r="28" fill={`url(#${gid('fl-halo')})`} />
      </g>
      <g className="candle-flame">
        <ellipse cx="30" cy="40" rx="9" ry="15" fill="#ff8c2a" opacity="0.35" filter={`url(#${gid('fl-wide')})`} />
        <path
          d="M30 20 C36 30 39 38 38 45 C37 51 34 54 30 54 C26 54 23 51 22 45 C21 38 24 30 30 20 Z"
          fill={`url(#${gid('fl-outer')})`}
          filter={`url(#${gid('fl-soft')})`}
        />
        <path
          d="M30 20 C36 30 39 38 38 45 C37 51 34 54 30 54 C26 54 23 51 22 45 C21 38 24 30 30 20 Z"
          fill={`url(#${gid('fl-outer')})`}
        />
        <path
          d="M30 30 C33.5 36 35 41 34.5 45.5 C34 49.5 32.2 51.5 30 51.5 C27.8 51.5 26 49.5 25.5 45.5 C25 41 26.5 36 30 30 Z"
          fill={`url(#${gid('fl-inner')})`}
          opacity="0.95"
        />
        <ellipse cx="30" cy="50" rx="5" ry="4.5" fill={`url(#${gid('fl-blue')})`} />
      </g>
    </svg>
  )
}

export function Candle({ variant = 'a', className = '', style }: CandleProps) {
  const v = VARIANTS[variant]
  const vars = {
    '--wick-x': `${v.x}%`,
    '--wick-y': `${v.y}%`,
    '--flame-k': v.k,
    '--candle-ratio': v.ratio,
    ...style,
  } as CSSProperties
  return (
    <span className={`candle candle-${variant} ${className}`} style={vars} aria-hidden="true">
      <img className="candle-art" src={asset(`art/${v.art}`)} alt="" draggable={false} />
      <Flame />
    </span>
  )
}
