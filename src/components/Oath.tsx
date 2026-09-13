import { useEffect, useRef, useState, type CSSProperties, type PointerEvent } from 'react'

type Props = {
  reduced: boolean
  onSworn: () => void
}

type Vein = { d: string; delay: number; dur: number; width: number }

/*
 * Ink veins that creep out from where the wand touched the parchment. Each
 * is a jittered random walk; a few fork halfway to read as blotting ink.
 */
function growVeins(x: number, y: number, w: number, h: number): Vein[] {
  const veins: Vein[] = []
  const reach = Math.hypot(w, h) * 0.62
  const count = 30
  for (let i = 0; i < count; i++) {
    const a0 = (i / count) * Math.PI * 2 + (Math.random() - 0.5) * 0.3
    let px = x
    let py = y
    let a = a0
    const steps = 7 + Math.floor(Math.random() * 5)
    const len = reach * (0.55 + Math.random() * 0.5)
    const seg = len / steps
    let d = `M${px.toFixed(1)} ${py.toFixed(1)}`
    for (let s = 0; s < steps; s++) {
      a += (Math.random() - 0.5) * 0.9
      const nx = px + Math.cos(a) * seg * (0.7 + Math.random() * 0.6)
      const ny = py + Math.sin(a) * seg * (0.7 + Math.random() * 0.6)
      const c1x = px + Math.cos(a - 0.4) * seg * 0.4
      const c1y = py + Math.sin(a - 0.4) * seg * 0.4
      d += ` Q${c1x.toFixed(1)} ${c1y.toFixed(1)} ${nx.toFixed(1)} ${ny.toFixed(1)}`
      if (s === 3 && Math.random() < 0.6) {
        // a fork
        let fx = nx
        let fy = ny
        let fa = a + (Math.random() < 0.5 ? 0.9 : -0.9)
        let fd = `M${fx.toFixed(1)} ${fy.toFixed(1)}`
        for (let k = 0; k < 4; k++) {
          fa += (Math.random() - 0.5) * 0.8
          const gx = fx + Math.cos(fa) * seg * 0.7
          const gy = fy + Math.sin(fa) * seg * 0.7
          fd += ` L${gx.toFixed(1)} ${gy.toFixed(1)}`
          fx = gx
          fy = gy
        }
        veins.push({ d: fd, delay: 0.45 + Math.random() * 0.25, dur: 0.7, width: 0.9 })
      }
      px = nx
      py = ny
    }
    veins.push({ d, delay: Math.random() * 0.22, dur: 1.05 + Math.random() * 0.35, width: 1.2 + Math.random() * 0.9 })
  }
  return veins
}

export function Oath({ reduced, onSworn }: Props) {
  const [stage, setStage] = useState<'waiting' | 'blooming' | 'done'>('waiting')
  const [veins, setVeins] = useState<Vein[]>([])
  const [size, setSize] = useState({ w: 1, h: 1 })
  const [tip, setTip] = useState<{ x: number; y: number } | null>(null)
  const timer = useRef<number[]>([])

  useEffect(() => () => timer.current.forEach((t) => window.clearTimeout(t)), [])

  const swear = (x: number, y: number) => {
    if (stage !== 'waiting') return
    if (reduced) {
      setStage('done')
      onSworn()
      return
    }
    const w = window.innerWidth
    const h = window.innerHeight
    setSize({ w, h })
    setTip({ x, y })
    setVeins(growVeins(x, y, w, h))
    setStage('blooming')
    timer.current.push(window.setTimeout(() => setStage('done'), 3350))
    timer.current.push(window.setTimeout(onSworn, 3900))
  }

  const onPointer = (e: PointerEvent<HTMLElement>) => {
    if ((e.target as HTMLElement).closest('button')) return
    swear(e.clientX, e.clientY)
  }

  return (
    <section
      className={`oath is-${stage}`}
      onPointerDown={onPointer}
      aria-label="Juramento de entrada"
    >
      {tip ? (
        <svg className="oath-ink" viewBox={`0 0 ${size.w} ${size.h}`} width={size.w} height={size.h} aria-hidden="true">
          {veins.map((v, i) => (
            <path
              key={i}
              className="vein"
              d={v.d}
              pathLength={1}
              style={{ '--d': `${v.delay}s`, '--t': `${v.dur}s`, strokeWidth: v.width } as CSSProperties}
            />
          ))}
          <circle className="oath-blot" cx={tip.x} cy={tip.y} r={7} />
        </svg>
      ) : null}

      <div className="oath-copy">
        <p className="oath-kicker">Toque o pergaminho com a ponta da varinha e diga, baixinho:</p>
        <p className="oath-phrase">Juro solenemente que não pretendo fazer nada de bom.</p>
        <button type="button" className="oath-btn" onClick={() => swear(window.innerWidth / 2, window.innerHeight * 0.58)}>
          Dizer o juramento
        </button>
      </div>

      <div className="oath-reveal" aria-hidden={stage === 'waiting'}>
        <p className="reveal-line" style={{ '--i': 0 } as CSSProperties}>
          Os senhores <b>Aluado</b>, <b>Rabicho</b>, <b>Almofadinhas</b> e <b>Pontas</b>,
        </p>
        <p className="reveal-line" style={{ '--i': 1 } as CSSProperties}>
          fornecedores de recursos para bruxos malfeitores,
        </p>
        <p className="reveal-line" style={{ '--i': 2 } as CSSProperties}>
          têm a honra de apresentar
        </p>
        <h1 className="reveal-title">
          <span>O Mapa</span>
          <span>do Maroto</span>
        </h1>
      </div>
    </section>
  )
}
