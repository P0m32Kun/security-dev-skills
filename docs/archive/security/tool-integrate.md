---
name: tool-integrate
description: 安全工具集成
version: 1.0.0
tags: [security, integration, automation]
triggers:
  - "集成安全工具"
  - "工具集成"
  - "安全自动化"
inputs:
  - name: tool_name
    description: 工具名称
    required: true
  - name: integration_target
    description: 集成目标（CI/CD、监控平台等）
    required: true
outputs:
  - name: integration_code
    description: 集成代码
  - name: documentation
    description: 集成文档
---

# 安全工具集成

## 前置条件
- 已完成工具选型（`security/research.md`）
- 已了解目标系统的集成接口

## 流程

### 1. 了解工具输入输出格式

#### 输入格式

```bash
# CLI 工具
semgrep --config=auto --json target/

# API 工具
curl -X POST https://api.tool.com/scan \
  -H "Authorization: Bearer TOKEN" \
  -d '{"target": "http://example.com"}'
```

#### 输出格式

```json
{
  "results": [
    {
      "check_id": "sql-injection",
      "path": "src/api/user.go",
      "start": {"line": 42, "col": 10},
      "end": {"line": 42, "col": 30},
      "message": "SQL injection vulnerability",
      "severity": "ERROR"
    }
  ],
  "errors": []
}
```

### 2. 编写 Parser

解析工具输出，转换为统一格式：

```python
"""
Parser for Semgrep JSON output
"""

from dataclasses import dataclass
from typing import List, Optional
import json

@dataclass
class Finding:
    """统一的漏洞发现格式"""
    tool: str
    rule_id: str
    file_path: str
    line_start: int
    line_end: int
    message: str
    severity: str
    confidence: str

class SemgrepParser:
    """Semgrep JSON 输出解析器"""
    
    def __init__(self):
        self.tool_name = "semgrep"
    
    def parse(self, json_output: str) -> List[Finding]:
        """解析 Semgrep JSON 输出"""
        data = json.loads(json_output)
        findings = []
        
        for result in data.get("results", []):
            finding = Finding(
                tool=self.tool_name,
                rule_id=result.get("check_id", "unknown"),
                file_path=result.get("path", ""),
                line_start=result.get("start", {}).get("line", 0),
                line_end=result.get("end", {}).get("line", 0),
                message=result.get("message", ""),
                severity=self._map_severity(result.get("severity", "INFO")),
                confidence="high"
            )
            findings.append(finding)
        
        return findings
    
    def _map_severity(self, severity: str) -> str:
        """映射严重程度"""
        mapping = {
            "ERROR": "critical",
            "WARNING": "high",
            "INFO": "medium",
        }
        return mapping.get(severity.lower(), "low")
```

### 3. 编写 Pipeline Tool

将工具集成到 CI/CD 流程：

```python
"""
Security Pipeline Tool

Usage:
    python pipeline.py --target ./src --output report.json
"""

import argparse
import subprocess
import json
from typing import List
from parser import SemgrepParser, Finding

class SecurityPipeline:
    """安全扫描 Pipeline"""
    
    def __init__(self):
        self.parser = SemgrepParser()
    
    def run_semgrep(self, target: str) -> List[Finding]:
        """运行 Semgrep 扫描"""
        cmd = [
            "semgrep",
            "--config=auto",
            "--json",
            target
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise RuntimeError(f"Semgrep failed: {result.stderr}")
        
        return self.parser.parse(result.stdout)
    
    def filter_findings(self, findings: List[Finding], 
                        min_severity: str = "high") -> List[Finding]:
        """过滤漏洞发现"""
        severity_order = {
            "critical": 4,
            "high": 3,
            "medium": 2,
            "low": 1
        }
        
        min_level = severity_order.get(min_severity, 3)
        
        return [
            f for f in findings
            if severity_order.get(f.severity, 0) >= min_level
        ]
    
    def generate_report(self, findings: List[Finding], 
                        output_path: str):
        """生成报告"""
        report = {
            "total": len(findings),
            "by_severity": {},
            "findings": []
        }
        
        # 按严重程度统计
        for finding in findings:
            severity = finding.severity
            report["by_severity"][severity] = \
                report["by_severity"].get(severity, 0) + 1
            report["findings"].append({
                "tool": finding.tool,
                "rule_id": finding.rule_id,
                "file": finding.file_path,
                "line": finding.line_start,
                "message": finding.message,
                "severity": finding.severity
            })
        
        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)

def main():
    parser = argparse.ArgumentParser(
        description="Security Pipeline Tool"
    )
    parser.add_argument("--target", required=True, 
                       help="Target directory")
    parser.add_argument("--output", default="report.json",
                       help="Output report path")
    parser.add_argument("--min-severity", default="high",
                       choices=["critical", "high", "medium", "low"],
                       help="Minimum severity to report")
    
    args = parser.parse_args()
    
    pipeline = SecurityPipeline()
    
    print(f"[*] Running security scan on {args.target}")
    findings = pipeline.run_semgrep(args.target)
    
    print(f"[*] Found {len(findings)} issues")
    filtered = pipeline.filter_findings(findings, args.min_severity)
    print(f"[*] {len(filtered)} issues above {args.min_severity} severity")
    
    pipeline.generate_report(filtered, args.output)
    print(f"[*] Report saved to {args.output}")

if __name__ == "__main__":
    main()
```

### 4. 集成测试

```python
"""
Tests for Security Pipeline
"""

import pytest
from parser import SemgrepParser, Finding

class TestSemgrepParser:
    """测试 Semgrep 解析器"""
    
    def test_parse_valid_output(self):
        """测试解析有效输出"""
        json_output = '''
        {
            "results": [
                {
                    "check_id": "sql-injection",
                    "path": "src/api/user.go",
                    "start": {"line": 42, "col": 10},
                    "end": {"line": 42, "col": 30},
                    "message": "SQL injection vulnerability",
                    "severity": "ERROR"
                }
            ],
            "errors": []
        }
        '''
        
        parser = SemgrepParser()
        findings = parser.parse(json_output)
        
        assert len(findings) == 1
        assert findings[0].rule_id == "sql-injection"
        assert findings[0].severity == "critical"
    
    def test_parse_empty_output(self):
        """测试解析空输出"""
        json_output = '{"results": [], "errors": []}'
        
        parser = SemgrepParser()
        findings = parser.parse(json_output)
        
        assert len(findings) == 0
```

### 5. 更新文档

更新项目文档，说明工具集成方式：

```markdown
## 安全工具集成

### Semgrep

**用途**：静态代码分析

**安装**：
```bash
pip install semgrep
```

**使用**：
```bash
python pipeline.py --target ./src --min-severity high
```

**CI/CD 集成**：
```yaml
# .github/workflows/security.yml
- name: Security Scan
  run: python pipeline.py --target ./src --output report.json
```
```

## 完成标准
- [ ] 工具输入输出格式已了解
- [ ] Parser 已编写并测试通过
- [ ] Pipeline Tool 已编写并测试通过
- [ ] CI/CD 集成已完成
- [ ] 文档已更新

## 参考
- `security/research.md` — 安全调研
- `security/poc.md` — PoC 编写
- [Semgrep 文档](https://semgrep.dev/docs/)
