import { createContext, useContext } from 'react'

export type BookNav = {
  /** Id of the tome currently open. */
  bookId: string
  /** Jump to a spread of the open tome. */
  goTo: (spread: number) => void
  /** Open the leaf of a spell, turning to another tome when needed. */
  openSpell: (id: string) => void
  /** Open a skill or race verbete in the open sheet. */
  openGift: (id: string) => void
}

export const BookNavContext = createContext<BookNav | null>(null)

export const useBookNav = () => useContext(BookNavContext)
