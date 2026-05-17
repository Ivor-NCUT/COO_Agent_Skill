#!/bin/bash
# Agent COO Notion 更新数据库脚本
# 用途：更新 Notion 数据库中的记录状态
# 注意：此脚本需要 Notion Integration Token
#       如果已配置 MCP，Agent 可以直接使用 patch-page MCP 工具

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
PAGE_ID=""
STATUS=""
PROPERTIES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --page)
            PAGE_ID="$2"
            shift 2
            ;;
        --status)
            STATUS="$2"
            shift 2
            ;;
        --properties)
            PROPERTIES="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

if [ -z "$PAGE_ID" ]; then
    echo "❌ 必须指定 --page（页面 ID）"
    echo "用法: ./notion-update-db.sh --page 'page_id' [--status '新状态'] [--properties '{...}']"
    exit 1
fi

# 检查依赖
if ! command -v curl &> /dev/null; then
    echo "❌ 未找到 curl，请先安装"
    exit 1
fi

# 构建更新内容
UPDATE_BODY="{\"properties\": {}}"

if [ -n "$STATUS" ]; then
    UPDATE_BODY=$(echo "$UPDATE_BODY" | sed "s/\"properties\": {}/\"properties\": {\"Status\": {\"select\": {\"name\": \"$STATUS\"}}}/")
fi

if [ -n "$PROPERTIES" ]; then
    UPDATE_BODY="{\"properties\": $PROPERTIES}"
fi

# 更新页面
echo "📝 更新页面: $PAGE_ID"

RESULT=$(curl -s -X PATCH \
    "https://api.notion.com/v1/pages/$PAGE_ID" \
    -H "Authorization: Bearer $NOTION_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "$UPDATE_BODY" 2>/dev/null || echo "")

if [ -n "$RESULT" ] && echo "$RESULT" | grep -q '"object": "page"'; then
    echo "✅ 页面已更新"
    echo "   链接: https://notion.so/$PAGE_ID"
else
    echo "❌ 更新失败"
    echo "$RESULT" | grep -o '"message": "[^"]*"' || echo "$RESULT"
    exit 1
fi
