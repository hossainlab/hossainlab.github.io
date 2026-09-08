# Site Redesign Plan — mdjubayerhossain.com

Direction: **Editorial-scientific**. Serif display + humanist sans, generous whitespace,
thin rules over card shadows, one restrained accent. Reference points: eLife, Nature
author pages, EMBL/Broad group sites.

Scope: all 4 phases.

---

## Phase 1 — Structure, config, reach  [DONE 2026-09-08]

- [ ] **Fix `_quarto.yml` indentation bug.** `site-url`, `search`, `reader-mode`,
      `draft-mode`, `google-analytics` are at project top level; Quarto only reads them
      under `website:`. Consequence: GA never fired (0 gtag refs in `docs/index.html`),
      no canonical URLs, no `sitemap.xml`, no search index.
- [ ] Enable search (`search: true` with `location: navbar`, `type: overlay`).
- [ ] Expand navbar: Home · Research · Publications · Teaching · Projects · Blog · About · CV.
      `about/`, `projects/`, `blog/`, `tutorials/` currently render but are unreachable.
- [ ] Add `robots.txt`; confirm Quarto emits `sitemap.xml` once `site-url` is nested.
- [ ] Per-page Open Graph + Twitter card meta (`open-graph`, `twitter-card` under `website:`).
- [ ] JSON-LD: `Person` on home/about, `ScholarlyArticle` on publication entries.
- [ ] Highwire `citation_*` meta on publication pages (Google Scholar indexing).
- [ ] Replace homepage popup toast with a static announcement strip below the navbar.

## Phase 2 — Design system  [DONE 2026-09-08]

- [ ] Global `:root` token layer at top of `styles.css`: type scale, spacing scale,
      color roles, radii, shadow levels. Today there is one scoped `:root` at line ~3728;
      the other ~5000 lines hardcode values.
- [ ] Typography: serif display (Source Serif 4 / Newsreader) + Inter body, self-hosted
      or via Google Fonts with real fallback stacks.
- [ ] Dark mode: `theme: [cosmo, custom-dark]` + token overrides; navbar toggle.
- [ ] Refactor existing card CSS to tokens; drop generic drop-shadows for hairline borders.
- [ ] Responsive audit at 375 / 768 / 1440.

## Phase 3 — Homepage rebuild  [DONE 2026-09-08]

Structure adapted from srijitseal.com at the user's request. Sections, in order:

1. **Hero** — eyebrow, name, one-line role, two-paragraph bio, topic pills,
   stats row, CTA buttons, and a right-rail card (photo, location, affiliations,
   obfuscated email, Scholar/GitHub/ORCID/LinkedIn buttons).
2. **SELECTED WORK / Featured Research** — 4 cards from `featured.yml`.
3. **RESEARCH AREAS / Three Data Modalities** — the existing SVG pillars.
4. **SPEAKING / Talks & Presentations** — filterable timeline (All 19 / Oral 7 /
   Poster 8 / Invited 4) from the existing conference + poster + invited YAML.
5. **FEATURED TOOLS / Tools & Tutorials** — tutorial series and research code.
6. **UPDATES / News** — timeline from `news.yml`.
7. **TRAINING / Open programmes** — DeepBio Academy cohorts.

New data files: `data/featured.yml`, `data/news.yml`.

> Note: a listing `contents:` path cannot live under an underscore-prefixed
> directory - Quarto skips those when globbing, and the listing silently
> renders empty. `_templates/` works only because it is read as a template,
> not globbed as content. Hence `data/`, not `_data/`.
New templates: `featured-card.ejs`, `news-item.ejs`, `talk-item.ejs`.

- [x] **Navbar is homepage section anchors**, as in the reference: Home / Work
      / Talks / Tutorials / Publications / News / About / CV. Quarto resolves
      them per page ("./#talks" on the homepage, "../#talks" below it) and its
      own nav script then rewrites them absolute, so a homepage click reloaded
      the page; a delegated click handler in `index.qmd` intercepts same-page
      hashes and scrolls instead. `scroll-margin-top: 4.5rem` keeps section
      headings clear of the pinned navbar.
- [x] Footer now carries every full page (Research, Projects, Publications,
      Teaching, Tutorials, Blog, About) since the navbar no longer links them.
- [x] Featured Research cards use the venue-initial monogram, the same
      placeholder as the publication list; the four unrelated pastel SVGs are
      no longer referenced.

Still open:
- [ ] Graphical abstracts for the Featured Research cards (currently journal-initial
      monograms). All four papers are open access, so their figures are reusable
      with attribution — needs the user's go-ahead.
- [ ] Real news items from the user (the three seeded entries are derived from
      publication dates, not events).
- [ ] Responsive check at 390px — not yet verified.

## Phase 4 — Research depth  [PARTLY DONE 2026-09-08]

- [x] Per-publication pages for all 16 journal articles under
      `publications/papers/<slug>/`. Abstracts pulled from PubMed (14 of 16 indexed;
      the two 2022 papers say so explicitly rather than carrying invented text).
      Each page carries Highwire `citation_*` tags, JSON-LD `ScholarlyArticle`,
      DOI / PMC / PubMed links and a BibTeX copy button.
      Generator: scratchpad `genpapers.py`, driven by `pubs.json` + `pubmed.json`.
