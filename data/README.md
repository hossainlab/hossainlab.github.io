# Site data

Every listing on the site reads from exactly one file in here. Nothing else in
the repository holds content: edit a file here and the page follows on the next
`quarto render`.

| File | Feeds | Template |
|---|---|---|
| `featured.yml` | Home > Featured Research | `featured-card.ejs` |
| `news.yml` | Home > News | `news-item.ejs` |
| `programmes.yml` | Home > Open Programmes | `programme-card.ejs` |
| `projects.yml` | Projects | `project-card.ejs` |
| `publications/journal-articles.yml` | Home > Recent Publications, Publications | `home-publication.ejs`, `publication-card.ejs` |
| `publications/gbd-contributions.yml` | Publications | `publication-card.ejs` |
| `publications/under-review.yml` | Publications | `publication-card.ejs` |
| `publications/working-papers.yml` | Publications | `publication-card.ejs` |
| `publications/conference-presentations.yml` | Home > Talks, Publications | `talk-item.ejs`, `publication-card.ejs` |
| `publications/posters.yml` | Home > Talks, Publications | `talk-item.ejs`, `publication-card.ejs` |
| `publications/invited-speaker.yml` | Home > Talks, Publications | `talk-item.ejs`, `publication-card.ejs` |
| `about/ventures.yml` | About | `venture-card.ejs` |
| `about/education.yml` | About | `education-card.ejs` |
| `about/certificates.yml` | About | `certificate-card.ejs` |
| `research/mentorship.yml` | Research | `mentee-card.ejs` |
| `research/collaborators.yml` | Research | `collaborator-card.ejs` |
| `teaching/courses.yml` | Teaching | `course-card.ejs` |
| `teaching/pipelines.yml` | Teaching | `pipeline-tutorial-card.ejs` |
| `teaching/videos.yml` | Teaching | `video-card.ejs` |
| `tutorials/scpy.yml` | Tutorials > Single-Cell with Python | `tutorial-card.ejs` |
| `tutorials/nextflow.yml` | Tutorials > Nextflow and nf-core | `tutorial-card.ejs` |

Each file documents its own fields in a header comment.

## Rules

- **One file per content type.** `publications/journal-articles.yml` is the only
  list of journal articles; the homepage and the publications page both read it.
  The old per-year splits are in `archive/publications/`.
- **`page:` values are site-absolute** (`/publications/papers/<slug>/`) because
  two pages at different depths consume the same file.
- **Data consumed by a listing cannot live under an underscore directory.**
  Quarto skips those when globbing `contents:` and the listing silently renders
  empty. That is why this is `data/` and not `_data/`.
- **Talks on the homepage are filtered to `categories: [Bioinformatics]`** by
  `talk-item.ejs`. The publications page shows every talk from the same files.

## archive/

Superseded or unreferenced files, kept deliberately and excluded from the render
in `_quarto.yml`: the per-year publication splits, two unused publication lists,
`about/academic.yml`, seven templates no page references, and the scratch files
from the redesign.
