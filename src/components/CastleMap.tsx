import { memo, useCallback, type CSSProperties, type KeyboardEvent, type MouseEvent } from 'react'
import { corridors, FRAME, places, type Box, type Frame, type Place } from '../data/map'
import { asset } from '../lib/asset'
import { InkDefs } from './InkDefs'
import { ribbon, Walkers } from './Walkers'

type Side = 'top' | 'right' | 'bottom' | 'left'
/* a door: the wall it opens in and, optionally, where along that wall */
type Door = { side: Side; at?: number }

type Props = {
  frame: Frame
  lite: boolean
  activeId: string | null
  busy: boolean
  onOpen: (id: string, el: SVGGraphicsElement) => void
}

const WALL = 9
const GAP = 46

/* Which wall of each room carries its door, per sheet. */
function doorsOf(p: Place, frame: Frame): Door[] {
  if (frame === 'l') {
    if (p.kind === 'hall') return [{ side: 'bottom', at: HALL_STAIR_X }, { side: 'left' }, { side: 'right' }]
    if (p.id === 'habilidades') return [{ side: 'right' }]
    if (p.id === 'racas') return [{ side: 'left' }]
    return [{ side: 'top' }]
  }
  if (p.kind === 'hall') return [{ side: 'bottom' }]
  if (p.kind === 'wing') return [{ side: 'top' }]
  if (p.id === 'setimo-ano') return [{ side: 'top' }]
  return p.p.x < 500 ? [{ side: 'right' }] : [{ side: 'left' }]
}

/* the hall's stair down to the long corridor, clear of its banner */
const HALL_STAIR_X = 660

/* The ink of one room: outer and inner wall lines with door gaps, the hatched
   wall thickness, jambs and the swing of every door. */
function walls(b: Box, doors: Door[]) {
  const { x, y, w, h } = b
  const cx = x + w / 2
  const cy = y + h / 2
  const g = GAP / 2
  const door = (s: Side) => doors.find((d) => d.side === s)
  const at = (s: Side) => door(s)?.at ?? (s === 'top' || s === 'bottom' ? cx : cy)
  const sides = (X: number, Y: number, W: number, H: number) => {
    const tx = at('top')
    const bx = at('bottom')
    const ly = at('left')
    const ry = at('right')
    return [
      door('top') ? `M${X} ${Y} H${tx - g} M${tx + g} ${Y} H${X + W}` : `M${X} ${Y} H${X + W}`,
      door('right') ? `M${X + W} ${Y} V${ry - g} M${X + W} ${ry + g} V${Y + H}` : `M${X + W} ${Y} V${Y + H}`,
      door('bottom') ? `M${X + W} ${Y + H} H${bx + g} M${bx - g} ${Y + H} H${X}` : `M${X + W} ${Y + H} H${X}`,
      door('left') ? `M${X} ${Y + H} V${ly + g} M${X} ${ly - g} V${Y}` : `M${X} ${Y + H} V${Y}`,
    ].join(' ')
  }
  const t = WALL
  const jambs: string[] = []
  const arcs: string[] = []
  for (const d of doors) {
    if (d.side === 'top') {
      const dx = at('top')
      jambs.push(`M${dx - g} ${y} V${y + t} M${dx + g} ${y} V${y + t}`)
      arcs.push(`M${dx + g} ${y + t} A${GAP} ${GAP} 0 0 1 ${dx - g} ${y + t + GAP} L${dx - g} ${y + t}`)
    } else if (d.side === 'bottom') {
      const dx = at('bottom')
      jambs.push(`M${dx - g} ${y + h} V${y + h - t} M${dx + g} ${y + h} V${y + h - t}`)
      arcs.push(`M${dx + g} ${y + h - t} A${GAP} ${GAP} 0 0 0 ${dx - g} ${y + h - t - GAP} L${dx - g} ${y + h - t}`)
    } else if (d.side === 'left') {
      const dy = at('left')
      jambs.push(`M${x} ${dy - g} H${x + t} M${x} ${dy + g} H${x + t}`)
      arcs.push(`M${x + t} ${dy + g} A${GAP} ${GAP} 0 0 0 ${x + t + GAP} ${dy - g} L${x + t} ${dy - g}`)
    } else {
      const dy = at('right')
      jambs.push(`M${x + w} ${dy - g} H${x + w - t} M${x + w} ${dy + g} H${x + w - t}`)
      arcs.push(`M${x + w - t} ${dy + g} A${GAP} ${GAP} 0 0 1 ${x + w - t - GAP} ${dy - g} L${x + w - t} ${dy - g}`)
    }
  }
  return {
    outer: sides(x, y, w, h),
    inner: sides(x + t, y + t, w - 2 * t, h - 2 * t),
    ring: `M${x} ${y} H${x + w} V${y + h} H${x} Z M${x + t} ${y + t} H${x + w - t} V${y + h - t} H${x + t} Z`,
    jambs: jambs.join(' '),
    arcs: arcs.join(' '),
  }
}

