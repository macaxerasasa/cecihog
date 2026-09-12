import { useId, type CSSProperties } from 'react'

type CandleProps = {
  /** Brass candlestick under the wax. Floating candles omit it. */
  holder?: boolean
  /** How far the candle has burned down, 0 (fresh) to 1 (stub). Changes wax height and drips. */
  burn?: number
  className?: string
  style?: CSSProperties
}

/**
 * A single taper: layered flame (blue root, orange body, white heart),
 * cream wax with a melted rim and drips, optional brass candlestick.
 * Drawn in a fixed 60x180 box so the flame always sits at the same
 * relative spot for alignment; wax height varies with `burn`.
 */
export function Candle({ holder = false, burn = 0.25, className = '', style }: CandleProps) {
  // Gradient ids must be unique per instance: Chrome will not resolve a paint
  // server that lives inside a display:none subtree (the wall sconces on
  // phones), and every candle used to share the first one in the DOM.
  const uid = useId().replace(/:/g, '')
  const gid = (name: string) => `${name}-${uid}`
  const waxTop = 74 + burn * 40
  const waxBottom = holder ? 138 : 168
  const waxH = waxBottom - waxTop
  const drip1 = waxTop + 6 + burn * 10
  const drip2 = waxTop + 14 + burn * 4

  return (
    <span className={`candle ${holder ? 'has-holder' : 'is-bare'} ${className}`} style={style} aria-hidden="true">
      <svg className="candle-svg" viewBox="0 0 60 180" preserveAspectRatio="xMidYMax meet">
        <defs>
          <radialGradient id={gid('cd-halo')} cx="0.5" cy="0.5" r="0.5">
            <stop offset="0" stopColor="#ffd88a" stopOpacity="0.55" />
            <stop offset="0.35" stopColor="#ff9a3c" stopOpacity="0.22" />
            <stop offset="1" stopColor="#ff7a1a" stopOpacity="0" />
          </radialGradient>
          <linearGradient id={gid('cd-wax')} x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#c9b18a" />
            <stop offset="0.22" stopColor="#f3e7cd" />
            <stop offset="0.55" stopColor="#fbf3e0" />
            <stop offset="0.8" stopColor="#e7d6b3" />
            <stop offset="1" stopColor="#b89b73" />
          </linearGradient>
          <linearGradient id={gid('cd-wax-glow')} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#ffb95a" stopOpacity="0.55" />
            <stop offset="0.45" stopColor="#ffb95a" stopOpacity="0.08" />
            <stop offset="1" stopColor="#ffb95a" stopOpacity="0" />
          </linearGradient>
          <linearGradient id={gid('cd-flame-outer')} x1="0" y1="1" x2="0" y2="0">
            <stop offset="0" stopColor="#ff5a12" stopOpacity="0.85" />
            <stop offset="0.45" stopColor="#ff9a2e" />
            <stop offset="0.85" stopColor="#ffd35c" />
            <stop offset="1" stopColor="#ffe9a8" stopOpacity="0.2" />
          </linearGradient>
          <linearGradient id={gid('cd-flame-inner')} x1="0" y1="1" x2="0" y2="0">
            <stop offset="0" stopColor="#ffb44a" />
            <stop offset="0.5" stopColor="#fff1b8" />
            <stop offset="1" stopColor="#ffffff" />
          </linearGradient>
          <radialGradient id={gid('cd-flame-blue')} cx="0.5" cy="0.7" r="0.5">
            <stop offset="0" stopColor="#7fc4ff" stopOpacity="0.95" />
            <stop offset="1" stopColor="#3b6bff" stopOpacity="0" />
          </radialGradient>
          <linearGradient id={gid('cd-brass')} x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#5a3c12" />
            <stop offset="0.25" stopColor="#c9962f" />
            <stop offset="0.5" stopColor="#ffe08a" />
            <stop offset="0.75" stopColor="#b8862a" />
            <stop offset="1" stopColor="#4d3110" />
          </linearGradient>
          <filter id={gid('cd-soft')} x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="1.6" />
          </filter>
          <filter id={gid('cd-blur-lg')} x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="6" />
          </filter>
        </defs>

        <g className="candle-halo">
          <circle cx="30" cy="58" r="30" fill={`url(#${gid('cd-halo')})`} />
        </g>

        {holder && (
          <g className="candle-holder">
            <ellipse cx="30" cy="172" rx="22" ry="5.5" fill="#1a0f06" opacity="0.6" />
            <path d="M8 168 Q30 160 52 168 L52 172 Q30 180 8 172 Z" fill={`url(#${gid('cd-brass')})`} />
            <ellipse cx="30" cy="167" rx="22" ry="5" fill={`url(#${gid('cd-brass')})`} />
            <ellipse cx="30" cy="166.4" rx="14" ry="3" fill="#2a1a08" opacity="0.5" />
            <path d="M25 165 Q23 158 27 154 L33 154 Q37 158 35 165 Z" fill={`url(#${gid('cd-brass')})`} />
            <rect x="26.5" y="146" width="7" height="9" rx="1.5" fill={`url(#${gid('cd-brass')})`} />
            <ellipse cx="30" cy="146" rx="6.5" ry="2" fill="#f0c860" opacity="0.9" />
            <path d="M18 140 Q30 136 42 140 L42 143 Q30 147 18 143 Z" fill={`url(#${gid('cd-brass')})`} />
            <ellipse cx="30" cy="139.6" rx="12" ry="3.2" fill={`url(#${gid('cd-brass')})`} />
            <ellipse cx="30" cy="139.2" rx="7.5" ry="1.9" fill="#3a2410" opacity="0.6" />
          </g>
        )}

        <g className="candle-wax">
          <rect x="20" y={waxTop} width="20" height={waxH} rx="2.2" fill={`url(#${gid('cd-wax')})`} />
          <rect x="20" y={waxTop} width="20" height={waxH} rx="2.2" fill={`url(#${gid('cd-wax-glow')})`} />
          <path
            d={`M22 ${drip1} q-2 6 0.5 12 q2.5 4 1.5 -8 z`}
            fill="#f7edd6"
            opacity="0.95"
          />
          <path
            d={`M37 ${drip2} q2 5 0 11 q-2 3 -1 -6 z`}
            fill="#efe1c3"
            opacity="0.9"
          />
          <path
            d={`M20.5 ${waxTop + 1} q9.5 -4 19 0 q-1.5 4 -9.5 5 q-8 -1 -9.5 -5 z`}
            fill="#e9d9b6"
          />
          <ellipse cx="30" cy={waxTop + 1.6} rx="7.5" ry="2.2" fill="#ffd47a" opacity="0.7" />
          <ellipse cx="30" cy={waxTop + 1.2} rx="5" ry="1.4" fill="#fff1c7" opacity="0.8" />
        </g>

        <path
          d={`M30 ${waxTop} q0.5 -4 -0.8 -8`}
          stroke="#2a1a0c"
          strokeWidth="1.6"
          strokeLinecap="round"
          fill="none"
        />
        <circle cx="29.2" cy={waxTop - 8} r="1.1" fill="#ff8a2a" />

        <g className="candle-flame" style={{ transformOrigin: `30px ${waxTop - 2}px` }}>
          <g transform={`translate(0 ${waxTop - 74})`}>
            <ellipse cx="30" cy="58" rx="9" ry="16" fill="#ff8c2a" opacity="0.35" filter={`url(#${gid('cd-blur-lg')})`} />
            <path
              d="M30 40 C36 50 39 58 38 65 C37 71 34 74 30 74 C26 74 23 71 22 65 C21 58 24 50 30 40 Z"
              fill={`url(#${gid('cd-flame-outer')})`}
              filter={`url(#${gid('cd-soft')})`}
            />
            <path
              d="M30 40 C36 50 39 58 38 65 C37 71 34 74 30 74 C26 74 23 71 22 65 C21 58 24 50 30 40 Z"
              fill={`url(#${gid('cd-flame-outer')})`}
            />
            <path
              d="M30 50 C33.5 56 35 61 34.5 65.5 C34 69.5 32.2 71.5 30 71.5 C27.8 71.5 26 69.5 25.5 65.5 C25 61 26.5 56 30 50 Z"
              fill={`url(#${gid('cd-flame-inner')})`}
              opacity="0.95"
            />
            <ellipse cx="30" cy="70" rx="5" ry="4.5" fill={`url(#${gid('cd-flame-blue')})`} />
          </g>
        </g>
      </svg>
    </span>
  )
}
