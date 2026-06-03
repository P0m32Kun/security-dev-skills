#!/usr/bin/env bash
set -euo pipefail

# Skill 触发测试 — 批量运行
#
# 对所有 prompts/*.txt 执行触发测试，生成总结报告。
#
# Usage:
#   ./run-all.sh [harness]
#
# Examples:
#   ./run-all.sh
#   ./run-all.sh claude
#   ./run-all.sh dry-run     # 不实际运行 agent，只验证框架

HARNESS="${1:-auto}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%s)
SUMMARY_DIR="$SCRIPT_DIR/results/summary_${TIMESTAMP}"
mkdir -p "$SUMMARY_DIR"

echo "=========================================="
echo "  Skill Triggering Tests — Batch Run"
echo "=========================================="
echo ""
echo "Harness: $HARNESS"
echo "Prompt directory: $SCRIPT_DIR/prompts"
echo "Summary dir: $SUMMARY_DIR"
echo ""

PROMPTS=("$SCRIPT_DIR"/prompts/*.txt)
TOTAL=${#PROMPTS[@]}
PASSED=0
FAILED=0
UNKNOWN=0

{
    echo "# Skill Triggering Test Report"
    echo ""
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Harness: $HARNESS"
    echo "Total prompts: $TOTAL"
    echo ""
    echo "## Results"
    echo ""
    echo "| Skill | Prompt | Result |"
    echo "|-------|--------|:------:|"
} > "$SUMMARY_DIR/report.md"

for prompt_file in "${PROMPTS[@]}"; do
    skill_name=$(basename "$prompt_file" .txt)
    prompt_name=$(basename "$prompt_file")

    echo "------------------------------------------"
    echo "Testing: $skill_name"
    echo "Prompt:  $prompt_name"
    echo "------------------------------------------"

    if bash "$SCRIPT_DIR/run-test.sh" "$skill_name" "$prompt_file" "$HARNESS" > "$SUMMARY_DIR/${skill_name}.log" 2>&1; then
        result="✅ PASS"
        PASSED=$((PASSED + 1))
    else
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            result="❌ FAIL"
            FAILED=$((FAILED + 1))
        else
            result="⚠️  UNKNOWN"
            UNKNOWN=$((UNKNOWN + 1))
        fi
    fi

    echo "  → $result"
    echo "| $skill_name | \`$prompt_name\` | $result |" >> "$SUMMARY_DIR/report.md"
done

# 总结
{
    echo ""
    echo "## Summary"
    echo ""
    echo "- **Total**: $TOTAL"
    echo "- **Passed**: $PASSED"
    echo "- **Failed**: $FAILED"
    echo "- **Unknown**: $UNKNOWN"
    echo ""
    echo "## Failed Skills"
    echo ""
    echo "Review failed skills' \`description\` fields in \`skills/*/SKILL.md\`."
    echo ""
    echo "Common fixes:"
    echo "- Add more specific trigger keywords"
    echo "- Remove workflow summary from description (only keep triggering conditions)"
    echo "- Add user-facing phrases (e.g. \"修复bug\", \"fix bug\")"
} >> "$SUMMARY_DIR/report.md"

echo ""
echo "=========================================="
echo "  Batch Summary"
echo "=========================================="
echo "Total:   $TOTAL"
echo "Passed:  $PASSED"
echo "Failed:  $FAILED"
echo "Unknown: $UNKNOWN"
echo ""
echo "Full report: $SUMMARY_DIR/report.md"
echo "Per-skill logs: $SUMMARY_DIR/*.log"
echo ""

if [ $FAILED -eq 0 ] && [ $UNKNOWN -eq 0 ]; then
    echo "✅ All skills triggered successfully."
    exit 0
else
    echo "❌ Some skills failed to trigger. Review the report."
    exit 1
fi
