import { getSpell, lightColor, paginateSpell, spellsOfYear, type SpellChunk } from '../data/spells'
import type { Spell } from '../types'

function Upgrade({ spell, index }: { spell: Spell; index: number }) {
  const u = spell.upgrades[index]
  return (
    <section className={`spell-upgrade ${u.locked ? 'is-locked' : ''}`}>
      <h5>
        <span className="upgrade-mark" aria-hidden="true">
          ✧
        </span>
        {u.label}
        {u.locked ? <span className="upgrade-lock">bloqueado</span> : null}
      </h5>
      <p>{u.text}</p>
    </section>
  )
}

function Chunks({ spell, chunks }: { spell: Spell; chunks: SpellChunk[] }) {
  const upgrades = chunks.filter((c) => c.kind === 'upgrade')
  return (
    <>
      {chunks.map((c, i) =>
        c.kind === 'effect' ? (
          <p key={i} className="spell-effect">
            {c.text}
          </p>
        ) : null,
      )}
      {upgrades.length ? (
        <div className="spell-upgrades">
          {upgrades.map((c) => (c.kind === 'upgrade' ? <Upgrade key={c.index} spell={spell} index={c.index} /> : null))}
        </div>
      ) : null}
    </>
  )
}

export function SpellEntry({ id, part = 0, parts = 1 }: { id: string; part?: number; parts?: number }) {
  const spell = getSpell(id)
  if (!spell) return null
  const leaves = paginateSpell(spell)
  const chunks = leaves[part] ?? []
  const last = part >= parts - 1
  const swatch = lightColor(spell.light)
  const number = spellsOfYear(spell.year).findIndex((s) => s.id === spell.id) + 1

  if (part > 0) {
    return (
      <article className="spell is-continued">
        <p className="spell-continued">
          <span>{spell.name}</span> — continuação
        </p>
        <Chunks spell={spell} chunks={chunks} />
        {!last ? (
          <p className="spell-turn" aria-hidden="true">
            continua ❧
          </p>
        ) : null}
      </article>
    )
  }

  return (
    <article className="spell">
      <header className="spell-head">
        <span className="spell-no">Nº {number}</span>
        <h3 className="spell-name">{spell.name}</h3>
        {spell.aliases.length ? <p className="spell-alias">ou {spell.aliases.join(', ')}</p> : null}
        {spell.tag ? <span className="spell-tag">{spell.tag}</span> : null}
      </header>
      <dl className="spell-meta">
        <div>
          <dt>Luz</dt>
          <dd>
            {swatch ? <i className="light-dot" style={{ background: swatch }} aria-hidden="true" /> : null}
            {spell.light}
          </dd>
        </div>
        <div>
          <dt>Classificação</dt>
          <dd>{spell.classification}</dd>
        </div>
        <div>
          <dt>Varinha</dt>
          <dd>{spell.movement || '—'}</dd>
        </div>
        {spell.requirement ? (
          <div className="is-requirement">
            <dt>Requisito</dt>
            <dd>{spell.requirement}</dd>
          </div>
        ) : null}
      </dl>
      <Chunks spell={spell} chunks={chunks} />
      {!last ? (
        <p className="spell-turn" aria-hidden="true">
          continua ❧
        </p>
      ) : null}
    </article>
  )
}