- [x] `page:` field added to every journal-article YAML entry; the publications
      listing now links titles to the local page and keeps the DOI as a secondary
      action.
- [ ] Per-project pages: abstract, key figure, methods, code repo, data accession.
- [ ] HTML CV page as source of truth; PDF generated from the same YAML.
- [ ] One interactive data element (e.g. embedded UMAP or volcano from own analysis).

## Phase 5 — Execution pass against the reference layout  [DONE 2026-09-08]

Fixes found by rendering the site and comparing it to the srijitseal.com snapshot,
not by reading the source:

- [x] **Hero right rail was 215px wide.** Quarto stamps `page-columns page-full`
      down the first-child chain of a raw HTML block on a `page-layout: full`
      page, so `.hero-body` and `.hero-layout` became Quarto's named page grid
      and `<aside>` was pushed into the margin column (`grid-column: body-end /
      page-end !important`). Opted the hero subtree out in `styles.css`; the rail
      is now 340px with a 304px portrait, matching the reference.
- [x] **Homepage bands were inset.** `section.section` sat in the `body-content`
      column, so every banded section stopped short of the viewport with white
      gutters. `main.page-columns > .section` now spans `screen-start /
      screen-end`.
- [x] **No icon on the site rendered.** Font Awesome was never loaded — only
      Bootstrap Icons (Quarto) and Academicons (the `{{< ai >}}` shortcode).
      Every `fa-*` class in `index.qmd`, five templates and four YAML data files
      was swapped to its `bi bi-*` equivalent.
- [x] Profile links moved out of the card into a 2x2 grid of full-width buttons,
      as in the reference.
- [x] Featured cards: fixed 180px figure box (aspect-ratio let a wide figure
      shrink its own box and knock the venue badges out of line), and the title
      line-clamp was dropped so titles are no longer truncated mid-phrase.
- [x] One filter chip across the site: `.filter-button`, `.pub-chip` and
      `.category-btn` had three different active states (accent tint, ink fill,
      solid accent fill). All three now use the accent tint.
- [x] Badge palette cut from six hues to accent + neutral, with amber kept for
      "not yet published". Dropped the 3px accent bar and purple variant under
      the publications group headers for a hairline.
- [x] Pipeline cards on the teaching page lost their 120px empty gradient banner
      (indigo / teal / purple per category) for a 3px accent rule; the category
      is already named by the pill below it.
- [x] **Band alternation was inverted.** Sampling the reference snapshot gives
      hero `#f5f8fa` -> Featured white -> Talks `#f5f8fa` -> Tools white ->
      Publications `#f5f8fa` -> News white. The homepage ran the opposite phase,
      so the hero and Featured Research shared one tint and read as a single
      block. `section-band` moved onto talks / publications / programmes.
- [x] Card titles (publications, resources, programmes) moved from serif to sans:
      the serif display face is now reserved for page and section headings.
- [x] `cv/CV-HossainMJ.pdf` is now a real source file listed under
      `project.resources`. It existed only as a committed build artefact, so a
      full `quarto render` deleted it and broke the navbar CV link.

- [x] **Publication action row.** `home-publication.ejs` emitted only Paper and
      DOI, and `journal-articles.yml` carried neither `page:` nor any other link
      field, so in practice every entry showed a single DOI button. The row now
      renders Paper / Code / Preprint / PDF / Full text / Data / Slides / DOI,
      each only when the matching YAML field exists. `page:`, `pmc:` and
      `pubmed:` were backfilled from the per-paper pages (16 / 13 / 13), and the
      2026 thyroid-cancer paper, present on the publications page but missing
      from the homepage list, was added.
- [x] **Authorship status removed** at the user's request. The "Corresponding
      Author" badge is gone from all five branches of `publication-card.ejs`
      and from the homepage row; on the homepage the whole chip went, because
      its else-branch ("Peer-Reviewed") then fired on every entry under a
      heading that already says Journal Articles. "PEER-REVIEWED" is kept on
      the publications page, where the same list also holds under-review,
      working papers and posters and the label separates them. The
      `corresponding:` field stays in the YAML, now unused by any template.

Still open:
- [ ] No `code:`, `preprint:` or `data:` URL exists anywhere in the repo, so
      those buttons render for nothing yet. Add the repository / bioRxiv /
      accession URLs to `publications/journal-articles.yml` and they appear with
      no further code change.
- [ ] The four Featured Research figures are generated pastel motifs, not the
      papers' own graphical abstracts. All four are open access, so the real
      figures are reusable with attribution — needs the user's go-ahead.
- [ ] Publication list thumbnails are journal-initial monograms for the same
      reason.
- [ ] Legacy `tp-*` / course / certificate CSS still hardcodes off-system hues.
      Most of it belongs to orphaned templates; worth deleting rather than
      retokenising.

---

## Constraints

- EJS templates: all HTML tags at column 0, else pandoc wraps content in `<pre><code>`.
- Never edit `docs/` by hand; it is build output. Run `quarto render`.
- `styles.css` is append-only by convention today; Phase 2 changes that deliberately.
