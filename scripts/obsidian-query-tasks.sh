#!/bin/bash
# Agent COO Obsidian 任务查询脚本
# 用途：查询 Obsidian Vault 中的待办任务

set -e

CONFIG_FILE="$HOME/.coo/obsidian-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Obsidian 配置文件"
    echo "   请先运行: ./scripts/obsidian-onboarding.sh"
    exit 1
fi

VAULT_PATH=$(cat "$CONFIG_FILE" | grep -o '"vault_path": "[^"]*"' | cut -d'"' -f4)

# 解析参数
STATUS="all"
OVERDUE=false
TAG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --status)
            STATUS="$2"
            shift 2
            ;;
        --overdue)
            OVERDUE=true
            shift
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --status <状态>       任务状态 (all/todo/done，默认: all)"
            echo "  --overdue             只显示逾期任务"
            echo "  --tag <标签>          按标签筛选"
            echo "  --help               显示此帮助"
            echo ""
            echo "示例:"
            echo "  $0 --status todo              # 查询所有未完成任务"
            echo "  $0 --overdue                  # 查询逾期任务"
            echo "  $0 --tag 项目A                # 查询标签为项目A的任务"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "Agent COO - 查询 Obsidian 任务"
echo "========================================"
echo ""
echo "Vault: $VAULT_PATH"
echo "状态: $STATUS"
[ "$OVERDUE" = true ] && echo "筛选: 逾期任务"
[ -n "$TAG" ] && echo "标签: $TAG"
echo ""

# 检查依赖
if ! command -v grep &> /dev/null; then
    echo "❌ 未找到 grep"
    exit 1
fi

# 构建搜索模式
case $STATUS in
    todo)
        PATTERN="\- \[ \]"
        ;;
    done)
        PATTERN="\- \[x\]"
        ;;
    all)
        PATTERN="\- \[[ x]\]"
        ;;
    *)
        echo "❌ 无效的状态: $STATUS"
        echo "使用 --help 查看用法"
        exit 1
        ;;
esac

# 搜索任务
echo "🔍 正在搜索任务..."
echo ""

# 查找所有 Markdown 文件中的任务
RESULTS=$(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -exec grep -H "$PATTERN" {} + 2>/dev/null || true)

if [ -z "$RESULTS" ]; then
    echo "⚠️  未找到任务"
    exit 0
fi

# 过滤结果
FILTERED="$RESULTS"

# 按标签筛选
if [ -n "$TAG" ]; then
    FILTERED=$(echo "$FILTERED" | grep -i "#$TAG" || true)
fi

# 按逾期筛选
if [ "$OVERDUE" = true ]; then
    TODAY=$(date +%Y-%m-%d)
    FILTERED=$(echo "$FILTERED" | while read line; do
        # 检查行中是否包含日期，且日期早于今天
        TASK_DATE=$(echo "$line" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -1)
        if [ -n "$TASK_DATE" ] && [ "$TASK_DATE" \< "$TODAY" ]; then
            echo "$line"
        fi
    done)
fi

# 输出结果
if [ -z "$FILTERED" ]; then
    echo "⚠️  未找到符合条件的任务"
else
    echo "✅ 找到任务:"
    echo ""
    echo "$FILTERED" | while read line; do
        FILE=$(echo "$line" | cut -d: -f1 | sed "s|$VAULT_PATH/||")
        TASK=$(echo "$line" | cut -d: -f2-)
        echo "  📄 $FILE"
        echo "     $TASK"
        echo ""
    done
fi
