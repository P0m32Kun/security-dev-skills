# Security Dev Skills — 安装说明

> 本文件供 coding agent 自动安装使用。
> 人类用户请参考 README.md。

## 给 Agent 的指令

如果你是一个 coding agent，请按照以下步骤自动安装 Security Dev Skills：

### 步骤 1：克隆仓库

```bash
git clone git@github.com:P0m32Kun/security-dev-skills.git ~/.security-dev-skills
```

### 步骤 2：进入目录

```bash
cd ~/.security-dev-skills
```

### 步骤 3：运行安装脚本

```bash
./install.sh
```

安装脚本会自动：
- 检查系统环境
- 安装 uv（Python 包管理器）
- 安装 Semble MCP（代码搜索）
- 安装 CodeGraph MCP（代码知识图谱）
- 配置 MCP 服务器

### 步骤 4：加载 Skill

根据你是什么 agent，选择对应的加载方式：

#### Claude Code

在项目的 `CLAUDE.md` 中添加：

```markdown
@~/.security-dev-skills/SKILL.md
```

或在 `~/.claude/CLAUDE.md` 中添加（全局生效）：

```markdown
@~/.security-dev-skills/SKILL.md
```

#### Codex (OpenAI)

在项目的 `AGENTS.md` 中添加：

```markdown
# Security Dev Skills

参考 ~/.security-dev-skills/SKILL.md 中的开发流程。

## 开发流程

Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective

每个阶段有明确的完成标准，不能跳过。详见 ~/.security-dev-skills/workflow/develop.feature.md
```

#### Cursor

在项目的 `.cursorrules` 中添加：

```markdown
# Security Dev Skills

参考 ~/.security-dev-skills/SKILL.md 中的开发流程。

## 开发流程

Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective

每个阶段有明确的完成标准，不能跳过。详见 ~/.security-dev-skills/workflow/develop.feature.md
```

#### OpenCode

在项目的 `AGENTS.md` 中添加：

```markdown
# Security Dev Skills

参考 ~/.security-dev-skills/SKILL.md 中的开发流程。

## 开发流程

Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective

每个阶段有明确的完成标准，不能跳过。详见 ~/.security-dev-skills/workflow/develop.feature.md
```

#### Windsurf / Codeium

在项目的 `.windsurfrules` 中添加：

```markdown
# Security Dev Skills

参考 ~/.security-dev-skills/SKILL.md 中的开发流程。

## 开发流程

Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective

每个阶段有明确的完成标准，不能跳过。详见 ~/.security-dev-skills/workflow/develop.feature.md
```

#### Aider

在项目的 `.aider.conf.yml` 中添加：

```yaml
read:
  - ~/.security-dev-skills/SKILL.md
```

#### 其他 Agent

将以下内容添加到你的 agent 配置文件中：

```markdown
# Security Dev Skills

参考 ~/.security-dev-skills/SKILL.md 中的开发流程。

## 开发流程

Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective

每个阶段有明确的完成标准，不能跳过。

## 核心 Skill

- 编排器：~/.security-dev-skills/workflow/develop.feature.md
- 回顾：~/.security-dev-skills/workflow/retrospective.md
- 文档同步：~/.security-dev-skills/docs/sync.md
- 测试策略：~/.security-dev-skills/testing/strategy.md
- 功能验证：~/.security-dev-skills/testing/verify.md
```

### 步骤 5：告知用户

安装完成后，告知用户：

```
Security Dev Skills 安装完成！

已安装：
- Skill 仓库：~/.security-dev-skills
- MCP 服务器：Semble（代码搜索）、CodeGraph（代码知识图谱）

下一步：
1. 重启你的 coding agent 以加载配置
2. 阅读 ~/.security-dev-skills/SKILL.md 了解开发流程
3. 开始使用：Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective
```

## 安装脚本说明

`install.sh` 支持以下参数：

```bash
./install.sh              # 安装所有依赖
./install.sh --required   # 只安装必需依赖
./install.sh --update     # 更新 skill 仓库
./install.sh --dry-run    # 预览安装内容
./install.sh --help       # 显示帮助
```

## 依赖清单

### 必需依赖

| 类型 | 名称 | 用途 |
|------|------|------|
| MCP | Semble | 快速代码搜索（节省 98% token） |
| MCP | CodeGraph | 代码知识图谱 |
| 工具 | uv | Python 包管理器 |
| 工具 | Git | 版本控制 |

### 可选依赖

| 类型 | 名称 | 用途 |
|------|------|------|
| MCP | Context7 | 实时文档查询 |
| MCP | Playwright | 浏览器自动化 |
| MCP | Agent Browser | AI 浏览器 |
| 工具 | Docker | 容器化 |

## 故障排除

### 问题：git clone 失败

```bash
# 检查 SSH 密钥
ssh -T git@github.com

# 如果没有 SSH 密钥，使用 HTTPS
git clone https://github.com/P0m32Kun/security-dev-skills.git ~/.security-dev-skills
```

### 问题：install.sh 权限不足

```bash
chmod +x install.sh
```

### 问题：uv 安装失败

```bash
# 手动安装 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 添加到 PATH
export PATH="$HOME/.local/bin:$PATH"
```

### 问题：npm 未安装

```bash
# macOS
brew install node

# Linux (Debian/Ubuntu)
sudo apt-get install nodejs npm

# Linux (Fedora)
sudo dnf install nodejs npm
```

## 自动更新

安装完成后，可以设置自动更新：

```bash
# 检查更新
./auto-update.sh --check

# 执行更新
./auto-update.sh

# 设置定时更新（每天凌晨 3 点）
./auto-update.sh --setup-cron
```

## 相关文档

- `SKILL.md` — 体系总览（必读）
- `README.md` — 仓库说明
- `docs/dependencies.md` — 依赖管理详细说明
- `docs/best-practices.md` — 优秀设计模式
