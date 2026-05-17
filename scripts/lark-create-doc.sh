#!/bin/bash
# Agent COO 飞书文档创建脚本
# 用途：创建飞书文档并写入内容

set -e

# 参数检查
if [ $# -lt 2 ]; then
    echo "用法: $0 <文档标题> <内容文件> [文件夹token]"
    echo ""
    echo "示例:"
    echo "  $0 'COO日报-2026-05-17' /path/to/content.md"
    echo "  $0 'COO日报-2026-05-17' /path/to/content.md fldxxxxxxxxxxxx"
    echo ""
    exit 1
fi

DOC_TITLE="$1"
CONTENT_FILE="$2"
FOLDER_TOKEN="${3:-}"

echo "========================================"
echo "Agent COO - 创建飞书文档"
echo "========================================"
echo ""
echo "标题: $DOC_TITLE"
echo "内容: $CONTENT_FILE"
[ -n "$FOLDER_TOKEN" ] && echo "文件夹: $FOLDER_TOKEN"
echo ""

# 检查 lark-cli
if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli 未安装"
    exit 1
fi

# 检查内容文件
if [ ! -f "$CONTENT_FILE" ]; then
    echo "❌ 内容文件不存在: $CONTENT_FILE"
    exit 1
fi

# 创建文档
echo "📝 正在创建文档..."
CREATE_RESULT=$(lark-cli docs create \
    --title "$DOC_TITLE" \
    --content "$(cat "$CONTENT_FILE")" \
    ${FOLDER_TOKEN:+--folder-token "$FOLDER_TOKEN"} 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ 文档创建成功"
    echo ""
    echo "结果:"
    echo "$CREATE_RESULT"
else
    echo "❌ 文档创建失败"
    echo ""
    echo "可能原因:"
    echo "  - 权限不足（需要 docs:document:write 权限）"
    echo "  - 文件夹 token 错误"
    echo ""
    exit 1
fi

echo ""
echo "========================================"
echo "创建完成"
echo "========================================"
