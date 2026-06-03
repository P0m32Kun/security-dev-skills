#!/usr/bin/env bash
set -euo pipefail

# Skill 触发测试 — 单条 prompt
#
# 验证：给定一条 naive prompt，agent 是否自动触发预期的 skill。
# 借鉴 obra/superpowers 的 skill-triggering 测试框架。
#
# Usage:
#   ./run-test.sh <skill-name> <prompt-file> [harness]
#
# Examples:
#   ./run-test.sh fix-bug ./prompts/fix-bug.txt
#   ./run-test.sh fix-bug ./prompts/fix-bug.txt claude
#   ./run-test.sh fix-bug ./prompts/fix-bug.txt qodercli

SKILL_NAME="${1:-}"
PROMPT_FILE="${2:-}"
HARNESS="${3:-auto}"

if [ -z "$SKILL_NAME" ] || [ -z "$PROMPT_FILE" ]; then
    echo "Usage: $0 <skill-name> <prompt-file> [harness]"
    echo ""
    echo "Harnesses:"
    echo "  auto        自动检测 (优先 claude, 其次 qodercli)"
    echo "  claude      Claude Code CLI (claude -p)"
    echo "  qodercli    Qoder CLI (qodercli -p)"
    echo "  dry-run     只打印要执行的命令，不实际运行"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "error: prompt file not found: $PROMPT_FILE" >&2
    exit 1
fi

if [ ! -d "$REPO_ROOT/skills/$SKILL_NAME" ]; then
    echo "error: skill not found: $SKILL_NAME" >&2
    echo "available skills:"
    ls "$REPO_ROOT/skills" | sed 's/^/  /'
    exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")
TIMESTAMP=$(date +%s)
RESULT_DIR="$SCRIPT_DIR/results/${TIMESTAMP}_${SKILL_NAME}"
mkdir -p "$RESULT_DIR"

echo "=========================================="
echo "  Skill Triggering Test"
echo "=========================================="
echo ""
echo "Skill:        $SKILL_NAME"
echo "Prompt file:  $PROMPT_FILE"
echo "Harness:      $HARNESS"
echo "Result dir:   $RESULT_DIR"
echo ""
echo "Prompt:"
echo "----------------------------------------"
echo "$PROMPT"
echo "----------------------------------------"
echo ""

# 选择 harness
detect_harness() {
    if command -v claude &>/dev/null; then
        echo "claude"
    elif command -v qodercli &>/dev/null; then
        echo "qodercli"
    else
        echo "none"
    fi
}

if [ "$HARNESS" = "auto" ]; then
    HARNESS=$(detect_harness)
    echo "[auto] detected harness: $HARNESS"
    echo ""
fi

# 保存 prompt
cp "$PROMPT_FILE" "$RESULT_DIR/prompt.txt"

# 运行 agent，捕获输出
run_claude() {
    # Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code
    # -p 是非交互单次 prompt 模式
    claude -p "$PROMPT" --output-format json > "$RESULT_DIR/response.json" 2> "$RESULT_DIR/stderr.log" || true
    # 提取文本响应
    if command -v jq &>/dev/null && [ -s "$RESULT_DIR/response.json" ]; then
        jq -r '.result // .content // empty' "$RESULT_DIR/response.json" > "$RESULT_DIR/response.txt" 2>/dev/null || true
    fi
    [ -s "$RESULT_DIR/response.txt" ] || cp "$RESULT_DIR/response.json" "$RESULT_DIR/response.txt" 2>/dev/null || true
}

run_qodercli() {
    qodercli -p "$PROMPT" > "$RESULT_DIR/response.txt" 2> "$RESULT_DIR/stderr.log" || true
}

run_dry_run() {
    echo "[dry-run] would execute:"
    echo ""
    case "$HARNESS" in
        claude)    echo "  claude -p \"<prompt>\"" ;;
        qodercli)  echo "  qodercli -p \"<prompt>\"" ;;
        *)         echo "  no harness available" ;;
    esac
    echo ""
    echo "[dry-run] would check response for skill name: $SKILL_NAME"
    cat > "$RESULT_DIR/response.txt" << EOF
[dry-run] 模拟响应。

我将使用 $SKILL_NAME skill 来处理这个任务。

[dry-run] 这个响应被标记为通过，用于验证测试框架本身。
EOF
}

case "$HARNESS" in
    claude)      run_claude ;;
    qodercli)    run_qodercli ;;
    dry-run)     run_dry_run ;;
    none)
        echo "error: no harness available. Install claude or qodercli." >&2
        exit 1
        ;;
    *)
        echo "error: unknown harness: $HARNESS" >&2
        exit 1
        ;;
esac

# 评估是否触发预期 skill
# 检查响应中是否出现 skill name（不区分大小写，支持连字符/下划线）
evaluate() {
    local response_file="$1"
    local skill="$2"

    if [ ! -s "$response_file" ]; then
        echo "UNKNOWN"
        return
    fi

    # 多种匹配模式：原 skill 名、连字符变体、下划线变体
    local patterns=(
        "$skill"
        "${skill//-/_}"
        "${skill//_/-}"
    )

    for pattern in "${patterns[@]}"; do
        if grep -qi "$pattern" "$response_file"; then
            echo "TRIGGERED"
            return
        fi
    done

    # 也检查 "skills/$skill" 路径引用
    if grep -qi "skills/$skill\|skill: $skill" "$response_file"; then
        echo "TRIGGERED"
        return
    fi

    echo "NOT_TRIGGERED"
}

RESULT=$(evaluate "$RESULT_DIR/response.txt" "$SKILL_NAME")
echo "$RESULT" > "$RESULT_DIR/result.txt"

echo ""
echo "=========================================="
echo "  Result: $RESULT"
echo "=========================================="
echo ""

if [ "$RESULT" = "TRIGGERED" ]; then
    echo "✅ PASS: skill '$SKILL_NAME' was triggered"
    exit 0
elif [ "$RESULT" = "NOT_TRIGGERED" ]; then
    echo "❌ FAIL: skill '$SKILL_NAME' was NOT triggered"
    echo ""
    echo "Check $RESULT_DIR/response.txt for actual agent behavior."
    echo ""
    echo "Possible causes:"
    echo "  - Skill description is too vague or missing keywords"
    echo "  - Description summarizes workflow (agent shortcuts to that)"
    echo "  - Bootstrap is not loaded"
    exit 1
else
    echo "⚠️  UNKNOWN: could not evaluate (empty response?)"
    echo ""
    echo "Check $RESULT_DIR/stderr.log for errors."
    exit 2
fi
