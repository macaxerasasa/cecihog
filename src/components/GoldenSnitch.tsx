import { useEffect, useRef } from 'react'
import { usePrefersReducedMotion } from '../hooks/usePrefersReducedMotion'

export function GoldenSnitch() {
  const ref = useRef<HTMLDivElement>(null)
  const reduced = usePrefersReducedMotion()

  useEffect(() => {
    const el = ref.current
    if (!el) return

    const pos = {
      x: window.innerWidth * 0.72,
      y: window.innerHeight * 0.28,
    }
    const vel = { x: 1.1, y: 0.4 }
    const mouse = { x: -2000, y: -2000 }

    const onMove = (e: PointerEvent) => {
      mouse.x = e.clientX
      mouse.y = e.clientY
    }
    window.addEventListener('pointermove', onMove)

    let raf = 0
    const tick = () => {
      const pad = 32
      const w = window.innerWidth
      const h = window.innerHeight
      const dx = pos.x - mouse.x
      const dy = pos.y - mouse.y
      const dist = Math.hypot(dx, dy) || 1

      if (!reduced && dist < 170) {
        const force = ((170 - dist) / 170) * 2.8
        vel.x += (dx / dist) * force
        vel.y += (dy / dist) * force
      }

      vel.x += (Math.random() - 0.5) * (reduced ? 0.04 : 0.18)
      vel.y += (Math.random() - 0.5) * (reduced ? 0.03 : 0.16)
      vel.x *= 0.94
      vel.y *= 0.94

      const speed = Math.hypot(vel.x, vel.y)
      const max = reduced ? 1.6 : 10
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

      el.style.transform = `translate(${pos.x}px, ${pos.y}px) rotate(${vel.x * 3.2}deg)`
      raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)

    return () => {
      cancelAnimationFrame(raf)
      window.removeEventListener('pointermove', onMove)
    }
  }, [reduced])

  return (
    <div className="snitch" ref={ref} aria-hidden="true">
      <svg viewBox="0 0 80 40" className="snitch-svg">
        <g className="snitch-wing is-left">
          <path
            d="M36 20 C 22 8, 8 6, 4 14 C 10 12, 18 16, 28 22 C 18 18, 8 22, 6 28 C 14 22, 26 22, 36 20"
            fill="url(#snitchMetal)"
          />
        </g>
        <g className="snitch-wing is-right">
          <path
            d="M44 20 C 58 8, 72 6, 76 14 C 70 12, 62 16, 52 22 C 62 18, 72 22, 74 28 C 66 22, 54 22, 44 20"
            fill="url(#snitchMetal)"
          />
        </g>
        <defs>
          <radialGradient id="snitchGold" cx="35%" cy="30%">
            <stop offset="0%" stopColor="#fff6d0" />
            <stop offset="45%" stopColor="#e8c24a" />
            <stop offset="100%" stopColor="#8a5a10" />
          </radialGradient>
          <linearGradient id="snitchMetal" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#f7f1dc" />
            <stop offset="50%" stopColor="#d4c48a" />
            <stop offset="100%" stopColor="#9a8048" />
          </linearGradient>
        </defs>
        <circle cx="40" cy="20" r="8.2" fill="url(#snitchGold)" />
        <circle cx="37.5" cy="17.6" r="2.2" fill="rgba(255,255,255,0.45)" />
      </svg>
    </div>
  )
}
