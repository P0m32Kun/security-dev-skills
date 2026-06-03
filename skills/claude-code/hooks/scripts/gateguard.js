#!/usr/bin/env node
'use strict';

/**
 * GateGuard — PreToolUse hook that forces investigation before editing files.
 *
 * File Edit Gating: denies first edit/write to a file, demanding investigation first.
 * Destructive Command Detection: blocks dangerous shell commands.
 *
 * Input (stdin):  { session_id, tool_name, tool_input: { file_path?, command? } }
 * Output (stdout): { permissionDecision: "deny", reason: "..." } or empty (allow)
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// ── Config ──────────────────────────────────────────────────────────────────

const STATE_DIR = path.join(os.homedir(), '.p-skills', 'gateguard');
const STATE_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes
const MAX_ENTRIES = 200;

// ── Helpers ─────────────────────────────────────────────────────────────────

function isDisabled() {
  const v = (process.env.P_SKILLS_GATEGUARD || '').toLowerCase().trim();
  return v === 'off' || v === 'false' || v === '0' || v === 'disabled';
}

function sessionKey(sessionId) {
  // Sanitize session id for use as filename
  return (sessionId || 'unknown').replace(/[^a-zA-Z0-9_-]/g, '_');
}

function statePath(sessionId) {
  return path.join(STATE_DIR, `state-${sessionKey(sessionId)}.json`);
}

function readState(sessionId) {
  try {
    const p = statePath(sessionId);
    if (!fs.existsSync(p)) return {};
    const raw = JSON.parse(fs.readFileSync(p, 'utf8'));
    // Check timeout
    if (Date.now() - (raw._ts || 0) > STATE_TIMEOUT_MS) return {};
    return raw;
  } catch {
    return {};
  }
}

function writeState(sessionId, state) {
  try {
    fs.mkdirSync(STATE_DIR, { recursive: true });
    state._ts = Date.now();
    const p = statePath(sessionId);
    const tmp = p + '.tmp.' + process.pid;
    fs.writeFileSync(tmp, JSON.stringify(state, null, 2));
    fs.renameSync(tmp, p);
  } catch {
    // silent
  }
}

function evictLRU(state) {
  const keys = Object.keys(state).filter(k => k !== '_ts');
  if (keys.length <= MAX_ENTRIES) return;
  // Sort by last access time, oldest first
  keys.sort((a, b) => (state[a]._at || 0) - (state[b]._at || 0));
  const toRemove = keys.slice(0, keys.length - MAX_ENTRIES);
  for (const k of toRemove) delete state[k];
}

function deny(reason) {
  console.log(JSON.stringify({ permissionDecision: 'deny', reason }));
}

// ── Destructive Command Detection ───────────────────────────────────────────

const DESTRUCTIVE_PATTERNS = [
  // rm -rf (various flag orderings)
  /\brm\s+(-[^\s]*r[^\s]*f|-[^\s]*f[^\s]*r)\b/,
  /\brm\s+(-[^\s]*r\s+-[^\s]*f|-[^\s]*f\s+-[^\s]*r)\b/,
  // git reset --hard
  /\bgit\s+reset\s+(?:\S+\s+)*--hard\b/,
  // git push --force (but NOT --force-with-lease)
  /\bgit\s+push\b[^\n]*--force(?!-with-lease)\b/,
  // git commit --amend
  /\bgit\s+commit\s+(?:\S+\s+)*--amend\b/,
  // git switch --force / -f / -C
  /\bgit\s+switch\s+(?:\S+\s+)*--force\b/,
  /\bgit\s+switch\s+(?:\S+\s+)*-[a-zA-Z]*f\b/,
  /\bgit\s+switch\s+(?:\S+\s+)*-[a-zA-Z]*C\b/,
  // git checkout --
  /\bgit\s+checkout\s+--\b/,
  // git rm -r
  /\bgit\s+rm\s+(?:\S+\s+)*-r\b/,
  // SQL destructive
  /\bDROP\s+TABLE\b/i,
  /\bDELETE\s+FROM\b/i,
  /\bTRUNCATE\b/i,
  // dd if=
  /\bdd\s+(?:\S+\s+)*if=/,
];

/**
 * Strip comments and split a command into segments that could each be dangerous.
 * Handles: pipes, &&, ||, ;, $(...), `...`, { ...; }, ( ... )
 */
function extractCommandSegments(command) {
  const segments = [];

  // Remove line comments (# ...) but not inside quotes
  let cleaned = command.replace(/(?:^|\s)#[^\n]*/g, ' ');

  // Add the full command
  segments.push(cleaned);

  // Extract subshell content: $(...) and `...`
  const subshellDollar = cleaned.matchAll(/\$\(([^)]*)\)/g);
  for (const m of subshellDollar) segments.push(m[1]);

  const subshellBacktick = cleaned.matchAll(/`([^`]*)`/g);
  for (const m of subshellBacktick) segments.push(m[1]);

  // Extract brace group content: { cmd; }
  const braceGroup = cleaned.matchAll(/\{\s*([^}]*)\s*\}/g);
  for (const m of braceGroup) segments.push(m[1]);

  // Split on pipe, &&, ||, ;
  const chainSplit = cleaned.split(/(?:\|\||&&|\|(?!\|)|;)/);
  for (const s of chainSplit) {
    const trimmed = s.trim();
    if (trimmed) segments.push(trimmed);
  }

  return segments;
}

function isDestructiveCommand(command) {
  if (!command || typeof command !== 'string') return false;
  const segments = extractCommandSegments(command);
  for (const seg of segments) {
    for (const pattern of DESTRUCTIVE_PATTERNS) {
      if (pattern.test(seg)) return pattern;
    }
  }
  return false;
}

// ── File Edit Gating ────────────────────────────────────────────────────────

function handleFileEdit(toolInput, state) {
  const filePath = toolInput.file_path || toolInput.path || toolInput.filePath;
  if (!filePath) return; // no file path, allow

  // Normalize the path
  const normalized = path.resolve(filePath);

  if (state[normalized]) {
    // Already gated — allow on retry
    state[normalized]._at = Date.now();
    state[normalized].retries = (state[normalized].retries || 1) + 1;
    return; // allow
  }

  // First touch — deny and gate
  state[normalized] = { _at: Date.now(), retries: 0 };
  deny(
    `First edit to ${path.basename(filePath)} requires investigation. ` +
    `Read the file and understand the surrounding code before editing. ` +
    `Your next edit to this file will be allowed.`
  );
  return 'denied';
}

// ── Main ────────────────────────────────────────────────────────────────────

function main() {
  if (isDisabled()) return;

  let input;
  try {
    input = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
  } catch {
    return; // allow on parse failure
  }

  const { session_id, tool_name, tool_input } = input || {};
  if (!tool_name || !tool_input) return;

  // Skip for subagent invocations (heuristic: session id contains 'subagent')
  if (session_id && /subagent/i.test(session_id)) return;

  const state = readState(session_id);

  try {
    if (tool_name === 'Edit' || tool_name === 'Write' || tool_name === 'MultiEdit') {
      handleFileEdit(tool_input, state);
    } else if (tool_name === 'Bash') {
      const matched = isDestructiveCommand(tool_input.command);
      if (matched) {
        deny(
          `Blocked destructive command. Pattern: ${matched.source}. ` +
          `If this is intentional, set P_SKILLS_GATEGUARD=off or remove the dangerous flag.`
        );
        return;
      }
    }
  } finally {
    evictLRU(state);
    writeState(session_id, state);
  }
}

main();
