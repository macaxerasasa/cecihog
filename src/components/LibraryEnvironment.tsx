import { memo, useEffect, useRef, type ReactNode } from 'react'

type Props = {
  awake: boolean
  busy: boolean
  reading?: boolean
  holding?: boolean
  children: ReactNode
}

export const LibraryEnvironment = memo(function LibraryEnvironment({ awake, busy, reading, holding, children }: Props) {
  const ref = useRef<HTMLDivElement>(null)

  /* Gentle parallax on the painted hall: pointer position → CSS vars, one write per frame.
     Only for fine pointers; phones keep the backdrop still. */
  useEffect(() => {
    const el = ref.current
    if (!el) return
    if (!window.matchMedia('(pointer: fine)').matches) return
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
    let raf = 0
    let tx = 0
    let ty = 0
    const onMove = (e: PointerEvent) => {
      if (el.classList.contains('is-holding')) return
      tx = (e.clientX / window.innerWidth - 0.5) * 2
      ty = (e.clientY / window.innerHeight - 0.5) * 2
      if (raf) return
      raf = window.requestAnimationFrame(() => {
        raf = 0
        if (el.classList.contains('is-holding')) return
        el.style.setProperty('--px', tx.toFixed(3))
        el.style.setProperty('--py', ty.toFixed(3))
      })
    }
    window.addEventListener('pointermove', onMove, { passive: true })
    return () => {
      window.removeEventListener('pointermove', onMove)
      if (raf) window.cancelAnimationFrame(raf)
    }
  }, [])

  return (
    <div
      ref={ref}
      className={`library ${awake ? 'is-awake' : 'is-boot'} ${busy ? 'is-busy' : ''} ${reading ? 'is-reading' : ''} ${holding ? 'is-holding' : ''}`}
    >
      <div className="stone-wall" aria-hidden="true" />
      <div className="hall-art" aria-hidden="true" />
      <div className="hall-tint" aria-hidden="true" />
      <div className="wall-grain" />
      <div className="window-light a" aria-hidden="true" />
      <div className="window-light b" aria-hidden="true" />
      <div className="floor" aria-hidden="true" />
      {children}
    </div>
  )
})
