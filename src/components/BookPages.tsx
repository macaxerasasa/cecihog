import type { ContentBlock } from '../types'
import { asset } from '../lib/asset'

function Block({ block }: { block: ContentBlock }) {
  switch (block.type) {
    case 'plate':
      return (
        <figure className={`ink-plate ${block.large ? 'is-large' : ''}`}>
          <span
            className="plate-art"
            role="img"
            aria-label={block.caption}
            style={{ backgroundImage: `url(${asset(`art/ink-${block.art}.webp`)})` }}
          />
          <figcaption>{block.caption}</figcaption>
        </figure>
      )
    case 'heading':
      return <h3>{block.text}</h3>
    case 'subheading':
      return <h4>{block.text}</h4>
    case 'ornament':
      return (
        <div className="ornament-line" aria-hidden="true">
          ✦ —— ✦
        </div>
      )
    case 'paragraph':
      return <p>{block.text}</p>
    case 'list':
      return (
        <ul className="plain-list">
          {block.items.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      )
    case 'entries':
      return (
        <ul className="entry-list">
          {block.items.map((item) => (
            <li key={item.title}>
              <strong>{item.title}</strong>
              {item.text}
            </li>
          ))}
        </ul>
      )
    case 'reserved':
      return (
        <div className="reserved-slot">
          <div className="label">{block.label}</div>
          <p>{block.hint}</p>
        </div>
      )
    default:
      return null
  }
}

export function BookPages({ blocks }: { blocks: ContentBlock[] }) {
  return (
    <>
      {blocks.map((block, i) => (
        <Block key={i} block={block} />
      ))}
    </>
  )
}