/* Entrance: strokes draw themselves from the top-left corner outwards. */
const drawDelay = (x: number, y: number, frame: Frame) =>
  ({ '--d': `${((x / FRAME[frame].w) * 0.55 + (y / FRAME[frame].h) * 0.85).toFixed(2)}s` }) as CSSProperties

function RoomInk({ p, frame }: { p: Place; frame: Frame }) {
  const b = p[frame]
  const k = walls(b, doorsOf(p, frame))
  const d = drawDelay(b.x, b.y, frame)
  return (
    <g className="room-ink" style={d}>
      <path className="wall-hatch" d={k.ring} fillRule="evenodd" />
      <path className="ink wall outer" d={k.outer} pathLength={1} />
      <path className="ink wall inner" d={k.inner} pathLength={1} />
      <path className="ink jamb" d={k.jambs} pathLength={1} />
      <path className="ink swing" d={k.arcs} pathLength={1} />
    </g>
  )
}

function Corridors({ frame }: { frame: Frame }) {
  return (
    <g className="corridor-ink">
      {corridors[frame].map((d, i) => {
        const m = d.match(/M\s*([\d.]+)\s+([\d.]+)/)
        const delay = m ? drawDelay(+m[1], +m[2], frame) : undefined
        return (
          <g key={i} style={delay}>
            <path className="ink corridor-edge" d={d} pathLength={1} />
            <path className="ink corridor-tread" d={d} pathLength={1} />
          </g>
        )
      })}
    </g>
  )
}

function Compass({ x, y, r }: { x: number; y: number; r: number }) {
  const pt = (a: number, k: number) => `${x + Math.sin(a) * r * k} ${y - Math.cos(a) * r * k}`
  const star = (n: number, k1: number, k2: number, rot = 0) => {
    const parts: string[] = []
    for (let i = 0; i < n; i++) {
      const a = rot + (i / n) * Math.PI * 2
      const b = a + Math.PI / n
      parts.push(`${i ? 'L' : 'M'}${pt(a, k1)} L${pt(b, k2)}`)
    }
    return parts.join(' ') + ' Z'
  }
  return (
    <g className="compass" style={drawDelay(x, y, 'l')}>
      <circle className="ink" cx={x} cy={y} r={r} pathLength={1} />
      <circle className="ink thin" cx={x} cy={y} r={r * 0.78} pathLength={1} />
      <path className="ink thin" d={star(8, 0.7, 0.16, Math.PI / 8)} pathLength={1} />
      <path className="compass-star" d={star(4, 0.95, 0.2)} />
      <path className="ink thin" d={star(4, 0.95, 0.2)} pathLength={1} />
      <text className="map-caps" x={x} y={y - r - 8} textAnchor="middle">
        N
      </text>
      <text className="map-caps" x={x} y={y + r + 22} textAnchor="middle">
        S
      </text>
      <text className="map-caps" x={x - r - 12} y={y + 6} textAnchor="middle">
        O
      </text>
      <text className="map-caps" x={x + r + 12} y={y + 6} textAnchor="middle">
        L
      </text>
    </g>
  )
}

function Forest({ x, y, w, h, n, label }: { x: number; y: number; w: number; h: number; n: number; label: [number, number] }) {
  // deterministic scatter
  const trees = Array.from({ length: n }, (_, i) => {
    const u = ((i * 7919) % 1000) / 1000
    const v = ((i * 104729) % 1000) / 1000
    const s = 18 + ((i * 31) % 5) * 3
    return { x: x + u * (w - s), y: y + v * (h - s * 1.5), s }
  })
  return (
    <g className="forest" style={drawDelay(x, y, 'l')}>
      {trees.map((t, i) => (
        <use key={i} href="#pine" x={t.x} y={t.y} width={t.s} height={t.s * 1.5} />
      ))}
      <text className="map-italic" x={label[0]} y={label[1]}>
        Floresta Proibida
      </text>
    </g>
  )
}

