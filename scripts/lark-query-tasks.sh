#!/bin/bash
# Agent COO 飞书任务查询脚本
# 用途：查询飞书任务列表，支持按状态、截止日期筛选

set -e

# 默认参数
STATUS=""
DUE_BEFORE=""
DUE_AFTER=""
LIMIT=50

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --status)
            STATUS="$2"
            shift 2
            ;;
        --due-before)
            DUE_BEFORE="$2"
            shift 2
            ;;
        --due-after)
            DUE_AFTER="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --status <状态>       按状态筛选 (todo/in_progress/done)"
            echo "  --due-before <日期>   截止日期在此之前 (YYYY-MM-DD)"
            echo "  --due-after <日期>    截止日期在此之后 (YYYY-MM-DD)"
            echo "  --limit <数量>        返回数量限制 (默认: 50)"
            echo "  --help               显示此帮助"
            echo ""
            echo "示例:"
            echo "  $0 --status todo                    # 查询所有待办任务"
            echo "  $0 --due-before 2026-05-20          # 查询即将到期的任务"
            echo "  $0 --status todo --limit 10         # 查询前10个待办任务"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

# 检查 lark-cli
if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli 未安装"
    echo "   请先安装: npm install -g @larksuiteoapi/lark-cli"
    exit 1
fi

echo "========================================"
echo "Agent COO - 查询飞书任务"
echo "========================================"
echo ""

# 构建查询参数
QUERY_ARGS=""
[ -n "$STATUS" ] && QUERY_ARGS="$QUERY_ARGS --status $STATUS"
[ -n "$DUE_BEFORE" ] && QUERY_ARGS="$QUERY_ARGS --due-before ${DUE_BEFORE}T23:59:59+08:00"
[ -n "$DUE_AFTER" ] && QUERY_ARGS="$QUERY_ARGS --due-after ${DUE_AFTER}T00:00:00+08:00"
[ -n "$LIMIT" ] && QUERY_ARGS="$QUERY_ARGS --limit $LIMIT"

# 查询任务
echo "🔍 正在查询任务..."
echo ""

if lark-cli task list $QUERY_ARGS 2>/dev/null; then
    echo ""
    echo "✅ 查询完成"
else
    echo ""
    echo "❌ 查询失败"
    echo ""
    echo "可能原因:"
    echo "  - 未登录飞书账号 (lark-cli auth login)"
    echo "  - 权限不足 (需要 task:user_task:read 权限)"
    echo "  - 参数格式错误"
    exit 1
fi
