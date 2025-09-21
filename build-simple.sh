#!/bin/bash

# Simple backup build script for Netlify
# Fallback if the main build.sh fails

echo "🔧 Simple Quarto build starting..."

# Install Quarto using the official installer
echo "📥 Downloading Quarto..."
curl -s https://quarto.org/download/latest/quarto-linux-amd64.tar.gz | tar -xzf -

# Find Quarto binary and add to PATH
QUARTO_BIN=$(find . -name "quarto" -type f -executable | head -1)
if [[ -z "$QUARTO_BIN" ]]; then
    echo "❌ Could not find Quarto binary"
    exit 1
fi

export PATH="$(dirname "$QUARTO_BIN"):$PATH"

echo "✅ Quarto version: $(quarto --version)"

# Simple render without R packages (use only if absolutely necessary)
echo "🚀 Rendering website..."
quarto render --to html

echo "✅ Simple build completed!"

# Check output
if [[ -f "docs/index.html" ]]; then
    echo "📄 index.html generated successfully"
    exit 0
else
    echo "❌ index.html not found"
    exit 1
fi