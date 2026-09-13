import { useId, useMemo, useState } from 'react'
import { races, searchGifts, skills, spreadOfGift, type Gift, type GiftHit } from '../data/gifts'
import { useBookNav } from './BookNavContext'

const WHERE_LABEL: Record<GiftHit['where'], string> = {
  name: '',
  alias: 'também chamado',
  meta: 'pela classificação',
  body: 'no texto',
}

function Result({ gift, hit, onPick }: { gift: Gift; hit?: GiftHit; onPick: (id: string) => void }) {
  const page = spreadOfGift(gift.id)
  return (
    <li>
      <button type="button" className="finder-hit" onClick={() => onPick(gift.id)}>
        <span className="hit-name">{gift.name}</span>
        <span className="hit-meta">
          {gift.tag}
          {hit && WHERE_LABEL[hit.where] ? <em> · {WHERE_LABEL[hit.where]}</em> : null}
        </span>
        <span className="hit-page">dobra {page + 1}</span>
      </button>
    </li>
  )
}

export function GiftSearch() {
  const nav = useBookNav()
  const [query, setQuery] = useState('')
  const inputId = useId()
  const hits = useMemo(() => searchGifts(query), [query])
  const searching = query.trim().length >= 2
  const pick = (id: string) => nav?.openGift(id)

  return (
    <div className="spell-finder">
      <h4>Localizar dom</h4>
      <label className="finder-field" htmlFor={inputId}>
        <span className="finder-quill" aria-hidden="true">
          ✎
        </span>
        <input
          id={inputId}
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Nome, linhagem ou efeito…"
          autoComplete="off"
          spellCheck={false}
          enterKeyHint="search"
          aria-label="Procurar uma habilidade ou raça"
        />
        {query ? (
          <button type="button" className="finder-clear" aria-label="Limpar a busca" onClick={() => setQuery('')}>
            ×
          </button>
        ) : null}
      </label>

      {searching ? (
        <div className="finder-results" aria-live="polite">
          {hits.length === 0 ? (
            <p className="finder-empty">
              Nenhum dom responde a <strong>“{query.trim()}”</strong>. Tente o nome, a linhagem (Gaunt, veela) ou a
              arte (mental, elemental, inato).
            </p>
          ) : (
            <ul className="finder-list">
              {hits.map((h) => (
                <Result key={h.gift.id} gift={h.gift} hit={h} onPick={pick} />
              ))}
            </ul>
          )}
        </div>
      ) : (
        <div className="finder-index">
          <p className="finder-group">
            Habilidades <span>{skills.length}</span>
          </p>
          <ul className="finder-list is-index">
            {skills.map((g) => (
              <Result key={g.id} gift={g} onPick={pick} />
            ))}
          </ul>
          <p className="finder-group">
            Raças <span>{races.length}</span>
          </p>
          <ul className="finder-list is-index">
            {races.map((g) => (
              <Result key={g.id} gift={g} onPick={pick} />
            ))}
          </ul>
          <p className="finder-note">Toque um nome para abrir a dobra do verbete.</p>
        </div>
      )}
    </div>
  )
}
