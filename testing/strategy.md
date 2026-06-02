---
name: test-strategy
description: 根据变更类型选择测试策略
version: 1.0.0
tags: [testing, strategy, planning]
triggers:
  - "测试策略"
  - "测试计划"
  - "进入 Implement 前"
inputs:
  - name: change_type
    description: 变更类型（新增功能/修 bug/重构/配置变更）
    required: true
  - name: change_scope
    description: 变更范围
    required: true
outputs:
  - name: test_plan
    description: 测试计划
---

# 测试策略选择

## 前置条件
- 需求已完成设计（Design 阶段通过）
- 明确变更类型和范围

## 流程

### 1. 分析变更类型

| 变更类型 | 描述 | 典型场景 |
|---------|------|---------|
| 新增功能 | 添加新的用户功能 | 新增 API、新增页面 |
| 修 bug | 修复已知问题 | 修复逻辑错误、修复样式 |
| 重构 | 不改变行为的代码优化 | 代码结构调整、性能优化 |
| 配置变更 | 修改配置或依赖 | 环境变量、依赖升级 |

### 2. 选择测试层级

根据变更类型选择测试层级组合：

| 变更类型 | Unit | Integration | E2E |
|---------|------|-------------|-----|
| 新增功能 | ✓ | ✓ | ✓ |
| 修 bug | ✓ | ✓ | 视情况 |
| 重构 | ✓ | ✓ | 回归 |
| 配置变更 | — | ✓ | 回归 |

#### Unit 测试
- **适用**：独立函数、工具方法、业务逻辑
- **工具**：Jest、Vitest、Go test、pytest
- **覆盖率**：核心逻辑 100%

#### Integration 测试
- **适用**：模块间交互、API 接口、数据库操作
- **工具**：Supertest、httpexpect、pytest
- **覆盖率**：关键路径 100%

#### E2E 测试
- **适用**：用户完整流程、跨系统交互
- **工具**：Playwright、Cypress、Selenium
- **覆盖率**：核心用户流程

### 3. 输出测试计划

```markdown
## 测试计划

### 变更概述
- 类型：新增功能
- 范围：用户认证模块
- 影响：登录、注册、权限

### 测试策略

#### Unit 测试
- [ ] `auth.service.test.ts` — 密码加密、token 生成
- [ ] `user.model.test.ts` — 用户模型验证

#### Integration 测试
- [ ] `auth.api.test.ts` — 登录接口、注册接口
- [ ] `auth.middleware.test.ts` — 认证中间件

#### E2E 测试
- [ ] `login.spec.ts` — 用户登录流程
- [ ] `register.spec.ts` — 用户注册流程

### 测试环境
- 本地：Docker Compose
- CI：GitHub Actions

### 预计时间
- Unit：2 小时
- Integration：3 小时
- E2E：4 小时
```

## 完成标准
- [ ] 变更类型已明确
- [ ] 测试层级已选择
- [ ] 测试计划已输出
- [ ] 测试计划已评审

## 参考
- `testing/e2e-write.md` — E2E 测试编写
- `testing/verify.md` — 用户视角功能验证
