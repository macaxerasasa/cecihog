import type { ReactNode } from 'react'

type Props = {
  awake: boolean
  busy: boolean
  reading?: boolean
  holding?: boolean
  children: ReactNode
}

export function LibraryEnvironment({ awake, busy, reading, holding, children }: Props) {
  return (
    <div
      className={`library ${awake ? 'is-awake' : 'is-boot'} ${busy ? 'is-busy' : ''} ${reading ? 'is-reading' : ''} ${holding ? 'is-holding' : ''}`}
    >
      <div className="stone-wall" aria-hidden="true" />
      <div className="wall-grain" />
      <div className="window-light a" aria-hidden="true" />
      <div className="window-light b" aria-hidden="true" />
      <div className="floor" aria-hidden="true" />
      {children}
    </div>
  )
}
