import { asset } from './asset'

const SHEET_ART = ['art/parchment.webp']

let started = false

/* Warm the textures a fold-out needs while the visitor is still reading the
   plan, so the first sheet unfolds already painted. */
export function preloadSheetArt() {
  if (started || typeof window === 'undefined') return
  started = true
  for (const path of SHEET_ART) {
    const img = new Image()
    img.decoding = 'async'
    img.src = asset(path)
    img.decode().catch(() => {})
  }
  if (document.fonts) {
    void document.fonts.load('400 16px "IM Fell English"')
    void document.fonts.load('italic 400 16px "IM Fell English"')
    void document.fonts.load('400 16px "IM Fell English SC"')
  }
}
