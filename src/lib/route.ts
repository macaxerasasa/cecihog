/*
 * Each open tome has its own address (`/tomo/<id>`), so a book can be linked
 * to, the back button closes it, and hosts can serve it as a page — while the
 * hall itself never reloads.
 */
const BASE = import.meta.env.BASE_URL.replace(/\/?$/, '/')

export const hallPath = () => BASE

export const bookPath = (id: string) => `${BASE}tomo/${id}`

/** Book id named by the current address, or null for the hall. */
export function readRoute(pathname = window.location.pathname): string | null {
  const rel = pathname.startsWith(BASE) ? pathname.slice(BASE.length) : pathname.replace(/^\//, '')
  const m = rel.match(/^tomo\/([a-z0-9-]+)\/?$/i)
  return m ? m[1] : null
}

/** Points the address at a tome (or the hall) without reloading. */
export function syncRoute(id: string | null, replace = false) {
  const target = id ? bookPath(id) : hallPath()
  if (window.location.pathname === target) return
  const url = target + window.location.search
  if (replace) window.history.replaceState({ book: id }, '', url)
  else window.history.pushState({ book: id }, '', url)
}
