import type { ReactNode } from 'react'

type Props = {
  awake: boolean
  busy: boolean
  children: ReactNode
}

export function LibraryEnvironment({ awake, busy, children }: Props) {
  return (
    <div className={`library ${awake ? 'is-awake' : 'is-boot'} ${busy ? 'is-busy' : ''}`}>
      <div className="wall-grain" />
      {children}
    </div>
  )
}
