# Quarto Website Development Makefile

.PHONY: dev install build clean serve help

# Default target
dev: install
	@echo "🚀 Starting development server with auto-reload..."
	@npm run dev

# Install dependencies
install:
	@echo "📦 Installing development dependencies..."
	@npm install

# Enhanced development with file watching
dev-watch: install
	@echo "👀 Starting development with enhanced file watching..."
	@npm run dev:watch

# Build the website
build:
	@echo "🔨 Building website..."
	@quarto render

# Fast build (HTML only)
build-fast:
	@echo "⚡ Fast building website..."
	@npm run render:fast

# Serve without auto-reload (for production testing)
serve:
	@echo "🌐 Serving website..."
	@npm run serve

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@quarto clean
	@rm -rf docs/_site

# Complete setup
setup:
	@echo "⚙️  Setting up development environment..."
	@npm run setup

# Preview specific file
preview-file:
	@echo "📄 Preview specific file (usage: make preview-file FILE=path/to/file.qmd)"
	@quarto preview $(FILE)

# Help
help:
	@echo "Available commands:"
	@echo "  make dev        - Start development server (default)"
	@echo "  make dev-watch  - Start with enhanced file watching"
	@echo "  make build      - Build the website"
	@echo "  make build-fast - Fast build (HTML only)"
	@echo "  make serve      - Serve without auto-reload"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make setup      - Complete setup"
	@echo "  make install    - Install dependencies"
	@echo "  make help       - Show this help"