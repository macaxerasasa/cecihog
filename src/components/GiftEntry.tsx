import { getGift } from '../data/gifts'
import { asset } from '../lib/asset'

export function GiftEntry({ id }: { id: string }) {
  const gift = getGift(id)
  if (!gift) return null
  const kind = gift.kind === 'skill' ? 'Hab.' : 'Raça'
  return (
    <article className="spell gift">
      <header className="spell-head">
        <span className="spell-no">{kind}</span>
        <h3 className="spell-name">{gift.name}</h3>
        {gift.aliases.length ? <p className="spell-alias">ou {gift.aliases[0]}</p> : null}
        <span className="spell-tag">{gift.tag}</span>
      </header>
      <dl className="spell-meta">
        <div>
          <dt>Raridade</dt>
          <dd>{gift.rarity}</dd>
        </div>
        {gift.requirement ? (
          <div className="is-requirement">
            <dt>Exige</dt>
            <dd>{gift.requirement}</dd>
          </div>
        ) : null}
      </dl>
      <figure className="ink-plate gift-plate">
        <img src={asset(`art/ink-${gift.art}.webp`)} alt={gift.caption} loading="lazy" decoding="async" />
        <figcaption>{gift.caption}</figcaption>
      </figure>
      {gift.text.map((p) => (
        <p key={p.slice(0, 24)} className="spell-effect">
          {p}
        </p>
      ))}
    </article>
  )
}
