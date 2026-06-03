---
name: e2e-write
description: 编写 E2E 测试
version: 1.0.0
tags: [testing, e2e, playwright]
triggers:
  - "编写 E2E 测试"
  - "用户流程测试"
  - "端到端测试"
inputs:
  - name: user_flow
    description: 用户流程描述
    required: true
  - name: test_conventions
    description: 项目 E2E 测试约定
    required: false
outputs:
  - name: test_spec
    description: E2E 测试 spec 文件
---

# E2E 测试编写

## 前置条件
- 用户流程已明确（Design 阶段通过）
- 项目有 E2E 测试框架（Playwright/Cypress）

## 流程

### 1. 阅读项目 E2E 测试约定

检查项目中的 E2E 测试规范：
- 文件命名：`*.spec.ts` / `*.test.ts`
- 目录结构：`tests/e2e/` / `e2e/`
- 工具配置：`playwright.config.ts` / `cypress.config.ts`

### 2. 编写 spec

#### 文件头注释

```typescript
/**
 * E2E 测试：用户登录流程
 * 
 * 覆盖场景：
 * - 正常登录
 * - 密码错误
 * - 账号不存在
 * - 登录态保持
 */
```

#### 测试结构

```typescript
import { test, expect } from '@playwright/test';

test.describe('用户登录', () => {
  test.beforeEach(async ({ page }) => {
    // 前置条件：访问登录页
    await page.goto('/login');
  });

  test('正常登录', async ({ page }) => {
    // 1. 输入账号密码
    await page.fill('[data-testid="username"]', 'testuser');
    await page.fill('[data-testid="password"]', 'password123');
    
    // 2. 点击登录
    await page.click('[data-testid="login-button"]');
    
    // 3. 验证跳转到首页
    await expect(page).toHaveURL('/dashboard');
    
    // 4. 验证用户信息显示
    await expect(page.locator('[data-testid="user-info"]')).toBeVisible();
  });

  test('密码错误', async ({ page }) => {
    // 1. 输入错误密码
    await page.fill('[data-testid="username"]', 'testuser');
    await page.fill('[data-testid="password"]', 'wrongpassword');
    
    // 2. 点击登录
    await page.click('[data-testid="login-button"]');
    
    // 3. 验证错误提示
    await expect(page.locator('[data-testid="error-message"]'))
      .toContainText('密码错误');
  });
});
```

### 3. 覆盖状态

确保覆盖以下状态：

| 状态 | 测试点 |
|------|--------|
| 加载中 | loading 指示器显示 |
| 空状态 | 无数据时的提示 |
| 错误状态 | 错误信息展示 |
| 成功状态 | 数据正确展示 |

### 4. Docker 环境运行验证

```bash
# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 运行 E2E 测试
npx playwright test

# 查看测试报告
npx playwright show-report
```

## 完成标准
- [ ] spec 文件已创建
- [ ] 覆盖用户视角的关键路径
- [ ] 覆盖加载/空/错误态
- [ ] Docker 环境测试通过
- [ ] 测试报告已生成

## 参考
- `testing/strategy.md` — 测试策略选择
- `testing/verify.md` — 用户视角功能验证
- [Playwright 文档](https://playwright.dev/)
