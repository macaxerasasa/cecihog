import type { BookData } from '../types'

export function BookCover({ book }: { book: BookData }) {
  return (
    <div className="cover-title">
      <div className="roman">{book.category === 'year' ? `Tomo  ${book.shortTitle}` : 'Estante-Mãe'}</div>
      <h2>{book.title}</h2>
      <div className="motto">“{book.motto}”</div>
    </div>
  )
}
