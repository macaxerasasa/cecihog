import { memo, useEffect, useRef } from 'react'

type Particle = {
  x: number
  y: number
  r: number
  s: number
  a: number
  vx: number
  vy: number
}

export const Particles = memo(function Particles({ active }: { active: boolean }) {
  const ref = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = ref.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    let raf = 0
    const dots: Particle[] = []
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    const lite = window.matchMedia('(max-width: 740px), (pointer: coarse)').matches
    const count = reduced ? 12 : lite ? 18 : 42

    const resize = () => {
      canvas.width = window.innerWidth * devicePixelRatio
      canvas.height = window.innerHeight * devicePixelRatio
      canvas.style.width = `${window.innerWidth}px`
      canvas.style.height = `${window.innerHeight}px`
      ctx.setTransform(1, 0, 0, 1, 0, 0)
      ctx.scale(devicePixelRatio, devicePixelRatio)
    }

    const spawn = (): Particle => ({
      x: Math.random() * window.innerWidth,
      y: Math.random() * window.innerHeight,
      r: Math.random() * 1.4 + 0.3,
      s: Math.random() * 0.25 + 0.05,
      a: Math.random() * 0.35 + 0.05,
      vx: (Math.random() - 0.5) * 0.15,
      vy: -Math.random() * 0.22 - 0.02,
    })

    for (let i = 0; i < count; i++) dots.push(spawn())
    resize()
    window.addEventListener('resize', resize)

    const tick = () => {
      ctx.clearRect(0, 0, window.innerWidth, window.innerHeight)
      if (active) {
        for (const d of dots) {
          d.x += d.vx
          d.y += d.vy
          d.a += Math.sin(d.y * 0.01) * 0.0008
          if (d.y < -4 || d.x < -4 || d.x > window.innerWidth + 4) {
            Object.assign(d, spawn(), { y: window.innerHeight + 2 })
          }
          ctx.beginPath()
          ctx.fillStyle = `rgba(255, 214, 150, ${Math.max(0.04, Math.min(0.4, d.a))})`
          ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2)
          ctx.fill()
        }
      }
      raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)

    return () => {
      cancelAnimationFrame(raf)
      window.removeEventListener('resize', resize)
    }
  }, [active])

  return <canvas ref={ref} className="particles-canvas" aria-hidden="true" />
})
