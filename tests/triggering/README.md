# Skill Triggering Tests

> 验证 p-skills 的 description 是否能让 agent 在收到自然语言 prompt 时自动触发预期的 skill。

借鉴 [obra/superpowers](https://github.com/obra/superpowers/tree/main/tests/skill-triggering) 的测试框架。

## 为什么需要这个测试

Skill 的 `description` 是 agent 决定加载哪个 skill 的**唯一信号**。如果 description 写坏了：

- Agent 走捷径，只看 description 不看正文（如果 description 总结了流程）
- Agent 触发错误的 skill（如果 description 太抽象）
- Agent 不触发任何 skill（如果 description 缺关键词）

这个测试用**不含 skill 名字**的 naive prompt 测试 agent 的自然触发行为。

## 快速使用

```bash
# 测试单个 skill
./run-test.sh fix-bug ./prompts/fix-bug.txt

# 测试所有 skill
./run-all.sh

# 预览（不实际运行 agent）
./run-all.sh dry-run

# 指定 harness
./run-all.sh claude
./run-all.sh qodercli
```

## 支持的 Harness

| Harness | CLI | 说明 |
|---------|-----|------|
| `claude` | `claude -p` | Claude Code CLI（推荐） |
| `qodercli` | `qodercli -p` | Qoder CLI |
| `dry-run` | — | 不运行 agent，只验证框架 |
| `auto` | — | 自动检测（默认） |

## 文件结构

```
tests/triggering/
├── README.md               # 本文件
├── run-test.sh             # 单条测试
├── run-all.sh              # 批量测试
├── prompts/                # Naive prompts（不含 skill 名字）
│   ├── fix-bug.txt
│   ├── tdd.txt
│   ├── brainstorming.txt
│   ├── doc-sync.txt
│   ├── verify.txt
│   ├── develop-feature.txt
│   ├── deploy.txt
│   ├── writing-plans.txt
│   ├── e2e-write.txt
│   ├── security-research.txt
│   ├── security-poc.txt
│   ├── retrospective.txt
│   └── dispatching-parallel-agents.txt
└── results/                # 自动生成（已 gitignore）
    ├── <timestamp>_<skill>/
    │   ├── prompt.txt      # 输入的 prompt
    │   ├── response.txt    # Agent 的响应
    │   ├── stderr.log      # 错误输出
    │   └── result.txt      # TRIGGERED / NOT_TRIGGERED / UNKNOWN
    └── summary_<timestamp>/
        ├── report.md       # 总结报告
        └── <skill>.log     # 每个 skill 的详细日志
```

## 评判标准

一个测试通过（`TRIGGERED`）意味着 agent 的响应中出现：

- Skill 原名（如 `fix-bug`）
- 变体（`fix_bug`）
- 路径引用（`skills/fix-bug`）
- 显式声明（`skill: fix-bug`）

## 失败的常见原因

如果某个 skill 测试失败，检查 `skills/<name>/SKILL.md` 的 description：

| 症状 | 原因 | 修复 |
|------|------|------|
| Agent 触发错误的 skill | Description 太抽象 | 加具体关键词和用户说法 |
| Agent 不触发任何 skill | Description 缺关键词 | 加 "Use when user says..." |
| Agent 走捷径不看正文 | Description 总结了流程 | 只保留触发条件 |
| Agent 触发但不完整 | Description 缺症状词 | 加症状（flaky、hanging、500 等） |

## 添加新测试

为每个新 skill 创建 `prompts/<skill-name>.txt`：

```text
[一条自然、不含 skill 名字的用户消息，描述典型使用场景]
```

**好的 prompt：**
- 不含 skill 名（"fix-bug"、"TDD" 等）
- 描述具体场景（"500 error"、"双因素认证"）
- 用户语气（"能帮我看看吗"、"你觉得该怎么设计"）

**坏的 prompt：**
- 包含 skill 名（"用 fix-bug skill"）
- 太抽象（"修一下"）
- 不像人话（"请执行 Bug 修复流程"）

## CI 集成

建议在 `.github/workflows/trigger-tests.yml` 中集成：

```yaml
name: Skill Triggering Tests

on:
  push:
    branches: [main]
    paths: ['skills/**']
  pull_request:
    branches: [main]
    paths: ['skills/**']

jobs:
  trigger-tests:
    runs-on: ubuntu-latest
    # 需要配置 ANTHROPIC_API_KEY 或其他 agent 凭证
    if: github.event_name == 'push' || github.event.pull_request.head.repo.full_name == github.repository
    steps:
      - uses: actions/checkout@v4
      - name: Install Claude CLI
        run: npm install -g @anthropic-ai/claude-code
      - name: Run trigger tests
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: ./tests/triggering/run-all.sh claude
      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: trigger-test-report
          path: tests/triggering/results/summary_*/report.md
```

## 维护

- 每次修改 skill 的 `description` 字段，跑一次 `./run-all.sh`
- 每次新增 skill，添加对应 prompt
- 测试失败时优先修 description，不要改 prompt（prompt 代表真实用户）
