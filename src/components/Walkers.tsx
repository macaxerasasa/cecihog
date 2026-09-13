import { memo, useEffect, useRef, useState, type CSSProperties } from 'react'
import { walks, type Frame, type Walk } from '../data/map'

/*
 * Footprints that betray whoever is out of bed. Nothing glides: each walker
 * lays one print per step along its route — left, right, left — and the
 * prints stay where they landed, fading as newer ones appear ahead, while
 * the name banner drifts along behind the freshest pair. Steps are timed
 * with setTimeout, so an idle map costs nothing between them.
 */
const KEEP = 9

type Print = { id: number; x: number; y: number; a: number }
type Pose = { prints: Print[]; tag: { x: number; y: number } }

export const Walkers = memo(function Walkers({ frame, lite, paused }: { frame: Frame; lite: boolean; paused: boolean }) {
  const list = lite ? walks[frame].slice(0, 2) : walks[frame]
  return (
    <g className="walkers" aria-hidden="true">
      {list.map((w, i) => (
        <Walker key={`${frame}-${w.name}`} walk={w} seed={i} paused={paused} />
      ))}
    </g>
  )
})

function Walker({ walk, seed, paused }: { walk: Walk; seed: number; paused: boolean }) {
  const guide = useRef<SVGPathElement>(null)
  const sim = useRef({ dist: 0, side: 1, id: 0, primed: false })
  const [pose, setPose] = useState<Pose | null>(null)

  useEffect(() => {
    const path = guide.current
    if (!path) return
    const total = path.getTotalLength()
    const s = sim.current
    if (!s.primed) {
      // start somewhere along the route, so the three do not set off together
      s.dist = ((seed * 0.37 + 0.11) % 1) * total
      s.primed = true
    }

    const step = (): Print => {
      let stride = walk.stride
      if (walk.restless && Math.random() < 0.08) stride *= 3 // Peeves hops ahead
      s.dist = (s.dist + stride) % total
      const p = path.getPointAtLength(s.dist)
      const q = path.getPointAtLength((s.dist + 1.5) % total)
      let a = Math.atan2(q.y - p.y, q.x - p.x)
      s.side = -s.side
      let spread = walk.gait === 'paw' ? 3.5 : 7
      if (walk.restless) {
        spread += Math.random() * 14
        a += ((Math.random() - 0.5) * 50 * Math.PI) / 180
      } else {
        a += ((Math.random() - 0.5) * 8 * Math.PI) / 180
      }
      return {
        id: s.id++,
        x: p.x + Math.cos(a + Math.PI / 2) * spread * s.side,
        y: p.y + Math.sin(a + Math.PI / 2) * spread * s.side,
        a: (a * 180) / Math.PI,
      }
    }
    const lay = (prev: Pose | null, print: Print): Pose => {
      const prints = [...(prev?.prints ?? []).slice(-(KEEP - 1)), print]
      // the banner rides between the two freshest prints, a little ahead
      const last = prints[prints.length - 2] ?? print
      return { prints, tag: { x: (print.x + last.x) / 2, y: (print.y + last.y) / 2 } }
    }

    // a few prints already on the parchment when the map is drawn
    setPose((prev) => {
      if (prev) return prev
      let pose: Pose | null = null
      for (let i = 0; i < 4; i++) pose = lay(pose, step())
      return pose
    })

    if (paused) return
    let timer = 0
    const [lo, hi] = walk.cadence
    const tick = () => {
      setPose((prev) => lay(prev, step()))
      let wait = lo + Math.random() * (hi - lo)
      if (Math.random() < walk.rest) wait += 1200 + Math.random() * 1800 // stops to listen, or to sit
      timer = window.setTimeout(tick, wait)
    }
    timer = window.setTimeout(tick, lo + Math.random() * (hi - lo))
    return () => window.clearTimeout(timer)
  }, [walk, seed, paused])

  const tagW = walk.name.length * 9.2 + 26
  const n = pose?.prints.length ?? 0
  return (
    <g className={`walker gait-${walk.gait}`}>
      <path ref={guide} className="walk-guide" d={walk.path} />
      {pose?.prints.map((p, i) => (
        <g
          key={p.id}
          className="print"
          data-age={n - 1 - i}
          transform={`translate(${p.x.toFixed(1)} ${p.y.toFixed(1)}) rotate(${(p.a + 90).toFixed(1)})`}
        >
          <g className="print-ink">
            {walk.gait === 'paw' ? (
              <use href="#paw" x="-4.5" y="-4.5" width="9" height="9" />
            ) : (
              <use href="#foot" x="-6" y="-11" width="12" height="22" />
            )}
          </g>
        </g>
      ))}
      {pose ? (
        <g
          className="walker-tag"
          style={{ transform: `translate(${pose.tag.x.toFixed(1)}px, ${pose.tag.y.toFixed(1)}px)` } as CSSProperties}
        >
          <path className="tag-ribbon" d={ribbon(tagW, 24)} transform={`translate(${-tagW / 2}, -48)`} />
          <text className="tag-name" x="0" y="-31" textAnchor="middle">
            {walk.name}
          </text>
        </g>
      ) : null}
    </g>
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
