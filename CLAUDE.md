# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Quarto-based academic website for Md. Jubayer Hossain, a biomedical researcher specializing in neuroepidemiology, cancer epidemiology, and bioinformatics. The site is built using Quarto and deployed to GitHub Pages.

## Common Commands

### Development and Building (Auto-Reload System)
- **Start development server** (recommended): `npm run dev` or `make dev`
- **Enhanced development with file watching**: `npm run dev-watch`
- **Manual preview**: `quarto preview` (serves on port 4321)
- **Build the website**: `npm run build` or `quarto render`
- **Fast build**: `npm run render:fast`
- **Clean build artifacts**: `npm run clean` or `quarto clean`

### Quick Setup
1. **First time setup**: `npm run setup` or `make setup`
2. **Start developing**: `npm run dev` (auto-reloads on file changes)
3. **Access site**: http://localhost:4321

### Alternative Commands
- **Using Make**: `make dev`, `make build`, `make clean`
- **VS Code**: Use Tasks (Ctrl+Shift+P → "Tasks: Run Task")
- **Node.js script**: `node dev-server.js`

### Site Structure
- **Main configuration**: `_quarto.yml` - Contains all website configuration including navigation, themes, and build settings
- **Variables**: `_variables.yml` - Contains site-wide variables like ORCID, GitHub URL, etc.
- **Output directory**: `docs/` - Generated site files for GitHub Pages deployment

## Architecture

### Content Organization
- `index.qmd` - Homepage with personal introduction and research interests
- `about/` - About section with detailed biography
- `research/` - Research interests and grants information
- `publications/` - Academic publications organized by type (peer-reviewed, working papers, etc.)
- `projects/` - Research projects and portfolios
- `teaching/` - Course listings and educational content
- `talks/` - Conference presentations and talks
- `blog/` - Blog posts with metadata configuration
- `cv/` - Curriculum vitae
- `press/` - Media appearances and press coverage
- `use/` - Tools and resources used

### Key Configuration Details
- **Engine**: Uses `knitr` engine for R code execution
- **Freeze**: Set to `auto` for selective re-rendering
- **Themes**: Light (flatly) and dark (darkly) themes configured
- **Formats**: Primarily HTML output with full page layout
- **Resources**: Files directory included in build output

### File Types
- `.qmd` files are the primary content format (Quarto Markdown)
- `.yml` files for configuration
- `.R` files in `hexscripts/` for R-specific utilities
- `.css/.scss` files for custom styling

### Navigation Structure
The site uses a navbar with main sections (Home, About, Research, Publications, Projects, Talks, Teaching) and a "More" dropdown for additional content like Blog, Press, and Dashboards.

## Development Notes
- The site uses Quarto's freeze feature, so only changed content gets re-rendered
- Academic icons are used via shortcodes like `{{< ai orcid>}}`
- The site includes social media integration and contact information
- Bootstrap-based themes with custom CSS styling