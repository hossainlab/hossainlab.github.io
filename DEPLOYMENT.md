# Deployment Guide

This document explains how to deploy the Jubayer Hossain academic website to Netlify.

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) installed
- [Node.js](https://nodejs.org/) (version 18 or higher)
- [R](https://www.r-project.org/) with required packages
- Git repository connected to GitHub/GitLab

## Quick Deployment to Netlify

### Option 1: Automatic Git-based Deployment (Recommended)

1. **Connect Repository to Netlify:**
   - Go to [Netlify](https://netlify.com)
   - Click "New site from Git"
   - Connect your GitHub/GitLab repository
   - Select the repository: `hossainlab.github.io`

2. **Configure Build Settings:**
   - **Build command:** `./build.sh`
   - **Publish directory:** `docs`
   - **Base directory:** (leave empty)

3. **Set Environment Variables** (in Netlify dashboard):
   ```
   QUARTO_DENO=true
   QUARTO_DENO_V8_OPTIONS=--max-heap-size=3000
   NODE_ENV=production
   ```

4. **Deploy:**
   - Click "Deploy site"
   - Netlify will automatically build and deploy on every push to main branch

### Option 2: Manual Deployment

1. **Install Dependencies:**
   ```bash
   npm install
   ```

2. **Build the Site:**
   ```bash
   npm run build
   ```

3. **Deploy to Netlify:**
   ```bash
   npm run deploy
   ```

## Configuration Files

### netlify.toml
- Contains build configuration, redirects, and headers
- Located in project root
- Handles caching, security headers, and URL redirects

### package.json
- Defines Node.js dependencies and build scripts
- Contains deployment commands for Netlify

### _redirects
- Located in `docs/` directory
- Handles URL redirects for clean URLs

## Build Process

The site build process follows these steps:

1. **Clean previous build** (optional)
2. **Render Quarto documents** to HTML
3. **Process R code chunks** and generate outputs
4. **Copy static assets** to docs directory
5. **Apply CSS and JavaScript optimizations**
6. **Generate site structure** in docs folder

## Required R Packages

Make sure these R packages are installed:

```r
install.packages(c(
  "yaml",
  "knitr",
  "rmarkdown"
))
```

## Environment Variables

Environment variables are configured directly in Netlify dashboard:

```
QUARTO_DENO=true
QUARTO_DENO_V8_OPTIONS=--max-heap-size=3000
QUARTO_R=true
```

## Troubleshooting

### Common Build Issues

1. **Build script exit code 2:**
   ```
   Build script returned non-zero exit code: 2
   ```
   Solutions:
   - Check build logs for specific error
   - Try using the simple build script: change build command to `./build-simple.sh`
   - Verify all files are committed to repository

2. **Quarto installation fails:**
   ```
   Failed to download Quarto
   ```
   Solutions:
   - Check internet connectivity in build environment
   - Try alternative build command: `curl -s https://quarto.org/download/latest/quarto-linux-amd64.tar.gz | tar -xzf - && export PATH="$(find . -name 'quarto' -type f | head -1 | xargs dirname):$PATH" && quarto render`

3. **R package missing:**
   ```
   Error: package 'yaml' not found
   ```
   Solution: The build script will automatically install required R packages

4. **Memory issues:**
   ```
   JavaScript heap out of memory
   ```
   Solution: Memory limit is configured in netlify.toml

5. **File permissions:**
   ```
   Permission denied: ./build.sh
   ```
   Solution: Build command includes `chmod +x build.sh`

### Alternative Build Commands

If the main build fails, try these alternatives in Netlify dashboard:

**Option 1: Simple build (recommended fallback)**
```bash
chmod +x build-simple.sh && ./build-simple.sh
```

**Option 2: Direct Quarto installation**
```bash
curl -s https://quarto.org/download/latest/quarto-linux-amd64.tar.gz | tar -xzf - && export PATH="$(find . -name 'quarto' -type f | head -1 | xargs dirname):$PATH" && quarto render
```

**Option 3: Manual steps**
```bash
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.31/quarto-1.7.31-linux-amd64.tar.gz && tar -xzf quarto-1.7.31-linux-amd64.tar.gz && export PATH="$PWD/quarto-1.7.31/bin:$PATH" && quarto render
```

### Build Commands

- **Development:** `npm run dev`
- **Build:** `npm run build`
- **Clean:** `npm run clean`
- **Deploy:** `npm run deploy`

## Performance Optimization

The site includes several optimizations:

- CSS and JavaScript minification
- Image optimization
- Caching headers for static assets
- Clean URLs with redirects
- Security headers

## Domain Configuration

To use a custom domain:

1. Add domain in Netlify dashboard
2. Configure DNS records
3. Update SITE_URL in environment variables
4. Update social media links if needed

## Monitoring

After deployment, monitor:

- Build logs in Netlify dashboard
- Site performance with Lighthouse
- Broken links and 404 errors
- Analytics (if configured)

## Support

For deployment issues:
- Check Netlify build logs
- Review Quarto documentation
- Check R package installations
- Verify environment variables