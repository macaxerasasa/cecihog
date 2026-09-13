import { asset } from './asset'

const HALL_ART = [
  'art/hall.webp',
  'art/hall-portrait.webp',
  'art/case.webp',
  'art/case-portrait.webp',
  'art/wood.webp',
  'art/leather.webp',
  'art/parchment.webp',
  'art/prop-candelabra.webp',
  'crests/gryffindor.webp',
  'crests/slytherin.webp',
  'crests/ravenclaw.webp',
  'crests/hufflepuff.webp',
]

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

const READER_ART = ['art/cover-frame.webp', 'art/cover-medallion.webp', 'art/page-border.webp']

let readerStarted = false

/* Fetch and decode the textures every open tome uses, so the first click does
   not pay for image decoding in the middle of the flight animation. */
export function preloadReaderArt() {
  if (readerStarted || typeof window === 'undefined') return
  readerStarted = true
  for (const path of READER_ART) {
    const img = new Image()
    img.decoding = 'async'
    img.src = asset(path)
    img.decode().catch(() => {})
  }
  if (document.fonts) {
    void document.fonts.load('400 16px Alegreya')
    void document.fonts.load('italic 400 16px Alegreya')
    void document.fonts.load('700 16px Alegreya')
    void document.fonts.load('400 16px "Almendra SC"')
    void document.fonts.load('400 16px "Almendra Display"')
  }
}
