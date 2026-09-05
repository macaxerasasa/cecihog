import { useEffect, useRef, type CSSProperties } from 'react'
import { usePrefersReducedMotion } from '../hooks/usePrefersReducedMotion'

const TRAIL = 9

export function GoldenSnitch() {
  const ref = useRef<HTMLDivElement>(null)
  const trailRef = useRef<HTMLDivElement>(null)
  const reduced = usePrefersReducedMotion()

  useEffect(() => {
    const el = ref.current
    const trail = trailRef.current
    if (!el || !trail) return
    const sparks = Array.from(trail.children) as HTMLElement[]

    const pos = { x: window.innerWidth * 0.72, y: window.innerHeight * 0.28 }
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
    const tick = () => {
      t += 1
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

      const speed = Math.hypot(vel.x, vel.y)
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

      const bank = Math.max(-28, Math.min(28, vel.x * 2.6))
      const pitch = Math.max(-10, Math.min(10, vel.y * 1.4))
      el.style.transform = `translate(${pos.x}px, ${pos.y}px) rotate(${bank + pitch}deg)`
      el.style.setProperty('--speed', String(Math.min(1, speed / max)))

      history.unshift({ x: pos.x, y: pos.y })
      if (history.length > TRAIL * 3) history.pop()
      sparks.forEach((s, i) => {
        const p = history[Math.min(history.length - 1, (i + 1) * 3)]
        if (!p) return
        const k = 1 - i / TRAIL
        s.style.transform = `translate(${p.x}px, ${p.y}px) scale(${0.35 + k * 0.65})`
        s.style.opacity = String(k * 0.85 * Math.min(1, speed / 4))
      })

      raf = requestAnimationFrame(tick)
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
        <span className="snitch-wing-ghost is-left" style={{ backgroundImage: 'url(/snitch/wing-left.png)' }} />
        <span className="snitch-wing-ghost is-right" style={{ backgroundImage: 'url(/snitch/wing-right.png)' }} />
        <img className="snitch-wing is-left" src="/snitch/wing-left.png" alt="" draggable={false} />
        <img className="snitch-wing is-right" src="/snitch/wing-right.png" alt="" draggable={false} />
        <img className="snitch-ball" src="/snitch/ball.png" alt="" draggable={false} />
        <span className="snitch-shine" />
      </div>
    </>
  )
}

