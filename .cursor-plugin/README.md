# P-Skills — Multi-Harness Plugin Manifests

> 本仓库根级的 `.xxx-plugin/` 目录和 `gemini-extension.json` 是各 coding agent 的 plugin manifest。
> 借鉴 [obra/superpowers](https://github.com/obra/superpowers) 的多 harness 分发模式。

## 支持的 Harness

| Harness | Manifest | 安装方式 |
|---------|----------|---------|
| **Claude Code** | `.claude-plugin/plugin.json` | `/plugin install p-skills` (marketplace) |
| **Codex CLI / App** | `.codex-plugin/plugin.json` | `/plugins` → search `p-skills` |
| **Cursor** | `.cursor-plugin/plugin.json` | `/add-plugin p-skills` |
| **OpenCode** | `.opencode/INSTALL.md` | 让 agent 读取 `.opencode/INSTALL.md` |
| **Gemini CLI** | `gemini-extension.json` | `gemini extensions install <repo>` |
| **GitHub Copilot CLI** | (复用 `.claude-plugin`) | `copilot plugin install p-skills` |
| **其他** | `install.sh` | 手动安装，参考 `INSTALL.md` |

## Manifest 字段说明

### 通用字段

```json
{
  "name": "p-skills",
  "description": "一句话描述（marketplace 展示）",
  "version": "0.9.1",
  "author": "作者",
  "repository": "https://github.com/P0m32Kun/p-skills",
  "license": "MIT",
  "keywords": ["skills", "tdd", "workflow"]
}
```

### 扩展字段

| 字段 | 用途 | Harness |
|------|------|---------|
| `skills: []` | 列出所有 skill 名 | Claude Code |
| `skills_dir` | Skill 目录路径 | Codex / Cursor |
| `bootstrap` | Session start 自动加载的入口 skill | 所有 |
| `rules: []` | Cursor rules 规则 | Cursor |
| `type` | 扩展类型 | Gemini |

## 安装机制对比

| Harness | 入口加载 | Skill 发现 |
|---------|---------|-----------|
| Claude Code | plugin 自动加载 bootstrap | 通过 `Skill` 工具 |
| Codex | plugin 自动加载 bootstrap | 通过 `skill` 工具 |
| Cursor | plugin 自动加载 bootstrap | 通过 rules 系统 |
| OpenCode | 用户让 agent 读 INSTALL.md | 通过 AGENTS.md 引用 |
| Gemini | extension 自动加载 | 通过 `activate_skill` 工具 |
| 其他 | `install.sh` 创建 symlink | 由 agent 自己发现 |

## 版本同步

所有 manifest 的 `version` 必须一致。发布新版本时：

```bash
./scripts/sync-plugin-manifests.sh 1.0.0
```

脚本会更新所有 plugin.json 和 gemini-extension.json 的 version 字段。

## 注册到 Marketplace

### Claude Code Marketplace

1. Fork `obra/superpowers-marketplace`（或自己建一个）
2. 在 `plugins.json` 中添加 p-skills 条目
3. 用户执行 `/plugin marketplace add P0m32Kun/p-skills-marketplace`
4. 用户执行 `/plugin install p-skills@p-skills-marketplace`

### Codex Marketplace

1. 提交到 OpenAI plugins registry（参考 Codex 官方文档）
2. 用户在 CLI 执行 `/plugins` → search `p-skills` → Install

### Cursor Marketplace

1. 提交到 Cursor plugins marketplace
2. 用户在 Agent chat 执行 `/add-plugin p-skills`

### Gemini Extensions

1. 在 GitHub repo 根级有 `gemini-extension.json`
2. 用户执行 `gemini extensions install https://github.com/P0m32Kun/p-skills`

## 测试集成

每个新 harness 集成必须通过触发测试：

```bash
# 用 naive prompt 测试 bootstrap 是否让 agent 自动触发 brainstorming
./tests/triggering/run-test.sh brainstorming ./tests/triggering/prompts/brainstorming.txt <harness>
```

**Acceptance test（借鉴 superpowers）**：发送 "Let's make a react todo list"，预期 agent 自动触发 `brainstorming` skill 而不是直接写代码。

## 贡献新 Harness

如果 p-skills 需要支持新 harness：

1. 创建 `.<harness>-plugin/` 目录
2. 添加 `plugin.json`（参考其他 manifest 的字段）
3. 在新 harness 中跑触发测试验证
4. 更新本 README 的 harness 表
5. 更新 `install.sh` 的 `get_agent_skill_dir` 和 `get_agent_config_file`
