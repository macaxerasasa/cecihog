import { useCallback, useEffect, useState } from 'react'

export function useShelfScale(baseWidth = 1180, baseHeight = 760) {
  const compute = useCallback(() => {
    const w = window.innerWidth
    const h = window.innerHeight
    const sx = (w * 0.96) / baseWidth
    const sy = (h * 0.9) / baseHeight
    return Math.min(1, sx, sy)
  }, [baseWidth, baseHeight])

  const [scale, setScale] = useState(1)

  useEffect(() => {
    const onResize = () => setScale(compute())
    onResize()
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [compute])

  return scale
}
