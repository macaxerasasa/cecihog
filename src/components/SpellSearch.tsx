import { useId, useMemo, useState } from 'react'
import { YEAR_NAMES, YEAR_ROMAN, searchSpells, spellsOfYear, spreadOfSpell, type SpellHit } from '../data/spells'
import type { Spell } from '../types'
import { useBookNav } from './BookNavContext'

const WHERE_LABEL: Record<SpellHit['where'], string> = {
  name: '',
  alias: 'também chamado',
  meta: 'pela classificação',
  effect: 'no texto',
}

function Result({ spell, year, hit, onPick }: { spell: Spell; year: number; hit?: SpellHit; onPick: (id: string) => void }) {
  const here = spell.year === year
  const page = spreadOfSpell(spell.id)
  return (
    <li>
      <button type="button" className="finder-hit" onClick={() => onPick(spell.id)}>
        <span className="hit-name">
          {spell.name}
          {spell.tag ? <em> ({spell.tag})</em> : null}
        </span>
        <span className="hit-meta">
          {spell.classification}
          {hit && WHERE_LABEL[hit.where] ? <em> · {WHERE_LABEL[hit.where]}</em> : null}
        </span>
        <span className="hit-page">{here ? `dobra ${page + 1}` : `Sala ${YEAR_ROMAN[spell.year - 1]}`}</span>
      </button>
    </li>
  )
}

export function SpellSearch({ year }: { year: number }) {
  const nav = useBookNav()
  const [query, setQuery] = useState('')
  const inputId = useId()
  const own = useMemo(() => spellsOfYear(year), [year])
  const hits = useMemo(() => searchSpells(query), [query])
  const searching = query.trim().length >= 2

  const here = hits.filter((h) => h.spell.year === year)
  const elsewhere = hits.filter((h) => h.spell.year !== year)
  const pick = (id: string) => nav?.openSpell(id)

  return (
    <div className="spell-finder">
      <h4>Localizar feitiço</h4>
      <label className="finder-field" htmlFor={inputId}>
        <span className="finder-quill" aria-hidden="true">
          ✎
        </span>
        <input
          id={inputId}
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Nome, classificação, luz ou gesto…"
          autoComplete="off"
          spellCheck={false}
          enterKeyHint="search"
          aria-label="Procurar um feitiço nas sete salas"
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
              Nenhum feitiço responde a <strong>“{query.trim()}”</strong>. Tente o nome em latim, a classificação
              (Encantamento, Azaração…) ou a cor da luz.
            </p>
          ) : null}
          {here.length ? (
            <>
              <p className="finder-group">
                Nesta sala <span>{here.length}</span>
              </p>
              <ul className="finder-list">
                {here.map((h) => (
                  <Result key={h.spell.id} spell={h.spell} year={year} hit={h} onPick={pick} />
                ))}
              </ul>
            </>
          ) : null}
          {elsewhere.length ? (
            <>
              <p className="finder-group">
                Em outras salas <span>{elsewhere.length}</span>
              </p>
              <ul className="finder-list">
                {elsewhere.slice(0, 24).map((h) => (
                  <Result key={h.spell.id} spell={h.spell} year={year} hit={h} onPick={pick} />
                ))}
              </ul>
              {elsewhere.length > 24 ? <p className="finder-more">… e mais {elsewhere.length - 24}. Refine a busca.</p> : null}
            </>
          ) : null}
        </div>
      ) : (
        <div className="finder-index">
          <p className="finder-group">
            Índice do {YEAR_NAMES[year - 1].toLowerCase()} ano <span>{own.length}</span>
          </p>
          <ul className="finder-list is-index">
            {own.map((s) => (
              <Result key={s.id} spell={s} year={year} onPick={pick} />
            ))}
          </ul>
          <p className="finder-note">
            A busca percorre as sete salas — um feitiço de outro ano abre a sala certa, na dobra certa.
          </p>
        </div>
      )}
    </div>
  )
}
