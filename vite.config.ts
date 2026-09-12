import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// GitHub Pages serves project sites from /<repo>/; the deploy workflow sets VITE_BASE.
const base = process.env.VITE_BASE || '/'

export default defineConfig({
  base,
  plugins: [react()],
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
