#!/bin/bash
# Agent COO Obsidian 读取笔记脚本
# 用途：读取 Obsidian Vault 中的笔记内容

set -e

CONFIG_FILE="$HOME/.coo/obsidian-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Obsidian 配置文件"
    echo "   请先运行: ./scripts/obsidian-onboarding.sh"
    exit 1
fi

VAULT_PATH=$(cat "$CONFIG_FILE" | grep -o '"vault_path": "[^"]*"' | cut -d'"' -f4)

# 参数检查
if [ $# -lt 1 ]; then
    echo "用法: $0 <文件名> [选项]"
    echo ""
    echo "选项:"
    echo "  --frontmatter         只显示 frontmatter"
    echo "  --content             只显示内容（不含 frontmatter）"
    echo "  --help               显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0 'Projects/项目A.md'"
    echo "  $0 'Strategy/战略方向.md' --content"
    exit 1
fi

FILE="$1"
shift

SHOW_FRONTMATTER=false
SHOW_CONTENT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --frontmatter)
            SHOW_FRONTMATTER=true
            shift
            ;;
        --content)
            SHOW_CONTENT=true
            shift
            ;;
        --help)
            echo "用法: $0 <文件名> [选项]"
            echo ""
            echo "选项:"
            echo "  --frontmatter         只显示 frontmatter"
            echo "  --content             只显示内容（不含 frontmatter）"
            echo "  --help               显示此帮助"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

FILE_PATH="$VAULT_PATH/$FILE"

# 检查文件是否存在
if [ ! -f "$FILE_PATH" ]; then
    echo "❌ 文件不存在: $FILE_PATH"
    exit 1
fi

echo "========================================"
echo "Agent COO - 读取 Obsidian 笔记"
echo "========================================"
echo ""
echo "文件: $FILE"
echo ""

# 读取文件内容
CONTENT=$(cat "$FILE_PATH")

# 检查是否有 frontmatter
if echo "$CONTENT" | head -1 | grep -q "^---$"; then
    HAS_FRONTMATTER=true
    # 提取 frontmatter
    FRONTMATTER=$(echo "$CONTENT" | awk '/^---$/{if(++count<=2)print;next} count==1{print}')
    # 提取内容
    BODY=$(echo "$CONTENT" | awk '/^---$/{count++;next} count==2{print}')
else
    HAS_FRONTMATTER=false
    FRONTMATTER=""
    BODY="$CONTENT"
fi

# 输出
if [ "$SHOW_FRONTMATTER" = true ] && [ "$HAS_FRONTMATTER" = true ]; then
    echo "---"
    echo "$FRONTMATTER"
    echo "---"
elif [ "$SHOW_CONTENT" = true ]; then
    echo "$BODY"
else
    # 默认显示全部
    echo "$CONTENT"
fi

echo ""
echo "✅ 读取完成"
