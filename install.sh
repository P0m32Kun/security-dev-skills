#!/bin/bash
#
# Security Dev Skills — 安装脚本
#
# 用法：
#   ./install.sh              # 安装所有依赖
#   ./install.sh --required   # 只安装必需依赖
#   ./install.sh --tags security  # 安装指定标签的依赖
#   ./install.sh --dry-run    # 预览安装内容
#
# 依赖清单：dependencies.yaml
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPENDENCIES_FILE="$SCRIPT_DIR/dependencies.yaml"
CLAUDE_CONFIG_DIR="$HOME/.claude"
MCP_CONFIG_FILE="$CLAUDE_CONFIG_DIR/settings.json"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 检查依赖
check_dependency() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查系统环境
check_system() {
    log_info "检查系统环境..."

    # 检查操作系统
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_success "操作系统: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_success "操作系统: Linux"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi

    # 检查包管理器
    if check_dependency brew; then
        PKG_MANAGER="brew"
        log_success "包管理器: Homebrew"
    elif check_dependency apt-get; then
        PKG_MANAGER="apt"
        log_success "包管理器: apt"
    else
        log_warn "未检测到包管理器，部分依赖可能需要手动安装"
        PKG_MANAGER="manual"
    fi

    # 检查 Node.js
    if check_dependency node; then
        NODE_VERSION=$(node --version)
        log_success "Node.js: $NODE_VERSION"
    else
        log_warn "Node.js 未安装，部分 MCP 服务器需要 Node.js"
    fi

    # 检查 Python
    if check_dependency python3; then
        PYTHON_VERSION=$(python3 --version)
        log_success "Python: $PYTHON_VERSION"
    else
        log_warn "Python 未安装，部分工具需要 Python"
    fi

    # 检查 pip
    if check_dependency pip3; then
        log_success "pip3: 已安装"
    elif check_dependency pip; then
        log_success "pip: 已安装"
    else
        log_warn "pip 未安装，部分 Python 工具可能无法安装"
    fi

    # 检查 Docker
    if check_dependency docker; then
        DOCKER_VERSION=$(docker --version)
        log_success "Docker: $DOCKER_VERSION"
    else
        log_warn "Docker 未安装，容器化功能将不可用"
    fi

    # 检查 Git
    if check_dependency git; then
        GIT_VERSION=$(git --version)
        log_success "Git: $GIT_VERSION"
    else
        log_error "Git 未安装，这是必需依赖"
        exit 1
    fi
}

# 安装 Homebrew 包
install_brew() {
    local package=$1
    if check_dependency "$package"; then
        log_success "$package 已安装"
        return 0
    fi

    log_info "安装 $package..."
    if brew install "$package"; then
        log_success "$package 安装成功"
        return 0
    else
        log_error "$package 安装失败"
        return 1
    fi
}

# 安装 npm 包
install_npm() {
    local package=$1
    local global=${2:-true}

    if $global; then
        if npm list -g "$package" &> /dev/null; then
            log_success "$package 已安装"
            return 0
        fi

        log_info "安装 $package (全局)..."
        if npm install -g "$package"; then
            log_success "$package 安装成功"
            return 0
        else
            log_error "$package 安装失败"
            return 1
        fi
    else
        log_info "安装 $package (本地)..."
        if npm install "$package"; then
            log_success "$package 安装成功"
            return 0
        else
            log_error "$package 安装失败"
            return 1
        fi
    fi
}

# 安装 pip 包
install_pip() {
    local package=$1
    local pip_cmd="pip3"

    if ! check_dependency pip3; then
        pip_cmd="pip"
    fi

    if $pip_cmd show "$package" &> /dev/null; then
        log_success "$package 已安装"
        return 0
    fi

    log_info "安装 $package..."
    if $pip_cmd install "$package"; then
        log_success "$package 安装成功"
        return 0
    else
        log_error "$package 安装失败"
        return 1
    fi
}

# 克隆 Git 仓库
clone_repo() {
    local url=$1
    local target_dir=$2

    if [ -d "$target_dir" ]; then
        log_success "仓库已存在: $target_dir"
        return 0
    fi

    log_info "克隆仓库: $url"
    if git clone "$url" "$target_dir"; then
        log_success "仓库克隆成功"
        return 0
    else
        log_error "仓库克隆失败"
        return 1
    fi
}

# 安装 MCP 服务器
install_mcp_server() {
    local name=$1
    local github_url=$2
    local command=$3
    shift 3
    local args=("$@")

    log_info "安装 MCP 服务器: $name"

    # 如果是 npx 命令，检查 npm 包
    if [ "$command" = "npx" ]; then
        local package="${args[-1]}"
        # 移除 -y 参数
        if [ "${args[0]}" = "-y" ]; then
            args=("${args[@]:1}")
        fi
        install_npm "$package" false
    fi

    # 配置 MCP 服务器
    configure_mcp_server "$name" "$command" "${args[@]}"
}

