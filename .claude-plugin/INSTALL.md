# P-Skills Claude Code Plugin Installation

## Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/P0m32Kun/p-skills.git
cd p-skills/.claude-plugin

# Run the installer
chmod +x install-plugin.sh
./install-plugin.sh
```

## Manual Install

### Option 1: Using Claude Code Plugin System

1. Add p-skills marketplace:
   ```bash
   # Add the marketplace (if not already added)
   claude plugin marketplace add P0m32Kun/p-skills
   ```

2. Install the plugin:
   ```bash
   claude plugin install p-skills@p-skills
   ```

### Option 2: Symlink Installation

```bash
# Create plugin directory
mkdir -p ~/.claude/plugins/cache/p-skills/p-skills/latest

# Copy plugin files
cp -r /path/to/p-skills/* ~/.claude/plugins/cache/p-skills/p-skills/latest/

# Update installed_plugins.json
# Add the following to ~/.claude/plugins/installed_plugins.json:
{
  "p-skills@local": [
    {
      "scope": "user",
      "installPath": "~/.claude/plugins/cache/p-skills/p-skills/latest",
      "version": "0.9.2",
      "installedAt": "2026-06-05T00:00:00.000Z",
      "lastUpdated": "2026-06-05T00:00:00.000Z",
      "gitCommitSha": "local"
    }
  ]
}
```

## Verification

After installation, restart Claude Code and verify:

```bash
# Check if plugin is installed
cat ~/.claude/plugins/installed_plugins.json | grep p-skills

# Test skill loading (in Claude Code)
# Type: /skill brainstorming
# Should show the brainstorming skill
```

## Troubleshooting

### Skills not loading

1. Check if plugin is in installed_plugins.json:
   ```bash
   cat ~/.claude/plugins/installed_plugins.json
   ```

2. Verify plugin cache exists:
   ```bash
   ls -la ~/.claude/plugins/cache/p-skills/
   ```

3. Restart Claude Code completely

### Plugin conflicts

If you have other skill plugins installed, they may conflict. Check:
```bash
cat ~/.claude/plugins/installed_plugins.json
```

## Updating

To update p-skills plugin:

```bash
cd /path/to/p-skills
git pull
cd .claude-plugin
./install-plugin.sh
```

## Uninstalling

```bash
# Remove from installed_plugins.json
# Edit ~/.claude/plugins/installed_plugins.json and remove p-skills entry

# Remove cache
rm -rf ~/.claude/plugins/cache/p-skills
```
