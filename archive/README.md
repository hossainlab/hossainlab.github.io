# archive/

Nothing here is rendered or referenced. `_quarto.yml` excludes `archive/` from
the render list. Kept on purpose rather than deleted.

| Path | Why it is here |
|---|---|
| `publications/journal-articles_2022..2026.yml` | Superseded by the single `data/publications/journal-articles.yml`. The five files held exactly the same 16 entries as the homepage list, so the site had two sources for one thing. Merged, keeping the richer field set per entry. |
| `publications/all-pubs.yml` | No `.qmd` referenced it. |
| `publications/publications.yml` | No `.qmd` referenced it. |
| `about/academic.yml` | No `.qmd` referenced it (its `academic-card.ejs` is here too). |
| `templates/*.ejs` | Seven templates no page uses: `academic-card`, `mentor-endorsement`, `mentor-plan`, `mentor-review`, `mentorship-page`, `pipeline-card`, `teaching-portfolio-page`. There is no mentorship or teaching-portfolio page on the site. |
| `scratch/scratch_srijit.*` | Working files from the homepage redesign. |

To bring something back: move it out, add a listing that points at it, and
render. Check `data/README.md` first - the live equivalent may already exist.
