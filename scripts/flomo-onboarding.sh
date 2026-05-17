#!/bin/bash
# Agent COO Flomo MCP Onboarding 脚本
# 用途：配置 Flomo MCP，用于快速记录灵感和洞察

set -e

echo "========================================"
echo "Agent COO - Flomo 配置"
echo "========================================"
echo ""
echo "Flomo 是一个轻量级的灵感记录工具。"
echo "Agent COO 可以通过 MCP 将精彩洞察直接写入你的 Flomo。"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 未检测到 Node.js"
    echo "   请先安装 Node.js: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js 已安装"
echo ""

# 获取 Flomo API URL
echo "========================================"
echo "配置 Flomo API"
echo "========================================"
echo ""
echo "请访问 https://flomoapp.com/mine?source=incoming_webhook"
echo "获取你的个人 API URL（以 https://flomoapp.com/iwh/ 开头）"
echo ""

read -p "请输入你的 Flomo API URL: " FLOMO_API_URL

if [ -z "$FLOMO_API_URL" ]; then
    echo "❌ API URL 不能为空"
    exit 1
fi

if ! echo "$FLOMO_API_URL" | grep -q "^https://flomoapp.com/iwh/"; then
    echo "⚠️  API URL 格式似乎不正确"
    echo "   正确的格式: https://flomoapp.com/iwh/xxxxxxxx"
    read -p "是否继续？(y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
        exit 1
    fi
fi

# 生成配置
CONFIG_DIR="$HOME/.coo"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/flomo-config.json" <<EOF
{
  "platform": "flomo",
  "api_url": "$FLOMO_API_URL",
  "enabled": true,
  "use_cases": [
    "快速记录灵感",
    "保存精彩洞察",
    "捕捉临时想法"
  ]
}
EOF

echo ""
echo "✅ 配置已保存到 $CONFIG_DIR/flomo-config.json"
echo ""

# 生成 MCP 配置示例
echo "========================================"
echo "MCP 配置"
echo "========================================"
echo ""
echo "请将以下内容添加到你的 MCP 配置文件："
echo ""
cat <<EOF
{
  "mcpServers": {
    "flomo": {
      "command": "npx",
      "args": ["-y", "@mcp-so/mcp-server-flomo"],
      "env": {
        "FLOMO_API_URL": "$FLOMO_API_URL"
      }
    }
  }
}
EOF

echo ""
echo "配置文件位置："
echo "  Claude Desktop: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo "  Cursor: ~/.cursor/mcp.json"
echo ""

# 测试连接
echo "========================================"
echo "测试连接"
echo "========================================"
echo ""

read -p "是否测试连接？(y/n，默认: y): " TEST_CONN
TEST_CONN=${TEST_CONN:-y}

if [ "$TEST_CONN" = "y" ] || [ "$TEST_CONN" = "Y" ]; then
    echo "📝 发送测试笔记..."
    
    TEST_RESULT=$(curl -s -X POST \
        "$FLOMO_API_URL" \
        -H "Content-Type: application/json" \
        -d '{
            "content": "Agent COO 已连接 ✅\n#AgentCOO #setup"
        }' 2>/dev/null || echo "")
    
    if [ -n "$TEST_RESULT" ] && echo "$TEST_RESULT" | grep -q "code.*0"; then
        echo "✅ 连接成功！测试笔记已发送到 Flomo"
    else
        echo "❌ 连接失败"
        echo "   请检查 API URL 是否正确"
        echo "   错误信息: $TEST_RESULT"
    fi
fi

echo ""
echo "========================================"
echo "Flomo 配置完成！"
echo "========================================"
echo ""
echo "💡 使用场景："
echo ""
echo "  1. 知识沉淀时，将精彩洞察同时写入 Flomo"
echo "  2. 每日复盘时，快速记录临时想法"
echo "  3. 会议中，捕捉关键灵感"
echo ""
echo "🔧 MCP 工具："
echo ""
echo "  write_note - 写入笔记"
echo "    参数: content (笔记内容)"
echo ""
echo "📱 在 Flomo App 中查看："
echo "   https://flomoapp.com"
echo ""
