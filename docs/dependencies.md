# 外部依赖管理

> 本文档说明如何管理 skill 体系的外部依赖。

## 概述

Security Dev Skills 依赖以下外部工具：

| 类型 | 工具 | 用途 | 必需 |
|------|------|------|------|
| MCP | CodeGraph | 代码知识图谱 | ✓ |
| MCP | Context7 | 实时文档查询 | — |
| MCP | Playwright | 浏览器自动化 | — |
| MCP | Agent Browser | AI 浏览器 | — |
| 工具 | Semgrep | 静态代码分析 | ✓ |
| 工具 | Docker | 容器化 | ✓ |
| 工具 | Git | 版本控制 | ✓ |
| Skill | Superpowers | 工作流自动化 | — |
| Skill | mattpocock/skills | 工程工具 | — |
| Skill | gstack | 浏览器/QA | — |
| Skill | Karpathy skills | 行为准则 | — |

## 快速安装

### 安装所有依赖

```bash
./install.sh
```

### 只安装必需依赖

```bash
./install.sh --required
```

### 安装指定类别

```bash
# 安装安全相关依赖
./install.sh --tags security

# 安装测试相关依赖
./install.sh --tags testing
```

### 预览安装内容

```bash
./install.sh --dry-run
```

## 依赖清单

依赖清单定义在 `dependencies.yaml` 文件中：

```yaml
# MCP 服务器
mcp_servers:
  - name: codegraph
    type: mcp
    description: 代码知识图谱
    source:
      github: "https://github.com/ricocf/codegraph"
    config:
      command: "codegraph"
      args: ["serve"]
    required: true
    tags: [code-analysis, search]

# 工具
tools:
  - name: semgrep
    type: tool
    description: 静态代码分析
    source:
      pip: "semgrep"
    required: true
    tags: [security, sast]

# 外部 Skill
skills:
  - name: superpowers
    type: skill
    description: 工作流自动化
    source:
      github: "https://github.com/obra/superpowers"
    required: false
    tags: [workflow]
```

## 添加新依赖

### 1. 编辑 dependencies.yaml

在相应的部分添加新依赖：

```yaml
# 添加新的 MCP 服务器
mcp_servers:
  - name: my-new-mcp
    type: mcp
    description: 我的新 MCP 服务器
    source:
      github: "https://github.com/user/repo"
    config:
      command: "npx"
      args: ["-y", "@user/mcp-package"]
    required: false
    tags: [category1, category2]

# 添加新的工具
tools:
  - name: my-new-tool
    type: tool
    description: 我的新工具
    source:
      npm: "@user/tool-package"
    required: false
    tags: [category1]

# 添加新的 Skill
skills:
  - name: my-new-skill
    type: skill
    description: 我的新 Skill
    source:
      github: "https://github.com/user/skill-repo"
    required: false
    tags: [category1]
```

### 2. 更新安装脚本（如需要）

如果新依赖需要特殊安装逻辑，在 `install.sh` 中添加相应函数。

### 3. 提交更改

```bash
git add dependencies.yaml install.sh
git commit -m "feat: 添加新依赖 my-new-mcp"
git push
```

## MCP 配置

MCP 服务器配置会自动写入 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "codegraph": {
      "command": "codegraph",
      "args": ["serve"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### 手动配置 MCP

如果自动配置失败，可以手动编辑配置文件：

```bash
# 编辑配置
vim ~/.claude/settings.json

# 查看已配置的 MCP
claude mcp list
```

## 外部 Skill 安装

外部 Skill 会安装到 `~/.claude/skills/` 目录：

```
~/.claude/skills/
├── superpowers/
├── mattpocock-skills/
├── gstack/
└── karpathy-skills/
```

### 引用外部 Skill

在 CLAUDE.md 中引用：

```markdown
# 使用 superpowers 的 brainstorming skill
参考 ~/.claude/skills/superpowers/skills/brainstorming/SKILL.md
```

## 依赖更新

### 检查更新

```bash
# 检查 MCP 服务器更新
npm outdated -g

# 检查 pip 包更新
pip list --outdated

# 检查 Git 仓库更新
cd ~/.claude/skills/superpowers && git pull
```

### 批量更新

```bash
# 更新所有 npm 包
npm update -g

# 更新所有 pip 包
pip install --upgrade semgrep

# 更新所有 skill
for skill in ~/.claude/skills/*/; do
  cd "$skill" && git pull
done
```

## 故障排除

### MCP 服务器无法启动

```bash
# 检查 MCP 状态
claude mcp list

# 查看 MCP 日志
claude mcp logs codegraph

# 重新安装 MCP
npm install -g @upstash/context7-mcp
```

### 工具安装失败

```bash
# 检查网络连接
ping github.com

# 检查权限
ls -la /usr/local/bin

# 使用代理（如需要）
export https_proxy=http://proxy:port
./install.sh
```

### Skill 加载失败

```bash
# 检查 skill 目录
ls -la ~/.claude/skills/

# 检查 skill 文件
cat ~/.claude/skills/superpowers/skills/brainstorming/SKILL.md

# 重新克隆 skill
rm -rf ~/.claude/skills/superpowers
./install.sh
```

## 参考

- `dependencies.yaml` — 依赖清单
- `install.sh` — 安装脚本
- `SKILL.md` — 体系总览
