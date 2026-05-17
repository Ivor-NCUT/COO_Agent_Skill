#!/bin/bash
# Agent COO Obsidian 创建笔记脚本
# 用途：在 Obsidian Vault 中创建结构化笔记

set -e

CONFIG_FILE="$HOME/.coo/obsidian-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Obsidian 配置文件"
    echo "   请先运行: ./scripts/obsidian-onboarding.sh"
    exit 1
fi

VAULT_PATH=$(cat "$CONFIG_FILE" | grep -o '"vault_path": "[^"]*"' | cut -d'"' -f4)

# 解析参数
FOLDER=""
TITLE=""
CONTENT=""
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --folder)
            FOLDER="$2"
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
        --tags)
            TAGS="$2"
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
    echo "用法: ./obsidian-create-note.sh --title '标题' --folder 'Projects' --content '内容' --tags 'tag1,tag2'"
    exit 1
fi

# 确定文件路径
if [ -n "$FOLDER" ]; then
    TARGET_DIR="$VAULT_PATH/$FOLDER"
    mkdir -p "$TARGET_DIR"
    FILE_PATH="$TARGET_DIR/$TITLE.md"
else
    FILE_PATH="$VAULT_PATH/$TITLE.md"
fi

# 生成 frontmatter
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)

FRONTMATTER="---\n"
FRONTMATTER+="id: $(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')_${DATE}\n"
FRONTMATTER+="created: $TIMESTAMP\n"

if [ -n "$TAGS" ]; then
    # 将逗号分隔的标签转换为 YAML 数组格式
    TAG_ARRAY=$(echo "$TAGS" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')
    FRONTMATTER+="tags: [$TAG_ARRAY]\n"
fi

FRONTMATTER+="---\n\n"

# 写入文件
echo -e "$FRONTMATTER# $TITLE\n\n$CONTENT" > "$FILE_PATH"

echo "✅ 笔记已创建: $FILE_PATH"

# 如果 Obsidian CLI 可用，尝试打开
if command -v obsidian &> /dev/null; then
    obsidian read file="$TITLE" 2>/dev/null || true
fi
