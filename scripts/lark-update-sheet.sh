#!/bin/bash
# Agent COO 飞书表格更新脚本
# 用途：将工作产出更新到飞书多维表格

set -e

# 参数检查
if [ $# -lt 3 ]; then
    echo "用法: $0 <表格token> <工作表名> <数据JSON>"
    echo ""
    echo "示例:"
    echo "  $0 shtxxxxxxxxxxxx 项目排期表 '[{\"项目名称\":\"A\",\"状态\":\"进行中\"}]'"
    echo ""
    exit 1
fi

SHEET_TOKEN="$1"
SHEET_NAME="$2"
DATA="$3"

echo "========================================"
echo "Agent COO - 更新飞书表格"
echo "========================================"
echo ""
echo "表格: $SHEET_TOKEN"
echo "工作表: $SHEET_NAME"
echo ""

# 检查 lark-cli
if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli 未安装"
    exit 1
fi

# 更新表格
echo "📝 正在更新表格..."
if lark-cli sheets values update \
    --spreadsheet-token "$SHEET_TOKEN" \
    --sheet-name "$SHEET_NAME" \
    --values "$DATA" 2>/dev/null; then
    echo "✅ 表格更新成功"
else
    echo "❌ 表格更新失败"
    echo ""
    echo "可能原因:"
    echo "  - 表格 token 错误"
    echo "  - 工作表名不存在"
    echo "  - 权限不足（需要 sheets:spreadsheet:write 权限）"
    echo ""
    exit 1
fi

echo ""
echo "========================================"
echo "更新完成"
echo "========================================"
