import { useEffect, useRef, useState, type MouseEvent, type PointerEvent, type TouchEvent } from 'react'

const GLYPH =
  'M 36 188 C 34 132 46 64 98 46 C 148 30 176 78 150 118 C 128 150 92 138 96 108 C 102 72 156 86 172 152'

const CHECKPOINTS = 36
const HIT_RADIUS = 34
const LOOKAHEAD = 12

type Pt = { x: number; y: number }

function samplePath(path: SVGPathElement, count: number): Pt[] {
  const len = path.getTotalLength()
  return Array.from({ length: count }, (_, i) => {
    const p = path.getPointAtLength((i / (count - 1)) * len)
    return { x: p.x, y: p.y }
  })
}

function dist(a: Pt, b: Pt) {
  return Math.hypot(a.x - b.x, a.y - b.y)
}

type Props = {
  reduced: boolean
  onUnlocked: () => void
}

export function WandGate({ reduced, onUnlocked }: Props) {
  const svgRef = useRef<SVGSVGElement>(null)
  const pathRef = useRef<SVGPathElement>(null)
  const doneRef = useRef(0)
  const drawingRef = useRef(false)
  const successRef = useRef(false)
  const [points, setPoints] = useState<Pt[]>([])
  const pointsRef = useRef<Pt[]>([])
  const [done, setDone] = useState(0)
  const [drawing, setDrawing] = useState(false)
  const [trail, setTrail] = useState<Pt[]>([])
  const [pathLen, setPathLen] = useState(480)
  const [wand, setWand] = useState({ x: -120, y: -120, angle: -28, on: false })
  const [success, setSuccess] = useState(false)
  const [leaving, setLeaving] = useState(false)

  useEffect(() => {
    const path = pathRef.current
    if (!path) return
    setPathLen(path.getTotalLength())
    const sampled = samplePath(path, CHECKPOINTS)
    pointsRef.current = sampled
    setPoints(sampled)
  }, [])

  const toLocal = (clientX: number, clientY: number): Pt | null => {
    const svg = svgRef.current
    if (!svg) return null
    const pt = svg.createSVGPoint()
    pt.x = clientX
    pt.y = clientY
    const ctm = svg.getScreenCTM()
    if (!ctm) return null
    const p = pt.matrixTransform(ctm.inverse())
    return { x: p.x, y: p.y }
  }

  const complete = () => {
    if (successRef.current) return
    successRef.current = true
    setSuccess(true)
    setDrawing(false)
    drawingRef.current = false
    window.setTimeout(() => {
      setLeaving(true)
      window.setTimeout(onUnlocked, 850)
    }, 650)
  }

  const usingPointer = useRef(false)

  const advance = (local: Pt) => {
    if (!pointsRef.current.length || successRef.current) return
    const pts = pointsRef.current
    let idx = doneRef.current
    const start = Math.max(0, idx - 1)
    const end = Math.min(pts.length - 1, idx + LOOKAHEAD)
    let best = -1
    for (let i = start; i <= end; i++) {
      if (dist(local, pts[i]) <= HIT_RADIUS) best = i
    }
    if (best >= idx) {
      const next = best + 1
      doneRef.current = next
      setDone(next)
      if (next >= pts.length) complete()
    }
  }

  const handleDown = (clientX: number, clientY: number) => {
    if (successRef.current) return
    drawingRef.current = true
    setDrawing(true)
    const local = toLocal(clientX, clientY)
    setWand({ x: clientX, y: clientY, angle: -28, on: true })
    if (local) {
      setTrail([local])
      advance(local)
    }
  }

  const handleMove = (clientX: number, clientY: number) => {
    setWand((prev) => {
      const dx = clientX - prev.x
      const dy = clientY - prev.y
      const angle = Math.abs(dx) + Math.abs(dy) > 1.5 ? (Math.atan2(dy, dx) * 180) / Math.PI + 90 : prev.angle
      return { x: clientX, y: clientY, angle, on: true }
    })
    const local = toLocal(clientX, clientY)
    if (!local || !drawingRef.current) return
    setTrail((t) => {
      const next = [...t, local]
      return next.length > 90 ? next.slice(-90) : next
    })
    advance(local)
  }

  const handleMoveRef = useRef(handleMove)
  handleMoveRef.current = handleMove

  const handleUp = () => {
    /* Keep tracing after release so the gesture stays attached to the wand, like a spell drill. */
  }

  useEffect(() => {
    const onMove = (e: globalThis.PointerEvent | globalThis.MouseEvent) => {
      if (!drawingRef.current) return
      handleMoveRef.current(e.clientX, e.clientY)
    }
    const onTouch = (e: globalThis.TouchEvent) => {
      if (!drawingRef.current) return
      const t = e.touches[0]
      if (t) {
        e.preventDefault()
        handleMoveRef.current(t.clientX, t.clientY)
      }
    }
    const onUp = () => {
      /* keep channeling */
    }
    window.addEventListener('pointermove', onMove)
    window.addEventListener('mousemove', onMove)
    window.addEventListener('touchmove', onTouch, { passive: false })
    window.addEventListener('pointerup', onUp)
    window.addEventListener('mouseup', onUp)
    window.addEventListener('touchend', onUp)
    return () => {
      window.removeEventListener('pointermove', onMove)
      window.removeEventListener('mousemove', onMove)
      window.removeEventListener('touchmove', onTouch)
      window.removeEventListener('pointerup', onUp)
      window.removeEventListener('mouseup', onUp)
      window.removeEventListener('touchend', onUp)
    }
  }, [])

  const onPointerDown = (e: PointerEvent<HTMLDivElement>) => {
    usingPointer.current = true
    e.currentTarget.setPointerCapture(e.pointerId)
    handleDown(e.clientX, e.clientY)
  }

  const onPointerMove = (e: PointerEvent<HTMLDivElement>) => {
    handleMove(e.clientX, e.clientY)
  }

  const onMouseDown = (e: MouseEvent<HTMLDivElement>) => {
    if (usingPointer.current) return
    handleDown(e.clientX, e.clientY)
  }

  const onMouseMove = (e: MouseEvent<HTMLDivElement>) => {
    if (usingPointer.current) return
    handleMove(e.clientX, e.clientY)
  }

  const onTouchStart = (e: TouchEvent<HTMLDivElement>) => {
    if (usingPointer.current) return
    const t = e.touches[0]
    if (t) handleDown(t.clientX, t.clientY)
  }

  const onTouchMove = (e: TouchEvent<HTMLDivElement>) => {
    if (usingPointer.current) return
    const t = e.touches[0]
    if (t) handleMove(t.clientX, t.clientY)
  }

  const onPointerUp = () => {
    handleUp()
  }

  const progress = points.length ? done / points.length : 0

  return (
    <div
      className={`wand-gate ${success ? 'is-success' : ''} ${leaving ? 'is-leaving' : ''}`}
      role="dialog"
      aria-modal="true"
      aria-labelledby="wand-title"
    >
      <div className="wand-sky" />
      <div className="wand-vignette" />
      <div className="house-embers" aria-hidden="true" />

      <div className="wand-copy">
        <p className="wand-kicker">Biblioteca de Hogwarts</p>
        <h1 id="wand-title">Alohomora</h1>
        <p className="wand-lead">
          Trace o glifo com a varinha, como no treino de feitiços, para abrir as portas da seção restrita.
        </p>
      </div>

      <div
        className="wand-stage"
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        onPointerCancel={onPointerUp}
        onMouseDown={onMouseDown}
        onMouseMove={onMouseMove}
        onMouseUp={handleUp}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={handleUp}
      >
        <svg
          ref={svgRef}
          className="wand-glyph"
          viewBox="0 0 210 230"
          aria-hidden="true"
        >
          <path className="glyph-ghost" d={GLYPH} />
          <path className="glyph-guide" d={GLYPH} strokeDasharray="7 11" />
          <path
            ref={pathRef}
            className="glyph-ink"
            d={GLYPH}
            strokeDasharray={pathLen}
            strokeDashoffset={pathLen * (1 - progress)}
          />
          {points.map((p, i) => (
            <circle
              key={i}
              className={`glyph-node ${i < done ? 'is-lit' : ''} ${i === 0 && done === 0 ? 'is-start' : ''}`}
              cx={p.x}
              cy={p.y}
              r={i === 0 ? 5.5 : 3.2}
            />
          ))}
          {trail.length > 1 ? (
            <polyline className="glyph-trail" points={trail.map((p) => `${p.x},${p.y}`).join(' ')} />
          ) : null}
        </svg>
        {drawing ? <span className="sr-only">Traçando o feitiço.</span> : null}
      </div>

      <p className="wand-hint">
        {success
          ? 'As fechaduras cedem…'
          : 'Toque no nó brilhante e siga o traço dourado — a varinha continua o gesto até concluir.'}
      </p>

      <button type="button" className={`wand-skip ${reduced ? '' : 'is-quiet'}`} onClick={complete}>
        {reduced ? 'Completar o gesto (movimento reduzido)' : 'Pronunciar o encantamento'}
      </button>

      <div
        className={`wand-cursor ${wand.on ? 'is-on' : ''}`}
        style={{
          left: wand.x,
          top: wand.y,
          transform: `translate(-18%, -12%) rotate(${wand.angle}deg)`,
        }}
        aria-hidden="true"
      >
        <span className="wand-stick" />
        <span className="wand-tip" />
      </div>
    </div>
  )
}
