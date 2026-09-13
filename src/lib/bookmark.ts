/**
 * Hands a page number from one tome to the next: the spell finder in book A
 * asks to open book B on the leaf of a given spell. The bookmark stays until
 * that book is closed, so a remount (StrictMode, resize) lands on the same
 * leaf.
 */
let pending: { bookId: string; spread: number } | null = null

export function setBookmark(bookId: string, spread: number) {
  pending = { bookId, spread }
}

export function peekBookmark(bookId: string | undefined): number {
  return bookId && pending?.bookId === bookId ? pending.spread : 0
}

export function clearBookmark(bookId: string | undefined) {
  if (bookId && pending?.bookId === bookId) pending = null
}
