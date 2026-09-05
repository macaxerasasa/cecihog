type PropProps = { className?: string }

const wrap = (name: string, extra?: string) => `shelf-prop ${name} ${extra ?? ''}`

export function ScrollStack({ className }: PropProps) {
  return (
    <span className={wrap('scrolls', className)} aria-hidden="true">
      <svg viewBox="0 0 120 60" className="prop-svg">
        <defs>
          <linearGradient id="sc-paper" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#f7ecd2" />
            <stop offset="0.55" stopColor="#e6d3a8" />
            <stop offset="1" stopColor="#bda372" />
          </linearGradient>
          <linearGradient id="sc-roll" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#fff8e6" />
            <stop offset="0.5" stopColor="#dcc79b" />
            <stop offset="1" stopColor="#8a6a3c" />
          </linearGradient>
          <radialGradient id="sc-end" cx="0.5" cy="0.5" r="0.5">
            <stop offset="0" stopColor="#8a6a3c" />
            <stop offset="0.35" stopColor="#e6d3a8" />
            <stop offset="0.55" stopColor="#8a6a3c" />
            <stop offset="0.75" stopColor="#f2e3c2" />
            <stop offset="1" stopColor="#6a4a24" />
          </radialGradient>
          <radialGradient id="sc-wax" cx="0.4" cy="0.35" r="0.6">
            <stop offset="0" stopColor="#e05a48" />
            <stop offset="0.6" stopColor="#8a1c14" />
            <stop offset="1" stopColor="#4a0c08" />
          </radialGradient>
          <linearGradient id="sc-ribbon" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#5a0c08" />
            <stop offset="0.5" stopColor="#ae1a12" />
            <stop offset="1" stopColor="#5a0c08" />
          </linearGradient>
        </defs>
        {/* bottom scroll */}
        <rect x="10" y="44" width="100" height="16" rx="8" fill="url(#sc-roll)" />
        <rect x="18" y="46" width="84" height="12" fill="url(#sc-paper)" />
        <path d="M18 46 h84 v2 h-84z" fill="rgba(255,255,255,0.35)" />
        <ellipse cx="10" cy="52" rx="7" ry="8" fill="url(#sc-end)" />
        <ellipse cx="110" cy="52" rx="7" ry="8" fill="url(#sc-end)" />
        <path d="M22 50 h60 M26 54 h44" stroke="rgba(90,60,30,0.35)" strokeWidth="0.8" />
        {/* middle scroll */}
        <rect x="18" y="30" width="86" height="15" rx="7.5" fill="url(#sc-roll)" />
        <rect x="26" y="32" width="70" height="11" fill="url(#sc-paper)" />
        <ellipse cx="18" cy="37.5" rx="6.5" ry="7.5" fill="url(#sc-end)" />
        <ellipse cx="104" cy="37.5" rx="6.5" ry="7.5" fill="url(#sc-end)" />
        <rect x="58" y="29" width="8" height="17" fill="url(#sc-ribbon)" opacity="0.9" />
        <path d="M30 36 h22 M34 40 h14" stroke="rgba(90,60,30,0.35)" strokeWidth="0.8" />
        {/* top scroll, slightly rotated */}
        <g transform="rotate(-4 60 24)">
          <rect x="30" y="17" width="64" height="13" rx="6.5" fill="url(#sc-roll)" />
          <rect x="36" y="19" width="52" height="9" fill="url(#sc-paper)" />
          <ellipse cx="30" cy="23.5" rx="5.5" ry="6.5" fill="url(#sc-end)" />
          <ellipse cx="94" cy="23.5" rx="5.5" ry="6.5" fill="url(#sc-end)" />
          <path d="M40 22 h30 M44 25.5 h18" stroke="rgba(90,60,30,0.35)" strokeWidth="0.8" />
        </g>
        {/* wax seal */}
        <circle cx="62" cy="15" r="6.5" fill="url(#sc-wax)" />
        <circle cx="62" cy="15" r="4" fill="none" stroke="rgba(255,200,170,0.35)" strokeWidth="0.6" />
        <text x="62" y="17.4" textAnchor="middle" fontSize="6" fontFamily="Cinzel, serif" fontWeight="700" fill="rgba(255,220,190,0.75)">
          H
        </text>
        <path d="M56 12 q3 -3 6 0" stroke="rgba(255,230,210,0.5)" strokeWidth="0.8" fill="none" />
      </svg>
    </span>
  )
}

