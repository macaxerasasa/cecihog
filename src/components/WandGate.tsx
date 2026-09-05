import { useEffect, useRef, useState, type PointerEvent, type TouchEvent } from 'react'

const GLYPH =
  'M 36 188 C 34 132 46 64 98 46 C 148 30 176 78 150 118 C 128 150 92 138 96 108 C 102 72 156 86 172 152'

/** Dense samples along the glyph so the ink can follow the wand tip continuously. */
const SAMPLES = 320
/** Decorative beads along the glyph that light up as the wand passes. */
const BEADS = 14
/** How close (viewBox units) the tip must be to the glyph to advance. */
const TOLERANCE = 19
/** How far ahead along the glyph (in length) the tip may jump in one move. */
const LOOKAHEAD_LEN = 42
/** Straying this far from the ink's tip counts as losing the thread. */
const LOST_DIST = 34
/** The gesture must begin this close to the start bead. */
const START_TOL = 22
/** Length of the lit stretch ahead of the ink that shows where to go next. */
const LEAD_LEN = 34

type Pt = { x: number; y: number }
type Sample = Pt & { len: number }

function samplePath(path: SVGPathElement, count: number): Sample[] {
  const total = path.getTotalLength()
  return Array.from({ length: count }, (_, i) => {
    const len = (i / (count - 1)) * total
    const p = path.getPointAtLength(len)
    return { x: p.x, y: p.y, len }
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
  const wandRef = useRef<HTMLDivElement>(null)

  const samplesRef = useRef<Sample[]>([])
  const idxRef = useRef(0)
  const armedRef = useRef(false)
  const successRef = useRef(false)
  const wandState = useRef({ x: -200, y: -200, angle: -32, lastX: -200, lastT: 0 })

  const [beads, setBeads] = useState<Sample[]>([])
  const [pathLen, setPathLen] = useState(480)
  const [progressLen, setProgressLen] = useState(0)
  const [tip, setTip] = useState<Pt | null>(null)
  const [trail, setTrail] = useState<Pt[]>([])
  const [armed, setArmed] = useState(false)
  const [lost, setLost] = useState(false)
  const [nudge, setNudge] = useState(0)
  const [success, setSuccess] = useState(false)
  const [leaving, setLeaving] = useState(false)

  useEffect(() => {
    const path = pathRef.current
    if (!path) return
    setPathLen(path.getTotalLength())
    samplesRef.current = samplePath(path, SAMPLES)
    setBeads(samplePath(path, BEADS))
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
    setArmed(false)
    armedRef.current = false
    setLost(false)
    const s = samplesRef.current
    if (s.length) {
      setProgressLen(s[s.length - 1].len)
      setTip(s[s.length - 1])
    }
    window.setTimeout(() => {
      setLeaving(true)
      window.setTimeout(onUnlocked, 850)
    }, 650)
  }

  /* Move the wand DOM node directly so the tip tracks the pointer with no render lag. */
  const placeWand = (clientX: number, clientY: number) => {
    const el = wandRef.current
    const w = wandState.current
    if (!el) return
    const now = performance.now()
    const dt = Math.max(8, now - w.lastT)
    const vx = ((clientX - w.lastX) / dt) * 16
    const lean = Math.max(-14, Math.min(14, vx * 1.6))
    w.angle += (-32 + lean - w.angle) * 0.18
    w.x = clientX
    w.y = clientY
    w.lastX = clientX
    w.lastT = now
    el.style.transform = `translate(${clientX}px, ${clientY}px) rotate(${w.angle}deg)`
    el.classList.add('is-on')
  }

  const advance = (local: Pt) => {
    const s = samplesRef.current
    if (!s.length || successRef.current || !armedRef.current) return
    const cur = idxRef.current
    const curLen = s[cur].len

    let best = -1
    for (let j = cur; j < s.length && s[j].len - curLen <= LOOKAHEAD_LEN; j++) {
      if (dist(local, s[j]) <= TOLERANCE) best = j
    }

    if (best > cur) {
      idxRef.current = best
      setProgressLen(s[best].len)
      setTip(s[best])
      setLost(false)
      if (best >= s.length - 2) complete()
      return
    }

    setLost(dist(local, s[cur]) > LOST_DIST)
  }

  const handleDown = (clientX: number, clientY: number) => {
    if (successRef.current) return
    placeWand(clientX, clientY)
    const local = toLocal(clientX, clientY)
    if (!local) return
    const s = samplesRef.current
    if (!s.length) return

    if (!armedRef.current) {
      if (dist(local, s[0]) > START_TOL) {
        setNudge((n) => n + 1)
        return
      }
      armedRef.current = true
      setArmed(true)
      idxRef.current = 0
      setProgressLen(0)
      setTip(s[0])
      setTrail([local])
      return
    }

    // Already channelling: a tap far off the glyph re-centres the gesture where the ink stopped.
    setTrail([local])
    advance(local)
  }

  const handleMove = (clientX: number, clientY: number) => {
    placeWand(clientX, clientY)
    if (!armedRef.current || successRef.current) return
    const local = toLocal(clientX, clientY)
    if (!local) return
    setTrail((t) => {
      const next = [...t, local]
      return next.length > 14 ? next.slice(-14) : next
    })
    advance(local)
  }

  const handleMoveRef = useRef(handleMove)
  handleMoveRef.current = handleMove

  useEffect(() => {
    const onMove = (e: globalThis.PointerEvent) => handleMoveRef.current(e.clientX, e.clientY)
    const onTouch = (e: globalThis.TouchEvent) => {
      const t = e.touches[0]
      if (t) {
        if (armedRef.current) e.preventDefault()
        handleMoveRef.current(t.clientX, t.clientY)
      }
    }
    window.addEventListener('pointermove', onMove)
    window.addEventListener('touchmove', onTouch, { passive: false })
    return () => {
      window.removeEventListener('pointermove', onMove)
      window.removeEventListener('touchmove', onTouch)
    }
  }, [])

  const onPointerDown = (e: PointerEvent<HTMLDivElement>) => {
    if (e.pointerType === 'touch') return
    handleDown(e.clientX, e.clientY)
  }

  const onTouchStart = (e: TouchEvent<HTMLDivElement>) => {
    const t = e.touches[0]
    if (t) handleDown(t.clientX, t.clientY)
  }

  const start = beads[0]
  const hint = success
    ? 'As fechaduras cedem…'
    : !armed
      ? 'Toque no nó brilhante para erguer a varinha e siga o traço dourado.'
      : lost
        ? 'A varinha perdeu o traço — volte à ponta da tinta para continuar.'
        : 'Continue pelo traço, sem pressa. A varinha segue o gesto até o fim.'

  return (
    <div
      className={`wand-gate ${success ? 'is-success' : ''} ${leaving ? 'is-leaving' : ''} ${armed ? 'is-armed' : ''} ${
        lost ? 'is-lost' : ''
      }`}
      role="dialog"
      aria-modal="true"
      aria-labelledby="wand-title"
      onPointerDown={onPointerDown}
      onTouchStart={onTouchStart}
    >
      <div className="wand-sky" />
      <div className="wand-stars" aria-hidden="true" />
      <div className="wand-stars far" aria-hidden="true" />
      <div className="wand-vignette" />
      <div className="house-embers" aria-hidden="true" />

      <div className="wand-copy">
        <p className="wand-kicker">
          <span className="kicker-rule" />
          Biblioteca de Hogwarts
          <span className="kicker-rule" />
        </p>
        <h1 id="wand-title">Alohomora</h1>
        <p className="wand-lead">
          Trace o glifo com a varinha, como no treino de feitiços, para abrir as portas da seção restrita.
        </p>
      </div>

      <div className="runic-ring" aria-hidden="true">
        <span className="ring outer" />
        <span className="ring inner" />
        <span className="ring dashes" />
      </div>

      <div className="wand-stage">
        <svg ref={svgRef} className="wand-glyph" viewBox="0 0 210 230" aria-hidden="true">
          <path className="glyph-ghost" d={GLYPH} />
          <path className="glyph-guide" d={GLYPH} strokeDasharray="7 11" />
          {armed && !success ? (
            <path
              className="glyph-lead"
              d={GLYPH}
              strokeDasharray={`0 ${progressLen} ${LEAD_LEN} ${pathLen}`}
            />
          ) : null}
          <path
            ref={pathRef}
            className="glyph-ink"
            d={GLYPH}
            strokeDasharray={pathLen}
            strokeDashoffset={pathLen - progressLen}
          />
          {beads.map((p, i) => (
            <circle
              key={i}
              className={`glyph-node ${p.len <= progressLen && (armed || success) ? 'is-lit' : ''}`}
              cx={p.x}
              cy={p.y}
              r={3}
            />
          ))}
          {start && !armed && !success ? (
            <g key={nudge} className={`glyph-start ${nudge ? 'is-nudged' : ''}`}>
              <circle className="glyph-start-ring" cx={start.x} cy={start.y} r={14} />
              <circle className="glyph-start-core" cx={start.x} cy={start.y} r={6} />
            </g>
          ) : null}
          {trail.length > 1 && armed ? (
            <polyline className="glyph-trail" points={trail.map((p) => `${p.x},${p.y}`).join(' ')} />
          ) : null}
          {tip && (armed || success) ? (
            <g className="glyph-spark">
              <circle cx={tip.x} cy={tip.y} r={9} className="glyph-spark-halo" />
              <circle cx={tip.x} cy={tip.y} r={3.4} className="glyph-spark-core" />
            </g>
          ) : null}
        </svg>
        {armed ? <span className="sr-only">Traçando o feitiço.</span> : null}
      </div>

      <p className="wand-hint">{hint}</p>

      <button
        type="button"
        className={`wand-skip ${reduced ? '' : 'is-quiet'}`}
        onClick={complete}
        onPointerDown={(e) => e.stopPropagation()}
        onTouchStart={(e) => e.stopPropagation()}
      >
        {reduced ? 'Completar o gesto (movimento reduzido)' : 'Pronunciar o encantamento'}
      </button>

      <div ref={wandRef} className="wand-cursor" aria-hidden="true">
        <span className="wand-stick" />
        <span className="wand-tip" />
      </div>
    </div>
  )
}
