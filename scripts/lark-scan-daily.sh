#!/bin/bash
# Agent COO 每日扫描脚本
# 用途：通过飞书 CLI 扫描当天的工作上下文

set -e

DATE=$(date +%Y-%m-%d)
START_TIME="${DATE}T00:00:00+08:00"
END_TIME="${DATE}T23:59:59+08:00"

echo "========================================"
echo "Agent COO - 每日扫描 ($DATE)"
echo "========================================"
echo ""

# 检查 lark-cli
if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli 未安装"
    exit 1
fi

# 创建输出目录
OUTPUT_DIR="$HOME/.coo/daily-scan/$DATE"
mkdir -p "$OUTPUT_DIR"

echo "📁 输出目录: $OUTPUT_DIR"
echo ""

# 1. 扫描日历日程
echo "📅 扫描日历日程..."
if lark-cli calendar event list --start-time "$START_TIME" --end-time "$END_TIME" > "$OUTPUT_DIR/calendar.json" 2>/dev/null; then
    EVENT_COUNT=$(cat "$OUTPUT_DIR/calendar.json" | grep -c '"event_id"' || echo "0")
    echo "  ✅ 找到 $EVENT_COUNT 个日程"
else
    echo "  ⚠️  无法读取日历（可能需要重新授权）"
fi
echo ""

# 2. 扫描任务
echo "✅ 扫描待办任务..."
if lark-cli task list --completed false > "$OUTPUT_DIR/tasks.json" 2>/dev/null; then
    TASK_COUNT=$(cat "$OUTPUT_DIR/tasks.json" | grep -c '"task_id"' || echo "0")
    echo "  ✅ 找到 $TASK_COUNT 个未完成任务"
else
    echo "  ⚠️  无法读取任务（可能需要重新授权）"
fi
echo ""

# 3. 扫描文档（最近编辑）
echo "📝 扫描最近编辑的文档..."
# 注意：飞书 CLI 文档 API 可能需要特定参数
if lark-cli docs list --limit 20 > "$OUTPUT_DIR/docs.json" 2>/dev/null; then
    DOC_COUNT=$(cat "$OUTPUT_DIR/docs.json" | grep -c '"doc_token"' || echo "0")
    echo "  ✅ 找到 $DOC_COUNT 个文档"
else
    echo "  ⚠️  无法读取文档列表（可能需要重新授权）"
fi
echo ""

# 4. 扫描会议记录（妙记）
echo "🎥 扫描会议记录..."
if lark-cli minutes list --start-time "$START_TIME" --end-time "$END_TIME" > "$OUTPUT_DIR/minutes.json" 2>/dev/null; then
    MINUTES_COUNT=$(cat "$OUTPUT_DIR/minutes.json" | grep -c '"minute_token"' || echo "0")
    echo "  ✅ 找到 $MINUTES_COUNT 个会议记录"
else
    echo "  ⚠️  无法读取会议记录（可能需要重新授权）"
fi
echo ""

# 生成扫描摘要
echo "========================================"
echo "扫描摘要"
echo "========================================"
echo ""
echo "日期: $DATE"
echo "输出: $OUTPUT_DIR"
echo ""
echo "扫描结果:"
[ -f "$OUTPUT_DIR/calendar.json" ] && echo "  📅 日历日程: $EVENT_COUNT"
[ -f "$OUTPUT_DIR/tasks.json" ] && echo "  ✅ 待办任务: $TASK_COUNT"
[ -f "$OUTPUT_DIR/docs.json" ] && echo "  📝 文档: $DOC_COUNT"
[ -f "$OUTPUT_DIR/minutes.json" ] && echo "  🎥 会议记录: $MINUTES_COUNT"
echo ""
echo "========================================"
echo "扫描完成"
echo "========================================"

# 提示用户下一步
echo ""
echo "下一步:"
echo "  1. 在 Codex/Claude Code 中运行: /coo-daily-review"
echo "  2. Agent COO 会读取 $OUTPUT_DIR 中的扫描结果"
echo "  3. 生成 COO 日报"
