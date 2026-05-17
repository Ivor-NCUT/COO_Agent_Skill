#!/bin/bash
# Agent COO Notion 每日扫描脚本
# 用途：扫描 Notion 工作区中的当日工作上下文
# 注意：此脚本需要 Notion Integration Token，通过 Notion API 直接调用
#       如果已配置 MCP，Agent 可以直接使用 MCP 工具，无需此脚本

set -e

CONFIG_FILE="$HOME/.coo/notion-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Notion 配置文件"
    echo "   请先运行: ./scripts/notion-onboarding.sh"
    exit 1
fi

# 读取配置
NOTION_TOKEN=$(cat "$CONFIG_FILE" | grep -o '"token": "[^"]*"' | cut -d'"' -f4)
MCP_TYPE=$(cat "$CONFIG_FILE" | grep -o '"mcp_type": "[^"]*"' | cut -d'"' -f4)

echo "========================================"
echo "Agent COO - Notion 每日扫描"
echo "========================================"
echo ""

# 检查 MCP 模式
if [ "$MCP_TYPE" = "remote" ]; then
    echo "ℹ️  你使用的是 Notion MCP Remote 模式"
    echo "   Agent 可以直接通过 MCP 工具访问 Notion"
    echo "   此脚本仅作为备用方案"
    echo ""
fi

# 检查 Token
if [ -z "$NOTION_TOKEN" ]; then
    echo "⚠️  未找到 Notion Token"
    echo "   如果你使用 MCP Remote 模式，可以忽略此警告"
    echo "   否则请先运行: ./scripts/notion-onboarding.sh"
    echo ""
    exit 0
fi

# 获取今日日期
TODAY=$(date +%Y-%m-%d)
TODAY_ISO="${TODAY}T00:00:00Z"
echo "📅 日期: $TODAY"
echo ""

# 检查依赖
if ! command -v curl &> /dev/null; then
    echo "❌ 未找到 curl，请先安装"
    exit 1
fi

# 搜索今日创建或修改的页面
echo "🔍 扫描今日修改的页面..."
SEARCH_RESULT=$(curl -s -X POST \
    https://api.notion.com/v1/search \
    -H "Authorization: Bearer $NOTION_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d '{
        "query": "",
        "sort": {
            "timestamp": "last_edited_time",
            "direction": "descending"
        },
        "page_size": 20
    }' 2>/dev/null || echo "")

if [ -n "$SEARCH_RESULT" ] && echo "$SEARCH_RESULT" | grep -q "results"; then
    echo "✅ 最近编辑的页面:"
    # 简单解析结果，显示标题
    echo "$SEARCH_RESULT" | grep -o '"title"[^}]*' | head -10 | while read line; do
        echo "  - $line"
    done
else
    echo "⚠️  未找到最近编辑的页面"
fi
echo ""

# 扫描数据库中的今日任务
echo "🔍 扫描任务数据库..."
TASK_DB=$(cat "$CONFIG_FILE" | grep -o '"tasks": "[^"]*"' | cut -d'"' -f4)

if [ -n "$TASK_DB" ]; then
    TASK_RESULT=$(curl -s -X POST \
        "https://api.notion.com/v1/databases/$TASK_DB/query" \
        -H "Authorization: Bearer $NOTION_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Notion-Version: 2022-06-28" \
        -d '{
            "filter": {
                "property": "Status",
                "select": {
                    "does_not_equal": "已完成"
                }
            }
        }' 2>/dev/null || echo "")
    
    if [ -n "$TASK_RESULT" ] && echo "$TASK_RESULT" | grep -q "results"; then
        TASK_COUNT=$(echo "$TASK_RESULT" | grep -o '"object": "page"' | wc -l | tr -d ' ')
        echo "📋 未完成任务数: $TASK_COUNT"
    else
        echo "⚠️  无法读取任务数据库"
    fi
else
    echo "⚠️  未配置任务数据库 ID"
fi
echo ""

# 输出摘要
echo "========================================"
echo "扫描摘要"
echo "========================================"
echo ""
echo "日期: $TODAY"
echo "MCP 模式: ${MCP_TYPE:-未配置}"
echo ""
echo "✅ 扫描完成"
echo ""
echo "💡 提示：如果你已配置 Notion MCP Remote，Agent 可以直接使用 MCP 工具"
echo "   进行更智能的查询和操作，无需依赖此脚本。"
