#!/usr/bin/env node

const { spawn } = require('child_process');
const chokidar = require('chokidar');
const path = require('path');

console.log('🚀 Starting Quarto development server with auto-reload...\n');

// Start Quarto preview server
const quartoProcess = spawn('quarto', ['preview', '--port', '4321'], {
  stdio: 'inherit',
  shell: true
});

// Watch for file changes
const watcher = chokidar.watch([
  '**/*.qmd',
  '**/*.yml',
  '**/*.yaml',
  '**/*.css',
  '**/*.scss',
  '**/*.js',
  '_quarto.yml',
  '_variables.yml'
], {
  ignored: [
    'docs/**',
    '.quarto/**',
    '_freeze/**',
    'node_modules/**',
    '.git/**'
  ],
  persistent: true,
  ignoreInitial: true
});

watcher.on('change', (filePath) => {
  const relativePath = path.relative(process.cwd(), filePath);
  console.log(`📝 File changed: ${relativePath}`);
  console.log('⚡ Quarto will auto-reload the preview...\n');
});

watcher.on('add', (filePath) => {
  const relativePath = path.relative(process.cwd(), filePath);
  console.log(`➕ New file added: ${relativePath}`);
});

watcher.on('unlink', (filePath) => {
  const relativePath = path.relative(process.cwd(), filePath);
  console.log(`🗑️  File deleted: ${relativePath}`);
});

console.log('👀 Watching for file changes...');
console.log('🌐 Server running at: http://localhost:4321');
console.log('⏹️  Press Ctrl+C to stop\n');

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Stopping development server...');
  watcher.close();
  quartoProcess.kill('SIGINT');
  process.exit(0);
});

process.on('SIGTERM', () => {
  watcher.close();
  quartoProcess.kill('SIGTERM');
  process.exit(0);
});