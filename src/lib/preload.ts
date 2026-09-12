import { asset } from './asset'

const HALL_ART = ['art/hall.webp', 'art/hall-portrait.webp', 'art/wood.webp', 'art/leather.webp', 'art/parchment.webp']

let started = false

/* Warm the browser cache while the visitor is still at the gate, so the hall
   reveals fully painted instead of popping textures in one by one. */
export function preloadHallArt() {
  if (started || typeof window === 'undefined') return
  started = true
  const portrait = window.matchMedia('(orientation: portrait)').matches
  const list = HALL_ART.filter((p) => (portrait ? p !== 'art/hall.webp' : p !== 'art/hall-portrait.webp'))
  for (const path of list) {
    const img = new Image()
    img.decoding = 'async'
    img.src = asset(path)
  }
}
