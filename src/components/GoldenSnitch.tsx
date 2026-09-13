import { useEffect, useRef, type CSSProperties } from 'react'
import { usePrefersReducedMotion } from '../hooks/usePrefersReducedMotion'
import { asset } from '../lib/asset'

const TRAIL = 9
/* The flight is simulated in fixed 60 Hz steps and the sprite is drawn at the
   screen's refresh rate, interpolating between steps: the snitch covers the
   same ground per second whether the page is running at 30, 60 or 120 fps,
   instead of crawling whenever the frame rate dips. */
const STEP = 1000 / 60
const MAX_STEPS = 4
const WING_L = asset('snitch/wing-left.png')
const WING_R = asset('snitch/wing-right.png')
const ghostL = { '--wing': `url(${WING_L})` } as CSSProperties
const ghostR = { '--wing': `url(${WING_R})` } as CSSProperties

export default function GoldenSnitch({ paused = false }: { paused?: boolean }) {
  const ref = useRef<HTMLDivElement>(null)
  const trailRef = useRef<HTMLDivElement>(null)
  const pausedRef = useRef(paused)
  pausedRef.current = paused
  const reduced = usePrefersReducedMotion()

  useEffect(() => {
    const el = ref.current
    const trail = trailRef.current
    if (!el || !trail) return
    const sparks = Array.from(trail.children) as HTMLElement[]

    const pos = { x: window.innerWidth * 0.72, y: window.innerHeight * 0.28 }
    const prev = { ...pos }
    const vel = { x: 1.1, y: 0.4 }
    const mouse = { x: -2000, y: -2000 }
    const history: { x: number; y: number }[] = []
    let dartCooldown = 240
    let t = 0

    const onMove = (e: PointerEvent) => {
      mouse.x = e.clientX
      mouse.y = e.clientY
    }
    window.addEventListener('pointermove', onMove)

    let raf = 0
    let last = 0
    let acc = STEP // first frame runs a step right away, as before
    let speed = 0
    const step = () => {
      t += 1
      prev.x = pos.x
      prev.y = pos.y
      const pad = 40
      const w = window.innerWidth
      const h = window.innerHeight
      const dx = pos.x - mouse.x
      const dy = pos.y - mouse.y
      const dist = Math.hypot(dx, dy) || 1

      if (!reduced && dist < 190) {
        const force = ((190 - dist) / 190) * 3.2
        vel.x += (dx / dist) * force
        vel.y += (dy / dist) * force
      }

      // Sudden darts, the way a snitch feints and bolts.
      dartCooldown -= 1
      if (!reduced && dartCooldown <= 0) {
        const a = Math.random() * Math.PI * 2
        const p = 5 + Math.random() * 5
        vel.x += Math.cos(a) * p
        vel.y += Math.sin(a) * p * 0.6
        dartCooldown = 160 + Math.random() * 260
      }

      vel.x += (Math.random() - 0.5) * (reduced ? 0.04 : 0.2)
      vel.y += (Math.random() - 0.5) * (reduced ? 0.03 : 0.18)
      // Hover bob when idle.
      vel.y += Math.sin(t / 18) * 0.05
      vel.x *= 0.935
      vel.y *= 0.935

      speed = Math.hypot(vel.x, vel.y)
      const max = reduced ? 1.6 : 12
      if (speed > max) {
        vel.x = (vel.x / speed) * max
        vel.y = (vel.y / speed) * max
      }
      if (speed < 0.35) {
        vel.x += 0.22
        vel.y -= 0.08
      }

      pos.x += vel.x
      pos.y += vel.y
      if (pos.x < pad) {
        pos.x = pad
        vel.x = Math.abs(vel.x) + 0.4
      }
      if (pos.y < pad) {
        pos.y = pad
        vel.y = Math.abs(vel.y) + 0.4
      }
      if (pos.x > w - pad) {
        pos.x = w - pad
        vel.x = -Math.abs(vel.x) - 0.4
      }
      if (pos.y > h - pad) {
        pos.y = h - pad
        vel.y = -Math.abs(vel.y) - 0.4
      }

      history.unshift({ x: pos.x, y: pos.y })
      if (history.length > TRAIL * 3) history.pop()
    }

    const tick = (now: number) => {
      raf = requestAnimationFrame(tick)
      if (pausedRef.current || document.visibilityState !== 'visible') {
        last = 0
        return
      }
      if (!last) last = now
      // a long gap (hidden tab, a stall) is not paid back as a burst of catch-up
      acc = Math.min(acc + (now - last), STEP * MAX_STEPS)
      last = now
      let steps = 0
      while (acc >= STEP && steps < MAX_STEPS) {
        step()
        acc -= STEP
        steps++
      }
      if (t === 0) return

      const k = acc / STEP
      const x = prev.x + (pos.x - prev.x) * k
      const y = prev.y + (pos.y - prev.y) * k
      const bank = Math.max(-28, Math.min(28, vel.x * 2.6))
      const pitch = Math.max(-10, Math.min(10, vel.y * 1.4))
      el.style.transform = `translate(${x}px, ${y}px) rotate(${bank + pitch}deg)`

      if (!steps) return
      const glow = Math.min(1, speed / 4)
      sparks.forEach((s, i) => {
        const p = history[Math.min(history.length - 1, (i + 1) * 3)]
        if (!p) return
        const k = 1 - i / TRAIL
        s.style.transform = `translate(${p.x}px, ${p.y}px) scale(${0.35 + k * 0.65})`
        s.style.opacity = String(k * 0.85 * glow)
      })
    }
    raf = requestAnimationFrame(tick)

    return () => {
      cancelAnimationFrame(raf)
      window.removeEventListener('pointermove', onMove)
    }
  }, [reduced])

  return (
    <>
      <div className="snitch-trail" ref={trailRef} aria-hidden="true">
        {Array.from({ length: TRAIL }).map((_, i) => (
          <span key={i} className="snitch-spark" style={{ '--i': i } as CSSProperties} />
        ))}
      </div>
      <div className="snitch" ref={ref} aria-hidden="true">
        <span className="snitch-aura" />
        <span className="snitch-wing-ghost is-far is-left" style={ghostL} />
        <span className="snitch-wing-ghost is-far is-right" style={ghostR} />
        <span className="snitch-wing-ghost is-left" style={ghostL} />
        <span className="snitch-wing-ghost is-right" style={ghostR} />
        <img className="snitch-wing is-left" src={WING_L} alt="" draggable={false} />
        <img className="snitch-wing is-right" src={WING_R} alt="" draggable={false} />
        <img className="snitch-ball" src={asset('snitch/ball.png')} alt="" draggable={false} />
        <span className="snitch-shine" />
      </div>
    </>
  )
}