export function Hourglass({ className }: PropProps) {
  return (
    <span className={wrap('hourglass', className)} aria-hidden="true">
      <svg viewBox="0 0 48 90" className="prop-svg">
        <defs>
          <linearGradient id="hg-wood" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#2a160c" />
            <stop offset="0.35" stopColor="#7a4a26" />
            <stop offset="0.5" stopColor="#a06a3a" />
            <stop offset="0.7" stopColor="#5a3418" />
            <stop offset="1" stopColor="#1e0e06" />
          </linearGradient>
          <linearGradient id="hg-brass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#6a4a14" />
            <stop offset="0.4" stopColor="#f0d078" />
            <stop offset="0.55" stopColor="#fff2c0" />
            <stop offset="0.75" stopColor="#c9a45a" />
            <stop offset="1" stopColor="#5a3a10" />
          </linearGradient>
          <linearGradient id="hg-glass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="rgba(255,255,255,0.32)" />
            <stop offset="0.3" stopColor="rgba(255,255,255,0.06)" />
            <stop offset="0.7" stopColor="rgba(255,255,255,0.04)" />
            <stop offset="1" stopColor="rgba(255,255,255,0.22)" />
          </linearGradient>
          <linearGradient id="hg-sand" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#f6dc94" />
            <stop offset="1" stopColor="#b98a2e" />
          </linearGradient>
        </defs>
        {/* posts */}
        <rect x="5" y="10" width="3" height="72" fill="url(#hg-wood)" />
        <rect x="40" y="10" width="3" height="72" fill="url(#hg-wood)" />
        <rect x="22.5" y="10" width="3" height="72" fill="url(#hg-wood)" opacity="0.55" />
        <g fill="url(#hg-brass)">
          <rect x="4" y="22" width="5" height="2.2" />
          <rect x="4" y="66" width="5" height="2.2" />
          <rect x="39" y="22" width="5" height="2.2" />
          <rect x="39" y="66" width="5" height="2.2" />
        </g>
        {/* glass */}
        <path
          d="M11 12 C 11 30, 22 38, 23.4 46 C 22 54, 11 62, 11 80 L 37 80 C 37 62, 26 54, 24.6 46 C 26 38, 37 30, 37 12 Z"
          fill="rgba(200,220,240,0.08)"
          stroke="rgba(255,255,255,0.35)"
          strokeWidth="0.9"
        />
        {/* sand top */}
        <path d="M14.5 26 C 16 33, 22 37, 23.4 44 L 24.6 44 C 26 37, 32 33, 33.5 26 Z" fill="url(#hg-sand)" />
        {/* stream */}
        <rect x="23.4" y="44" width="1.2" height="26" fill="#f0d078" opacity="0.9" />
        {/* sand bottom */}
        <path d="M13 80 C 15 70, 20 66, 24 64 C 28 66, 33 70, 35 80 Z" fill="url(#hg-sand)" />
        <path d="M13 80 h22" stroke="#8a6222" strokeWidth="0.6" />
        {/* glass sheen */}
        <path
          d="M11 12 C 11 30, 22 38, 23.4 46 C 22 54, 11 62, 11 80 L 37 80 C 37 62, 26 54, 24.6 46 C 26 38, 37 30, 37 12 Z"
          fill="url(#hg-glass)"
        />
        <path d="M14 16 C 14 28, 20 34, 21 40" stroke="rgba(255,255,255,0.55)" strokeWidth="1" fill="none" strokeLinecap="round" />
        {/* caps */}
        <rect x="2" y="4" width="44" height="8" rx="2" fill="url(#hg-wood)" />
        <rect x="2" y="80" width="44" height="8" rx="2" fill="url(#hg-wood)" />
        <rect x="2" y="10.5" width="44" height="1.8" fill="url(#hg-brass)" />
        <rect x="2" y="79.5" width="44" height="1.8" fill="url(#hg-brass)" />
        <rect x="4" y="2" width="40" height="3" rx="1" fill="url(#hg-brass)" />
        <rect x="4" y="87" width="40" height="3" rx="1" fill="url(#hg-brass)" />
      </svg>
    </span>
  )
}

