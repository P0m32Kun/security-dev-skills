#!/bin/bash
#
# Security Dev Skills — 安装脚本
#
# 用法：
#   ./install.sh              # 安装所有依赖
#   ./install.sh --required   # 只安装必需依赖
#   ./install.sh --update     # 更新 skill 仓库
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
SKILL_REPO_URL="git@github.com:P0m32Kun/security-dev-skills.git"
SKILL_INSTALL_DIR="$HOME/.claude/skills/security-dev-skills"

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

    # 检查 Git
    if check_dependency git; then
        GIT_VERSION=$(git --version)
        log_success "Git: $GIT_VERSION"
    else
        log_error "Git 未安装，这是必需依赖"
        exit 1
    fi

    # 检查 Node.js
    if check_dependency node; then
        NODE_VERSION=$(node --version)
        log_success "Node.js: $NODE_VERSION"
    else
        log_warn "Node.js 未安装，部分 MCP 服务器需要 Node.js"
    fi

    # 检查 npm
    if check_dependency npm; then
        NPM_VERSION=$(npm --version)
        log_success "npm: $NPM_VERSION"
    else
        log_warn "npm 未安装，部分 MCP 服务器需要 npm"
    fi

    # 检查 Python
    if check_dependency python3; then
        PYTHON_VERSION=$(python3 --version)
        log_success "Python: $PYTHON_VERSION"
    else
        log_warn "Python 未安装，部分工具需要 Python"
    fi

    # 检查 uv（Python 包管理器）
    if check_dependency uv; then
        UV_VERSION=$(uv --version)
        log_success "uv: $UV_VERSION"
    else
        log_warn "uv 未安装，将尝试安装"
        install_uv
    fi

    # 检查 Docker
    if check_dependency docker; then
        DOCKER_VERSION=$(docker --version)
        log_success "Docker: $DOCKER_VERSION"
    else
        log_warn "Docker 未安装，容器化功能将不可用"
    fi
}

# 安装 uv（Python 包管理器）
install_uv() {
    log_info "安装 uv..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        # 添加到 PATH
        export PATH="$HOME/.local/bin:$PATH"
        log_success "uv 安装成功"
    else
        log_error "uv 安装失败"
        log_warn "请手动安装: https://docs.astral.sh/uv/getting-started/installation/"
    fi
}

# 安装 MCP 服务器
install_mcp_server() {
    local name=$1
    local install_cmd=$2
    shift 2
    local install_args=("$@")
    local config_cmd=$1
    shift
    local config_args=("$@")

    log_info "安装 MCP 服务器: $name"

    # 检查是否已安装
    if check_dependency "$name"; then
        log_success "$name 已安装"
        return 0
    fi

    # 执行安装命令
    if [ "$install_cmd" = "uv" ]; then
        if uv tool install "${install_args[@]}"; then
            log_success "$name 安装成功"
        else
            log_error "$name 安装失败"
            return 1
        fi
    elif [ "$install_cmd" = "npm" ]; then
        if npm install -g "${install_args[@]}"; then
            log_success "$name 安装成功"
        else
            log_error "$name 安装失败"
            return 1
        fi
    else
        log_error "未知的安装命令: $install_cmd"
        return 1
    fi

    # 配置 MCP 服务器
    configure_mcp_server "$name" "$config_cmd" "${config_args[@]}"
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

    # 使用 Python 更新配置
    python3 << EOF
import json

config_file = "$MCP_CONFIG_FILE"
name = "$name"
command = "$command"
args_str = """$(printf '%s\n' "${args[@]}")"""
args = [a for a in args_str.split('\n') if a]

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

# 安装 skill 仓库
install_skill_repo() {
    log_info "安装 Security Dev Skills..."

    # 如果已存在，更新
    if [ -d "$SKILL_INSTALL_DIR" ]; then
        log_info "Skill 仓库已存在，更新中..."
        cd "$SKILL_INSTALL_DIR"
        git pull
        log_success "Skill 仓库更新成功"
        return 0
    fi

    # 克隆仓库
    log_info "克隆 Skill 仓库..."
    mkdir -p "$(dirname "$SKILL_INSTALL_DIR")"
    if git clone "$SKILL_REPO_URL" "$SKILL_INSTALL_DIR"; then
        log_success "Skill 仓库安装成功"
    else
        log_error "Skill 仓库安装失败"
        return 1
    fi
}

# 更新 skill 仓库
update_skill_repo() {
    log_info "更新 Security Dev Skills..."

    if [ ! -d "$SKILL_INSTALL_DIR" ]; then
        log_error "Skill 仓库未安装"
        return 1
    fi

    cd "$SKILL_INSTALL_DIR"

    # 检查是否有更新
    git fetch
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse @{u})

    if [ "$LOCAL" = "$REMOTE" ]; then
        log_success "Skill 仓库已是最新版本"
        return 0
    fi

    # 拉取更新
    if git pull; then
        log_success "Skill 仓库更新成功"

        # 重新安装依赖（如有新增）
        log_info "检查依赖更新..."
        install_dependencies
    else
        log_error "Skill 仓库更新失败"
        return 1
    fi
}

