import { copyFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import react from '@vitejs/plugin-react'
import { defineConfig, type Plugin } from 'vite'

/* GitHub Pages has no rewrites: serving index.html as 404.html lets /tomo/<id> load the app. */
const spaFallback = (): Plugin => {
  let outDir = 'dist'
  return {
    name: 'spa-fallback-404',
    apply: 'build',
    configResolved(config) {
      outDir = resolve(config.root, config.build.outDir)
    },
    closeBundle() {
      copyFileSync(join(outDir, 'index.html'), join(outDir, '404.html'))
    },
  }
}

// GitHub Pages serves project sites from /<repo>/; the deploy workflow sets VITE_BASE.
const base = process.env.VITE_BASE || '/'

export default defineConfig({
  base,
  plugins: [react(), spaFallback()],
  server: {
    host: '127.0.0.1',
    port: 45217,
    strictPort: true,
  },
  preview: {
    host: '127.0.0.1',
    port: 45217,
    strictPort: true,
  },
})
