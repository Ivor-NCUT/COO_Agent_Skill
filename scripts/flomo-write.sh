#!/bin/bash
# Agent COO Flomo 写入脚本
# 用途：通过 curl 直接向 Flomo 写入笔记（MCP 的备用方案）

set -e

CONFIG_FILE="$HOME/.coo/flomo-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Flomo 配置文件"
    echo "   请先运行: ./scripts/flomo-onboarding.sh"
    exit 1
fi

FLOMO_API_URL=$(cat "$CONFIG_FILE" | grep -o '"api_url": "[^"]*"' | cut -d'"' -f4)

if [ -z "$FLOMO_API_URL" ]; then
    echo "❌ 未找到 Flomo API URL"
    echo "   请先运行: ./scripts/flomo-onboarding.sh"
    exit 1
fi

# 解析参数
CONTENT=""
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --content)
            CONTENT="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --content <内容>      笔记内容 (必填)"
            echo "  --tags <标签>         标签，用逗号分隔"
            echo "  --help               显示此帮助"
            echo ""
            echo "示例:"
            echo "  $0 --content '今天学到了 MCP 协议'"
            echo "  $0 --content '项目A的关键洞察' --tags '项目A,洞察'"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

if [ -z "$CONTENT" ]; then
    echo "❌ 笔记内容不能为空"
    echo "使用 --help 查看用法"
    exit 1
fi

# 添加标签
if [ -n "$TAGS" ]; then
    # 将逗号分隔的标签转换为 Flomo 格式
    FORMATTED_TAGS=$(echo "$TAGS" | sed 's/,/ #/g' | sed 's/^/#/')
    CONTENT="$CONTENT\n$FORMATTED_TAGS"
fi

echo "========================================"
echo "Agent COO - 写入 Flomo"
echo "========================================"
echo ""
echo "内容: $CONTENT"
echo ""

# 发送笔记
RESULT=$(curl -s -X POST \
    "$FLOMO_API_URL" \
    -H "Content-Type: application/json" \
    -d "{\"content\": \"$CONTENT\"}" 2>/dev/null || echo "")

if [ -n "$RESULT" ] && echo "$RESULT" | grep -q "code.*0"; then
    echo "✅ 笔记已发送到 Flomo"
else
    echo "❌ 发送失败"
    echo "   错误信息: $RESULT"
    exit 1
fi
