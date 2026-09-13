import { useEffect, useRef, useState, type CSSProperties } from 'react'

type Print = { id: number; x: number; y: number; a: number }

const MAX = 14
const STRIDE = 36

/*
 * The map knows where the reader is: on fine pointers a pair of footprints
 * follows the wand across the parchment under a banner that reads "Você",
 * and the wand's light warms the paper around it. Prints are spawned every
 * STRIDE px of travel and fade on their own; the banner and the light are
 * moved with one transform write per frame.
 */
export function YourSteps({ paused }: { paused: boolean }) {
  const [prints, setPrints] = useState<Print[]>([])
  const [seen, setSeen] = useState(false)
  const tagRef = useRef<HTMLDivElement>(null)
  const lightRef = useRef<HTMLDivElement>(null)
  const pausedRef = useRef(paused)
  pausedRef.current = paused

  useEffect(() => {
    let last: { x: number; y: number } | null = null
    let acc = 0
    let side = 1
    let id = 0
    let raf = 0
    const target = { x: window.innerWidth / 2, y: window.innerHeight / 2 }
    const cur = { ...target }

    const tick = () => {
      raf = 0
      cur.x += (target.x - cur.x) * 0.2
      cur.y += (target.y - cur.y) * 0.2
      const t = `translate(${cur.x.toFixed(1)}px, ${cur.y.toFixed(1)}px)`
      if (tagRef.current) tagRef.current.style.transform = t
      if (lightRef.current) lightRef.current.style.transform = t
      if (Math.abs(target.x - cur.x) > 0.4 || Math.abs(target.y - cur.y) > 0.4) raf = requestAnimationFrame(tick)
    }

    const onMove = (e: PointerEvent) => {
      // only a mouse leaves prints: a finger is already on the parchment
      if (e.pointerType !== 'mouse') return
      target.x = e.clientX
      target.y = e.clientY
      if (!raf) raf = requestAnimationFrame(tick)
      if (!last) {
        last = { x: e.clientX, y: e.clientY }
        cur.x = e.clientX
        cur.y = e.clientY
        setSeen(true)
        return
      }
      if (pausedRef.current) {
        last = { x: e.clientX, y: e.clientY }
        return
      }
      const dx = e.clientX - last.x
      const dy = e.clientY - last.y
      acc += Math.hypot(dx, dy)
      if (acc >= STRIDE) {
        acc = 0
        side = -side
        const a = Math.atan2(dy, dx)
        const p: Print = {
          id: id++,
          x: e.clientX + Math.cos(a + Math.PI / 2) * 7 * side,
          y: e.clientY + Math.sin(a + Math.PI / 2) * 7 * side,
          a,
        }
        setPrints((ps) => [...ps.slice(-(MAX - 1)), p])
      }
      last = { x: e.clientX, y: e.clientY }
    }

    window.addEventListener('pointermove', onMove, { passive: true })
    return () => {
      window.removeEventListener('pointermove', onMove)
      cancelAnimationFrame(raf)
    }
  }, [])

  return (
    <div className={`your-steps ${paused || !seen ? 'is-hidden' : ''}`} aria-hidden="true">
      <div ref={lightRef} className="wandlight" />
      {prints.map((p) => (
        <svg
          key={p.id}
          className="your-print"
          viewBox="-8 -14 16 28"
          style={{ '--x': `${p.x}px`, '--y': `${p.y}px`, '--a': `${(p.a * 180) / Math.PI + 90}deg` } as CSSProperties}
        >
          <use href="#foot" />
        </svg>
      ))}
      <div ref={tagRef} className="your-tag">
        <span>Você</span>
      </div>
    </div>
  )
}
