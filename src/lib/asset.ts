/**
 * Resolve a file from `public/` against Vite's base URL, so the site also
 * works when served from a sub-path such as GitHub Pages (`/cecihog/`).
 */
export function asset(path: string): string {
  return `${import.meta.env.BASE_URL}${path.replace(/^\//, '')}`
}
