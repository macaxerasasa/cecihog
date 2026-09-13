import { memo, type ReactNode } from 'react'
import { asset } from '../lib/asset'

type PropProps = { className?: string }

/*
 * Painted shelf clutter. Each prop is a cut-out render (alpha WebP); the
 * things that should live — the orb's mist, the potions, the lantern's
 * candle — get a light overlay animated in CSS on top of the picture.
 */
const Prop = memo(function Prop({ name, className = '', children }: PropProps & { name: string; children?: ReactNode }) {
  return (
    <span className={`shelf-prop ${name} ${className}`} aria-hidden="true">
      <img className="prop-art" src={asset(`art/prop-${name}.webp`)} alt="" draggable={false} />
      {children}
    </span>
  )
})

export function ScrollStack({ className }: PropProps) {
  return <Prop name="scrolls" className={className} />
}

export function Hourglass({ className }: PropProps) {
  return <Prop name="hourglass" className={className} />
}

export function CrystalBall({ className }: PropProps) {
  return (
    <Prop name="orb" className={className}>
      <i className="orb-halo" />
      <i className="orb-nebula" />
    </Prop>
  )
}

export function Inkwell({ className }: PropProps) {
  return <Prop name="inkwell" className={className} />
}

export function PotionVials({ className }: PropProps) {
  return (
    <Prop name="potions" className={className}>
      <i className="potion-glow a" />
      <i className="potion-glow b" />
      <i className="potion-glow c" />
    </Prop>
  )
}

export function Lantern({ className }: PropProps) {
  return (
    <Prop name="lantern" className={className}>
      <i className="lantern-glow" />
      <i className="lantern-flame" />
    </Prop>
  )
}

export function FlatStack({ className }: PropProps) {
  return <Prop name="stack" className={className} />
}
