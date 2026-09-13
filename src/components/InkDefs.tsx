/*
 * Shared SVG paint servers for the castle plan: the hand-drawn wobble, the
 * hatching that shades the walls, and the footprint / tree glyphs the map
 * stamps many times over.
 */
export function InkDefs() {
  return (
    <defs>
      <filter id="wobble" x="-2%" y="-2%" width="104%" height="104%" colorInterpolationFilters="sRGB">
        <feTurbulence type="fractalNoise" baseFrequency="0.011" numOctaves="2" seed="11" result="n" />
        <feDisplacementMap in="SourceGraphic" in2="n" scale="2.4" xChannelSelector="R" yChannelSelector="G" />
      </filter>

      <pattern id="hatch" width="7" height="7" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
        <line x1="0" y1="0" x2="0" y2="7" stroke="var(--ink)" strokeWidth="0.9" opacity="0.32" />
      </pattern>

      <pattern id="water" width="46" height="14" patternUnits="userSpaceOnUse">
        <path
          d="M0 7 q 5.75 -5 11.5 0 t 11.5 0 t 11.5 0 t 11.5 0"
          fill="none"
          stroke="var(--ink)"
          strokeWidth="0.9"
          opacity="0.42"
        />
      </pattern>

      {/* a bare foot, toes pointing +x, about 14 × 26 units */}
      <symbol id="foot" viewBox="-8 -14 16 28" overflow="visible">
        <ellipse cx="0" cy="3" rx="4.6" ry="7.5" fill="var(--ink)" />
        <ellipse cx="-0.6" cy="-3" rx="4.2" ry="5" fill="var(--ink)" />
        <circle cx="-1.2" cy="-9.4" r="1.9" fill="var(--ink)" />
        <circle cx="1.6" cy="-10.4" r="1.6" fill="var(--ink)" />
        <circle cx="4" cy="-9.4" r="1.4" fill="var(--ink)" />
        <circle cx="-4.4" cy="-8.2" r="1.5" fill="var(--ink)" />
        <circle cx="5.9" cy="-7.6" r="1.1" fill="var(--ink)" />
      </symbol>

      {/* a cat's paw: the pad and four toes, toes toward -y */}
      <symbol id="paw" viewBox="-8 -8 16 16" overflow="visible">
        <ellipse cx="0" cy="2.4" rx="3.9" ry="3.1" fill="var(--ink)" />
        <ellipse cx="-4.6" cy="-1.2" rx="1.5" ry="1.9" fill="var(--ink)" transform="rotate(-20 -4.6 -1.2)" />
        <ellipse cx="-1.7" cy="-4.2" rx="1.5" ry="1.9" fill="var(--ink)" />
        <ellipse cx="1.7" cy="-4.2" rx="1.5" ry="1.9" fill="var(--ink)" />
        <ellipse cx="4.6" cy="-1.2" rx="1.5" ry="1.9" fill="var(--ink)" transform="rotate(20 4.6 -1.2)" />
      </symbol>

      {/* a pine of the Forbidden Forest */}
      <symbol id="pine" viewBox="0 0 20 30" overflow="visible">
        <path
          d="M10 1 L15 10 L12.5 10 L17.5 18 L14.5 18 L19 26 L11.2 26 L11.2 29.5 L8.8 29.5 L8.8 26 L1 26 L5.5 18 L2.5 18 L7.5 10 L5 10 Z"
          fill="none"
          stroke="var(--ink)"
          strokeWidth="1.1"
          strokeLinejoin="round"
        />
        <path d="M10 6 V 24" stroke="var(--ink)" strokeWidth="0.8" opacity="0.5" />
      </symbol>

      {/* a small round tower seen from above */}
      <symbol id="tower" viewBox="-20 -20 40 40" overflow="visible">
        <circle r="17" fill="none" stroke="var(--ink)" strokeWidth="2" />
        <circle r="12" fill="url(#hatch)" stroke="var(--ink)" strokeWidth="0.9" />
        {Array.from({ length: 8 }, (_, i) => {
          const a = (i / 8) * Math.PI * 2
          return (
            <rect
              key={i}
              x={-2.2}
              y={-19.5}
              width={4.4}
              height={4}
              fill="var(--ink)"
              transform={`rotate(${(a * 180) / Math.PI})`}
            />
          )
        })}
      </symbol>

      {/* a flight of stairs, drawn along +y */}
      <symbol id="stair" viewBox="0 0 30 40" overflow="visible">
        {Array.from({ length: 7 }, (_, i) => (
          <line key={i} x1="3" y1={4 + i * 5.2} x2="27" y2={4 + i * 5.2} stroke="var(--ink)" strokeWidth="1.2" />
        ))}
        <path d="M3 2 V 38 M27 2 V 38" stroke="var(--ink)" strokeWidth="1.4" fill="none" />
        <path d="M15 5 L15 34 M11 30 L15 35 L19 30" stroke="var(--ink)" strokeWidth="0.9" fill="none" opacity="0.6" />
      </symbol>
    </defs>
  )
}
