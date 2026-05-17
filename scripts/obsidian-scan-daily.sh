#!/bin/bash
# Agent COO Obsidian 每日扫描脚本
# 用途：扫描 Obsidian Vault 中的当日工作上下文

set -e

CONFIG_FILE="$HOME/.coo/obsidian-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 Obsidian 配置文件"
    echo "   请先运行: ./scripts/obsidian-onboarding.sh"
    exit 1
fi

VAULT_PATH=$(cat "$CONFIG_FILE" | grep -o '"vault_path": "[^"]*"' | cut -d'"' -f4)

echo "========================================"
echo "Agent COO - Obsidian 每日扫描"
echo "========================================"
echo ""
echo "📁 Vault: $VAULT_PATH"
echo ""

# 获取今日日期
TODAY=$(date +%Y-%m-%d)
echo "📅 日期: $TODAY"
echo ""

# 扫描今日日记
echo "🔍 扫描今日日记..."
DAILY_NOTE=$(obsidian daily 2>/dev/null || echo "")
if [ -n "$DAILY_NOTE" ]; then
    echo "✅ 今日日记已创建"
else
    echo "⚠️  今日日记未找到"
fi
echo ""

# 扫描今日创建/修改的文件
echo "🔍 扫描今日修改的笔记..."
if command -v find &> /dev/null; then
    RECENT_FILES=$(find "$VAULT_PATH" -name "*.md" -mtime -1 -not -path "*/.obsidian/*" 2>/dev/null | head -20)
    if [ -n "$RECENT_FILES" ]; then
        echo "✅ 今日修改的笔记:"
        echo "$RECENT_FILES" | while read file; do
            echo "  - $(basename "$file")"
        done
    else
        echo "⚠️  今日无修改记录"
    fi
fi
echo ""

# 扫描待办任务
echo "🔍 扫描待办任务..."
if command -v grep &> /dev/null; then
    TODO_COUNT=$(grep -r "\- \[ \]" "$VAULT_PATH" --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "📋 未完成任务数: $TODO_COUNT"
    
    # 扫描逾期任务（简单判断：包含日期且日期早于今天）
    OVERDUE_TASKS=$(grep -r "\- \[ \]" "$VAULT_PATH" --include="*.md" 2>/dev/null | grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" | while read line; do
        TASK_DATE=$(echo "$line" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -1)
        if [ -n "$TASK_DATE" ] && [ "$TASK_DATE" \< "$TODAY" ]; then
            echo "  ⚠️  $line"
        fi
    done)
    
    if [ -n "$OVERDUE_TASKS" ]; then
        echo ""
        echo "🚨 逾期任务:"
        echo "$OVERDUE_TASKS"
    fi
fi
echo ""

# 扫描会议记录
echo "🔍 扫描会议记录..."
MEETING_DIR="$VAULT_PATH/Meetings"
if [ -d "$MEETING_DIR" ]; then
    RECENT_MEETINGS=$(find "$MEETING_DIR" -name "*.md" -mtime -7 2>/dev/null | head -10)
    if [ -n "$RECENT_MEETINGS" ]; then
        echo "✅ 近期会议记录:"
        echo "$RECENT_MEETINGS" | while read file; do
            echo "  - $(basename "$file")"
        done
    else
        echo "⚠️  近期无会议记录"
    fi
else
    echo "⚠️  Meetings 目录不存在"
fi
echo ""

# 输出摘要
echo "========================================"
echo "扫描摘要"
echo "========================================"
echo ""
echo "日期: $TODAY"
echo "Vault: $VAULT_PATH"
echo "待办任务: $TODO_COUNT"
echo ""
echo "✅ 扫描完成"
