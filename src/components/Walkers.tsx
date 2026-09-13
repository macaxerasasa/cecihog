import { memo, type CSSProperties } from 'react'
import { walks, type Frame } from '../data/map'

/*
 * Footprints that wander the corridors with a name banner, the way the map
 * betrays whoever is out of bed. Each walker is a few `<g>` elements riding
 * the same motion path: the feet turn with the corridor, the banner stays
 * upright, and three lagging copies leave the fading trail.
 */
const TRAIL = [0.5, 0.3, 0.15]

export const Walkers = memo(function Walkers({ frame, lite }: { frame: Frame; lite: boolean }) {
  const list = lite ? walks[frame].slice(0, 1) : walks[frame]
  return (
    <g className="walkers" aria-hidden="true">
      {list.map((w, i) => {
        const ride = {
          offsetPath: `path("${w.path}")`,
          '--t': `${w.seconds}s`,
          '--o': `${-(i * 17 + 3)}s`,
        } as CSSProperties
        const tagW = w.name.length * 9.2 + 26
        return (
          <g key={w.name} className="walker">
            {!lite
              ? TRAIL.map((o, k) => (
                  <g
                    key={k}
                    className="walker-feet is-trail"
                    style={{ ...ride, '--lag': `${-(k + 1) * 1.1}s`, opacity: o } as CSSProperties}
                  >
                    <Feet />
                  </g>
                ))
              : null}
            <g className="walker-feet" style={ride}>
              <Feet />
            </g>
            <g className="walker-tag" style={ride}>
              <path className="tag-ribbon" d={ribbon(tagW, 24)} transform={`translate(${-tagW / 2}, -48)`} />
              <text className="tag-name" x="0" y="-31" textAnchor="middle">
                {w.name}
              </text>
            </g>
          </g>
        )
      })}
    </g>
  )
})

/* Two feet astride the path; the glyph's toes point -y, so each is turned
   to face +x, the direction offset-rotate carries the group in. */
function Feet() {
  return (
    <>
      <g className="foot l" transform="translate(0 -9) rotate(90)">
        <use href="#foot" x="-7" y="-13" width="14" height="26" />
      </g>
      <g className="foot r" transform="translate(0 9) rotate(90)">
        <use href="#foot" x="-7" y="-13" width="14" height="26" />
      </g>
    </>
  )
}

/** A scroll banner with forked tails, drawn in a w × h box from (0, 0). */
export function ribbon(w: number, h: number) {
  const t = h * 0.42 // tail depth
  const n = h * 0.5 // notch
  return [
    `M ${t} 0 H ${w - t}`,
    `L ${w} 0 L ${w - n * 0.6} ${h / 2} L ${w} ${h} L ${w - t} ${h}`,
    `H ${t}`,
    `L 0 ${h} L ${n * 0.6} ${h / 2} L 0 0 Z`,
  ].join(' ')
}
