import { memo } from 'react'
import { asset } from '../lib/asset'

type House = {
  id: 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'
  name: string
  primary: string
  glow: string
  metal: string
  metalHi: string
  corner: 'tl' | 'tr' | 'bl' | 'br'
}

const HOUSES: House[] = [
  {
    id: 'gryffindor',
    name: 'Grifinória',
    primary: '#ae0001',
    glow: 'rgba(200, 30, 20, 0.55)',
    metal: '#b98a2e',
    metalHi: '#f6e2a4',
    corner: 'tl',
  },
  {
    id: 'slytherin',
    name: 'Sonserina',
    primary: '#1a472a',
    glow: 'rgba(40, 160, 90, 0.5)',
    metal: '#8c9299',
    metalHi: '#e6eaee',
    corner: 'tr',
  },
  {
    id: 'ravenclaw',
    name: 'Corvinal',
    primary: '#0e1a40',
    glow: 'rgba(40, 120, 220, 0.55)',
    metal: '#946b2d',
    metalHi: '#e2b96a',
    corner: 'bl',
  },
  {
    id: 'hufflepuff',
    name: 'Lufa-Lufa',
    primary: '#ecb939',
    glow: 'rgba(240, 190, 60, 0.55)',
    metal: '#3a2f28',
    metalHi: '#f5d77a',
    corner: 'br',
  },
]

/* Filigree drawn for the top-left corner; the others are mirrored with CSS. */
function Filigree({ house }: { house: House }) {
  const gid = `fil-${house.id}`
  return (
    <svg viewBox="0 0 260 260" className="corner-filigree" aria-hidden="true">
      <defs>
        <linearGradient id={gid} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor={house.metalHi} />
          <stop offset="0.45" stopColor={house.metal} />
          <stop offset="0.7" stopColor={house.metalHi} />
          <stop offset="1" stopColor={house.metal} />
        </linearGradient>
        <linearGradient id={`${gid}-band`} x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor={house.primary} stopOpacity="0.95" />
          <stop offset="1" stopColor={house.primary} stopOpacity="0" />
        </linearGradient>
        <linearGradient id={`${gid}-bandv`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor={house.primary} stopOpacity="0.95" />
          <stop offset="1" stopColor={house.primary} stopOpacity="0" />
        </linearGradient>
      </defs>

      {/* house colour bands along the two edges */}
      <rect x="0" y="0" width="260" height="7" fill={`url(#${gid}-band)`} />
      <rect x="0" y="0" width="7" height="260" fill={`url(#${gid}-bandv)`} />
      <rect x="0" y="9" width="200" height="1.2" fill={`url(#${gid})`} opacity="0.7" />
      <rect x="9" y="0" width="1.2" height="200" fill={`url(#${gid})`} opacity="0.7" />

      <g fill="none" stroke={`url(#${gid})`} strokeLinecap="round" strokeLinejoin="round">
        {/* main frame lines with curled ends */}
        <path d="M14 22 H 150 c 14 0 22 -6 26 -12" strokeWidth="2.4" />
        <path d="M22 14 V 150 c 0 14 -6 22 -12 26" strokeWidth="2.4" />
        <path d="M176 10 c 8 0 12 5 12 10 c 0 5 -5 8 -9 6 c -4 -2 -3 -8 2 -8" strokeWidth="1.8" />
        <path d="M10 176 c 0 8 5 12 10 12 c 5 0 8 -5 6 -9 c -2 -4 -8 -3 -8 2" strokeWidth="1.8" />

        {/* inner scrollwork */}
        <path
          d="M32 32 C 60 30, 88 34, 104 48 C 116 58, 112 74, 98 74 C 88 74, 84 64, 90 58 C 98 50, 112 56, 112 68"
          strokeWidth="1.9"
        />
        <path
          d="M32 32 C 30 60, 34 88, 48 104 C 58 116, 74 112, 74 98 C 74 88, 64 84, 58 90 C 50 98, 56 112, 68 112"
          strokeWidth="1.9"
        />
        <path d="M46 46 C 70 44, 90 52, 96 62" strokeWidth="1.1" opacity="0.7" />
        <path d="M46 46 C 44 70, 52 90, 62 96" strokeWidth="1.1" opacity="0.7" />

        {/* acanthus leaves */}
        <path d="M120 40 c 10 -8 22 -8 30 0 c -8 6 -20 8 -30 0 z" strokeWidth="1.4" fill={house.metal} fillOpacity="0.35" />
        <path d="M40 120 c -8 10 -8 22 0 30 c 6 -8 8 -20 0 -30 z" strokeWidth="1.4" fill={house.metal} fillOpacity="0.35" />
        <path d="M150 40 c 10 -6 20 -4 26 2" strokeWidth="1.2" />
        <path d="M40 150 c -6 10 -4 20 2 26" strokeWidth="1.2" />

        {/* small trefoils along the frame */}
        <path d="M72 22 m -6 0 a 3 3 0 1 0 6 0 a 3 3 0 1 0 6 0 a 3 3 0 1 0 -6 0 a 3 3 0 1 0 -6 0" strokeWidth="1.2" />
        <path d="M22 72 m 0 -6 a 3 3 0 1 0 0 6 a 3 3 0 1 0 0 6 a 3 3 0 1 0 0 -6 a 3 3 0 1 0 0 -6" strokeWidth="1.2" />
      </g>

      {/* jewel at the crossing */}
      <g transform="translate(32 32)">
        <path d="M0 -9 L 9 0 L 0 9 L -9 0 Z" fill={house.primary} stroke={`url(#${gid})`} strokeWidth="1.6" />
        <path d="M0 -4 L 4 0 L 0 4 L -4 0 Z" fill={house.metalHi} opacity="0.85" />
      </g>
      <circle cx="98" cy="74" r="2.4" fill={house.metalHi} />
      <circle cx="74" cy="98" r="2.4" fill={house.metalHi} />
    </svg>
  )
}

export const HouseCorners = memo(function HouseCorners() {
  return (
    <div className="house-corners" aria-hidden="true">
      {HOUSES.map((house) => (
        <div
          key={house.id}
          className={`house-corner ${house.corner} ${house.id}`}
          style={{ ['--house' as string]: house.primary, ['--house-glow' as string]: house.glow }}
        >
          <Filigree house={house} />
          <div className="crest-wrap">
            <span className="crest-glow" />
            <img src={asset(`crests/${house.id}.png`)} alt="" className="crest-img" draggable={false} />
          </div>
        </div>
      ))}
    </div>
  )
})
