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

type Props = {
  active: boolean
  paused?: boolean
}

export const Particles = memo(function Particles({ active, paused = false }: Props) {
  const ref = useRef<HTMLCanvasElement>(null)
  const activeRef = useRef(active)
  const pausedRef = useRef(paused)
  activeRef.current = active
  pausedRef.current = paused

  useEffect(() => {
    const canvas = ref.current
    if (!canvas) return
    const lite = window.matchMedia('(max-width: 740px), (pointer: coarse)').matches
    const dpr = lite ? 1 : Math.min(window.devicePixelRatio || 1, 1.25)
    const ctx = canvas.getContext('2d', { alpha: true, desynchronized: true })
    if (!ctx) return

    const dots: Particle[] = []
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    const count = reduced ? 8 : lite ? 12 : 22

    const resize = () => {
      canvas.width = Math.max(1, Math.floor(window.innerWidth * dpr))
      canvas.height = Math.max(1, Math.floor(window.innerHeight * dpr))
      canvas.style.width = `${window.innerWidth}px`
      canvas.style.height = `${window.innerHeight}px`
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
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

    let raf = 0
    const tick = () => {
      raf = requestAnimationFrame(tick)
      if (!activeRef.current || pausedRef.current || document.visibilityState !== 'visible') return
      ctx.clearRect(0, 0, window.innerWidth, window.innerHeight)
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

    return () => {
      cancelAnimationFrame(raf)
      window.removeEventListener('resize', resize)
    }
  }, [])

  return <canvas ref={ref} className="particles-canvas" aria-hidden="true" />
})