export function CrystalBall({ className }: PropProps) {
  return (
    <span className={wrap('orb', className)} aria-hidden="true">
      <svg viewBox="0 0 72 93.5" className="prop-svg">
        <defs>
          <radialGradient id="cb-glow" cx="0.5" cy="0.5" r="0.5">
            <stop offset="0" stopColor="rgba(170,110,255,0.55)" />
            <stop offset="1" stopColor="rgba(170,110,255,0)" />
          </radialGradient>
          <radialGradient id="cb-sphere" cx="0.38" cy="0.32" r="0.75">
            <stop offset="0" stopColor="#c9b6ff" />
            <stop offset="0.25" stopColor="#6a4ad0" />
            <stop offset="0.6" stopColor="#2a1668" />
            <stop offset="1" stopColor="#0c0630" />
          </radialGradient>
          <radialGradient id="cb-neb" cx="0.6" cy="0.62" r="0.5">
            <stop offset="0" stopColor="rgba(255,150,220,0.7)" />
            <stop offset="0.5" stopColor="rgba(120,80,255,0.35)" />
            <stop offset="1" stopColor="rgba(120,80,255,0)" />
          </radialGradient>
          <radialGradient id="cb-hi" cx="0.5" cy="0.5" r="0.5">
            <stop offset="0" stopColor="rgba(255,255,255,0.95)" />
            <stop offset="1" stopColor="rgba(255,255,255,0)" />
          </radialGradient>
          <linearGradient id="cb-gold" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#5a3a10" />
            <stop offset="0.4" stopColor="#f0d078" />
            <stop offset="0.55" stopColor="#fff4cc" />
            <stop offset="0.75" stopColor="#c9a45a" />
            <stop offset="1" stopColor="#4a2e0c" />
          </linearGradient>
          <filter id="cb-blur" x="-40%" y="-40%" width="180%" height="180%">
            <feGaussianBlur stdDeviation="2.4" />
          </filter>
        </defs>
        <circle cx="36" cy="36" r="36" fill="url(#cb-glow)" className="orb-halo" />
        {/* stand */}
        <g fill="url(#cb-gold)">
          <path d="M14 90 L 22 76 L 30 78 L 24 90 Z" />
          <path d="M58 90 L 50 76 L 42 78 L 48 90 Z" />
          <path d="M31 90 L 36 74 L 41 90 Z" />
          <ellipse cx="36" cy="90" rx="24" ry="3.4" />
          <ellipse cx="36" cy="88" rx="22" ry="2.6" fill="#f0d078" opacity="0.5" />
          <path d="M14 70 C 18 64, 28 62, 36 62 C 44 62, 54 64, 58 70 C 54 74, 44 76, 36 76 C 28 76, 18 74, 14 70 Z" />
        </g>
        <path d="M18 70 C 24 66, 30 65, 36 65 C 42 65, 48 66, 54 70" stroke="rgba(255,244,204,0.6)" strokeWidth="1" fill="none" />
        <g stroke="#5a3a10" strokeWidth="0.6" fill="none" opacity="0.7">
          <path d="M22 76 l-3 8 M30 78 l-4 8 M50 76 l3 8 M42 78 l4 8" />
        </g>
        {/* sphere */}
        <circle cx="36" cy="38" r="27" fill="url(#cb-sphere)" />
        <ellipse cx="42" cy="46" rx="14" ry="9" fill="url(#cb-neb)" filter="url(#cb-blur)" className="orb-nebula" />
        <path
          d="M22 44 C 28 36, 40 34, 48 40 C 42 42, 34 48, 28 54"
          stroke="rgba(255,190,240,0.35)"
          strokeWidth="1.6"
          fill="none"
          strokeLinecap="round"
          filter="url(#cb-blur)"
        />
        <g fill="#fff" opacity="0.8">
          <circle cx="30" cy="42" r="0.7" />
          <circle cx="44" cy="30" r="0.5" />
          <circle cx="40" cy="52" r="0.6" />
          <circle cx="26" cy="32" r="0.45" />
          <circle cx="48" cy="48" r="0.4" />
        </g>
        <ellipse cx="26" cy="26" rx="8" ry="5" fill="url(#cb-hi)" transform="rotate(-30 26 26)" />
        <path d="M18 46 C 20 56, 30 62, 40 62" stroke="rgba(255,255,255,0.28)" strokeWidth="1.2" fill="none" strokeLinecap="round" />
        <circle cx="36" cy="38" r="27" fill="none" stroke="rgba(255,255,255,0.28)" strokeWidth="0.7" />
      </svg>
    </span>
  )
}

