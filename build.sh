#!/bin/bash

# Netlify build script for Quarto website
# This script installs Quarto and renders the website

set -e  # Exit on any error

echo "🔧 Installing Quarto..."

# Download and install Quarto (no sudo required)
curl -LO https://quarto.org/download/latest/quarto-linux-amd64.tar.gz
mkdir -p quarto
tar -xzf quarto-linux-amd64.tar.gz -C quarto --strip-components=1

# Add to PATH
export PATH="$PWD/quarto/bin:$PATH"

# Verify installation
echo "✅ Quarto installed successfully:"
quarto --version

# Install R packages if needed
echo "📦 Installing R packages..."
Rscript -e "
if (!require('yaml', quietly = TRUE)) {
  install.packages('yaml', repos = 'https://cloud.r-project.org/')
}
if (!require('knitr', quietly = TRUE)) {
  install.packages('knitr', repos = 'https://cloud.r-project.org/')
}
if (!require('rmarkdown', quietly = TRUE)) {
  install.packages('rmarkdown', repos = 'https://cloud.r-project.org/')
}
cat('✅ R packages installed successfully\n')
"

# Check Quarto installation
echo "🔍 Checking Quarto installation..."
quarto check

# Render the website
echo "🚀 Rendering website..."
quarto render

echo "✅ Build completed successfully!"
echo "📁 Output directory: docs/"