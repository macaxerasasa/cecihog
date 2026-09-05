import { useEffect, useRef, useState, type PointerEvent } from 'react'

const GLYPH =
  'M 36 188 C 34 132 46 64 98 46 C 148 30 176 78 150 118 C 128 150 92 138 96 108 C 102 72 156 86 172 152'

const CHECKPOINTS = 28

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
    setPoints(samplePath(path, CHECKPOINTS))
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

  const advance = (local: Pt) => {
    if (!points.length || successRef.current) return
    const radius = 18
    let idx = doneRef.current
    let hops = 0
    while (idx < points.length && hops < 5) {
      if (dist(local, points[idx]) <= radius) {
        idx += 1
        hops += 1
      } else break
    }
    if (idx !== doneRef.current) {
      doneRef.current = idx
      setDone(idx)
      if (idx >= points.length) complete()
    }
  }

  const onPointerDown = (e: PointerEvent<HTMLDivElement>) => {
    if (successRef.current) return
    e.currentTarget.setPointerCapture(e.pointerId)
    drawingRef.current = true
    setDrawing(true)
    const local = toLocal(e.clientX, e.clientY)
    setWand({ x: e.clientX, y: e.clientY, angle: -28, on: true })
    if (local) {
      setTrail([local])
      advance(local)
    }
  }

  const onPointerMove = (e: PointerEvent<HTMLDivElement>) => {
    setWand((prev) => {
      const dx = e.clientX - prev.x
      const dy = e.clientY - prev.y
      const angle = Math.abs(dx) + Math.abs(dy) > 1.5 ? (Math.atan2(dy, dx) * 180) / Math.PI + 90 : prev.angle
      return { x: e.clientX, y: e.clientY, angle, on: true }
    })
    const local = toLocal(e.clientX, e.clientY)
    if (!local || !drawingRef.current) return
    setTrail((t) => {
      const next = [...t, local]
      return next.length > 90 ? next.slice(-90) : next
    })
    advance(local)
  }

  const onPointerUp = () => {
    drawingRef.current = false
    setDrawing(false)
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
          : 'Toque no nó brilhante e desenhe o percurso dourado até o fim.'}
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
