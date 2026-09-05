import type { CSSProperties } from 'react'
import { Candle } from './Candle'

function Bracket() {
  return (
    <svg className="sconce-bracket" viewBox="0 0 80 120" aria-hidden="true">
      <defs>
        <linearGradient id="sc-iron" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#1b1410" />
          <stop offset="0.4" stopColor="#4a3a2c" />
          <stop offset="0.6" stopColor="#6b563f" />
          <stop offset="1" stopColor="#1b1410" />
        </linearGradient>
        <linearGradient id="sc-brass" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#5a3c12" />
          <stop offset="0.35" stopColor="#d3a23a" />
          <stop offset="0.55" stopColor="#ffe08a" />
          <stop offset="1" stopColor="#5a3c12" />
        </linearGradient>
      </defs>
      {/* wall plate */}
      <path d="M32 46 L48 46 L52 54 L52 96 L48 104 L32 104 L28 96 L28 54 Z" fill="url(#sc-iron)" />
      <path d="M40 50 L46 56 L40 62 L34 56 Z" fill="#8a6b3c" opacity="0.7" />
      <circle cx="40" cy="92" r="2.4" fill="#8a6b3c" />
      {/* scroll arm */}
      <path
        d="M40 70 C18 70 12 44 26 34 C34 28 44 34 40 42 C37 47 31 44 33 39"
        stroke="url(#sc-iron)"
        strokeWidth="4.5"
        strokeLinecap="round"
        fill="none"
      />
      <path
        d="M40 70 C18 70 12 44 26 34"
        stroke="rgba(255,220,150,0.35)"
        strokeWidth="1.2"
        strokeLinecap="round"
        fill="none"
      />
      {/* drip pan + cup */}
      <ellipse cx="26" cy="30" rx="16" ry="4.5" fill="url(#sc-brass)" />
      <ellipse cx="26" cy="29.4" rx="10" ry="2.6" fill="#2a1a08" opacity="0.6" />
      <path d="M18 30 L34 30 L32 22 L20 22 Z" fill="url(#sc-brass)" />
    </svg>
  )
}

/* Iron scroll-arm sconces on the stone wall, one on each side at the same height. */
export function WallSconces() {
  return (
    <div className="wall-sconces" aria-hidden="true">
      {(['left', 'right'] as const).map((side, i) => (
        <div key={side} className={`wall-sconce ${side}`}>
          <Bracket />
          <Candle
            burn={0.35}
            className="sconce-candle"
            style={{ '--flicker-delay': `${-1.4 * i}s` } as CSSProperties}
          />
        </div>
      ))}
    </div>
  )
}