export function Inkwell({ className }: PropProps) {
  return (
    <span className={wrap('inkwell', className)} aria-hidden="true">
      <svg viewBox="0 0 80 92" className="prop-svg">
        <defs>
          <linearGradient id="ik-glass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#0c1418" />
            <stop offset="0.25" stopColor="#24363e" />
            <stop offset="0.45" stopColor="#0c1418" />
            <stop offset="0.7" stopColor="#1c2a30" />
            <stop offset="1" stopColor="#060a0c" />
          </linearGradient>
          <linearGradient id="ik-brass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#5a3a10" />
            <stop offset="0.4" stopColor="#f0d078" />
            <stop offset="0.55" stopColor="#fff2c0" />
            <stop offset="0.75" stopColor="#c9a45a" />
            <stop offset="1" stopColor="#4a2e0c" />
          </linearGradient>
          <linearGradient id="ik-feather" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#f8f2e4" />
            <stop offset="0.5" stopColor="#e3d6bd" />
            <stop offset="1" stopColor="#b8a688" />
          </linearGradient>
          <linearGradient id="ik-shaft" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#fff9ec" />
            <stop offset="1" stopColor="#c9b892" />
          </linearGradient>
        </defs>
        {/* quill */}
        <g transform="rotate(26 40 92)">
          <path
            d="M40 92 C 39 60, 36 40, 42 8 C 48 28, 52 44, 50 70 C 49 80, 45 88, 40 92 Z"
            fill="url(#ik-feather)"
          />
          <path d="M40 92 C 41 62, 42 40, 42 10" stroke="url(#ik-shaft)" strokeWidth="1.6" fill="none" />
          <g stroke="rgba(120,100,70,0.35)" strokeWidth="0.5" fill="none">
            <path d="M42 24 l6 4 M42 30 l7 5 M42 36 l7 6 M42 42 l7 7 M42 48 l6 8 M42 54 l6 8 M42 60 l5 9" />
            <path d="M41 26 l-3 4 M41 32 l-3 5 M41 38 l-3 6" />
          </g>
          <path d="M40 92 C 39.5 86, 39 80, 39.5 74" stroke="#4a3a20" strokeWidth="1.4" fill="none" strokeLinecap="round" />
          <path d="M39.6 92 l-1.2 4" stroke="#1a1410" strokeWidth="1.4" strokeLinecap="round" />
        </g>
        {/* pot body: faceted glass */}
        <path d="M12 60 L 18 50 L 50 50 L 56 60 L 56 92 L 12 92 Z" fill="url(#ik-glass)" />
        <path d="M12 60 L 56 60" stroke="rgba(255,255,255,0.18)" strokeWidth="0.8" />
        <path d="M18 50 L 12 60 L 12 92" stroke="rgba(255,255,255,0.3)" strokeWidth="0.8" fill="none" />
        <path d="M24 92 L 24 60 L 28 50" stroke="rgba(255,255,255,0.12)" strokeWidth="0.8" fill="none" />
        <path d="M44 92 L 44 60 L 40 50" stroke="rgba(255,255,255,0.1)" strokeWidth="0.8" fill="none" />
        <path d="M14 66 L 22 66 L 22 90 L 14 90 Z" fill="rgba(255,255,255,0.08)" />
        {/* ink surface */}
        <ellipse cx="34" cy="50" rx="16" ry="4" fill="#06080a" />
        <ellipse cx="30" cy="49.5" rx="7" ry="1.6" fill="rgba(120,160,200,0.22)" />
        {/* brass collar + open lid */}
        <path d="M16 48 h36 v4 h-36 z" fill="url(#ik-brass)" />
        <ellipse cx="34" cy="48" rx="18" ry="3" fill="url(#ik-brass)" />
        <ellipse cx="34" cy="48" rx="14" ry="2" fill="#0a0c10" />
        <g transform="rotate(-62 52 47)">
          <ellipse cx="52" cy="47" rx="15" ry="3.2" fill="url(#ik-brass)" />
          <ellipse cx="52" cy="46.4" rx="11" ry="1.8" fill="#8a6222" opacity="0.7" />
        </g>
        <circle cx="52" cy="47" r="1.6" fill="#f0d078" />
        {/* ink drop */}
        <path d="M60 68 c 0 -2 1.5 -4 1.5 -4 s 1.5 2 1.5 4 a 1.5 1.5 0 0 1 -3 0 z" fill="#0c1418" opacity="0.9" />
      </svg>
    </span>
  )
}

