#!/bin/bash
# P-Skills Claude Code Plugin Installer
# This script installs p-skills as a Claude Code plugin

set -e

echo "🚀 Installing p-skills as Claude Code plugin..."

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Code is not installed. Please install it first."
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# Check if plugin.json exists
if [ ! -f "$SCRIPT_DIR/plugin.json" ]; then
    echo "❌ plugin.json not found in $SCRIPT_DIR"
    exit 1
fi

# Create plugins directory if it doesn't exist
PLUGINS_DIR="$HOME/.claude/plugins"
mkdir -p "$PLUGINS_DIR"

# Check if p-skills is already installed
if [ -f "$PLUGINS_DIR/installed_plugins.json" ]; then
    if grep -q "p-skills" "$PLUGINS_DIR/installed_plugins.json"; then
        echo "⚠️  p-skills is already installed. Updating..."
        # Remove old installation
        rm -rf "$PLUGINS_DIR/cache/p-skills" 2>/dev/null || true
    fi
fi

# Create cache directory
CACHE_DIR="$PLUGINS_DIR/cache/p-skills/p-skills/latest"
mkdir -p "$CACHE_DIR"

# Copy plugin files
echo "📦 Copying plugin files..."
cp -r "$PLUGIN_DIR"/* "$CACHE_DIR/"

# Update installed_plugins.json
INSTALLED_PLUGINS="$PLUGINS_DIR/installed_plugins.json"
if [ ! -f "$INSTALLED_PLUGINS" ]; then
    echo '{"version":2,"plugins":{}}' > "$INSTALLED_PLUGINS"
fi

# Use Python to update JSON (more reliable than jq)
python3 << 'PYTHON_SCRIPT'
import json
import os
from datetime import datetime

plugins_file = os.path.expanduser("~/.claude/plugins/installed_plugins.json")
cache_path = os.path.expanduser("~/.claude/plugins/cache/p-skills/p-skills/latest")

with open(plugins_file, 'r') as f:
    data = json.load(f)

data["plugins"]["p-skills@local"] = [
    {
        "scope": "user",
        "installPath": cache_path,
        "version": "0.9.2",
        "installedAt": datetime.utcnow().isoformat() + "Z",
        "lastUpdated": datetime.utcnow().isoformat() + "Z",
        "gitCommitSha": "local"
    }
]

with open(plugins_file, 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_SCRIPT

echo "✅ p-skills plugin installed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart Claude Code to load the plugin"
echo "   2. Skills will be automatically available via the Skill tool"
echo ""
echo "🔧 To verify installation:"
echo "   cat ~/.claude/plugins/installed_plugins.json | grep p-skills"
