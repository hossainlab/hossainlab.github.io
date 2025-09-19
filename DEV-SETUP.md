# Development Setup - Auto-Reload System

This project now includes an automated development system that eliminates the need to manually restart servers.

## 🚀 Quick Start

```bash
# First time setup
npm run setup

# Start development (auto-reloads on changes)
npm run dev
```

Visit: http://localhost:4321

## 📋 Available Commands

### NPM Scripts
```bash
npm run dev          # Start development server with auto-reload
npm run dev-watch    # Enhanced development with file watching
npm run build        # Build the website
npm run render-fast  # Fast HTML-only build
npm run serve        # Serve without auto-reload
npm run clean        # Clean build artifacts
npm run setup        # Complete setup
```

### Make Commands
```bash
make dev            # Start development server (default)
make dev-watch      # Enhanced file watching
make build          # Build website
make build-fast     # Fast build
make serve          # Serve without auto-reload
make clean          # Clean artifacts
make setup          # Complete setup
make help           # Show all commands
```

### Direct Node.js
```bash
node dev-server.js  # Custom development server with enhanced logging
```

## 🔧 What's Included

### Auto-Reload Features
- **File Watching**: Monitors `.qmd`, `.yml`, `.css`, `.scss`, `.js` files
- **Smart Ignoring**: Excludes build artifacts and temporary files
- **Live Reload**: Browser automatically refreshes on changes
- **Enhanced Logging**: Clear feedback on what files changed

### VS Code Integration
- **Tasks**: Press `Ctrl+Shift+P` → "Tasks: Run Task"
- **Launch Configurations**: Debug-ready setup
- **Integrated Terminal**: Seamless development experience

### File Monitoring
The system watches:
- `**/*.qmd` - Quarto markdown files
- `**/*.yml`, `**/*.yaml` - Configuration files
- `**/*.css`, `**/*.scss` - Stylesheets
- `**/*.js` - JavaScript files
- `_quarto.yml`, `_variables.yml` - Main config files

Ignores:
- `docs/**` - Build output
- `.quarto/**` - Quarto cache
- `_freeze/**` - Frozen content
- `node_modules/**` - Dependencies
- `.git/**` - Git files

## 🛠️ Configuration Files

| File | Purpose |
|------|---------|
| `package.json` | NPM scripts and dependencies |
| `nodemon.json` | File watching configuration |
| `dev-server.js` | Custom development server |
| `Makefile` | Make commands for convenience |
| `.vscode/tasks.json` | VS Code task integration |
| `.vscode/launch.json` | VS Code debugging setup |

## 🔄 Workflow

1. **Start Once**: Run `npm run dev`
2. **Edit Files**: Make changes to any `.qmd`, `.css`, or config files
3. **Auto-Reload**: Browser automatically refreshes
4. **No Manual Restarts**: System handles everything automatically

## 🐛 Troubleshooting

**Port 4321 in use?**
```bash
# Kill existing processes
npx kill-port 4321
npm run dev
```

**Dependencies missing?**
```bash
npm run setup
```

**Clean slate?**
```bash
npm run clean
npm run dev
```

## 💡 Tips

- Keep the terminal open to see file change notifications
- Use `Ctrl+C` to stop the development server
- The server starts automatically in your default browser
- Changes to `_quarto.yml` may require a manual refresh

---

*Never manually restart your development server again! 🎉*