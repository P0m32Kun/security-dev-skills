# Git 工作流规范

> 分支管理、提交规范、PR 标准。

## 分支命名

### 格式

```
<type>/<简短描述>
```

### 类型前缀

| 前缀 | 用途 | 示例 |
|------|------|------|
| `feat/` | 新功能 | `feat/user-auth` |
| `fix/` | Bug 修复 | `fix/login-crash` |
| `refactor/` | 重构 | `refactor/auth-module` |
| `docs/` | 文档 | `docs/api-guide` |
| `test/` | 测试 | `test/auth-integration` |
| `chore/` | 构建/工具 | `chore/update-deps` |
| `perf/` | 性能优化 | `perf/query-optimization` |
| `security/` | 安全修复 | `security/xss-fix` |

### 命名规则

- 全小写，单词间用连字符 `-` 连接
- 描述部分不超过 5 个单词
- 不包含特殊字符、空格、下划线
- 不包含 issue 编号（放在 commit message 里）

## 提交规范（Conventional Commits）

### 格式

```
<type>(<scope>): <subject>

[body]

[footer]
```

### 类型

| 类型 | 用途 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `refactor` | 重构（不改行为） |
| `docs` | 文档 |
| `test` | 测试 |
| `chore` | 构建/工具/依赖 |
| `perf` | 性能优化 |
| `style` | 格式（不影响逻辑） |
| `ci` | CI/CD 配置 |
| `revert` | 回滚 |

### 规则

- subject 不超过 72 字符
- subject 用祈使语气（"add" 不是 "added"）
- subject 首字母小写
- body 说明"为什么"而不是"做了什么"
- footer 引用 issue：`Closes #123`

### 示例

```
feat(auth): add OAuth2 login support

Implement Google and GitHub OAuth2 providers using passport.js.
Token refresh is handled automatically with a 5-minute buffer.

Closes #456
```

## 禁止操作

以下操作需要显式用户确认：

| 操作 | 原因 |
|------|------|
| `git push --force` | 可能覆盖他人工作 |
| `git reset --hard` | 丢失未提交的更改 |
| `git rebase`（已推送的分支） | 改写历史 |
| `git checkout -- <file>` | 丢失工作区修改 |
| `git clean -fd` | 删除未跟踪文件 |
| 直接推送到 `main`/`master` | 绕过 review |

## PR 标准

### PR 标题

遵循 Conventional Commits 格式，与 commit message 一致。

### PR 描述模板

```
## 变更内容
- 具体变更 1
- 具体变更 2

## 变更原因
为什么需要这个变更

## 测试
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试通过

## 影响范围
- 影响的模块/功能
- 是否有 breaking change

## 关联 Issue
Closes #XXX
```

### 合并条件

- [ ] CI 全部通过
- [ ] 至少 1 人 approve（或 self-merge 仅限小改动）
- [ ] 无未解决的 review comment
- [ ] 分支已与目标分支同步（rebase 或 merge）
- [ ] commit 历史整洁（squash if needed）

## 提交粒度

- **一个 commit 做一件事** — 不要把"修 bug"和"加功能"混在一起
- **每个 commit 可独立编译和测试** — 不引入中间态的编译错误
- **WIP commit 只在本地** — 推送前 squash 掉
