#!/bin/bash

# Simple Quarto installation script for Netlify
set -e

echo "Installing Quarto..."

# Use the official Quarto installer
curl -LO https://quarto.org/download/latest/quarto-linux-amd64.tar.gz
mkdir -p quarto
tar -xzf quarto-linux-amd64.tar.gz -C quarto --strip-components=1

# Add to PATH
export PATH="$PWD/quarto/bin:$PATH"

# Verify installation
echo "Quarto version:"
quarto --version

echo "Quarto installed successfully!"