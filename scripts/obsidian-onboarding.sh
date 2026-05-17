#!/bin/bash
# Agent COO Obsidian CLI Onboarding 脚本
# 用途：帮助用户快速配置 Obsidian CLI，使其能被 Agent COO 调用

set -e

echo "========================================"
echo "Agent COO - Obsidian CLI Onboarding"
echo "========================================"
echo ""

# 检查 obsidian CLI 是否已安装
if ! command -v obsidian &> /dev/null; then
    echo "❌ 未检测到 obsidian CLI"
    echo ""
    echo "请先安装 Obsidian CLI："
    echo "  Obsidian v1.12+ 已内置 CLI，确保你的 Obsidian 版本 >= 1.12"
    echo "  如果已安装但命令找不到，尝试重启终端或检查 PATH"
    echo ""
    exit 1
fi

echo "✅ obsidian CLI 已安装"
echo ""

# 检查版本
OBSIDIAN_VERSION=$(obsidian --version 2>/dev/null || echo "unknown")
echo "📋 Obsidian CLI 版本: $OBSIDIAN_VERSION"
echo ""

# 列出可用的 vault
echo "🔍 扫描可用的 Vault..."
echo ""
VAULT_LIST=$(obsidian vault:list 2>/dev/null || echo "")

if [ -z "$VAULT_LIST" ]; then
    echo "⚠️  未找到已配置的 Vault，或 Obsidian 未运行"
    echo "   请确保 Obsidian 已启动并至少打开过一个 Vault"
    echo ""
fi

# 询问用户配置
echo "========================================"
echo "配置 Agent COO - Obsidian"
echo "========================================"
echo ""

read -p "你的 Obsidian Vault 路径 (例如: /Users/xxx/Documents/ObsidianVault): " VAULT_PATH

if [ -z "$VAULT_PATH" ]; then
    echo "❌ Vault 路径不能为空"
    exit 1
fi

if [ ! -d "$VAULT_PATH" ]; then
    echo "⚠️  路径不存在，是否创建？(y/n): " CREATE_VAULT
    read CREATE_VAULT
    if [ "$CREATE_VAULT" = "y" ] || [ "$CREATE_VAULT" = "Y" ]; then
        mkdir -p "$VAULT_PATH"
        echo "✅ 已创建 Vault 目录"
    else
        echo "❌ 请提供有效的 Vault 路径"
        exit 1
    fi
fi

read -p "你希望 COO 扫描哪些目录？(Projects/Tasks/Meetings/全部，默认：全部): " SCAN_DIRS
SCAN_DIRS=${SCAN_DIRS:-全部}

read -p "你的战略文档位置？(Vault 内相对路径，例如 Strategy/战略方向.md): " STRATEGY_DOC

read -p "你希望每天自动执行还是手动召唤？(自动/手动，默认：手动): " MODE
MODE=${MODE:-手动}

# 创建 COO 目录结构
echo ""
echo "========================================"
echo "创建 COO 业务系统目录结构..."
echo "========================================"
echo ""

mkdir -p "$VAULT_PATH/Projects"
mkdir -p "$VAULT_PATH/Tasks"
mkdir -p "$VAULT_PATH/Customers"
mkdir -p "$VAULT_PATH/Content"
mkdir -p "$VAULT_PATH/Intelligence"
mkdir -p "$VAULT_PATH/Meetings"
mkdir -p "$VAULT_PATH/Services"
mkdir -p "$VAULT_PATH/Strategy"
mkdir -p "$VAULT_PATH/Daily"

echo "✅ 已创建目录结构："
echo "  Projects/    - 项目排期表"
echo "  Tasks/       - 任务协同表"
echo "  Customers/   - 客户/合作方管理表"
echo "  Content/     - 内容/作品管理表"
echo "  Intelligence/ - 情报与机会表"
echo "  Meetings/    - 会议记录合集"
echo "  Services/    - 服务交付说明书"
echo "  Strategy/    - 战略文档"
echo "  Daily/       - 每日复盘日报"
echo ""

# 生成配置
CONFIG_DIR="$HOME/.coo"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/obsidian-config.json" <<EOF
{
  "platform": "obsidian",
  "vault_path": "$VAULT_PATH",
  "scan_dirs": "$SCAN_DIRS",
  "strategy_doc": "$STRATEGY_DOC",
  "mode": "$MODE",
  "folders": {
    "projects": "Projects",
    "tasks": "Tasks",
    "customers": "Customers",
    "content": "Content",
    "intelligence": "Intelligence",
    "meetings": "Meetings",
    "services": "Services",
    "strategy": "Strategy",
    "daily": "Daily"
  },
  "cli": {
    "installed": true,
    "version": "$OBSIDIAN_VERSION"
  }
}
EOF

echo "✅ 配置已保存到 $CONFIG_DIR/obsidian-config.json"
echo ""

# 创建示例战略文档模板
if [ ! -f "$VAULT_PATH/Strategy/战略方向.md" ] && [ -z "$STRATEGY_DOC" ]; then
    cat > "$VAULT_PATH/Strategy/战略方向.md" <<'EOF'
---
id: strategy_main
created: 2026-05-17
tags: [战略, 方向]
---

# 战略方向

## 长期目标

（在这里写下你的长期目标）

## 当前阶段重点

（在这里写下当前阶段的重点）

## 不做的事情

（在这里写下你明确不做的事情）

## 关键指标

（在这里写下你关注的关键指标）
EOF
    echo "📝 已创建战略文档模板: Strategy/战略方向.md"
    echo ""
fi

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
fi

echo "📝 手动触发："
echo ""
echo "  在 Codex/Claude Code 中输入："
echo "  /coo 或 COO，帮我做今日复盘"
echo ""

echo "🔧 Obsidian CLI 常用命令："
echo ""
echo "  obsidian daily                          # 打开/创建今日日记"
echo "  obsidian daily:append content='...'     # 追加内容到日记"
echo "  obsidian create name='标题' content='...'   # 创建笔记"
echo "  obsidian read file='文件名'                 # 读取笔记"
echo "  obsidian append file='文件名' content='...' # 追加内容"
echo "  obsidian search query='关键词'              # 搜索笔记"
echo "  obsidian search:context query='关键词'      # 带上下文的深度搜索"
echo ""

echo "📚 推荐插件（可选）："
echo ""
echo "  - Dataview:     数据库查询，替代多维表格"
echo "  - Tasks:        任务管理，支持筛选和统计"
echo "  - Templater:    模板系统，自动化日报生成"
echo "  - Periodic Notes: 周期笔记，自动创建日报/周报"
echo ""

echo "========================================"
echo "Onboarding 完成！"
echo "========================================"