function Lake({ d, label }: { d: string; label: [number, number] }) {
  return (
    <g className="lake" style={drawDelay(label[0], label[1], 'l')}>
      <path className="lake-water" d={d} />
      <path className="ink lake-shore" d={d} pathLength={1} />
      <text className="map-italic" x={label[0]} y={label[1]} textAnchor="middle">
        Lago Negro
      </text>
    </g>
  )
}

function Scale({ x, y, w }: { x: number; y: number; w: number }) {
  return (
    <g className="scale" style={drawDelay(x, y, 'l')}>
      <path className="ink thin" d={`M${x} ${y} H${x + w} M${x} ${y - 6} V${y + 6} M${x + w / 2} ${y - 4} V${y + 4} M${x + w} ${y - 6} V${y + 6}`} pathLength={1} />
      <text className="map-italic small" x={x + w / 2} y={y + 22} textAnchor="middle">
        cem passos, de pé no chão
      </text>
    </g>
  )
}

/* Grounds along the foot of the landscape sheet: the greenhouses, Hagrid's
   hut and the Quidditch pitch, each a few strokes with an italic label. */
function Landmarks() {
  return (
    <g className="landmarks">
      <g style={drawDelay(480, 880, 'l')}>
        {[0, 1, 2].map((i) => (
          <g key={i}>
            <path className="ink thin" d={`M${486 + i * 54} 930 V 892 L ${506 + i * 54} 876 L ${526 + i * 54} 892 V 930 Z`} pathLength={1} />
            <path className="ink thin" d={`M${506 + i * 54} 876 V 930 M${486 + i * 54} 911 H ${526 + i * 54}`} pathLength={1} />
          </g>
        ))}
        <text className="map-italic small" x={560} y={956} textAnchor="middle">
          Estufas
        </text>
      </g>
      <g style={drawDelay(430, 880, 'l')}>
        <path className="ink thin" d="M404 928 V 898 L 426 878 L 448 898 V 928 Z M 420 928 V 910 H 432 V 928 M 438 888 V 878 H 444 V 893" pathLength={1} />
        <text className="map-italic small" x={426} y={950} textAnchor="middle">
          Cabana
        </text>
      </g>
      <g style={drawDelay(1000, 880, 'l')}>
        <ellipse className="ink thin" cx={1030} cy={912} rx={96} ry={40} pathLength={1} />
        <path className="ink thin" d="M934 912 H 1126 M1030 872 V 952" pathLength={1} />
        {[952, 1030, 1108].map((x, i) => (
          <g key={i}>
            <path className="ink thin" d={`M${x} ${i === 1 ? 900 : 906} V ${i === 1 ? 924 : 918}`} pathLength={1} />
            <circle className="ink thin" cx={x} cy={i === 1 ? 894 : 900} r={i === 1 ? 6 : 5} pathLength={1} />
          </g>
        ))}
        <text className="map-italic small" x={1030} y={976} textAnchor="middle">
          Campo de Quadribol
        </text>
      </g>
    </g>
  )
}

function Decor({ frame }: { frame: Frame }) {
  if (frame === 'l') {
    return (
      <>
        <Corridors frame="l" />
        <g className="stairs">
          <use href="#stair" x={HALL_STAIR_X - 15} y={482} width={30} height={40} />
          {Array.from({ length: 7 }, (_, i) => (
            <use key={i} href="#stair" x={189 + i * 197} y={572} width={30} height={40} />
          ))}
        </g>
        <g className="towers" style={drawDelay(220, 150, 'l')}>
          <use href="#tower" x={214} y={126} width={40} height={40} />
          <text className="map-italic" x={234} y={200} textAnchor="middle">
            Corujal
          </text>
          <use href="#tower" x={1324} y={126} width={40} height={40} />
          <text className="map-italic" x={1344} y={200} textAnchor="middle">
            Torre de Astronomia
          </text>
        </g>
        <Compass x={1476} y={128} r={54} />
        <Landmarks />
        <Forest x={70} y={862} w={330} h={110} n={15} label={[236, 996]} />
        <Lake
          d="M1160 916 C 1200 870, 1270 852, 1340 866 S 1470 898, 1500 870 L 1500 978 C 1440 996, 1330 1000, 1240 984 S 1160 966, 1160 916 Z"
          label={[1330, 948]}
        />
        <Scale x={700} y={946} w={200} />
      </>
    )
  }
  return (
    <>
      <Corridors frame="p" />
      <g className="stairs">
        <use href="#stair" x={485} y={506} width={30} height={40} />
        <use href="#stair" x={485} y={1366} width={30} height={40} />
      </g>
      <Compass x={900} y={160} r={44} />
      <g className="towers" style={drawDelay(120, 150, 'p')}>
        <use href="#tower" x={90} y={120} width={40} height={40} />
        <text className="map-italic" x={110} y={196} textAnchor="middle">
          Corujal
        </text>
      </g>
      <Forest x={60} y={1420} w={210} h={104} n={9} label={[165, 1566]} />
      <Lake d="M730 1436 C 780 1406, 860 1416, 930 1446 L 930 1530 C 860 1550, 780 1542, 730 1516 Z" label={[830, 1566]} />
      <Scale x={800} y={236} w={180} />
    </>
  )
}