# 配置 MCP 服务器
configure_mcp_server() {
    local name=$1
    local command=$2
    shift 2
    local args=("$@")

    log_info "配置 MCP 服务器: $name"

    # 确保配置目录存在
    mkdir -p "$CLAUDE_CONFIG_DIR"

    # 如果配置文件不存在，创建初始配置
    if [ ! -f "$MCP_CONFIG_FILE" ]; then
        echo '{"mcpServers":{}}' > "$MCP_CONFIG_FILE"
    fi

    # 使用 Python 更新配置（避免 jq 依赖）
    python3 << EOF
import json
import sys

config_file = "$MCP_CONFIG_FILE"
name = "$name"
command = "$command"
args = [$(printf '"%s",' "${args[@]}" | sed 's/,$//')]

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except:
    config = {"mcpServers": {}}

if "mcpServers" not in config:
    config["mcpServers"] = {}

config["mcpServers"][name] = {
    "command": command,
    "args": args
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"MCP 服务器 {name} 配置成功")
EOF
}

# 安装工具
install_tool() {
    local name=$1
    local type=$2
    local package=$3

    log_info "安装工具: $name ($type)"

    case $type in
        brew)
            install_brew "$package"
            ;;
        npm)
            install_npm "$package"
            ;;
        pip)
            install_pip "$package"
            ;;
        manual)
            log_warn "需要手动安装: $name"
            log_warn "请参考: $package"
            ;;
        *)
            log_error "未知的安装类型: $type"
            return 1
            ;;
    esac
}

# 安装外部 Skill
install_skill() {
    local name=$1
    local github_url=$2
    local target_dir="$HOME/.claude/skills/$name"

    log_info "安装 Skill: $name"
    clone_repo "$github_url" "$target_dir"
}

# 显示帮助
show_help() {
    cat << EOF
Security Dev Skills — 安装脚本

用法:
    ./install.sh              安装所有依赖
    ./install.sh --required   只安装必需依赖
    ./install.sh --tags TAG   安装指定标签的依赖
    ./install.sh --dry-run    预览安装内容
    ./install.sh --help       显示帮助

示例:
    ./install.sh --required          # 只安装必需依赖
    ./install.sh --tags security     # 安装安全相关依赖
    ./install.sh --tags testing      # 安装测试相关依赖
    ./install.sh --dry-run           # 预览安装内容

依赖清单: dependencies.yaml
EOF
}

# 主安装流程
main() {
    local required_only=false
    local tags=""
    local dry_run=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --required)
                required_only=true
                shift
                ;;
            --tags)
                tags="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo "=========================================="
    echo "  Security Dev Skills — 安装"
    echo "=========================================="
    echo ""

    # 检查系统环境
    check_system

    echo ""
    log_info "开始安装依赖..."
    echo ""

    # 安装必需工具
    log_info "安装必需工具..."
    install_tool "git" "brew" "git"
    install_tool "docker" "manual" "https://docs.docker.com/get-docker/"

    # 安装安全工具
    if [ -z "$tags" ] || [[ "$tags" == *"security"* ]]; then
        log_info "安装安全工具..."
        install_tool "semgrep" "pip" "semgrep"
    fi

    # 安装测试工具
    if [ -z "$tags" ] || [[ "$tags" == *"testing"* ]]; then
        log_info "安装测试工具..."
        install_tool "playwright-cli" "npm" "@playwright/test"
    fi

    # 安装 MCP 服务器
    log_info "安装 MCP 服务器..."

    # CodeGraph（必需）
    install_mcp_server "codegraph" \
        "https://github.com/ricocf/codegraph" \
        "codegraph" "serve"

    # Context7（可选）
    if ! $required_only; then
        install_mcp_server "context7" \
            "https://github.com/upstash/context7" \
            "npx" "-y" "@upstash/context7-mcp"
    fi

    # Playwright MCP（可选）
    if ! $required_only; then
        install_mcp_server "playwright" \
            "https://github.com/anthropics/anthropic-quickstarts/tree/main/mcp-playwright" \
            "npx" "-y" "@anthropic-ai/mcp-playwright"
    fi

    # Agent Browser MCP（可选）
    if ! $required_only; then
        install_mcp_server "agent-browser" \
            "https://github.com/anthropics/anthropic-quickstarts/tree/main/mcp-browser" \
            "npx" "-y" "@anthropic-ai/mcp-browser"
    fi

    # 安装外部 Skill
    if ! $required_only; then
        log_info "安装外部 Skill..."

        install_skill "superpowers" \
            "https://github.com/obra/superpowers"

        install_skill "mattpocock-skills" \
            "https://github.com/mattpocock/skills"

        install_skill "gstack" \
            "https://github.com/garrytan/gstack"

        install_skill "karpathy-skills" \
            "https://github.com/multica-ai/andrej-karpathy-skills"
    fi

    echo ""
    echo "=========================================="
    echo "  安装完成！"
    echo "=========================================="
    echo ""

    # 显示安装摘要
    log_info "安装摘要："
    echo "  - MCP 配置: $MCP_CONFIG_FILE"
    echo "  - Skill 目录: $HOME/.claude/skills/"
    echo ""

    log_info "下一步："
    echo "  1. 重启 Claude Code 以加载 MCP 服务器"
    echo "  2. 运行 `claude mcp list` 查看已配置的 MCP"
    echo "  3. 开始使用 skill 体系：阅读 SKILL.md"
    echo ""
}

# 运行主流程
main "$@"
