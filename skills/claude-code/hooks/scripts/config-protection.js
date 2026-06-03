#!/usr/bin/env node
'use strict';

/**
 * Config Protection — PreToolUse hook that blocks modification of linter/formatter configs.
 *
 * Allows first-time creation of new config files.
 * Blocks edits to existing protected config files.
 * Special handling for pyproject.toml and tsconfig.json.
 *
 * Input (stdin):  { tool_name, tool_input: { file_path?, command? } }
 * Output (stdout): { permissionDecision: "deny", reason: "..." } or empty (allow)
 */

const fs = require('fs');
const path = require('path');

// ── Protected Config Basenames ──────────────────────────────────────────────

// Files matched by exact basename (with glob-like dot-prefix patterns)
const PROTECTED_PATTERNS = [
  // ESLint
  /^\.eslintrc/,
  /^eslint\.config\./,
  // Prettier
  /^\.prettierrc/,
  /^prettier\.config\./,
  // Biome
  /^biome\.json$/,
  /^biome\.jsonc$/,
  // Ruff
  /^\.ruff\.toml$/,
  /^ruff\.toml$/,
  // ShellCheck
  /^\.shellcheckrc$/,
  // Stylelint
  /^\.stylelintrc/,
  // Markdownlint
  /^\.markdownlint/,
  /^markdownlint-cli2\./,
  /^markdownlint-cli\./,
];

// Files that need content inspection
const PARTIAL_PROTECTED = {
  'pyproject.toml': (content) => content.includes('[tool.ruff]'),
  'tsconfig.json': (content) => content.includes('compilerOptions'),
};

// ── Helpers ─────────────────────────────────────────────────────────────────

function deny(reason) {
  console.log(JSON.stringify({ permissionDecision: 'deny', reason }));
}

function isProtectedBasename(basename) {
  return PROTECTED_PATTERNS.some(re => re.test(basename));
}

function isPartialProtected(filePath, basename) {
  const check = PARTIAL_PROTECTED[basename];
  if (!check) return false;
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return check(content);
  } catch {
    return false; // If we can't read it, allow (probably doesn't exist)
  }
}

function fileExists(filePath) {
  try {
    fs.accessSync(filePath, fs.constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

// ── Main ────────────────────────────────────────────────────────────────────

function main() {
  let input;
  try {
    input = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
  } catch {
    return; // allow on parse failure
  }

  const { tool_name, tool_input } = input || {};
  if (!tool_name || !tool_input) return;

  // Only gate Edit, Write, MultiEdit
  if (tool_name !== 'Edit' && tool_name !== 'Write' && tool_name !== 'MultiEdit') return;

  const filePath = tool_input.file_path || tool_input.path || tool_input.filePath;
  if (!filePath) return;

  const basename = path.basename(filePath);

  // Check if this is a fully protected config file
  const isFullyProtected = isProtectedBasename(basename);

  // Check if this is a partially protected file (needs content inspection)
  const isPartial = isFullyProtected ? false : isPartialProtected(filePath, basename);

  if (!isFullyProtected && !isPartial) return; // not protected, allow

  // Allow first-time creation (file doesn't exist yet)
  if (!fileExists(filePath)) return;

  // Block modification of existing protected file
  const target = isPartial ? `${basename} (contains protected section)` : basename;
  deny(
    `Blocked modification of linter/formatter config: ${target}. ` +
    `Config changes should be discussed and approved separately. ` +
    `To override, modify the file manually or adjust config-protection.js.`
  );
}

main();
