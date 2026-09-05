import type { BookData } from '../types'

export function BookCover({ book }: { book: BookData }) {
  const kicker = book.category === 'year' ? `Ano ${book.shortTitle}` : 'Hogwarts'
  const monogram = book.category === 'year' ? book.shortTitle : book.title.charAt(0)
  return (
    <div className="cover-title">
      <span className="cover-corner tl" aria-hidden="true" />
      <span className="cover-corner tr" aria-hidden="true" />
      <span className="cover-corner bl" aria-hidden="true" />
      <span className="cover-corner br" aria-hidden="true" />
      <div className="roman">{kicker}</div>
      <div className="cover-medallion" aria-hidden="true">
        <span className="medallion-ring" />
        <span className="medallion-mark">{monogram}</span>
      </div>
      <h2>{book.title}</h2>
      <div className="cover-rule" aria-hidden="true">
        <span />
        <i>❦</i>
        <span />
      </div>
      <div className="motto">“{book.motto}”</div>
    </div>
  )
}
