#!/bin/bash
# Agent COO 每日复盘主脚本
# 用途：编排每日复盘流程，调用扫描、分析、生成日报

set -e

DATE=$(date +%Y-%m-%d)
COO_DIR="$HOME/.coo"
SCAN_DIR="$COO_DIR/daily-scan/$DATE"

echo "========================================"
echo "Agent COO - 每日复盘 ($DATE)"
echo "========================================"
echo ""

# Step 1: 扫描工作上下文
echo "📡 Step 1: 扫描工作上下文..."
if [ -f "$(dirname "$0")/lark-scan-daily.sh" ]; then
    bash "$(dirname "$0")/lark-scan-daily.sh"
else
    echo "  ⚠️ 扫描脚本未找到，跳过扫描"
fi
echo ""

# Step 2: 检查扫描结果
echo "📊 Step 2: 检查扫描结果..."
if [ -d "$SCAN_DIR" ]; then
    echo "  ✅ 扫描结果目录: $SCAN_DIR"
    ls -1 "$SCAN_DIR" | while read file; do
        echo "    - $file"
    done
else
    echo "  ⚠️  未找到扫描结果"
fi
echo ""

# Step 3: 提示用户调用 Agent
echo "🤖 Step 3: 调用 Agent COO..."
echo ""
echo "请在 Codex/Claude Code 中运行以下命令："
echo ""
echo "  /coo-daily-review"
echo ""
echo "或手动输入："
echo ""
echo "  COO，帮我做今日复盘。"
echo "  扫描结果在: $SCAN_DIR"
echo ""

echo "========================================"
echo "每日复盘流程准备完成"
echo "========================================"
