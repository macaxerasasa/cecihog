import { memo, type CSSProperties } from 'react'
import type { ContentBlock } from '../types'
import { asset } from '../lib/asset'
import { SpellEntry } from './SpellEntry'
import { SpellSearch } from './SpellSearch'

/* One block of a sheet, inked in the map's hand. */
const Block = memo(function Block({ block }: { block: ContentBlock }) {
  switch (block.type) {
    case 'heading':
      return <h2 className="ink-h">{block.text}</h2>
    case 'subheading':
      return <h3 className="ink-sub">{block.text}</h3>
    case 'ornament':
      return (
        <div className="ink-orn" aria-hidden="true">
          ✦ —— ✦
        </div>
      )
    case 'paragraph':
      return <p className="ink-p">{block.text}</p>
    case 'list':
      return (
        <ul className="ink-list">
          {block.items.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      )
    case 'entries':
      return (
        <dl className="ink-entries">
          {block.items.map((item) => (
            <div key={item.title}>
              <dt>{item.title}</dt>
              <dd>{item.text}</dd>
            </div>
          ))}
        </dl>
      )
    case 'plate':
      return (
        <figure className={`ink-plate ${block.large ? 'is-large' : ''}`}>
          <img src={asset(`art/ink-${block.art}.webp`)} alt={block.caption} loading="lazy" decoding="async" />
          <figcaption>{block.caption}</figcaption>
        </figure>
      )
    case 'spell':
      return <SpellEntry id={block.id} part={block.part} parts={block.parts} />
    case 'spell-search':
      return <SpellSearch year={block.year} />
    case 'reserved':
      return (
        <div className="ink-reserved">
          <span className="reserved-label">{block.label}</span>
          <p>{block.hint}</p>
          <span className="reserved-stamp" aria-hidden="true">
            por escrever
          </span>
        </div>
      )
    default:
      return null
  }
})

export const MapBlocks = memo(function MapBlocks({ blocks }: { blocks: ContentBlock[] }) {
  const lead = blocks.findIndex((b) => b.type === 'paragraph')
  return (
    <>
      {blocks.map((block, i) => (
        <div key={i} className={`ink-in ${i === lead ? 'is-lead' : ''}`} style={{ '--k': i } as CSSProperties}>
          <Block block={block} />
        </div>
      ))}
    </>
  )
})
