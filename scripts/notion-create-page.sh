#!/bin/bash
# Agent COO Notion 创建页面脚本
# 用途：在 Notion 中创建结构化页面
# 注意：此脚本需要 Notion Integration Token
#       如果已配置 MCP，Agent 可以直接使用 post-page MCP 工具

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
PARENT_ID=""
TITLE=""
CONTENT=""
DB_ID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --parent)
            PARENT_ID="$2"
            shift 2
            ;;
        --database)
            DB_ID="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --content)
            CONTENT="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

if [ -z "$TITLE" ]; then
    echo "❌ 标题不能为空"
    echo "用法: ./notion-create-page.sh --title '标题' [--parent 'page_id' | --database 'db_id'] [--content '内容']"
    exit 1
fi

# 检查依赖
if ! command -v curl &> /dev/null; then
    echo "❌ 未找到 curl，请先安装"
    exit 1
fi

# 构建请求体
if [ -n "$DB_ID" ]; then
    # 创建数据库记录
    REQUEST_BODY=$(cat <<EOF
{
    "parent": {
        "database_id": "$DB_ID"
    },
    "properties": {
        "Name": {
            "title": [
                {
                    "text": {
                        "content": "$TITLE"
                    }
                }
            ]
        }
    }
}
EOF
)
elif [ -n "$PARENT_ID" ]; then
    # 创建子页面
    REQUEST_BODY=$(cat <<EOF
{
    "parent": {
        "page_id": "$PARENT_ID"
    },
    "properties": {
        "title": {
            "title": [
                {
                    "text": {
                        "content": "$TITLE"
                    }
                }
            ]
        }
    }
}
EOF
)
else
    echo "❌ 必须指定 --parent 或 --database"
    exit 1
fi

# 创建页面
echo "📝 创建页面: $TITLE"

RESULT=$(curl -s -X POST \
    https://api.notion.com/v1/pages \
    -H "Authorization: Bearer $NOTION_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "$REQUEST_BODY" 2>/dev/null || echo "")

if [ -n "$RESULT" ] && echo "$RESULT" | grep -q '"object": "page"'; then
    PAGE_ID=$(echo "$RESULT" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
    echo "✅ 页面已创建"
    echo "   ID: $PAGE_ID"
    echo "   链接: https://notion.so/$PAGE_ID"
    
    # 如果有内容，追加到页面
    if [ -n "$CONTENT" ]; then
        curl -s -X PATCH \
            "https://api.notion.com/v1/blocks/$PAGE_ID/children" \
            -H "Authorization: Bearer $NOTION_TOKEN" \
            -H "Content-Type: application/json" \
            -H "Notion-Version: 2022-06-28" \
            -d "{
                \"children\": [
                    {
                        \"object\": \"block\",
                        \"type\": \"paragraph\",
                        \"paragraph\": {
                            \"rich_text\": [
                                {
                                    \"type\": \"text\",
                                    \"text\": {
                                        \"content\": \"$CONTENT\"
                                    }
                                }
                            ]
                        }
                    }
                ]
            }" > /dev/null
        echo "✅ 内容已追加"
    fi
else
    echo "❌ 创建失败"
    echo "$RESULT" | grep -o '"message": "[^"]*"' || echo "$RESULT"
    exit 1
fi