# 安装依赖
install_dependencies() {
    log_info "安装依赖..."

    # 安装必需工具
    log_info "检查必需工具..."
    if ! check_dependency git; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi

    # 安装 uv
    if ! check_dependency uv; then
        install_uv
    fi

    # 安装 MCP 服务器
    log_info "安装 MCP 服务器..."

    # Semble（必需）- 代码搜索
    install_mcp_server "semble" \
        "uv" "tool" "install" "semble" \
        "uvx" "--from" "semble[mcp]" "semble"

    # CodeGraph（必需）- 代码知识图谱
    install_mcp_server "codegraph" \
        "npm" "install" "-g" "codegraph" \
        "codegraph" "serve"

    # Context7（可选）- 实时文档
    if ! $required_only; then
        install_mcp_server "context7" \
            "npm" "install" "-g" "@upstash/context7-mcp" \
            "npx" "-y" "@upstash/context7-mcp"
    fi

    # Playwright MCP（可选）- 浏览器自动化
    if ! $required_only; then
        install_mcp_server "playwright" \
            "npm" "install" "-g" "@anthropic-ai/mcp-playwright" \
            "npx" "-y" "@anthropic-ai/mcp-playwright"
    fi

    # Agent Browser MCP（可选）- AI 浏览器
    if ! $required_only; then
        install_mcp_server "agent-browser" \
            "npm" "install" "-g" "@anthropic-ai/mcp-browser" \
            "npx" "-y" "@anthropic-ai/mcp-browser"
    fi

    log_success "依赖安装完成"
}

# 显示帮助
show_help() {
    cat << EOF
Security Dev Skills — 安装脚本

用法:
    ./install.sh              安装所有依赖
    ./install.sh --required   只安装必需依赖
    ./install.sh --update     更新 skill 仓库
    ./install.sh --dry-run    预览安装内容
    ./install.sh --help       显示帮助

示例:
    ./install.sh              # 安装所有依赖
    ./install.sh --required   # 只安装必需依赖
    ./install.sh --update     # 更新 skill 仓库

依赖清单: dependencies.yaml
EOF
}

# 主安装流程
main() {
    local required_only=false
    local update_only=false
    local dry_run=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --required)
                required_only=true
                shift
                ;;
            --update)
                update_only=true
                shift
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

    # 如果只是更新
    if $update_only; then
        update_skill_repo
        exit 0
    fi

    # 安装 skill 仓库
    install_skill_repo

    echo ""

    # 安装依赖
    install_dependencies

    echo ""
    echo "=========================================="
    echo "  安装完成！"
    echo "=========================================="
    echo ""

    # 显示安装摘要
    log_info "安装摘要："
    echo "  - Skill 仓库: $SKILL_INSTALL_DIR"
    echo "  - MCP 配置: $MCP_CONFIG_FILE"
    echo ""

    log_info "下一步："
    echo "  1. 重启 Claude Code 以加载 MCP 服务器"
    echo "  2. 运行 `claude mcp list` 查看已配置的 MCP"
    echo "  3. 开始使用 skill 体系：阅读 SKILL.md"
    echo ""

    log_info "自动更新："
    echo "  运行 ./install.sh --update 可更新 skill 仓库"
    echo "  或设置定时任务自动更新"
    echo ""
}

# 运行主流程
main "$@"
