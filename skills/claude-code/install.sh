#!/usr/bin/env bash
set -euo pipefail

# P-Skills Claude Code Module Installer
# Installs hooks, creates required directories, merges configuration.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P_SKILLS_DIR="${HOME}/.p-skills"
CLAUDE_DIR="${HOME}/.claude"
HOOKS_FILE="${CLAUDE_DIR}/hooks.json"
GATEGUARD_DIR="${P_SKILLS_DIR}/gateguard"
SESSIONS_DIR="${P_SKILLS_DIR}/sessions"
LEARNING_DIR="${P_SKILLS_DIR}/learning"

# Colors (only when stdout is a terminal)
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'
else
  GREEN='' YELLOW='' RED='' NC=''
fi

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Uninstall ──────────────────────────────────────────────────────────────────

uninstall() {
  info "Uninstalling P-Skills Claude Code hooks..."

  if [ ! -f "$HOOKS_FILE" ]; then
    info "No hooks.json found, nothing to do."
    return 0
  fi

  # Check if hooks.json contains our entries
  if ! grep -q "p-skills" "$HOOKS_FILE" 2>/dev/null; then
    info "No P-Skills hooks found in hooks.json."
    return 0
  fi

  # Remove p-skills hook entries using node
  if command -v node >/dev/null 2>&1; then
    node -e "
      const fs = require('fs');
      const file = '${HOOKS_FILE}';
      let hooks;
      try { hooks = JSON.parse(fs.readFileSync(file, 'utf8')); } catch { process.exit(0); }
      if (!hooks || typeof hooks !== 'object') process.exit(0);

      const pSkillsDir = '${SCRIPT_DIR}/hooks/scripts';
      let removed = 0;

      for (const event of Object.keys(hooks)) {
        if (!Array.isArray(hooks[event])) continue;
        const before = hooks[event].length;
        hooks[event] = hooks[event].filter(h => {
          if (typeof h === 'string') return !h.includes('p-skills');
          if (h && h.script && h.script.includes(pSkillsDir)) return false;
          if (h && h.command && h.command.includes('p-skills')) return false;
          return true;
        });
        removed += before - hooks[event].length;
        if (hooks[event].length === 0) delete hooks[event];
      }

      if (removed > 0) {
        fs.writeFileSync(file, JSON.stringify(hooks, null, 2) + '\n');
        console.log('Removed ' + removed + ' P-Skills hook(s).');
      } else {
        console.log('No P-Skills hooks to remove.');
      }
    "
  else
    warn "Node.js not found. Cannot automatically remove hooks from hooks.json."
    warn "Please manually remove P-Skills entries from: $HOOKS_FILE"
  fi

  info "Uninstall complete."
  info "Directories ${GATEGUARD_DIR}, ${SESSIONS_DIR}, ${LEARNING_DIR} were not removed (may contain user data)."
}

# ── Argument parsing ───────────────────────────────────────────────────────────

if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "-u" ]; then
  uninstall
  exit 0
fi

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Usage: $0 [--uninstall|--help]"
  echo ""
  echo "Installs P-Skills Claude Code hooks and creates required directories."
  echo ""
  echo "Options:"
  echo "  --uninstall, -u   Remove P-Skills hooks from hooks.json"
  echo "  --help, -h        Show this help"
  exit 0
fi

# ── Pre-flight checks ─────────────────────────────────────────────────────────

if ! command -v node >/dev/null 2>&1; then
  error "Node.js is required but not found in PATH."
  error "Install Node.js: https://nodejs.org/"
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 14 ] 2>/dev/null; then
  error "Node.js >= 14 required, found: $(node -v)"
  exit 1
fi

info "Node.js $(node -v) detected."

# ── Create directories ────────────────────────────────────────────────────────

for dir in "$GATEGUARD_DIR" "$SESSIONS_DIR" "$LEARNING_DIR"; do
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    info "Created: $dir"
  fi
done

# ── Verify hook scripts exist ─────────────────────────────────────────────────

HOOKS_SCRIPTS_DIR="${SCRIPT_DIR}/hooks/scripts"
REQUIRED_SCRIPTS=("context-monitor.js" "quality-gate.js" "meta-skill-update.js")

for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -f "${HOOKS_SCRIPTS_DIR}/${script}" ]; then
    error "Missing hook script: ${HOOKS_SCRIPTS_DIR}/${script}"
    exit 1
  fi
done

info "All hook scripts verified."

# ── Merge hooks into hooks.json ───────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR"

if ! command -v node >/dev/null 2>&1; then
  error "Node.js not found, cannot merge hooks."
  exit 1
fi

node -e "
  const fs = require('fs');
  const path = require('path');

  const hooksFile = '${HOOKS_FILE}';
  const scriptsDir = '${HOOKS_SCRIPTS_DIR}';

  // Read existing hooks or start fresh
  let hooks = {};
  if (fs.existsSync(hooksFile)) {
    try {
      hooks = JSON.parse(fs.readFileSync(hooksFile, 'utf8'));
      if (typeof hooks !== 'object' || hooks === null) hooks = {};
    } catch {
      hooks = {};
    }
  }

  // Define our hooks
  const ourHooks = [
    { event: 'PostToolUse', script: path.join(scriptsDir, 'context-monitor.js') },
    { event: 'PostToolUse', script: path.join(scriptsDir, 'quality-gate.js') },
    { event: 'PostToolUse', script: path.join(scriptsDir, 'meta-skill-update.js') },
  ];

  let added = 0;

  for (const hook of ourHooks) {
    if (!hooks[hook.event]) {
      hooks[hook.event] = [];
    }

    // Check if this hook is already registered (by script path)
    const alreadyExists = hooks[hook.event].some(h => {
      if (typeof h === 'string') return h === hook.script;
      return h && h.script === hook.script;
    });

    if (!alreadyExists) {
      hooks[hook.event].push({ type: 'command', command: 'node ' + hook.script });
      added++;
    }
  }

  fs.writeFileSync(hooksFile, JSON.stringify(hooks, null, 2) + '\n');
  console.log('Added ' + added + ' hook(s). Total PostToolUse: ' + (hooks.PostToolUse || []).length);
"

info "Hooks merged into: $HOOKS_FILE"

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
info "Installation complete!"
echo ""
echo "  Hooks:     3 PostToolUse hooks registered"
echo "  Directories:"
echo "    - ${GATEGUARD_DIR}"
echo "    - ${SESSIONS_DIR}"
echo "    - ${LEARNING_DIR}"
echo ""
echo "  To uninstall: $0 --uninstall"
echo ""
