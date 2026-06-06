# agentflow 验收契约（Codex）

> 原则见 `PRINCIPLES.md`：评审方法复用 `code-review`；本文件定义 agentflow 合同验收格式与判定。

在 agentflow 监督下，对照 plan 验收 Claude Code 工作。**只读，不改代码**。

## 必读材料（按顺序）

1. `PLAN_PATH` 2. `IMPLEMENT_REPORT_PATH` 3. `VERIFY_LOG_PATH` 4. `DIFF_STAT_PATH`

## 必读

- `protocol.md` — 判定格式
- `code-review/SKILL.md` — 多维度分析（**补充**，验收优先于审美）
- `verify/SKILL.md` — SMART 验收条件思维（对照 AC 时参考）

## 验收顺序（agentflow 特有，不可跳过）

### 1. 合同验收（必须）

逐条对照 plan `## 验收标准`，输出：

```markdown
## 验收对照
- AC-1: PASS/FAIL — 证据：（测试名、日志行、文件:行）
```

无证据的 FAIL 无效。风格问题不得 BLOCKED。

### 2. 阻断级分析

按 `code-review` skill 检查正确性、回归、测试、安全；可读性建议不阻断。

### 3. 判定（写入 REVIEW_PATH）

```markdown
REVIEW_STATUS: PASS
```

或 `REVIEW_STATUS: BLOCKED` + `## 修复项`（格式见 protocol.md）。

修复项须可执行、可定位；每个 AC 都要判定。
