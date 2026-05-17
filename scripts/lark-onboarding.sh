#!/bin/bash
# Agent COO 飞书 CLI Onboarding 脚本
# 用途：帮助用户快速配置飞书 CLI，使其能被 Agent COO 调用

set -e

echo "========================================"
echo "Agent COO - 飞书 CLI Onboarding"
echo "========================================"
echo ""

# 检查 lark-cli 是否已安装
if ! command -v lark-cli &> /dev/null; then
    echo "❌ 未检测到 lark-cli"
    echo ""
    echo "请先安装飞书 CLI："
    echo "  npm install -g @larksuiteoapi/lark-cli"
    echo ""
    exit 1
fi

echo "✅ lark-cli 已安装"
echo ""

# 检查是否已登录
if ! lark-cli auth status &> /dev/null; then
    echo "📝 需要登录飞书账号"
    echo ""
    echo "请运行："
    echo "  lark-cli auth login"
    echo ""
    echo "登录后重新运行此脚本"
    exit 1
fi

echo "✅ 已登录飞书"
echo ""

# 检查必要权限
echo "🔍 检查权限..."
REQUIRED_SCOPES=(
    "docs:document:read"
    "docs:document:write"
    "sheets:spreadsheet:read"
    "sheets:spreadsheet:write"
    "task:user_task:read"
    "task:user_task:write"
    "calendar:calendar:read"
    "calendar:calendar_event:read"
    "im:message:read"
    "minutes:video:read"
)

echo ""
echo "必要权限："
for scope in "${REQUIRED_SCOPES[@]}"; do
    echo "  - $scope"
done

echo ""
echo "⚠️  如果缺少权限，请重新登录："
echo "  lark-cli auth login --scopes docs:document:read,docs:document:write,..."
echo ""

# 询问用户配置
echo "========================================"
echo "配置 Agent COO"
echo "========================================"
echo ""

read -p "你的业务管理系统在哪个平台？(飞书/Notion/其他，默认：飞书): " PLATFORM
PLATFORM=${PLATFORM:-飞书}

read -p "你希望 COO 扫描哪些渠道？(文档/会议/消息/日历/任务，默认：全部): " CHANNELS
CHANNELS=${CHANNELS:-全部}

read -p "你的战略文档位置？(飞书文档链接或本地路径): " STRATEGY_DOC

read -p "你希望每天自动执行还是手动召唤？(自动/手动，默认：手动): " MODE
MODE=${MODE:-手动}

# 生成配置
echo ""
echo "========================================"
echo "生成配置..."
echo "========================================"
echo ""

CONFIG_DIR="$HOME/.coo"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.json" <<EOF
{
  "platform": "$PLATFORM",
  "channels": "$CHANNELS",
  "strategy_doc": "$STRATEGY_DOC",
  "mode": "$MODE",
  "lark_cli": {
    "installed": true,
    "scopes": [
      "docs:document:read",
      "docs:document:write",
      "sheets:spreadsheet:read",
      "sheets:spreadsheet:write",
      "task:user_task:read",
      "task:user_task:write",
      "calendar:calendar:read",
      "calendar:calendar_event:read",
      "im:message:read",
      "minutes:video:read"
    ]
  }
}
EOF

echo "✅ 配置已保存到 $CONFIG_DIR/config.json"
echo ""

# 输出使用说明
echo "========================================"
echo "使用说明"
echo "========================================"
echo ""

if [ "$MODE" = "自动" ]; then
    echo "🕐 定时任务设置："
    echo ""
    echo "  添加以下 cron 任务（每天晚上 11 点执行）："
    echo "  0 23 * * * cd $(pwd) && /usr/bin/env bash -c 'source ~/.zshrc; coo daily-review'"
    echo ""
    echo "  或使用系统定时任务："
    echo "  launchctl load -w ~/Library/LaunchAgents/com.coo.daily-review.plist"
    echo ""
fi

echo "📝 手动触发："
echo ""
echo "  在 Codex/Claude Code 中输入："
echo "  /coo 或 COO，帮我做今日复盘"
echo ""

echo "🔧 子命令："
echo ""
echo "  /coo-daily-review     - 每日复盘"
echo "  /coo-todo-cleanup     - 待办清理"
echo "  /coo-knowledge-ingestion - 知识沉淀"
echo "  /coo-strategy-alignment  - 战略对齐"
echo "  /coo-skill-iteration     - Skill 迭代"
echo ""

echo "========================================"
echo "Onboarding 完成！"
echo "========================================"
