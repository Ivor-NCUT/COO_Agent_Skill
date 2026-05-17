#!/bin/bash
# Agent COO 统一 Onboarding 脚本
# 用途：引导用户选择平台并完成初始配置

set -e

echo "========================================"
echo "Agent COO - 数字运营合伙人"
echo "========================================"
echo ""
echo "创业之后找的第一个人是谁？COO。"
echo "现在，让 Agent 成为你的运营合伙人。"
echo ""

# 检查是否已配置
CONFIG_FILE="$HOME/.coo/config.json"
if [ -f "$CONFIG_FILE" ]; then
    CURRENT_PLATFORM=$(cat "$CONFIG_FILE" | grep -o '"platform": "[^"]*"' | cut -d'"' -f4)
    echo "⚠️  检测到已有配置"
    echo "   当前平台: $CURRENT_PLATFORM"
    read -p "是否重新配置？(y/n，默认: n): " RECONFIG
    RECONFIG=${RECONFIG:-n}
    if [ "$RECONFIG" != "y" ] && [ "$RECONFIG" != "Y" ]; then
        echo ""
        echo "✅ 保持现有配置，退出 onboarding"
        exit 0
    fi
fi

echo ""
echo "========================================"
echo "Step 1: 选择你的主平台"
echo "========================================"
echo ""
echo "Agent COO 支持三个平台，请选择你的主平台："
echo ""
echo "1. 飞书 (Feishu/Lark)"
echo "   - 适合：中国企业、已有飞书生态"
echo "   - 优势：日历、会议、IM、文档一体化"
echo "   - 技术：lark-cli + lark-* skills"
echo ""
echo "2. Notion"
echo "   - 适合：海外团队、喜欢数据库视图"
echo "   - 优势：灵活的页面结构、强大的数据库"
echo "   - 技术：Notion MCP Remote (OAuth)"
echo ""
echo "3. Obsidian"
echo "   - 适合：个人知识管理、本地优先"
echo "   - 优势：Markdown 原生、完全本地控制"
echo "   - 技术：Obsidian CLI v1.12+ + MCP 搜索增强"
echo ""

read -p "请选择 (1-飞书/2-Notion/3-Obsidian): " PLATFORM_CHOICE

case $PLATFORM_CHOICE in
    1)
        PLATFORM="feishu"
        PLATFORM_NAME="飞书"
        ;;
    2)
        PLATFORM="notion"
        PLATFORM_NAME="Notion"
        ;;
    3)
        PLATFORM="obsidian"
        PLATFORM_NAME="Obsidian"
        ;;
    *)
        echo "❌ 无效选择，请重新运行脚本"
        exit 1
        ;;
esac

echo ""
echo "✅ 已选择: $PLATFORM_NAME"
echo ""

# 根据平台执行对应的 onboarding
case $PLATFORM in
    feishu)
        echo "========================================"
        echo "Step 2: 飞书配置"
        echo "========================================"
        echo ""
        
        if [ -f "./scripts/lark-onboarding.sh" ]; then
            ./scripts/lark-onboarding.sh
        else
            echo "⚠️  未找到 lark-onboarding.sh 脚本"
            echo "   请手动运行: ./scripts/lark-onboarding.sh"
        fi
        ;;
    
    notion)
        echo "========================================"
        echo "Step 2: Notion 配置"
        echo "========================================"
        echo ""
        
        if [ -f "./scripts/notion-onboarding.sh" ]; then
            ./scripts/notion-onboarding.sh
        else
            echo "⚠️  未找到 notion-onboarding.sh 脚本"
            echo "   请手动运行: ./scripts/notion-onboarding.sh"
        fi
        ;;
    
    obsidian)
        echo "========================================"
        echo "Step 2: Obsidian 配置"
        echo "========================================"
        echo ""
        
        if [ -f "./scripts/obsidian-onboarding.sh" ]; then
            ./scripts/obsidian-onboarding.sh
        else
            echo "⚠️  未找到 obsidian-onboarding.sh 脚本"
            echo "   请手动运行: ./scripts/obsidian-onboarding.sh"
        fi
        ;;
esac

# 生成统一配置
echo ""
echo "========================================"
echo "Step 3: 生成统一配置"
echo "========================================"
echo ""

CONFIG_DIR="$HOME/.coo"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.json" <<EOF
{
  "platform": "$PLATFORM",
  "platform_name": "$PLATFORM_NAME",
  "version": "1.0.0",
  "onboarding_date": "$(date +%Y-%m-%d)",
  "features": {
    "daily_review": true,
    "todo_cleanup": true,
    "knowledge_ingestion": true,
    "strategy_alignment": true,
    "skill_iteration": true
  }
}
EOF

echo "✅ 统一配置已保存到 $CONFIG_DIR/config.json"
echo ""

# 输出使用说明
echo "========================================"
echo "Agent COO 使用指南"
echo "========================================"
echo ""
echo "🚀 快速开始："
echo ""
echo "  在 Codex/Claude Code 中输入："
echo "  /coo 或 COO，帮我做今日复盘"
echo ""
echo "📋 子命令："
echo ""
echo "  /coo-daily-review      - 每日复盘"
echo "  /coo-todo-cleanup      - 待办清理"
echo "  /coo-knowledge-ingestion - 知识沉淀"
echo "  /coo-strategy-alignment  - 战略对齐"
echo "  /coo-skill-iteration     - Skill 迭代"
echo ""
echo "🔧 平台特定命令："
echo ""

case $PLATFORM in
    feishu)
        echo "  飞书 CLI 命令："
        echo "    lark-cli auth status     - 检查登录状态"
        echo "    lark-calendar +agenda    - 查看日程"
        echo "    lark-task +get-my-tasks  - 查看任务"
        echo ""
        ;;
    notion)
        echo "  Notion MCP 工具："
        echo "    query-data-source        - 查询数据库"
        echo "    post-page                - 创建页面"
        echo "    post-search              - 搜索内容"
        echo ""
        echo "  MCP 配置在 Claude Desktop / Cursor 中自动生效"
        echo ""
        ;;
    obsidian)
        echo "  Obsidian CLI 命令："
        echo "    obsidian daily           - 打开今日日记"
        echo "    obsidian search          - 搜索笔记"
        echo "    obsidian create          - 创建笔记"
        echo ""
        ;;
esac

echo "📚 文档："
echo ""
echo "  README.md              - 项目说明"
echo "  知识库/方法论/         - 核心理念和方法论"
echo "  知识库/Skill知识包/    - 各子 skill 的详细工作流"
echo ""

echo "========================================"
echo "Onboarding 完成！"
echo "========================================"
echo ""
echo "你的 Agent COO 已就绪。"
echo "现在，开始你的工作，让 COO 帮你维护系统。"
