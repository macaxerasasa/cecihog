(() => {
  const D = window.SITE_DATA;
  const $ = (s, el = document) => el.querySelector(s);
  const $$ = (s, el = document) => [...el.querySelectorAll(s)];
  const app = $("#app");
  const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const HASH = !!window.HASH_ROUTER;

  const slug = s => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
  const plain = s => s.replace(/<[^>]+>/g, "");
  const norm = s => plain(s).normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/["<>]/g, "").toLowerCase();
  const paras = (list = []) => list.map(p => `<p>${p}</p>`).join("");
  const navOf = path => D.nav.find(n => n.path === path);
  const pad = n => String(n).padStart(2, "0");

  const GRADE_KANJI = { "Esp.": "特級", "Especial": "特級", "Um": "一級", "Dois": "二級", "Três": "三級", "Quatro": "四級" };
  const GRADE_ORDER = ["Esp.", "Especial", "Um", "Dois", "Três", "Quatro"];

  /* ------------------------------------------------------------ chrome */

  function renderChrome() {
    $("#brand-name").textContent = D.meta.name;
    const links = D.nav.map((n, i) => `
      <li><a href="${n.path}" data-link>
        <span class="nav-num">${pad(i + 1)}</span>
        <span class="nav-label">${n.label}</span>
        <span class="nav-kanji" aria-hidden="true">${n.kanji}</span>
      </a></li>`).join("");
    $("#nav-list").innerHTML = links;
    $("#drawer-list").innerHTML = links;
    $("#footer-text").textContent = D.meta.footer;
  }

  function setActiveNav(path) {
    $$("[data-link]").forEach(a => a.classList.toggle("is-active", a.getAttribute("href") === path));
  }

  /* ------------------------------------------------------------ shared blocks */

  function pageHero(path, title, intro, extra = "") {
    const n = navOf(path);
    const idx = D.nav.indexOf(n) + 1;
    return `
      <header class="page-hero">
        <div class="page-hero__kanji" aria-hidden="true">${n.kanji}</div>
        <div class="page-hero__inner">
          <p class="eyebrow"><span>${pad(idx)}</span> ${n.label}</p>
          <h1 class="page-title" data-split>${title}</h1>
          <div class="page-hero__intro">${paras(intro)}</div>
          ${extra}
        </div>
      </header>`;
  }

  function pager(path) {
    const i = D.nav.findIndex(n => n.path === path);
    const prev = D.nav[(i - 1 + D.nav.length) % D.nav.length];
    const next = D.nav[(i + 1) % D.nav.length];
    return `
      <nav class="pager" aria-label="Navegação entre páginas">
        <a href="${prev.path}" data-link class="pager__item">
          <span class="pager__dir">← Anterior</span>
          <span class="pager__label">${prev.label}</span>
          <span class="pager__kanji" aria-hidden="true">${prev.kanji}</span>
        </a>
        <a href="${next.path}" data-link class="pager__item pager__item--next">
          <span class="pager__dir">Próxima →</span>
          <span class="pager__label">${next.label}</span>
          <span class="pager__kanji" aria-hidden="true">${next.kanji}</span>
        </a>
      </nav>`;
  }

  function toc(items) {
    return `
      <aside class="toc" aria-label="Nesta página">
        <p class="toc__title">Nesta página</p>
        <ol>${items.map(t => t.heading
          ? `<li class="toc__group"><a href="#${t.id}" data-toc>${t.label}</a></li>`
          : `<li><a href="#${t.id}" data-toc>${t.label}</a></li>`).join("")}</ol>
      </aside>`;
  }

  function filterBar({ placeholder, chips = [], chipLabel = "Todos" }) {
    return `
      <div class="filterbar">
        <label class="search">
          <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
          <input type="search" placeholder="${placeholder}" data-search aria-label="${placeholder}">
        </label>
        ${chips.length ? `<div class="chips" role="group">
          <button class="chip is-on" data-chip="">${chipLabel}</button>
          ${chips.map(c => `<button class="chip" data-chip="${c}">${c}</button>`).join("")}
        </div>` : ""}
        <p class="filterbar__count" data-count></p>
      </div>`;
  }

  function wireFilter(root, itemSel, textOf, chipOf) {
    const input = $("[data-search]", root);
    const count = $("[data-count]", root);
    const items = $$(itemSel, root);
    let chip = "";
    const run = () => {
      const q = norm(input.value.trim());
      let shown = 0;
      items.forEach(el => {
        const ok = (!q || textOf(el).includes(q)) && (!chip || (chipOf(el) || "").split("|").includes(chip));
        el.hidden = !ok;
        if (ok) shown++;
      });
      count.textContent = `${shown} de ${items.length}`;
      // esconde grupos que ficaram sem nenhum item visível
      $$("[data-filter-group]", root).forEach(g => { g.hidden = !$$(itemSel, g).some(e => !e.hidden); });
      const empty = $("[data-empty]", root);
      if (empty) empty.hidden = shown > 0;
    };
    input.addEventListener("input", run);
    $$("[data-chip]", root).forEach(b => b.addEventListener("click", () => {
      chip = b.dataset.chip;
      $$("[data-chip]", root).forEach(x => x.classList.toggle("is-on", x === b));
      run();
    }));
    run();
  }

  const emptyState = `<p class="empty" data-empty hidden>Nada encontrado. Tente outra busca.</p>`;

  /* ------------------------------------------------------------ pages */

  const pages = {};

  pages["/"] = () => {
    const m = D.meta;
    return `
      <section class="home">
        <canvas class="embers" aria-hidden="true"></canvas>
        <div class="home__moon" aria-hidden="true"></div>
        <div class="home__vertical" aria-hidden="true">呪術廻戦</div>
        <div class="home__inner">
          <p class="home__place">${m.place}</p>
          <h1 class="home__status" data-split>${m.status}</h1>
          <p class="home__title">${m.fullName}</p>
          <blockquote class="home__quote">${m.quote}</blockquote>
          <a href="${D.nav[0].path}" data-link class="btn">Entrar no arquivo <span aria-hidden="true">→</span></a>
        </div>
        <div class="home__city" aria-hidden="true"></div>
        <div class="home__scroll" aria-hidden="true"><span></span></div>
      </section>
      <section class="index">
        <div class="index__head">
          <p class="eyebrow"><span>索引</span> Arquivo</p>
          <h2 class="section-title">Registros do Mundo Jujutsu</h2>
        </div>
        <ol class="index__grid">
          ${D.nav.map((n, i) => `
            <li class="reveal" style="--d:${i * 60}ms">
              <a href="${n.path}" data-link class="tile">
                <span class="tile__num">${pad(i + 1)}</span>
                <span class="tile__kanji" aria-hidden="true">${n.kanji}</span>
                <span class="tile__label">${n.label}</span>
                <span class="tile__blurb">${n.blurb}</span>
                <span class="tile__arrow" aria-hidden="true">→</span>
              </a>
            </li>`).join("")}
        </ol>
      </section>`;
  };

  pages["/arsenal"] = () => {
    const P = D.arsenal;
    const grades = GRADE_ORDER.filter(g => P.items.some(i => i.grade === g));
    return `
      ${pageHero("/arsenal", P.title, P.intro)}
      <div class="wrap" data-filter-root>
        ${filterBar({ placeholder: "Buscar arma ou possuidor…", chips: grades, chipLabel: "Todos os graus" })}
        <div class="weapons">
          ${P.items.map(w => `
            <article class="weapon reveal" data-grade="${w.grade}" data-text="${norm(w.title + " " + w.owner + " " + w.paragraphs.join(" "))}">
              <div class="weapon__seal" data-grade-tone="${GRADE_KANJI[w.grade] === "特級" ? "especial" : slug(w.grade)}">
                <span class="weapon__seal-kanji" aria-hidden="true">${GRADE_KANJI[w.grade] || "級"}</span>
                <span class="weapon__seal-grade">${w.grade}</span>
                <span class="weapon__seal-label">Classificação</span>
              </div>
              <div class="weapon__body">
                <h2 class="card-title">${w.title}</h2>
                ${paras(w.paragraphs)}
                <p class="meta-line"><span>Possuidor</span>${w.owner}</p>
              </div>
            </article>`).join("")}
          ${emptyState}
        </div>
      </div>
      ${pager("/arsenal")}`;
  };

  pages["/classes"] = () => {
    const P = D.classes;
    return `
      ${pageHero("/classes", P.title, P.intro)}
      <div class="wrap">
        <div class="class-tabs" role="tablist" aria-label="Classes">
          ${P.items.map((c, i) => `
            <button role="tab" class="class-tab" aria-selected="${i === 0}" data-tab="${i}">
              <span class="class-tab__img">${c.image ? `<img src="${c.image}" alt="" loading="lazy" onerror="this.remove()">` : ""}<span>${c.kanji}</span></span>
              <span class="class-tab__name">${c.name}</span>
            </button>`).join("")}
        </div>
        ${P.items.map((c, i) => `
          <section class="class-panel" role="tabpanel" data-panel="${i}" ${i ? "hidden" : ""}>
            <div class="class-panel__head">
              <span class="class-panel__kanji" aria-hidden="true">${c.kanji}</span>
              <div>
                <p class="eyebrow"><span>${pad(i + 1)}</span> Classe</p>
                <h2 class="section-title">${c.name}</h2>
              </div>
            </div>
            <div class="prose">${paras(c.paragraphs)}${c.perksIntro ? `<p>${c.perksIntro}</p>` : ""}</div>
            <ol class="perks">
              ${c.perks.map((p, j) => `
                <li class="perk">
                  <span class="perk__num">${pad(j + 1)}</span>
                  <h3 class="perk__title">${p.title}</h3>
                  ${paras(p.paragraphs)}
                  ${p.effect ? `<p class="effect"><span>Efeito</span>${p.effect}</p>` : ""}
                </li>`).join("")}
            </ol>
            <div class="prose">${paras(c.outro)}</div>
          </section>`).join("")}
      </div>
      ${pager("/classes")}`;
  };

  pages["/cronologia"] = () => {
    const P = D.cronologia;
    // anos só para a trilha visual: "Entre os Anos 1260 e 1350" -> "1260–1350"
    const years = d => (d.match(/\d{3,4}/g) || [d]).join("–");
    const eventId = (e, i) => "periodo-" + (i + 1) + "-" + slug(years(e.date));
    const block = b => typeof b === "string"
      ? `<p>${b}</p>`
      : `<ul class="event-list${b.compact ? " event-list--compact" : ""}">${b.list.map(li => `<li>${li}</li>`).join("")}</ul>`;
    const tocItems = P.events.map((e, i) => ({ id: eventId(e, i), label: years(e.date) + (e.aka ? ` · ${e.aka}` : "") }));
    return `
      ${pageHero("/cronologia", P.title, P.intro)}
      <div class="wrap wrap--toc">
        ${toc(tocItems)}
        <ol class="timeline">
          ${P.events.map((e, i) => `
            <li class="event reveal" id="${eventId(e, i)}">
              <div class="event__date" aria-hidden="true"><span>${years(e.date).replace("–", "<i>–</i>")}</span></div>
              <div class="event__dot" aria-hidden="true"></div>
              <div class="event__body">
                <h2 class="event__title">${e.date}</h2>
                ${e.aka ? `<p class="event__aka">Também conhecido como <strong>"${e.aka}"</strong></p>` : ""}
                <div class="event__text">${e.body.map(block).join("")}</div>
              </div>
            </li>`).join("")}
        </ol>
      </div>
      ${pager("/cronologia")}`;
  };

  pages["/familias"] = () => {
    const P = D.familias;
    const tocItems = [];
    P.groups.forEach(g => {
      if (g.title) tocItems.push({ heading: true, id: slug(g.title), label: g.title });
      g.items.forEach(f => tocItems.push({ id: slug(f.name), label: f.name }));
    });
    const family = f => `
      <article class="family reveal" id="${slug(f.name)}">
        <div class="family__crest" aria-hidden="true"><span>${f.crest}</span></div>
        <div class="family__main">
          <h3 class="section-title">${f.name}</h3>
          <div class="prose">${paras(f.paragraphs)}</div>
          <div class="family__facts${f.holders ? "" : " family__facts--single"}">
            <div class="fact">
              <p class="fact__label">Herança</p>
              <p>${f.receives.join("<br>")}</p>
            </div>
            ${f.holders ? `
              <div class="fact">
                <p class="fact__label">${f.holders.label}</p>
                <ul class="members">${f.holders.names.map(n => `<li><span>${n}</span></li>`).join("")}</ul>
              </div>` : ""}
          </div>
          <section class="technique-box">
            <div class="technique-box__seal" aria-hidden="true">術<br>式</div>
            <div>
              <h4 class="card-title">${f.technique.name}</h4>
              ${paras(f.technique.paragraphs)}
            </div>
          </section>
        </div>
      </article>`;
    return `
      ${pageHero("/familias", P.title, P.intro)}
      <div class="wrap wrap--toc">
        ${toc(tocItems)}
        <div class="families">
          ${P.groups.map(g => `
            ${g.title ? `
              <header class="group-head" id="${slug(g.title)}">
                <h2 class="page-title group-head__title">${g.title}</h2>
                ${g.intro.length ? `<div class="prose">${paras(g.intro)}</div>` : ""}
              </header>` : ""}
            ${g.items.map(family).join("")}`).join("")}
        </div>
      </div>
      ${pager("/familias")}`;
  };

  pages["/fichas"] = () => {
    const P = D.fichas;
    const list = P.characters || [];
    if (!list.length) {
      return `
        ${pageHero("/fichas", P.title, P.intro)}
        <div class="wrap">
          <section class="empty-archive">
            <span class="empty-archive__seal" aria-hidden="true">倉</span>
            <h2 class="section-title">Nenhuma ficha registrada</h2>
            <p>As fichas dos feiticeiros aparecem aqui assim que forem cadastradas.</p>
          </section>
        </div>
        ${pager("/fichas")}`;
    }
    const grades = GRADE_ORDER.filter(g => list.some(c => c.grade === g));
    return `
      ${pageHero("/fichas", P.title, P.intro)}
      <div class="wrap" data-filter-root>
        ${filterBar({ placeholder: "Buscar feiticeiro, classe ou técnica…", chips: grades, chipLabel: "Todos os graus" })}
        <ul class="roster">
          ${list.map(c => `
            <li class="reveal" data-grade="${c.grade || ""}" data-text="${norm([c.name, c.className, c.technique, c.player].join(" "))}">
              <article class="card-char">
                <span class="card-char__img">
                  ${c.image ? `<img src="${c.image}" alt="" loading="lazy" onerror="this.remove()">` : ""}
                  <span class="card-char__initial">${(c.name || "?").trim()[0]}</span>
                  ${GRADE_KANJI[c.grade] ? `<span class="card-char__grade">${GRADE_KANJI[c.grade]}</span>` : ""}
                </span>
                <span class="card-char__name">${c.name || ""}</span>
                <span class="card-char__class">${[c.className, c.technique].filter(Boolean).join(" · ")}</span>
                ${c.player ? `<span class="card-char__class">Jogador: ${c.player}</span>` : ""}
                ${c.bio && c.bio.length ? `<div class="card-char__bio">${paras(c.bio)}</div>` : ""}
              </article>
            </li>`).join("")}
          ${emptyState}
        </ul>
      </div>
      ${pager("/fichas")}`;
  };

  /* Lê assets/js/sistemas-texto.js (marcadores #, ##, ###, -) e monta as seções */
  function parseSistemas(raw) {
    const sections = [];
    let sec = null, html = "", openRanks = false, openRank = false, openRules = false, openItem = false, rankFresh = false;
    const closeRank = () => { if (openRank) { html += `</div></li>`; openRank = false; } };
    const closeRanks = () => { closeRank(); if (openRanks) { html += `</ol>`; openRanks = false; } };
    const closeRules = () => { if (openRules) { html += `</ol>`; openRules = false; } };
    const closeItem = () => { if (openItem) { html += `</article>`; openItem = false; } };
    const closeAll = () => { closeRanks(); closeRules(); closeItem(); };
    const finish = () => { if (sec) { closeAll(); sec.html = html; sections.push(sec); } html = ""; };

    (raw || "").split(/\r?\n/).map(l => l.trim()).forEach(l => {
      if (!l) return;
      let m;
      if ((m = l.match(/^#\s+(.+)$/))) { finish(); sec = { title: m[1] }; return; }
      if (!sec) sec = { title: "" };
      if ((m = l.match(/^##\s+(.+)$/))) { closeAll(); html += `<h3 class="doc-sub">${m[1]}</h3>`; return; }
      if ((m = l.match(/^###\s+(.+)$/))) { closeAll(); html += `<article class="doc-item"><h4 class="doc-item__title">${m[1]}</h4>`; openItem = true; return; }
      if ((m = l.match(/^-\s+(.+)$/))) {
        closeRanks();
        if (!openRules) { html += `<ol class="rule-list rule-list--plain">`; openRules = true; }
        html += `<li><p>${m[1]}</p></li>`;
        return;
      }
      closeRules();
      if ((m = l.match(/^Ranque (\d+)$/))) {
        closeRank();
        if (!openRanks) { html += `<ol class="ranks">`; openRanks = true; }
        const n = +m[1];
        html += `<li class="rank" style="--n:${n}"><div class="rank__n"><span>${l}</span><b>${n}</b><i aria-hidden="true"></i></div><div class="rank__body">`;
        openRank = true; rankFresh = true;
        return;
      }
      if (/^Ranque \d+ em .+$/.test(l)) { html += `<p class="req">${l}</p>`; return; }
      if (openRank && rankFresh && l.length <= 60 && !/[.;!?]$/.test(l)) { html += `<p class="rank__tag">${l}</p>`; rankFresh = false; return; }
      rankFresh = false;
      if (l.startsWith("Efeito:")) { html += `<p class="effect"><span>Efeito</span>${l.replace(/^Efeito:\s*/, "")}</p>`; return; }
      html += `<p>${l}</p>`;
    });
    finish();
    return sections;
  }

  let sisCache;
  pages["/sistemas"] = () => {
    const P = D.sistemas;
    const S = sisCache || (sisCache = parseSistemas(window.SISTEMAS_TEXTO));
    const tocItems = S.map(s => ({ id: slug(s.title), label: s.title }));
    return `
      ${pageHero("/sistemas", P.title, [])}
      <div class="wrap wrap--toc">
        ${toc(tocItems)}
        <div class="doc">
          ${S.map((s, i) => `
            <section class="doc__section" id="${slug(s.title)}">
              <h2 class="section-title"><span class="section-num">${pad(i + 1)}</span>${s.title}</h2>
              <div class="doc__body">${s.html}</div>
            </section>`).join("")}
        </div>
      </div>
      ${pager("/sistemas")}`;
  };

  /* Lê o texto de assets/js/tecnicas-texto.js e separa em técnicas e níveis */
  function parseTecnicas(raw) {
    const lines = (raw || "").split(/\r?\n/).map(l => l.trim());
    const isSlots = l => /^\(\d+\/\d+\)$/.test(l);
    const isLevel = l => /^Nível (Um|Dois|Três|Quatro|Cinco|Único)$/.test(l);
    const intro = [], items = [];
    let cur = null, target = intro;
    for (let i = 0; i < lines.length; i++) {
      const l = lines[i];
      if (!l) continue;
      let j = i + 1;
      while (j < lines.length && !lines[j]) j++;
      if (isSlots(lines[j] || "")) {
        cur = { name: l, slots: lines[j].slice(1, -1), intro: [], levels: [] };
        items.push(cur); target = cur.intro; i = j;
        continue;
      }
      if (cur && isLevel(l)) {
        const lv = { title: l, lines: [] };
        cur.levels.push(lv); target = lv.lines;
        continue;
      }
      target.push(l);
    }
    return { intro, items };
  }

  // "Nome — texto" deixa o nome em negrito (só quando é um nome curto no começo)
  const boldHead = l => l.replace(/^([^—,.;]{2,45}?)(\s?—\s)/, "<b>$1</b>$2");
  const isSubheading = l => l.length <= 40 && !/[.:;,!?”)]$/.test(l) && !l.startsWith("•");
  function linesToHtml(ls) {
    let html = "", list = null;
    const flush = () => { if (list) { html += `<ul class="tech-list">${list.join("")}</ul>`; list = null; } };
    ls.forEach(l => {
      if (l.startsWith("•")) { (list = list || []).push(`<li>${boldHead(l.slice(1).trim())}</li>`); return; }
      flush();
      html += isSubheading(l) ? `<h4 class="tech-sub">${l}</h4>` : `<p>${boldHead(l)}</p>`;
    });
    flush();
    return html;
  }

  let tecCache;
  pages["/tecnicas"] = () => {
    const P = D.tecnicas;
    const T = tecCache || (tecCache = parseTecnicas(window.TECNICAS_TEXTO));
    const tagOf = t => P.tags[t.name] || {};
    const catOf = t => tagOf(t).category || "Outras";
    const cats = [...new Set(T.items.map(catOf))];
    const KANJI = { "Um": "壱", "Dois": "弐", "Três": "参", "Quatro": "肆", "Cinco": "伍", "Único": "唯" };
    return `
      ${pageHero("/tecnicas", P.title, T.intro.slice(0, 1))}
      <div class="wrap" data-filter-root>
        ${T.intro.length > 1 ? `<aside class="notice">${linesToHtml(T.intro.slice(1))}</aside>` : ""}
        ${filterBar({ placeholder: "Buscar técnica, família ou palavra…", chips: cats, chipLabel: "Todas" })}
        <div class="techniques">
          ${T.items.map((t, i) => {
            const tag = tagOf(t);
            const introLines = t.intro.slice();
            const exclusive = introLines[0] && /^Exclusiva/.test(introLines[0]) ? introLines.shift() : "";
            return `
            <details class="tech reveal" id="${slug(t.name)}" data-cat="${catOf(t)}" data-text="${norm([t.name, tag.owner || "", catOf(t), ...t.intro].join(" "))}" ${i === 0 ? "open" : ""}>
              <summary>
                <span class="tech__seal" aria-hidden="true"><span>${tag.symbol || "術"}</span><small>${pad(i + 1)}</small></span>
                <span class="tech__name">${t.name}</span>
                <span class="tech__tags">
                  ${catOf(t) !== "Outras" ? `<span class="tag">${catOf(t)}</span>` : ""}
                  ${tag.owner ? `<span class="tag tag--ghost">${tag.owner}</span>` : ""}
                  ${exclusive ? `<span class="tag tag--ghost">${exclusive}</span>` : ""}
                  <span class="tag tag--ghost" title="Vagas">(${t.slots})</span>
                </span>
                <span class="tech__chev" aria-hidden="true"></span>
              </summary>
              <div class="tech__body">
                ${introLines.length ? `<div class="prose">${linesToHtml(introLines)}</div>` : ""}
                <div class="levels">
                  ${t.levels.map(l => `
                    <section class="level">
                      <h3 class="level__title"><span>${KANJI[l.title.replace("Nível ", "")] || "級"}</span>${l.title}</h3>
                      <div class="level__text">${linesToHtml(l.lines)}</div>
                    </section>`).join("")}
                </div>
              </div>
            </details>`;
          }).join("")}
          ${emptyState}
        </div>
      </div>
      ${pager("/tecnicas")}`;
  };

  /* Lê assets/js/vantagens-texto.js: intro, grupos (#) e vantagens com (vagas) */
  function parseVantagens(raw) {
    const lines = (raw || "").split(/\r?\n/).map(l => l.trim()).filter(Boolean);
    const intro = [], groups = [];
    let group = null, item = null;
    for (let i = 0; i < lines.length; i++) {
      const l = lines[i];
      let m;
      if ((m = l.match(/^#\s+(.+)$/))) { group = { title: m[1], intro: [], items: [] }; groups.push(group); item = null; continue; }
      if (/^\(\d+\/\d+\)$/.test(lines[i + 1] || "")) {
        const [taken, total] = lines[i + 1].slice(1, -1).split("/").map(Number);
        item = { name: l, slots: lines[i + 1], taken, total, holders: "", lines: [] };
        if (!group) { group = { title: "", intro: [], items: [] }; groups.push(group); }
        group.items.push(item);
        i++;
        const next = lines[i + 1] || "";
        if (next && next.length <= 80 && !/[.;:]$/.test(next) && !/^\(\d+\/\d+\)$/.test(lines[i + 2] || "")) { item.holders = next; i++; }
        continue;
      }
      if (item) item.lines.push(l);
      else if (group) group.intro.push(l);
      else intro.push(l);
    }
    return { intro, groups };
  }

  function vantagemBody(ls) {
    let html = "", recebe = null;
    const flush = () => { if (recebe) { html += `<ul class="bonus">${recebe.join("")}</ul>`; recebe = null; } };
    ls.forEach(l => {
      if (/^Recebe\b/.test(l)) { (recebe = recebe || []).push(`<li>${l}</li>`); return; }
      flush();
      const isSub = l.length <= 40 && (!/[.;!?]$/.test(l));
      html += isSub ? `<h4 class="tech-sub">${l}</h4>` : `<p>${l}</p>`;
    });
    flush();
    return html;
  }

  let vanCache;
  pages["/vantagens"] = () => {
    const P = D.vantagens;
    const V = vanCache || (vanCache = parseVantagens(window.VANTAGENS_TEXTO));
    const groupLabel = g => /princip/i.test(g.title) ? "Principais" : /secund/i.test(g.title) ? "Secundárias" : g.title;
    const chips = [...V.groups.map(groupLabel), "Com vagas"];
    return `
      ${pageHero("/vantagens", P.title, V.intro)}
      <div class="wrap" data-filter-root>
        ${filterBar({ placeholder: "Buscar vantagem…", chips, chipLabel: "Todas" })}
        ${V.groups.map(g => `
          <section class="adv-group" data-filter-group>
            ${g.title ? `
              <header class="adv-group__head">
                <h2 class="page-title group-head__title">${g.title}</h2>
                ${g.intro.length ? `<div class="prose">${paras(g.intro)}</div>` : ""}
              </header>` : ""}
            <div class="perks-grid">
              ${g.items.map(v => {
                const open = v.taken < v.total;
                const cats = [groupLabel(g), open ? "Com vagas" : ""].filter(Boolean).join("|");
                return `
                <article class="adv reveal${open ? " is-open" : " is-full"}" data-cat="${cats}" data-text="${norm([v.name, v.holders, ...v.lines].join(" "))}">
                  <div class="adv__top">
                    <span class="slots" title="Vagas ocupadas">
                      <span class="slots__dots" aria-hidden="true">${Array.from({ length: v.total }, (_, k) => `<i class="${k < v.taken ? "on" : ""}"></i>`).join("")}</span>
                      ${v.slots}
                    </span>
                    <span class="adv__state">${open ? "Vagas abertas" : "Esgotada"}</span>
                  </div>
                  <h3 class="card-title">${v.name}</h3>
                  ${v.holders ? `<p class="holders"><span>Portadores</span>${v.holders}</p>` : ""}
                  <div class="adv__body">${vantagemBody(v.lines)}</div>
                </article>`;
              }).join("")}
            </div>
          </section>`).join("")}
        ${emptyState}
      </div>
      ${pager("/vantagens")}`;
  };

  /* ------------------------------------------------------------ behaviours */

  function splitTitles(root) {
    $$("[data-split]", root).forEach(el => {
      const text = el.textContent;
      el.setAttribute("aria-label", text);
      let i = 0;
      el.innerHTML = text.split(" ").map(word =>
        `<span class="word" aria-hidden="true">${[...word].map(ch => `<span class="ch" style="--i:${i++}">${ch}</span>`).join("")}</span>`
      ).join(" ");
    });
  }

  let revealObs;
  function setupReveal(root) {
    revealObs?.disconnect();
    const els = $$(".reveal", root);
    if (reduceMotion || !("IntersectionObserver" in window)) { els.forEach(e => e.classList.add("in")); return; }
    revealObs = new IntersectionObserver(entries => entries.forEach(en => {
      if (en.isIntersecting) { en.target.classList.add("in"); revealObs.unobserve(en.target); }
    }), { rootMargin: "0px 0px -8% 0px" });
    els.forEach(e => revealObs.observe(e));
  }

  let tocObs;
  function setupToc(root) {
    tocObs?.disconnect();
    const links = $$("[data-toc]", root);
    if (!links.length) return;
    tocObs = new IntersectionObserver(entries => entries.forEach(en => {
      if (en.isIntersecting) links.forEach(a => a.classList.toggle("is-active", a.getAttribute("href") === "#" + en.target.id));
    }), { rootMargin: "-30% 0px -60% 0px" });
    links.forEach(a => {
      const t = document.getElementById(a.getAttribute("href").slice(1));
      if (t) tocObs.observe(t);
      a.addEventListener("click", e => {
        e.preventDefault();
        t?.scrollIntoView({ behavior: reduceMotion ? "auto" : "smooth", block: "start" });
        if (!HASH) history.replaceState(null, "", a.getAttribute("href"));
      });
    });
  }

  function setupPage(path, root) {
    splitTitles(root);
    setupReveal(root);
    setupToc(root);

    const fr = $("[data-filter-root]", root);
    if (fr) {
      const keyAttr = fr.querySelector("[data-grade]") ? "grade" : "cat";
      const sel = path === "/fichas" ? ".roster > li[data-text]"
        : path === "/arsenal" ? ".weapon" : path === "/tecnicas" ? ".tech" : ".adv";
      wireFilter(fr, sel, el => el.dataset.text, el => el.dataset[keyAttr]);
    }

    $$(".class-tab", root).forEach(tab => tab.addEventListener("click", () => {
      $$(".class-tab", root).forEach(t => t.setAttribute("aria-selected", t === tab));
      $$(".class-panel", root).forEach(p => p.hidden = p.dataset.panel !== tab.dataset.tab);
    }));

    const canvas = $(".embers", root);
    if (canvas) startEmbers(canvas);
  }

  /* brasas de energia amaldiçoada subindo na tela inicial */
  let embersRAF;
  function startEmbers(canvas) {
    cancelAnimationFrame(embersRAF);
    if (reduceMotion) return;
    const ctx = canvas.getContext("2d");
    let w, h, dpr;
    const size = () => {
      dpr = Math.min(devicePixelRatio || 1, 2);
      w = canvas.clientWidth; h = canvas.clientHeight;
      canvas.width = w * dpr; canvas.height = h * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    size();
    addEventListener("resize", size);
    const count = Math.round(Math.min(90, w / 14));
    const make = (initial) => ({
      x: Math.random() * w,
      y: initial ? Math.random() * h : h + 10,
      r: Math.random() * 1.8 + .4,
      vy: Math.random() * .6 + .2,
      vx: (Math.random() - .5) * .3,
      a: Math.random() * .6 + .2,
      t: Math.random() * 100
    });
    const ps = Array.from({ length: count }, () => make(true));
    const tick = () => {
      if (!canvas.isConnected) { removeEventListener("resize", size); return; }
      ctx.clearRect(0, 0, w, h);
      for (const p of ps) {
        p.t += .02; p.y -= p.vy; p.x += p.vx + Math.sin(p.t) * .25;
        if (p.y < -10) Object.assign(p, make(false));
        const fade = Math.min(1, p.y / (h * .6));
        ctx.beginPath();
        ctx.fillStyle = `rgba(255, ${60 + p.r * 30 | 0}, 50, ${p.a * fade})`;
        ctx.shadowColor = "rgba(255,40,40,.9)";
        ctx.shadowBlur = 8;
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();
      }
      embersRAF = requestAnimationFrame(tick);
    };
    tick();
  }

  /* ------------------------------------------------------------ router */

  const TITLES = { "/": "Início" };
  D.nav.forEach(n => TITLES[n.path] = n.label);

  let first = true;
  async function render(path, { scroll = true } = {}) {
    if (!pages[path]) path = "/";
    current = path;
    const curtain = $("#curtain");
    if (!first && !reduceMotion) {
      curtain.classList.remove("out"); curtain.classList.add("in");
      await new Promise(r => setTimeout(r, 420));
    }
    app.innerHTML = pages[path]();
    document.title = `${TITLES[path]} — ${D.meta.fullName}`;
    document.body.dataset.page = path === "/" ? "home" : path.slice(1);
    setActiveNav(path);
    setupPage(path, app);
    closeDrawer();
    if (scroll) {
      const hash = !HASH && location.hash && document.getElementById(location.hash.slice(1));
      hash ? hash.scrollIntoView() : scrollTo(0, 0);
    }
    if (!first && !reduceMotion) { curtain.classList.remove("in"); curtain.classList.add("out"); }
    first = false;
    app.focus({ preventScroll: true });
  }

  /* Rotas: na Vercel usa endereços normais (/arsenal). Onde isso não é possível
     (ex.: link de Artifact), defina window.HASH_ROUTER = true e o site passa a
     usar #arsenal. Um # que não é página (ex.: #forca) continua sendo âncora. */
  const hashRoute = () => {
    const h = location.hash.slice(1);
    if (!h || h === "inicio") return "/";
    return pages["/" + h] ? "/" + h : null;
  };
  const currentPath = () => HASH ? (hashRoute() || current) : location.pathname;
  let current = "/";

  document.addEventListener("click", e => {
    const a = e.target.closest("a[data-link]");
    if (!a || e.metaKey || e.ctrlKey || e.shiftKey || a.target) return;
    e.preventDefault();
    const path = a.getAttribute("href");
    if (path === currentPath()) { scrollTo({ top: 0, behavior: "smooth" }); closeDrawer(); return; }
    if (HASH) { location.hash = path === "/" ? "inicio" : path.slice(1); return; }
    history.pushState(null, "", path);
    render(path);
  });
  if (HASH) {
    addEventListener("hashchange", () => {
      const p = hashRoute();
      if (p && p !== current) render(p);
    });
  } else {
    addEventListener("popstate", () => render(location.pathname, { scroll: false }));
  }

  /* ------------------------------------------------------------ header / drawer / progress */

  const drawer = $("#drawer");
  const burger = $("#burger");
  function closeDrawer() {
    drawer.classList.remove("open");
    burger.setAttribute("aria-expanded", "false");
    document.body.classList.remove("no-scroll");
  }
  burger.addEventListener("click", () => {
    const open = !drawer.classList.contains("open");
    drawer.classList.toggle("open", open);
    burger.setAttribute("aria-expanded", String(open));
    document.body.classList.toggle("no-scroll", open);
  });
  addEventListener("keydown", e => { if (e.key === "Escape") closeDrawer(); });

  const bar = $("#progress");
  const header = $("#site-header");
  const onScroll = () => {
    const max = document.documentElement.scrollHeight - innerHeight;
    bar.style.transform = `scaleX(${max > 0 ? scrollY / max : 0})`;
    header.classList.toggle("is-scrolled", scrollY > 30);
  };
  addEventListener("scroll", onScroll, { passive: true });

  renderChrome();
  render(HASH ? (hashRoute() || "/") : location.pathname, { scroll: !HASH && !!location.hash }).then(onScroll);
})();