export function PotionVials({ className }: PropProps) {
  return (
    <span className={wrap('potions', className)} aria-hidden="true">
      <svg viewBox="0 0 110 84" className="prop-svg">
        <defs>
          <radialGradient id="pv-green" cx="0.45" cy="0.7" r="0.7">
            <stop offset="0" stopColor="#c6ff9a" />
            <stop offset="0.45" stopColor="#3fbf5a" />
            <stop offset="1" stopColor="#0d4020" />
          </radialGradient>
          <radialGradient id="pv-pink" cx="0.45" cy="0.7" r="0.7">
            <stop offset="0" stopColor="#ffd6f2" />
            <stop offset="0.5" stopColor="#e64aa8" />
            <stop offset="1" stopColor="#5a0c3a" />
          </radialGradient>
          <radialGradient id="pv-amber" cx="0.45" cy="0.7" r="0.7">
            <stop offset="0" stopColor="#ffe9a8" />
            <stop offset="0.5" stopColor="#e0912a" />
            <stop offset="1" stopColor="#5a2c08" />
          </radialGradient>
          <linearGradient id="pv-glass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="rgba(255,255,255,0.42)" />
            <stop offset="0.25" stopColor="rgba(255,255,255,0.06)" />
            <stop offset="0.75" stopColor="rgba(255,255,255,0.03)" />
            <stop offset="1" stopColor="rgba(255,255,255,0.28)" />
          </linearGradient>
          <linearGradient id="pv-cork" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#6a4a26" />
            <stop offset="0.5" stopColor="#b98a52" />
            <stop offset="1" stopColor="#5a3a1a" />
          </linearGradient>
          <linearGradient id="pv-label" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#f4e8cc" />
            <stop offset="1" stopColor="#d4c096" />
          </linearGradient>
          <filter id="pv-glow" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="3" />
          </filter>
        </defs>
        {/* glows */}
        <ellipse cx="26" cy="66" rx="18" ry="14" fill="rgba(80,220,110,0.28)" filter="url(#pv-glow)" className="potion-glow" />
        <ellipse cx="58" cy="60" rx="10" ry="18" fill="rgba(230,80,170,0.25)" filter="url(#pv-glow)" className="potion-glow b" />
        <ellipse cx="90" cy="66" rx="14" ry="14" fill="rgba(240,150,40,0.24)" filter="url(#pv-glow)" className="potion-glow c" />

        {/* round flask (green) */}
        <g>
          <path d="M20 30 h12 v14 c 10 4 14 14 14 24 a 20 20 0 0 1 -40 0 c 0 -10 4 -20 14 -24 z" fill="rgba(180,230,200,0.12)" />
          <path d="M8 66 a 18 18 0 0 0 36 0 c 0 -8 -4 -15 -12 -19 h-12 c -8 4 -12 11 -12 19 z" fill="url(#pv-green)" />
          <circle cx="18" cy="70" r="1.2" fill="rgba(255,255,255,0.7)" />
          <circle cx="30" cy="62" r="0.8" fill="rgba(255,255,255,0.7)" />
          <circle cx="24" cy="76" r="0.6" fill="rgba(255,255,255,0.6)" />
          <path d="M20 30 h12 v14 c 10 4 14 14 14 24 a 20 20 0 0 1 -40 0 c 0 -10 4 -20 14 -24 z" fill="url(#pv-glass)" />
          <path d="M14 56 c -2 6 -2 12 0 18" stroke="rgba(255,255,255,0.6)" strokeWidth="1.4" fill="none" strokeLinecap="round" />
          <rect x="19" y="22" width="14" height="10" rx="2" fill="url(#pv-cork)" />
          <path d="M19 26 h14" stroke="rgba(0,0,0,0.3)" strokeWidth="0.6" />
          <rect x="14" y="58" width="24" height="10" fill="url(#pv-label)" transform="rotate(-6 26 63)" />
          <path d="M18 62 h14 M19 65 h10" stroke="#5a3a18" strokeWidth="0.8" transform="rotate(-6 26 63)" />
        </g>

        {/* tall vial (pink) */}
        <g>
          <path d="M52 22 h12 v52 a 6 6 0 0 1 -12 0 z" fill="rgba(255,200,240,0.12)" />
          <path d="M52 44 h12 v30 a 6 6 0 0 1 -12 0 z" fill="url(#pv-pink)" />
          <circle cx="56" cy="58" r="0.8" fill="rgba(255,255,255,0.7)" />
          <circle cx="60" cy="68" r="0.6" fill="rgba(255,255,255,0.7)" />
          <path d="M52 22 h12 v52 a 6 6 0 0 1 -12 0 z" fill="url(#pv-glass)" />
          <path d="M54.5 26 v40" stroke="rgba(255,255,255,0.6)" strokeWidth="1.2" strokeLinecap="round" />
          <path d="M50 20 h16 v4 h-16z" fill="url(#pv-cork)" />
          <rect x="50" y="14" width="16" height="7" rx="1.5" fill="url(#pv-cork)" />
          <path d="M50 22 h16" stroke="#f0d078" strokeWidth="1" />
          <path d="M66 24 c 3 6 4 10 2 14" stroke="#ae1a12" strokeWidth="1.2" fill="none" />
        </g>

        {/* square bottle (amber) */}
        <g>
          <path d="M84 36 h12 v6 l 6 4 v36 h-24 v-36 l 6 -4 z" fill="rgba(255,220,160,0.12)" />
          <path d="M78 56 h24 v26 h-24 z" fill="url(#pv-amber)" />
          <circle cx="92" cy="66" r="0.9" fill="rgba(255,255,255,0.7)" />
          <path d="M84 36 h12 v6 l 6 4 v36 h-24 v-36 l 6 -4 z" fill="url(#pv-glass)" />
          <path d="M80 48 v30" stroke="rgba(255,255,255,0.55)" strokeWidth="1.4" strokeLinecap="round" />
          <rect x="83" y="30" width="14" height="8" rx="2" fill="url(#pv-cork)" />
          <rect x="82" y="60" width="16" height="12" fill="url(#pv-label)" />
          <path d="M85 64 h10 M86 67 h7" stroke="#5a3a18" strokeWidth="0.8" />
          <circle cx="90" cy="70" r="1" fill="#8a1c14" />
        </g>
      </svg>
    </span>
  )
}

