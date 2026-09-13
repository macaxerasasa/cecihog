import { memo, type CSSProperties } from 'react'
import { Candle } from './Candle'

/* Iron scroll-arm sconces on the stone wall, one on each side at the same height. */
export const WallSconces = memo(function WallSconces() {
  return (
    <div className="wall-sconces" aria-hidden="true">
      {(['left', 'right'] as const).map((side, i) => (
        <div key={side} className={`wall-sconce ${side}`}>
          <Candle
            variant="sconce"
            className="sconce-candle"
            style={{ '--flicker-delay': `${-1.4 * i}s` } as CSSProperties}
          />
        </div>
      ))}
    </div>
  )
})
