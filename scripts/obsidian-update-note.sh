#!/bin/bash
# Agent COO Obsidian 更新笔记脚本
# 用途：更新 Obsidian Vault 中的笔记内容

set -e

CONFIG_FILE="$HOME/.coo/obsidian-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Obsidian 配置文件"
    echo "   请先运行: ./scripts/obsidian-onboarding.sh"
    exit 1
fi

VAULT_PATH=$(cat "$CONFIG_FILE" | grep -o '"vault_path": "[^"]*"' | cut -d'"' -f4)

# 解析参数
FILE=""
CONTENT=""
APPEND=false
PREPEND=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --file)
            FILE="$2"
            shift 2
            ;;
        --content)
            CONTENT="$2"
            shift 2
            ;;
        --append)
            APPEND=true
            shift
            ;;
        --prepend)
            PREPEND=true
            shift
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --file <文件名>       笔记文件名 (相对 Vault 根目录)"
            echo "  --content <内容>      要写入的内容"
            echo "  --append              追加到文件末尾"
            echo "  --prepend             插入到文件开头"
            echo "  --help               显示此帮助"
            echo ""
            echo "示例:"
            echo "  $0 --file 'Projects/项目A.md' --content '## 新进展' --append"
            echo "  $0 --file 'Daily/2026-05-17.md' --content '# 日报' --prepend"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

if [ -z "$FILE" ]; then
    echo "❌ 文件名不能为空"
    echo "使用 --help 查看用法"
    exit 1
fi

FILE_PATH="$VAULT_PATH/$FILE"

# 检查文件是否存在
if [ ! -f "$FILE_PATH" ]; then
    echo "❌ 文件不存在: $FILE_PATH"
    echo "   请先创建文件"
    exit 1
fi

echo "========================================"
echo "Agent COO - 更新 Obsidian 笔记"
echo "========================================"
echo ""
echo "文件: $FILE"
echo "操作: $([ "$APPEND" = true ] && echo '追加' || ([ "$PREPEND" = true ] && echo '插入' || echo '覆盖'))"
echo ""

# 执行更新
if [ "$APPEND" = true ]; then
    # 追加内容
    if [ -n "$CONTENT" ]; then
        echo -e "\n$CONTENT" >> "$FILE_PATH"
        echo "✅ 内容已追加"
    else
        echo "⚠️  内容为空，未追加"
    fi
elif [ "$PREPEND" = true ]; then
    # 插入到开头
    if [ -n "$CONTENT" ]; then
        # 创建临时文件
        TEMP_FILE=$(mktemp)
        echo -e "$CONTENT\n" > "$TEMP_FILE"
        cat "$FILE_PATH" >> "$TEMP_FILE"
        mv "$TEMP_FILE" "$FILE_PATH"
        echo "✅ 内容已插入到开头"
    else
        echo "⚠️  内容为空，未插入"
    fi
else
    # 覆盖文件（谨慎使用）
    if [ -n "$CONTENT" ]; then
        echo "$CONTENT" > "$FILE_PATH"
        echo "✅ 文件已覆盖"
    else
        echo "⚠️  内容为空，未覆盖"
    fi
fi

# 如果 Obsidian CLI 可用，尝试刷新
if command -v obsidian &> /dev/null; then
    obsidian read file="$FILE" 2>/dev/null || true
fi

echo ""
echo "✅ 更新完成"