export function Lantern({ className }: PropProps) {
  return (
    <span className={wrap('lantern', className)} aria-hidden="true">
      <svg viewBox="0 0 60 104" className="prop-svg">
        <defs>
          <linearGradient id="ln-brass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="#3a2408" />
            <stop offset="0.35" stopColor="#c9a45a" />
            <stop offset="0.5" stopColor="#fff0c0" />
            <stop offset="0.7" stopColor="#b98a2e" />
            <stop offset="1" stopColor="#2a1806" />
          </linearGradient>
          <radialGradient id="ln-flame" cx="0.5" cy="0.8" r="0.6">
            <stop offset="0" stopColor="#fffbe6" />
            <stop offset="0.3" stopColor="#ffd77a" />
            <stop offset="0.7" stopColor="#f07a1c" />
            <stop offset="1" stopColor="rgba(240,90,20,0)" />
          </radialGradient>
          <radialGradient id="ln-glow" cx="0.5" cy="0.5" r="0.5">
            <stop offset="0" stopColor="rgba(255,190,90,0.7)" />
            <stop offset="1" stopColor="rgba(255,150,50,0)" />
          </radialGradient>
          <linearGradient id="ln-glass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stopColor="rgba(255,240,200,0.32)" />
            <stop offset="0.5" stopColor="rgba(255,240,200,0.06)" />
            <stop offset="1" stopColor="rgba(255,240,200,0.22)" />
          </linearGradient>
        </defs>
        <circle cx="30" cy="62" r="30" fill="url(#ln-glow)" className="lantern-glow" />
        {/* ring handle */}
        <path d="M30 4 a 8 8 0 1 0 0.01 0" fill="none" stroke="url(#ln-brass)" strokeWidth="2.6" />
        <rect x="27" y="12" width="6" height="6" fill="url(#ln-brass)" />
        {/* cap */}
        <path d="M12 30 L 30 16 L 48 30 Z" fill="url(#ln-brass)" />
        <path d="M14 30 h32 v4 h-32 z" fill="url(#ln-brass)" />
        <path d="M22 22 h16" stroke="rgba(0,0,0,0.35)" strokeWidth="0.8" />
        <g stroke="rgba(0,0,0,0.4)" strokeWidth="0.6">
          <path d="M18 27 l4 -3 M38 24 l4 3" />
        </g>
        {/* glass body */}
        <rect x="14" y="34" width="32" height="54" fill="rgba(255,220,160,0.1)" />
        <ellipse cx="30" cy="70" rx="10" ry="16" fill="url(#ln-flame)" opacity="0.55" filter="blur(2px)" />
        {/* candle */}
        <rect x="26" y="62" width="8" height="24" fill="#f4e8cc" />
        <path d="M26 66 c 0 3 2 4 2 7 c 0 2 -2 3 -2 3 z" fill="#fffaf0" />
        <rect x="29.4" y="58" width="1.2" height="5" fill="#1a1008" />
        <path d="M30 60 c -3 -6 -2 -12 0 -16 c 2 4 3 10 0 16 z" fill="url(#ln-flame)" className="lantern-flame" />
        {/* glass panes */}
        <rect x="14" y="34" width="32" height="54" fill="url(#ln-glass)" />
        <g fill="url(#ln-brass)">
          <rect x="12" y="34" width="3" height="54" />
          <rect x="45" y="34" width="3" height="54" />
          <rect x="28.8" y="34" width="2.4" height="54" opacity="0.9" />
          <rect x="12" y="60" width="36" height="2" opacity="0.9" />
        </g>
        <path d="M17 38 v46" stroke="rgba(255,255,255,0.35)" strokeWidth="1" strokeLinecap="round" />
        {/* base */}
        <rect x="10" y="88" width="40" height="6" rx="1.5" fill="url(#ln-brass)" />
        <rect x="14" y="94" width="32" height="4" fill="url(#ln-brass)" />
        <rect x="8" y="98" width="44" height="6" rx="2" fill="url(#ln-brass)" />
        <g fill="#fff0c0" opacity="0.7">
          <circle cx="14" cy="91" r="0.9" />
          <circle cx="46" cy="91" r="0.9" />
        </g>
      </svg>
    </span>
  )
}
