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
        <svg viewBox="0 0 120 64" className="snitch-svg">
          <defs>
            <radialGradient id="sn-ball" cx="0.36" cy="0.3" r="0.72">
              <stop offset="0" stopColor="#fff9e0" />
              <stop offset="0.25" stopColor="#ffe08a" />
              <stop offset="0.55" stopColor="#d9a53a" />
              <stop offset="0.82" stopColor="#8a5a12" />
              <stop offset="1" stopColor="#4a2d06" />
            </radialGradient>
            <radialGradient id="sn-rim" cx="0.5" cy="0.5" r="0.5">
              <stop offset="0.78" stopColor="#ffd97a" stopOpacity="0" />
              <stop offset="0.93" stopColor="#ffe9a8" stopOpacity="0.55" />
              <stop offset="1" stopColor="#fff6d6" stopOpacity="0" />
            </radialGradient>
            <linearGradient id="sn-band" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0" stopColor="#5a3a0c" />
              <stop offset="0.4" stopColor="#ffe9a6" />
              <stop offset="0.6" stopColor="#c8912a" />
              <stop offset="1" stopColor="#4a2d06" />
            </linearGradient>
            <linearGradient id="sn-feather" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0" stopColor="#fbf6e6" stopOpacity="0.95" />
              <stop offset="0.5" stopColor="#e7dcb8" stopOpacity="0.75" />
              <stop offset="1" stopColor="#bfae7c" stopOpacity="0.35" />
            </linearGradient>
            <linearGradient id="sn-vein" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0" stopColor="#8a7644" stopOpacity="0.9" />
              <stop offset="1" stopColor="#8a7644" stopOpacity="0" />
            </linearGradient>
            <filter id="sn-glow" x="-60%" y="-60%" width="220%" height="220%">
              <feGaussianBlur stdDeviation="3.5" />
            </filter>
            <filter id="sn-wingblur" x="-20%" y="-40%" width="140%" height="180%">
              <feGaussianBlur stdDeviation="0.5" />
            </filter>
          </defs>

          <circle cx="60" cy="32" r="16" fill="#ffb638" opacity="0.5" filter="url(#sn-glow)" />

          <g className="snitch-wing is-left" filter="url(#sn-wingblur)">
            <path
              d="M46 31 C 36 20, 20 10, 4 12 C 8 16, 14 18, 20 20 C 12 20, 6 24, 2 30 C 8 28, 16 27, 24 27 C 16 30, 10 35, 8 42 C 16 36, 26 33, 36 33 C 30 38, 28 44, 30 50 C 34 42, 40 36, 46 33 Z"
              fill="url(#sn-feather)"
            />
            <path d="M46 31 C 36 22, 24 15, 8 13" stroke="url(#sn-vein)" strokeWidth="1" fill="none" />
            <path d="M46 31 C 34 27, 22 26, 6 29" stroke="url(#sn-vein)" strokeWidth="0.9" fill="none" />
            <path d="M46 32 C 36 32, 24 34, 12 40" stroke="url(#sn-vein)" strokeWidth="0.9" fill="none" />
            <path d="M46 33 C 40 36, 34 40, 31 48" stroke="url(#sn-vein)" strokeWidth="0.8" fill="none" />
            <path d="M46 30 C 40 26, 34 24, 28 23" stroke="#fffaf0" strokeWidth="0.6" opacity="0.7" fill="none" />
          </g>
          <g className="snitch-wing is-right" filter="url(#sn-wingblur)">
            <path
              d="M74 31 C 84 20, 100 10, 116 12 C 112 16, 106 18, 100 20 C 108 20, 114 24, 118 30 C 112 28, 104 27, 96 27 C 104 30, 110 35, 112 42 C 104 36, 94 33, 84 33 C 90 38, 92 44, 90 50 C 86 42, 80 36, 74 33 Z"
              fill="url(#sn-feather)"
            />
            <path d="M74 31 C 84 22, 96 15, 112 13" stroke="url(#sn-vein)" strokeWidth="1" fill="none" />
            <path d="M74 31 C 86 27, 98 26, 114 29" stroke="url(#sn-vein)" strokeWidth="0.9" fill="none" />
            <path d="M74 32 C 84 32, 96 34, 108 40" stroke="url(#sn-vein)" strokeWidth="0.9" fill="none" />
            <path d="M74 33 C 80 36, 86 40, 89 48" stroke="url(#sn-vein)" strokeWidth="0.8" fill="none" />
            <path d="M74 30 C 80 26, 86 24, 92 23" stroke="#fffaf0" strokeWidth="0.6" opacity="0.7" fill="none" />
          </g>

          {/* wing sockets */}
          <ellipse cx="47" cy="32" rx="3" ry="4.5" fill="url(#sn-band)" />
          <ellipse cx="73" cy="32" rx="3" ry="4.5" fill="url(#sn-band)" />

          {/* ball */}
          <circle cx="60" cy="32" r="14" fill="url(#sn-ball)" />
          <circle cx="60" cy="32" r="14" fill="url(#sn-rim)" />
          {/* engraved meridians */}
          <path d="M60 18 C 52 22, 52 42, 60 46" stroke="#7a4d0c" strokeWidth="0.8" opacity="0.65" fill="none" />
          <path d="M60 18 C 68 22, 68 42, 60 46" stroke="#7a4d0c" strokeWidth="0.8" opacity="0.65" fill="none" />
          <path d="M60 18 C 56 24, 56 40, 60 46" stroke="#ffe9a8" strokeWidth="0.5" opacity="0.55" fill="none" />
          {/* equator band with rivets */}
          <path d="M46.3 30 Q60 36 73.7 30 Q60 40 46.3 30 Z" fill="url(#sn-band)" opacity="0.95" />
          <path d="M46.3 30 Q60 36 73.7 30" stroke="#5a3a0c" strokeWidth="0.5" fill="none" opacity="0.8" />
          {[50, 55, 60, 65, 70].map((x) => (
            <circle key={x} cx={x} cy={32.6 + Math.abs(60 - x) * -0.12} r="0.75" fill="#fff4c8" opacity="0.9" />
          ))}
          {/* filigree scrolls on the upper hemisphere */}
          <path
            d="M53 26 q3 -4 6 -1 q3 3 6 -1"
            stroke="#fff1c4"
            strokeWidth="0.7"
            fill="none"
            opacity="0.75"
          />
          <path
            d="M55 40 q2.5 3 5 0.5 q2.5 -2.5 5 0.5"
            stroke="#5a3a0c"
            strokeWidth="0.6"
            fill="none"
            opacity="0.6"
          />
          {/* specular */}
          <ellipse cx="55" cy="25.5" rx="4.2" ry="2.6" fill="#fff" opacity="0.7" transform="rotate(-30 55 25.5)" />
          <circle cx="66" cy="39" r="1.6" fill="#fff6d6" opacity="0.35" />
        </svg>
      </div>
    </>
  )
}
