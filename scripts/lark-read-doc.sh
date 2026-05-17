#!/bin/bash
# Agent COO 飞书文档读取脚本
# 用途：读取飞书文档内容，支持导出为 Markdown

set -e

# 参数检查
if [ $# -lt 1 ]; then
    echo "用法: $0 <文档token> [输出文件]"
    echo ""
    echo "示例:"
    echo "  $0 docxxxxxxxxxxxx"
    echo "  $0 docxxxxxxxxxxxx /path/to/output.md"
    echo ""
    exit 1
fi

DOC_TOKEN="$1"
OUTPUT_FILE="${2:-}"

echo "========================================"
echo "Agent COO - 读取飞书文档"
echo "========================================"
echo ""
echo "文档: $DOC_TOKEN"
[ -n "$OUTPUT_FILE" ] && echo "输出: $OUTPUT_FILE"
echo ""

# 检查 lark-cli
if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli 未安装"
    echo "   请先安装: npm install -g @larksuiteoapi/lark-cli"
    exit 1
fi

# 读取文档
echo "📖 正在读取文档..."
DOC_CONTENT=$(lark-cli docs get --token "$DOC_TOKEN" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$DOC_CONTENT" ]; then
    echo "✅ 文档读取成功"
    echo ""
    
    if [ -n "$OUTPUT_FILE" ]; then
        echo "$DOC_CONTENT" > "$OUTPUT_FILE"
        echo "✅ 已保存到: $OUTPUT_FILE"
    else
        echo "文档内容:"
        echo "----------------------------------------"
        echo "$DOC_CONTENT"
        echo "----------------------------------------"
    fi
else
    echo "❌ 文档读取失败"
    echo ""
    echo "可能原因:"
    echo "  - 文档 token 错误"
    echo "  - 文档不存在或已被删除"
    echo "  - 权限不足 (需要 docs:document:read 权限)"
    echo "  - 未登录飞书账号 (lark-cli auth login)"
    exit 1
fi