function Room({
  p,
  frame,
  active,
  disabled,
  onOpen,
}: {
  p: Place
  frame: Frame
  active: boolean
  disabled: boolean
  onOpen: Props['onOpen']
}) {
  const b = p[frame]
  const cx = b.x + b.w / 2
  const isRoom = p.kind === 'room'
  const bw = p.name.length * 12.4 + 48
  const bh = 32
  const by = b.y + b.h + 10
  const art = asset(`art/ink-${p.art}.webp`)
  const artBox = isRoom
    ? { x: b.x + b.w * 0.5, y: b.y + 22, w: b.w * 0.44, h: b.h - 44 }
    : p.kind === 'hall'
      ? { x: cx - 112, y: b.y + 22, w: 224, h: b.h - 44 }
      : { x: cx - 78, y: b.y + 26, w: 156, h: b.h - 52 }
  const style = { '--d': `${1.15 + (b.x / FRAME[frame].w) * 0.5 + (b.y / FRAME[frame].h) * 0.6}s` } as CSSProperties
  const activate = (e: MouseEvent<SVGGElement>) => {
    if (disabled) return
    onOpen(p.id, e.currentTarget)
  }
  const onKey = (e: KeyboardEvent<SVGGElement>) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault()
      if (!disabled) onOpen(p.id, e.currentTarget)
    }
  }
  return (
    <g
      className={`place kind-${p.kind} ${active ? 'is-active' : ''} ${disabled ? 'is-disabled' : ''}`}
      style={style}
      data-id={p.id}
      role="button"
      tabIndex={disabled ? -1 : 0}
      aria-label={`Abrir ${p.book.title} — ${p.name}`}
      aria-disabled={disabled || undefined}
      onClick={activate}
      onKeyDown={onKey}
    >
      <rect className="place-hit" x={b.x - 8} y={b.y - 8} width={b.w + 16} height={b.h + bh + 44} rx={6} />
      <rect className="place-floor" x={b.x + WALL} y={b.y + WALL} width={b.w - 2 * WALL} height={b.h - 2 * WALL} />
      {p.numeral ? (
        <text className="place-numeral" x={b.x + b.w * 0.27} y={b.y + b.h * 0.66} textAnchor="middle">
          {p.numeral}
        </text>
      ) : null}
      <image className="place-art" href={art} x={artBox.x} y={artBox.y} width={artBox.w} height={artBox.h} preserveAspectRatio="xMidYMid meet" />
      <g className="place-banner" transform={`translate(${cx - bw / 2} ${by})`}>
        <path className="banner-ribbon" d={ribbon(bw, bh)} />
        <text className="banner-name" x={bw / 2} y={bh / 2 + 7} textAnchor="middle">
          {p.name}
        </text>
      </g>
      <text className="place-note" x={cx} y={by + bh + 20} textAnchor="middle">
        {p.note}
      </text>
    </g>
  )
}

export const CastleMap = memo(function CastleMap({ frame, lite, activeId, busy, onOpen }: Props) {
  const { w, h } = FRAME[frame]
  const open = useCallback((id: string, el: SVGGraphicsElement) => onOpen(id, el), [onOpen])
  return (
    <svg className={`castle-map frame-${frame}`} viewBox={`0 0 ${w} ${h}`} role="group" aria-label="Planta do castelo de Hogwarts">
      <InkDefs />
      <g className="ink-static" filter={lite ? undefined : 'url(#wobble)'}>
        <Decor frame={frame} />
        {places.map((p) => (
          <RoomInk key={p.id} p={p} frame={frame} />
        ))}
      </g>
      <Walkers frame={frame} lite={lite} />
      <g className="places">
        {places.map((p) => (
          <Room key={p.id} p={p} frame={frame} active={activeId === p.id} disabled={busy} onOpen={open} />
        ))}
      </g>
    </svg>
  )
})
