#!/bin/bash

# Netlify build script for Quarto website
# This script installs Quarto and renders the website

set -euo pipefail  # Exit on any error, undefined variables, and pipe failures

echo "🔧 Starting Quarto website build..."
echo "Current directory: $(pwd)"
echo "Available disk space: $(df -h . | tail -1)"

# Function to handle errors
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Check if we're in the right directory
if [[ ! -f "_quarto.yml" ]]; then
    error_exit "_quarto.yml not found. Are we in the right directory?"
fi

echo "🔧 Installing Quarto..."

# Download and install Quarto with better error handling
QUARTO_VERSION="1.7.31"
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"

echo "Downloading Quarto from: $QUARTO_URL"
if ! curl -fLO "$QUARTO_URL"; then
    error_exit "Failed to download Quarto"
fi

echo "Extracting Quarto..."
mkdir -p quarto
if ! tar -xzf "quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" -C quarto --strip-components=1; then
    error_exit "Failed to extract Quarto"
fi

# Add to PATH
export PATH="$PWD/quarto/bin:$PATH"
echo "Quarto path: $PWD/quarto/bin"

# Verify installation
echo "✅ Verifying Quarto installation..."
if ! quarto --version; then
    error_exit "Quarto installation failed"
fi

# Check if R is available and install packages
echo "📦 Checking R availability..."
if command -v R >/dev/null 2>&1; then
    echo "R found, installing packages..."
    R --slave --no-restore --no-save -e "
    options(repos = c(CRAN = 'https://cloud.r-project.org/'))

    # Install required packages
    packages <- c('yaml', 'knitr', 'rmarkdown')
    for (pkg in packages) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
            cat(paste('Installing', pkg, '...\n'))
            install.packages(pkg, quiet = TRUE)
        } else {
            cat(paste(pkg, 'already installed\n'))
        }
    }
    cat('✅ R packages ready\n')
    " || echo "⚠️  R package installation had issues, but continuing..."
else
    echo "⚠️  R not found, skipping R package installation"
fi

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
if [[ -d "docs" ]]; then
    rm -rf docs/*
fi

# Render the website
echo "🚀 Rendering website..."
if ! quarto render; then
    echo "❌ Quarto render failed"
    echo "Checking for common issues..."

    # Check if docs directory exists
    if [[ ! -d "docs" ]]; then
        echo "docs directory was not created"
    fi

    # Check for any error logs
    if [[ -f ".quarto/render-errors.log" ]]; then
        echo "Render errors found:"
        cat ".quarto/render-errors.log"
    fi

    error_exit "Website rendering failed"
fi

# Verify output
echo "🔍 Verifying output..."
if [[ ! -d "docs" ]]; then
    error_exit "docs directory was not created"
fi

if [[ ! -f "docs/index.html" ]]; then
    error_exit "index.html was not generated"
fi

echo "✅ Build completed successfully!"
echo "📁 Output directory: docs/"
echo "📊 Files generated: $(find docs -type f | wc -l)"
echo "📏 Total size: $(du -sh docs/ | cut -f1)"

# List key files for verification
echo "🗂️  Key files generated:"
ls -la docs/ | head -10