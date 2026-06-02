# Security Dev Skills

> 可移植的标准化开发流程 skill 仓库，适用于任何 coding agent。

## 这是什么

一套覆盖完整开发生命周期的 skill 体系，解决三个核心问题：

1. **文档散乱** — 统一文档格式和同步机制
2. **文档更新无强制** — 代码变更后自动触发文档更新
3. **测试能力不足** — 从用户视角验证功能，不只是编译通过

## 快速开始

### 1. 克隆仓库

```bash
git clone <repo-url> security-dev-skills
```

### 2. 在你的 coding agent 中加载

**Claude Code** — 在项目 CLAUDE.md 中引用：
```markdown
@path/to/security-dev-skills/SKILL.md
```

**Cursor** — 在 .cursorrules 中引用：
```markdown
参考 path/to/security-dev-skills/SKILL.md 中的开发流程。
```

**其他 agent** — 直接阅读 SKILL.md，按流程执行。

### 3. 使用

启动新需求时，按 SKILL.md 中的流程执行：

```
Research → Design → Implement → Doc-Sync → Verify → Release
```

每个阶段有明确的完成标准，不能跳过。

## 目录结构

```
security-dev-skills/
├── SKILL.md                      # 体系总览（必读）
├── workflow/
│   └── develop.feature.md        # 编排器：完整需求开发流程
├── docs/
│   ├── sync.md                   # 文档同步
│   ├── validate.md               # 文档一致性校验
│   └── templates/                # 文档模板
├── testing/
│   ├── strategy.md               # 测试策略选择
│   ├── e2e-write.md              # E2E 测试编写
│   └── verify.md                 # 用户视角功能验证
├── security/
│   ├── research.md               # 安全工具/思路调研
│   ├── poc.md                    # PoC 编写
│   └── tool-integrate.md         # 工具集成
└── release/
    └── deploy.md                 # 发布部署流程
```

## 与外部 Skill 的关系

| 我们的 Skill | 复用/参考 | 关系 |
|-------------|----------|------|
| `workflow/develop.feature` | superpowers 的 brainstorming/writing-plans | 编排器引用它们作为 Design 阶段实现 |
| `testing/e2e-write` | mattpocock 的 tdd | 参考 red-green-refactor 思路 |
| `docs/sync` | 无 | 完全新建，基于 CLAUDE.md 文档同步约束 |
| `security/*` | 无 | 完全新建 |

## 贡献

1. 每个 skill 是一个独立的 `.md` 文件
2. 遵循 SKILL.md 中定义的文件格式规范
3. 新增 skill 需更新 SKILL.md 的索引

## License

MIT
