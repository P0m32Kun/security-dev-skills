# Changelog

本文件记录 P Skills 的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### Added
- `install.sh` — 新增 Reasonix 支持（自动发现 `~/.reasonix/skills/p-skills/` 下的扁平 skill 链接）
- `AGENTS.md` — 任何 coding agent 的通用入口（借鉴 CLAUDE.md / AGENTS.md 约定，但 agent-agnostic）
- `docs/tools-reference.md` — 跨 agent 工具等价表（适配层），skill 内容只用通用术语
- `skills/writing-skills/` — 元技能：创建/编辑/改进 skill（借鉴 obra/superpowers 的 TDD-for-docs 方法论）
- `skills/subagent-driven-development/` — 按 plan 顺序派 fresh subagent 实现 + 双阶段 review（spec → quality）
- `skills/dispatching-parallel-agents/` — 并行派多个独立 subagent 做独立任务 + 聚合 + 冲突解决
- `tests/triggering/` — Skill 触发测试框架（`run-test.sh` / `run-all.sh` / 13 个 naive prompts），借鉴 superpowers 的 skill-triggering 测试
- `.claude-plugin/plugin.json` — Claude Code plugin manifest
- `.codex-plugin/plugin.json` — Codex CLI/App plugin manifest
- `.cursor-plugin/plugin.json` — Cursor plugin manifest
- `.opencode/INSTALL.md` — OpenCode 安装入口
- `gemini-extension.json` — Gemini CLI extension manifest
- `scripts/sync-plugin-manifests.sh` — 同步所有 manifest 版本号的脚本
- `.claude-plugin/README.md` — 多 harness plugin manifest 说明文档
- 所有 skill 增加 `## Red Flags — STOP` 和 `## Common Rationalizations` 章节（借鉴 superpowers 的反合理化模式）
- `skills/claude-code/` — Claude Code 专项优化模块
  - 10 个 hooks: gateguard（事实强制）、config-protection（配置保护）、quality-gate（质量门禁）、context-monitor（上下文监控）、learning-observer/evolve（使用模式学习）、meta-skill-update（改进记忆）、session-recovery/summary/learning（会话持久化）
  - 3 个 rules: coding-style、git-workflow、agent-behavior
  - 4 个 skills: de-sloppify（代码清理）、context-audit（上下文审计）、model-routing（模型选择）、continuous-learning（持续学习 + 改进记忆）
  - install.sh 支持 --uninstall，智能合并 hooks.json
  - 设计来源: [affaan-m/ecc](https://github.com/affaan-m/ecc), [microsoft/SkillOpt](https://github.com/microsoft/SkillOpt)

### Changed
- **Agent-Agnostic 重构**：skill 内容只用通用术语（"读文件"、"执行命令"、"派 subagent"），具体工具名由 agent 运行时按 `docs/tools-reference.md` 映射
  - `skills/subagent-driven-development/SKILL.md` — 移除具体 agent 列举
  - `skills/writing-skills/SKILL.md` — 移除 Anthropic 特定链接
  - `skills/bootstrap/SKILL.md` — 路径表标注为"示例"，显式声明"p-skills 不绑定任何 agent"
  - `SKILL.md` — 新增"Agent-Agnostic"核心理念；可移植性约束加入工具映射说明
  - `README.md` — 开篇明确"agent-agnostic"定位；新增"支持的 Agent"表覆盖所有主流 coding agent
- **Frontmatter 规范精简**：只允许 `name` + `description` 两个字段（借鉴 superpowers 实测结论），去掉 version/tags/triggers/inputs/outputs/auto-update
- **Description 写法规范**：必须以 "Use when…" 开头，只描述触发条件，**不总结流程**（实测表明 agent 会走捷径跳过正文）
- `SKILL.md` 重写：精简 frontmatter 规范说明、skill 索引统一指向 `skills/<name>/`、移除依赖/安装细节（已拆到 INSTALL.md / DEPENDENCIES.md）
- `skills/bootstrap/SKILL.md` — 修正路径契约，列出多 agent 兼容的安装路径
- `skills/develop-feature/SKILL.md` — Implement 阶段显式引入 subagent-driven-development 编排方式
- `install.sh` — 重写为**扁平化链接**：每个 skill 单独建链到 agent 的 skill 根目录（`<agent_root>/fix-bug → ~/.p-skills/skills/fix-bug`），兼容 agent 一层 `<name>/SKILL.md` 自动发现；同时清理旧版聚合链接（`<agent_root>/p-skills → ~/.p-skills`）；`uninstall` 动态发现并删除所有本仓库创建的链接
- `scripts/validate-skills.sh` — 必填字段从 `name/description/version` 改为 `name/description`
- `.gitignore` — 增加 `tests/triggering/results/`（自动生成，不入库）

### Removed
- 删除 `workflow/`、`testing/`、`security/`、`release/` 顶层目录（内容已归档到 `docs/archive/`，`skills/` 是规范源）
- 删除 `docs/sync.md`、`docs/validate.md`（已归档到 `docs/archive/`）
- 删除 `RESTRUCTURE.md`（已归档到 `docs/archive/`）

### Fixed
- 消除 agent 读到过期/漂移内容的风险（旧源文件与 `skills/` 已 diff 全部漂移）
- 修正 `install.sh` 和 `bootstrap` 中写死的 `~/.pi/agent/skills/` 路径（改为多 agent 兼容）
- 修正 SKILL.md 索引中的旧路径引用

## [0.9.1] - 2026-06-02

### Added
- `workflow/brainstorming.md` — 需求讨论与设计探索 skill（借鉴 superpowers）
- `workflow/writing-plans.md` — 实施计划编写 skill（借鉴 superpowers）
- `testing/tdd.md` — 测试驱动开发 skill（借鉴 mattpocock/skills）
- `integrations/README.md` — 集成 skills 总览（使用场景与流程联动）
- `release/deploy.md` — 多场景发布支持（npm/Python/二进制/通用 Git tag）
- `.github/workflows/lint.yml` — CI 工作流（frontmatter 校验、Markdown lint、ShellCheck、YAML lint）
- `scripts/validate-skills.sh` — Skill 文件 frontmatter 校验脚本
- `.markdownlint.json` — Markdown lint 配置
- `.yamllint.yml` — YAML lint 配置

### Changed
- `workflow/develop.feature.md` — 移除对外部 skill 的引用，改用自建 skill
- `SKILL.md` — 更新 skill 索引，添加 brainstorming、writing-plans、tdd
- 依赖状态统一：AgentMemory 改为可选，Docker 改为仅部署场景需要
- CodeGraph GitHub 地址统一修正
- `dependencies.yaml` — 补充 AgentMemory 条目
- `.gitignore` — 添加 `.deps-status` 缓存文件
- `DESIGN.md` — 状态更新为“已完成”
- `docs/best-practices.md` — 移除与 analysis.md 重复的“学习来源”段
- `docs/analysis.md` — 更新完成状态
- `SKILL.md` — 增加 allowed-tools 字段说明、auto-update 错误处理
- `release/deploy.md` — 增加 npm/Python/二进制发布场景

### Fixed
- 版本号同步：SKILL.md 改为 0.9.0
- 消除所有对 ricocf/codegraph 的错误引用

## [0.9.0] - 2026-06-02

### Added
- `check-deps.sh` — 依赖检查脚本（带缓存）
  - 检查结果缓存到 `.deps-status` 文件
  - 缓存有效期 24 小时
  - 支持 `--force` 强制重新检查
  - 支持 `--status` 查看缓存状态

### Changed
- 优化依赖检查机制：缓存优先，避免每次启动都检查
  - 首次安装时检查并写入缓存
  - 更新时检测到依赖变更才重新检查
  - Agent 启动时读取缓存，不重新检查
- 更新 `auto-update.sh`，更新后自动检查依赖
- 更新 `DEPENDENCIES.md` 说明缓存机制

## [0.8.0] - 2026-06-02

### Added
- `DEPENDENCIES.md` — 依赖检查清单（供 agent 使用）
  - Agent 启动时检查依赖
  - 缺失依赖时提示用户安装

### Changed
- 简化 install.sh，移除依赖安装逻辑
  - 安装脚本只负责克隆仓库和创建软链接
  - 依赖检查交给 agent 自行完成
- 更新 SKILL.md 增加依赖检查说明

## [0.7.0] - 2026-06-02

### Changed
- 安装脚本重构：支持自动检测 agent 并创建软链接
  - 自动检测已安装的 Coding Agent
  - 创建软链接到各 agent 的 skill 目录
  - 更新 agent 配置文件
  - 支持 `--agent` 参数指定 agent
  - 支持 `--list-agents` 列出支持的 agent
- 更新 README.md 反映新的安装方式

## [0.6.0] - 2026-06-02

### Added
- `INSTALL.md` — 安装说明（供 agent 自动安装使用）
- 支持多种 coding agent：
  - Claude Code（CLAUDE.md）
  - Codex（AGENTS.md）
  - Cursor（.cursorrules）
  - OpenCode（AGENTS.md）
  - Windsurf（.windsurfrules）
  - Aider（.aider.conf.yml）
- 更新 `README.md` 增加两种安装方式：
  - 人类手动安装
  - Agent 自动安装

### Changed
- 优化 README.md 结构，更清晰的安装指引
- 安装目录改为 ~/.p-skills（更通用）

## [0.5.0] - 2026-06-02

### Added
- 外部依赖管理系统
  - `dependencies.yaml` — 依赖清单
  - `install.sh` — 一键安装脚本
  - `auto-update.sh` — 自动更新脚本
  - `docs/dependencies.md` — 依赖管理文档
- 支持的外部依赖：
  - MCP 服务器：Semble, CodeGraph, Context7, Playwright, Agent Browser
  - 工具：uv, Docker, Git
- 自动更新机制：
  - 手动更新：`./auto-update.sh`
  - 定时更新：`./auto-update.sh --setup-cron`
- `docs/best-practices.md` — 优秀 skill 设计模式文档
- 更新 SKILL.md 增加外部依赖章节和设计来源

### Changed
- 移除外部 Skill 依赖，保持仓库独立性
- 将 Semgrep 替换为 Semble（代码搜索工具）
- 明确设计理念：吸收优点，自己实现，不依赖外部 skill

## [0.4.0] - 2026-06-02

### Changed
- 优化 skill 体系，参考优秀 skill 仓库
  - 增加 HARD-GATE 阻断机制
  - 增加 Anti-Patterns 反模式
  - 增加决策树（测试策略）
  - 增加 SMART 验收条件
  - 增加 CONTEXT.md（领域知识）
- 优化 workflow/develop.feature.md
- 优化 testing/strategy.md
- 优化 testing/verify.md
- 优化 docs/sync.md

## [0.3.0] - 2026-06-02

### Added
- 回顾环节 skill：workflow/retrospective.md
  - 收集问题（工具失败、报错、踩坑、skill 评估）
  - 分析根因
  - 量化影响（时间、token）
  - 输出优化建议
- 更新 workflow/develop.feature.md 增加 Retrospective 阶段
- 更新 SKILL.md 增加 retrospective skill 索引
- 参考优秀 skill 仓库：superpowers, gstack, andrej-karpathy-skills, mattpocock/skills

## [0.2.0] - 2026-06-02

### Added
- 完整 skill 体系实现
- 文档 Skill：doc-sync, doc-validate, 文档模板
- 测试 Skill：test-strategy, e2e-write, verify
- 安全 Skill：security-research, poc, tool-integrate
- 发布 Skill：deploy
- 编排器：develop.feature（完整需求开发流程）
- README.md — 仓库说明 + 快速开始
- SKILL.md — 体系总览
- DESIGN.md — 设计文档

## [0.1.0] - 2026-06-02

### Added
- 项目初始化
- 目录结构：workflow/, docs/, testing/, security/, release/
