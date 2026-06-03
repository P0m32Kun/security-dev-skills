#!/usr/bin/env node
'use strict';

const { execSync } = require('child_process');
const path = require('path');

const TIMEOUT = 10000;
const MAX_OUTPUT = 2000;

function run(cmd, cwd) {
  try {
    return execSync(cmd, { cwd, timeout: TIMEOUT, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
  } catch {
    return null;
  }
}

function detectChecks(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const cwd = path.dirname(filePath);

  switch (ext) {
    case '.js': case '.jsx': case '.ts': case '.tsx': case '.mjs': case '.cjs':
      return [
        { cmd: `biome check "${filePath}"`, name: 'biome' },
        { cmd: `prettier --check "${filePath}"`, name: 'prettier' },
        { cmd: `eslint "${filePath}"`, name: 'eslint' },
      ].map(c => ({ ...c, cwd }));

    case '.py':
      return [
        { cmd: `ruff check "${filePath}"`, name: 'ruff' },
        { cmd: `black --check "${filePath}"`, name: 'black' },
      ].map(c => ({ ...c, cwd }));

    case '.go':
      return [
        { cmd: `go vet "${filePath}"`, name: 'go vet' },
        { cmd: `gofmt -l "${filePath}"`, name: 'gofmt' },
      ].map(c => ({ ...c, cwd }));

    case '.rs':
      return [
        { cmd: `cargo check`, name: 'cargo check' },
        { cmd: `cargo fmt --check`, name: 'cargo fmt' },
      ].map(c => ({ ...c, cwd: path.dirname(filePath) }));

    case '.md':
      return [
        { cmd: `markdownlint-cli2 "${filePath}"`, name: 'markdownlint-cli2' },
        { cmd: `markdownlint "${filePath}"`, name: 'markdownlint' },
      ].map(c => ({ ...c, cwd }));

    default:
      return [];
  }
}

function main() {
  let input;
  try {
    input = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
  } catch {
    return;
  }

  const toolName = input.tool_name || '';
  if (!['Edit', 'Write', 'MultiEdit'].includes(toolName)) return;

  const toolInput = input.tool_input || {};
  const filePath = toolInput.file_path || toolInput.path || '';
  if (!filePath) return;

  const checks = detectChecks(filePath);
  if (checks.length === 0) return;

  const issues = [];
  for (const check of checks) {
    const result = run(check.cmd, check.cwd);
    if (result !== null && result !== '') {
      issues.push(`[${check.name}] ${result}`);
    }
    if (issues.length > 0) break; // fail-fast
  }

  if (issues.length > 0) {
    const msg = issues.join('\n').slice(0, MAX_OUTPUT);
    console.log(JSON.stringify({ additionalContext: `⚠️ Quality gate: ${msg}` }));
  }
}

main();
