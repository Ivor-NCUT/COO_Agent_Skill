#!/bin/bash
# Agent COO Notion 查询数据库脚本
# 用途：查询 Notion 数据库记录，支持过滤和排序
# 注意：此脚本需要 Notion Integration Token
#       如果已配置 MCP，Agent 可以直接使用 query-data-source MCP 工具

set -e

CONFIG_FILE="$HOME/.coo/notion-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Notion 配置文件"
    echo "   请先运行: ./scripts/notion-onboarding.sh"
    exit 1
fi

NOTION_TOKEN=$(cat "$CONFIG_FILE" | grep -o '"token": "[^"]*"' | cut -d'"' -f4)

if [ -z "$NOTION_TOKEN" ]; then
    echo "❌ 未找到 Notion Token"
    echo "   请先运行: ./scripts/notion-onboarding.sh"
    exit 1
fi

# 解析参数
DB_ID=""
FILTER=""
SORT=""
LIMIT=10

while [[ $# -gt 0 ]]; do
    case $1 in
        --database)
            DB_ID="$2"
            shift 2
            ;;
        --filter)
            FILTER="$2"
            shift 2
            ;;
        --sort)
            SORT="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

if [ -z "$DB_ID" ]; then
    echo "❌ 必须指定 --database（数据库 ID）"
    echo "用法: ./notion-query-db.sh --database 'db_id' [--filter '{...}'] [--sort '{...}'] [--limit 10]"
    exit 1
fi

# 检查依赖
if ! command -v curl &> /dev/null; then
    echo "❌ 未找到 curl，请先安装"
    exit 1
fi

# 构建查询体
QUERY_BODY="{\"page_size\": $LIMIT}"

if [ -n "$FILTER" ]; then
    QUERY_BODY=$(echo "$QUERY_BODY" | sed "s/}/, \"filter\": $FILTER}/")
fi

if [ -n "$SORT" ]; then
    QUERY_BODY=$(echo "$QUERY_BODY" | sed "s/}/, \"sorts\": [$SORT]}/")
fi

# 查询数据库
echo "🔍 查询数据库: $DB_ID"

RESULT=$(curl -s -X POST \
    "https://api.notion.com/v1/databases/$DB_ID/query" \
    -H "Authorization: Bearer $NOTION_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "$QUERY_BODY" 2>/dev/null || echo "")

if [ -n "$RESULT" ] && echo "$RESULT" | grep -q '"object": "list"'; then
    RESULT_COUNT=$(echo "$RESULT" | grep -o '"object": "page"' | wc -l | tr -d ' ')
    echo "✅ 查询成功，找到 $RESULT_COUNT 条记录"
    echo ""
    
    # 简单输出记录标题
    echo "$RESULT" | grep -o '"title"[^}]*' | head -$LIMIT | while read line; do
        echo "  - $line"
    done
else
    echo "❌ 查询失败"
    echo "$RESULT" | grep -o '"message": "[^"]*"' || echo "$RESULT"
    exit 1
fi
