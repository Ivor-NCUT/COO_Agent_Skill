#!/bin/bash
# Agent COO 飞书任务创建脚本
# 用途：在飞书任务中创建新任务

set -e

# 参数
TITLE=""
DESCRIPTION=""
DUE_DATE=""
PRIORITY=""
ASSIGNEE=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --title)
            TITLE="$2"
            shift 2
            ;;
        --description)
            DESCRIPTION="$2"
            shift 2
            ;;
        --due)
            DUE_DATE="$2"
            shift 2
            ;;
        --priority)
            PRIORITY="$2"
            shift 2
            ;;
        --assignee)
            ASSIGNEE="$2"
            shift 2
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --title <标题>        任务标题 (必填)"
            echo "  --description <描述>  任务描述"
            echo "  --due <日期>          截止日期 (YYYY-MM-DD)"
            echo "  --priority <优先级>   优先级 (high/medium/low)"
            echo "  --assignee <用户ID>   负责人"
            echo "  --help               显示此帮助"
            echo ""
            echo "示例:"
            echo "  $0 --title '完成项目提案' --due 2026-05-20 --priority high"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

# 检查必填参数
if [ -z "$TITLE" ]; then
    echo "❌ 任务标题不能为空"
    echo "使用 --help 查看用法"
    exit 1
fi

# 检查 lark-cli
if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli 未安装"
    echo "   请先安装: npm install -g @larksuiteoapi/lark-cli"
    exit 1
fi

echo "========================================"
echo "Agent COO - 创建飞书任务"
echo "========================================"
echo ""
echo "标题: $TITLE"
[ -n "$DESCRIPTION" ] && echo "描述: $DESCRIPTION"
[ -n "$DUE_DATE" ] && echo "截止: $DUE_DATE"
[ -n "$PRIORITY" ] && echo "优先级: $PRIORITY"
[ -n "$ASSIGNEE" ] && echo "负责人: $ASSIGNEE"
echo ""

# 构建创建参数
CREATE_ARGS="--title \"$TITLE\""
[ -n "$DESCRIPTION" ] && CREATE_ARGS="$CREATE_ARGS --description \"$DESCRIPTION\""
[ -n "$DUE_DATE" ] && CREATE_ARGS="$CREATE_ARGS --due \"${DUE_DATE}T23:59:59+08:00\""
[ -n "$PRIORITY" ] && CREATE_ARGS="$CREATE_ARGS --priority $PRIORITY"
[ -n "$ASSIGNEE" ] && CREATE_ARGS="$CREATE_ARGS --assignee \"$ASSIGNEE\""

# 创建任务
echo "📝 正在创建任务..."
if lark-cli task create $CREATE_ARGS 2>/dev/null; then
    echo ""
    echo "✅ 任务创建成功"
else
    echo ""
    echo "❌ 任务创建失败"
    echo ""
    echo "可能原因:"
    echo "  - 未登录飞书账号 (lark-cli auth login)"
    echo "  - 权限不足 (需要 task:user_task:write 权限)"
    echo "  - 参数格式错误"
    exit 1
fi
