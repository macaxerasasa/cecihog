import { useBookNav } from './BookNavContext'

export function SheetToc({
  heading = 'Índice',
  items,
}: {
  heading?: string
  items: { label: string; note?: string; spread: number }[]
}) {
  const nav = useBookNav()
  return (
    <div className="spell-finder">
      <h4>{heading}</h4>
      <ul className="finder-list is-index">
        {items.map((item) => (
          <li key={item.label}>
            <button type="button" className="finder-hit" onClick={() => nav?.goTo(item.spread)}>
              <span className="hit-name">{item.label}</span>
              {item.note ? <span className="hit-meta">{item.note}</span> : null}
              <span className="hit-page">dobra {item.spread + 1}</span>
            </button>
          </li>
        ))}
      </ul>
      <p className="finder-note">Toque um título para abrir a dobra do sistema.</p>
    </div>
  )
}
