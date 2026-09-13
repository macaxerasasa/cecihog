/*
 * Pulls the "Sumário de Feitiços" Google Doc and rewrites src/data/spells.json.
 *
 *   npm run spells            # fetch the shared document
 *   npm run spells -- file.txt  # or parse a local plain-text export
 *
 * The document is a flat list: a YEAR header ("PRIMEIRO ANO" …), then one
 * block per spell whose first line is the name and whose following lines are
 * "Campo: valor" pairs (Efeito, Luz, Classificação, Movimento manual,
 * Requisito, Aprimoramento …). Blocks are separated by a rule of underscores.
 */
import { readFileSync, writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const DOC_ID = '1siEb-jUvgbmemHvgpILEorGQlLgzPu9j-I4FaDl95zY'
const EXPORT_URL = `https://docs.google.com/document/d/${DOC_ID}/export?format=txt`
const YEARS = ['PRIMEIRO ANO', 'SEGUNDO ANO', 'TERCEIRO ANO', 'QUARTO ANO', 'QUINTO ANO', 'SEXTO ANO', 'SÉTIMO ANO']

const FIELD =
  /^\s*(Efeito|Luz|Classifica[çc][ãa]o|Classifica[çc][õo]es|Movimentos? manua(?:l|is)|Aprimoramento[^:]*|Requisito[^:]*|Observa[çc][ãa]o[^:]*|Nota[^:]*)\s*:\s*(.*)$/i

async function load(arg) {
  if (arg) return readFileSync(arg, 'utf8')
  const res = await fetch(EXPORT_URL)
  if (!res.ok) throw new Error(`Google Docs export failed: ${res.status}`)
  return await res.text()
}

const clean = (s) => s.replace(/\s+/g, ' ').replace(/\s+([.;,])/g, '$1').trim()
const trimEnd = (s) => clean(s).replace(/[;.\s]+$/g, '')

function slug(s) {
  return s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

const SMALL = new Set(['de', 'do', 'da', 'ou', 'e'])
function titleCase(s) {
  return s
    .toLowerCase()
    .split(' ')
    .map((w, i) =>
      w
        .split('-')
        .map((p) => (SMALL.has(p) && i > 0 ? p : p.charAt(0).toUpperCase() + p.slice(1)))
        .join('-'),
    )
    .join(' ')
}

/** "EXPECTO PATRONUM (Merecimento)" → name, tag; "CRUCIO ou CRUCIATUS" → name + alias */
function parseName(raw) {
  let s = raw.trim().replace(/:$/, '')
  let tag
  const paren = s.match(/\(([^)]+)\)\s*$/)
  if (paren) {
    tag = paren[1].trim()
    s = s.slice(0, paren.index).trim()
  }
  const parts = s.split(/\s+ou\s+/i).map((p) => titleCase(p.trim()))
  return { name: parts[0], aliases: parts.slice(1), tag }
}

function parse(text) {
  const lines = text.replace(/\r/g, '').split('\n').map((l) => l.replace(/\s+$/g, ''))
  const starts = []
  lines.forEach((l, i) => {
    if (/^\s*Efeito\s*:/i.test(l)) {
      let j = i - 1
      while (j >= 0 && !lines[j].trim()) j--
      starts.push([j, i])
    }
  })

  let year = 0
  const spells = []
  starts.forEach(([nameAt, effectAt], k) => {
    const end = k + 1 < starts.length ? starts[k + 1][0] : lines.length
    for (let j = Math.max(0, nameAt - 20); j < nameAt; j++) {
      const idx = YEARS.indexOf(lines[j].trim())
      if (idx >= 0) year = idx + 1
    }
    const fields = []
    for (const l of lines.slice(effectAt, end)) {
      const s = l.trim()
      if (!s || /^_+$/.test(s) || YEARS.includes(s)) continue
      const m = s.match(FIELD)
      if (m) fields.push([m[1].trim(), m[2].trim()])
      else if (fields.length) fields[fields.length - 1][1] += '\n' + s
    }
    spells.push({ year, rawName: lines[nameAt].trim(), fields })
  })

  // A stray "Aprimoramento (bloqueado):" block that carries its own "Efeito:" is
  // an upgrade of the spell right before it, not a new spell.
  const merged = []
  for (const s of spells) {
    if (/^aprimoramento/i.test(s.rawName) && merged.length) {
      const eff = s.fields.find(([k]) => /^efeito$/i.test(k))
      if (eff) merged[merged.length - 1].fields.push([s.rawName.replace(/:$/, ''), eff[1]])
      continue
    }
    merged.push(s)
  }

  const seen = new Map()
  return merged.map((s) => {
    const { name, aliases, tag } = parseName(s.rawName)
    const get = (re) => s.fields.filter(([k]) => re.test(k)).map(([, v]) => v)
    const effect = get(/^efeito$/i)
      .join('\n')
      .split('\n')
      .map(clean)
      .filter(Boolean)
    const upgrades = s.fields
      .filter(([k]) => /^aprimoramento/i.test(k))
      .map(([k, v]) => {
        const num = k.match(/\d+/)
        return {
          label: num ? `Aprimoramento ${['I', 'II', 'III', 'IV'][Number(num[0]) - 1] ?? num[0]}` : 'Aprimoramento',
          locked: /bloquead/i.test(k),
          text: clean(v),
        }
      })
    let id = slug(name)
    if (seen.has(id)) id = `${id}-${s.year}`
    seen.set(id, true)
    const requirement = get(/^requisito/i)[0]
    return {
      id,
      year: s.year,
      name,
      aliases,
      ...(tag ? { tag } : {}),
      effect,
      light: trimEnd(get(/^luz$/i)[0] ?? 'não há').toLowerCase(),
      classification: trimEnd(get(/^classifica/i)[0] ?? ''),
      movement: trimEnd(get(/^movimento/i)[0] ?? ''),
      ...(requirement ? { requirement: trimEnd(requirement) } : {}),
      upgrades,
    }
  })
}

const here = dirname(fileURLToPath(import.meta.url))
const text = await load(process.argv[2])
const spells = parse(text)
const out = resolve(here, '../src/data/spells.json')
writeFileSync(out, JSON.stringify(spells, null, 2) + '\n')
const perYear = spells.reduce((m, s) => ((m[s.year] = (m[s.year] ?? 0) + 1), m), {})
console.log(`${spells.length} feitiços →`, out)
console.log(perYear)
