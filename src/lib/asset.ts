/**
 * Resolve a file from `public/` against Vite's base URL, so the site also
 * works when served from a sub-path such as GitHub Pages (`/cecihog/`).
 */
/* bump when a public/art file is replaced in place, so Vercel/CDN clients
   that cached the old bytes (the art route used to be immutable) refetch */
const ART_REV = '4'

export function asset(path: string): string {
  const url = `${import.meta.env.BASE_URL}${path.replace(/^\//, '')}`
  if (path.startsWith('art/')) return `${url}?v=${ART_REV}`
  return url
}
