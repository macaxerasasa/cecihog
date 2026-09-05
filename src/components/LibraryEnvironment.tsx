import type { ReactNode } from 'react'

type Props = {
  awake: boolean
  busy: boolean
  reading?: boolean
  children: ReactNode
}

export function LibraryEnvironment({ awake, busy, reading, children }: Props) {
  return (
    <div
      className={`library ${awake ? 'is-awake' : 'is-boot'} ${busy ? 'is-busy' : ''} ${reading ? 'is-reading' : ''}`}
    >
      <div className="wall-grain" />
      {children}
    </div>
  )
}
