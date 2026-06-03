#!/usr/bin/env bash
set -euo pipefail

# 同步所有 plugin manifest 的版本号。
#
# Usage:
#   ./scripts/sync-plugin-manifests.sh <new-version>
#   ./scripts/sync-plugin-manifests.sh 1.0.0
#
# 该脚本更新以下文件中的 version 字段：
#   - .claude-plugin/plugin.json
#   - .codex-plugin/plugin.json
#   - .cursor-plugin/plugin.json
#   - gemini-extension.json

REPO="$(cd "$(dirname "$0")/.." && pwd)"
NEW_VERSION="${1:-}"

if [ -z "$NEW_VERSION" ]; then
    echo "Usage: $0 <new-version>"
    echo ""
    echo "Current versions:"
    for f in .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json gemini-extension.json; do
        if [ -f "$REPO/$f" ]; then
            version=$(grep -o '"version": *"[^"]*"' "$REPO/$f" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
            printf "  %-35s %s\n" "$f" "$version"
        fi
    done
    exit 1
fi

# 校验语义化版本
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    echo "error: invalid semantic version: $NEW_VERSION" >&2
    exit 1
fi

echo "Syncing plugin manifests to version: $NEW_VERSION"
echo ""

update_json() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "[skip] $file (not found)"
        return
    fi

    if command -v jq &>/dev/null; then
        local tmp="${file}.tmp"
        jq ".version = \"$NEW_VERSION\"" "$file" > "$tmp" && mv "$tmp" "$file"
    else
        # 没有 jq，用 sed 替换
        sed -i.bak -E "s/\"version\": *\"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$file"
        rm -f "${file}.bak"
    fi

    echo "[updated] $file"
}

cd "$REPO"
update_json ".claude-plugin/plugin.json"
update_json ".codex-plugin/plugin.json"
update_json ".cursor-plugin/plugin.json"
update_json "gemini-extension.json"

echo ""
echo "Done. Remember to:"
echo "  1. Update CHANGELOG.md"
echo "  2. git add -A && git commit -m \"chore: bump version to $NEW_VERSION\""
echo "  3. git tag v$NEW_VERSION"
echo "  4. git push origin main --tags"
