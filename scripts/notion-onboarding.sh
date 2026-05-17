#!/bin/bash
# Agent COO Notion MCP Onboarding 脚本
# 用途：帮助用户快速配置 Notion MCP，使其能被 Agent COO 调用

set -e

echo "========================================"
echo "Agent COO - Notion MCP Onboarding"
echo "========================================"
echo ""

# 检查 Node.js 环境
if ! command -v node &> /dev/null; then
    echo "❌ 未检测到 Node.js"
    echo ""
    echo "请先安装 Node.js："
    echo "  https://nodejs.org/ (推荐 v18+)")
    echo ""
    exit 1
fi

echo "✅ Node.js 已安装"
echo ""

# 检查 npx
if ! command -v npx &> /dev/null; then
    echo "❌ 未检测到 npx"
    echo "   npx 通常随 Node.js 一起安装"
    exit 1
fi

echo "✅ npx 已安装"
echo ""

# 询问 Notion 配置方式
echo "========================================"
echo "Notion MCP 配置方式"
echo "========================================"
echo ""
echo "Notion 支持两种 MCP 连接方式："
echo ""
echo "1. Notion MCP Remote（推荐）"
echo "   - 通过 OAuth 一键授权"
echo "   - 官方优先支持，功能更强大"
echo "   - 无需手动管理 Token"
echo ""
echo "2. Local MCP Server"
echo "   - 本地运行 MCP Server"
echo "   - 需要手动配置 Integration Token"
echo "   - 适合离线环境"
echo ""

read -p "选择配置方式 (1-Remote/2-Local，默认: 1): " MCP_MODE
MCP_MODE=${MCP_MODE:-1}

if [ "$MCP_MODE" = "1" ]; then
    echo ""
    echo "📝 Notion MCP Remote 配置步骤："
    echo ""
    echo "1. 打开 Notion 设置 → Connections → MCP"
    echo "2. 点击 'Add MCP connection'"
    echo "3. 选择你的 Agent 客户端（Claude Desktop / Cursor / 其他）"
    echo "4. 授权访问你的 Notion 工作区"
    echo ""
    echo "✅ 授权完成后，Notion MCP 即可使用"
    echo ""
    
    MCP_TYPE="remote"
else
    echo ""
    echo "📝 Local MCP Server 配置步骤："
    echo ""
    echo "1. 访问 https://www.notion.so/my-integrations"
    echo "2. 创建一个新的 Integration"
    echo "3. 复制 Integration Token（以 ntn_ 开头）"
    echo ""
    
    read -p "请输入你的 Notion Integration Token: " NOTION_TOKEN
    
    if [ -z "$NOTION_TOKEN" ]; then
        echo "❌ Token 不能为空"
        exit 1
    fi
    
    echo ""
    echo "✅ Token 已接收"
    echo ""
    
    MCP_TYPE="local"
fi

# 询问数据库配置
echo "========================================"
echo "配置业务系统数据库"
echo "========================================"
echo ""
echo "Agent COO 需要以下数据库来管理你的业务系统："
echo ""

read -p "项目排期表 Database ID (可选，留空则跳过): " PROJECT_DB
read -p "任务协同表 Database ID (可选，留空则跳过): " TASK_DB
read -p "客户管理表 Database ID (可选，留空则跳过): " CUSTOMER_DB
read -p "内容管理表 Database ID (可选，留空则跳过): " CONTENT_DB
read -p "情报与机会表 Database ID (可选，留空则跳过): " INTELLIGENCE_DB

echo ""
read -p "战略文档 Page ID (可选，留空则跳过): " STRATEGY_PAGE

echo ""
read -p "你希望每天自动执行还是手动召唤？(自动/手动，默认：手动): " MODE
MODE=${MODE:-手动}

# 生成配置
CONFIG_DIR="$HOME/.coo"
mkdir -p "$CONFIG_DIR"

if [ "$MCP_TYPE" = "remote" ]; then
    cat > "$CONFIG_DIR/notion-config.json" <<EOF
{
  "platform": "notion",
  "mcp_type": "remote",
  "mode": "$MODE",
  "databases": {
    "projects": "$PROJECT_DB",
    "tasks": "$TASK_DB",
    "customers": "$CUSTOMER_DB",
    "content": "$CONTENT_DB",
    "intelligence": "$INTELLIGENCE_DB"
  },
  "pages": {
    "strategy": "$STRATEGY_PAGE"
  }
}
EOF
else
    cat > "$CONFIG_DIR/notion-config.json" <<EOF
{
  "platform": "notion",
  "mcp_type": "local",
  "token": "$NOTION_TOKEN",
  "mode": "$MODE",
  "databases": {
    "projects": "$PROJECT_DB",
    "tasks": "$TASK_DB",
    "customers": "$CUSTOMER_DB",
    "content": "$CONTENT_DB",
    "intelligence": "$INTELLIGENCE_DB"
  },
  "pages": {
    "strategy": "$STRATEGY_PAGE"
  }
}
EOF
fi

echo ""
echo "✅ 配置已保存到 $CONFIG_DIR/notion-config.json"
echo ""

# 生成 MCP 配置示例
echo "========================================"
echo "MCP 配置示例"
echo "========================================"
echo ""

if [ "$MCP_TYPE" = "local" ]; then
    echo "请将以下内容添加到你的 MCP 配置文件："
    echo ""
    echo "Claude Desktop: ~/Library/Application Support/Claude/claude_desktop_config.json"
    echo "Cursor: ~/.cursor/mcp.json"
    echo ""
    cat <<EOF
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "$NOTION_TOKEN"
      }
    }
  }
}
EOF
fi

echo ""

# 输出使用说明
echo "========================================"
echo "使用说明"
echo "========================================"
echo ""

if [ "$MODE" = "自动" ]; then
    echo "🕐 定时任务设置："
    echo ""
    echo "  添加以下 cron 任务（每天晚上 11 点执行）："
    echo "  0 23 * * * cd $(pwd) && /usr/bin/env bash -c 'source ~/.zshrc; coo daily-review'"
    echo ""
fi

echo "📝 手动触发："
echo ""
echo "  在 Codex/Claude Code 中输入："
echo "  /coo 或 COO，帮我做今日复盘"
echo ""

echo "🔧 Notion MCP 常用工具："
echo ""
echo "  query-data-source    - 查询数据库记录"
echo "  create-a-data-source - 创建新数据库"
echo "  post-page            - 创建新页面"
echo "  patch-page           - 更新页面内容"
echo "  get-page             - 读取页面内容"
echo "  post-search          - 搜索内容"
echo "  get-block-children   - 读取块内容"
echo ""

echo "📚 数据库设置建议："
echo ""
echo "  每个数据库建议包含以下属性："
echo "  - Name (标题)"
echo "  - Status (状态: 未开始/进行中/已完成)"
echo "  - Priority (优先级: 高/中/低)"
echo "  - Deadline (截止日期)"
echo "  - Tags (标签)"
echo "  - Assignee (负责人)"
echo ""

echo "========================================"
echo "Onboarding 完成！"
echo "========================================"
