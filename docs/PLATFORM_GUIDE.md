# Agent COO 三平台使用指南

本文档提供飞书、Notion、Obsidian 三个平台的详细使用案例和最佳实践。

## 目录

- [飞书 (Feishu/Lark)](#飞书-feishulark)
- [Notion](#notion)
- [Obsidian](#obsidian)
- [平台混用](#平台混用)
- [常见问题](#常见问题)

---

## 飞书 (Feishu/Lark)

### 适用场景

- 中国企业，团队已在用飞书
- 需要日历、会议、IM、文档一体化
- 多人协作，权限管理严格

### 核心工作流

#### 1. 每日复盘

```bash
# 扫描当天工作上下文
./scripts/lark-scan-daily.sh

# 查询未完成任务
./scripts/lark-query-tasks.sh --status todo

# 查询即将到期的任务
./scripts/lark-query-tasks.sh --due-before 2026-05-20
```

#### 2. 创建日报

```bash
# 创建飞书文档作为日报
./scripts/lark-create-doc.sh "COO日报-2026-05-17" /path/to/daily-report.md

# 更新项目排期表
./scripts/lark-update-sheet.sh sht_xxx "项目排期表" '[{"项目名称":"A","状态":"进行中"}]'
```

#### 3. 任务管理

```bash
# 创建任务
./scripts/lark-create-task.sh --title "完成项目提案" --due 2026-05-20 --priority high

# 读取战略文档
./scripts/lark-read-doc.sh doc_xxx /path/to/strategy.md
```

### 飞书 CLI 常用命令

```bash
# 登录
lark-cli auth login

# 查看日程
lark-cli calendar event list --start-time 2026-05-17T00:00:00+08:00 --end-time 2026-05-17T23:59:59+08:00

# 查看任务
lark-cli task list --status todo

# 创建文档
lark-cli docs create --title "新文档" --content "文档内容"

# 读取文档
lark-cli docs get --token doc_xxx

# 更新表格
lark-cli sheets values update --spreadsheet-token sht_xxx --sheet-name "Sheet1" --values "[[\"A\",\"B\"]]"
```

### 目录结构建议

```
飞书知识库/
├── 00 CEO驾驶舱/
│   ├── 每日任务表
│   ├── CEO问题队列
│   └── 日程编排表
├── 01 业务系统/
│   ├── 项目排期表（多维表格）
│   ├── 任务协同表（多维表格）
│   ├── 客户管理表（多维表格）
│   ├── 内容管理表（多维表格）
│   └── 情报与机会表（多维表格）
├── 02 知识资产/
│   ├── SOP文档库
│   ├── Agent Skill文档库
│   ├── 重要知识结晶
│   └── 方法论/
├── 03 会议记录/
│   ├── 2026-05/
│   └── 2026-06/
└── 04 战略文档/
    ├── 业务模型说明书
    ├── CEO工作原则
    └── 服务边界文档
```

---

## Notion

### 适用场景

- 海外团队，国际化协作
- 喜欢数据库视图和灵活页面结构
- 需要强大的筛选、排序、关联功能

### 核心工作流

#### 1. 每日复盘

```bash
# 扫描 Notion 工作区
./scripts/notion-scan-daily.sh

# 查询未完成任务
./scripts/notion-query-db.sh --database db_xxx \
  --filter '{"property":"Status","select":{"does_not_equal":"已完成"}}'

# 查询今日到期的任务
./scripts/notion-query-db.sh --database db_xxx \
  --filter '{"property":"Deadline","date":{"equals":"2026-05-17"}}'
```

#### 2. 创建记录

```bash
# 创建项目记录
./scripts/notion-create-page.sh --database db_xxx \
  --title "新项目A" \
  --content "项目描述和背景"

# 创建会议记录
./scripts/notion-create-page.sh --parent page_xxx \
  --title "周会-2026-05-17" \
  --content "会议纪要和行动项"
```

#### 3. 更新状态

```bash
# 更新任务状态
./scripts/notion-update-db.sh --page page_xxx --status "已完成"

# 批量更新（通过脚本循环）
for page_id in page_1 page_2 page_3; do
  ./scripts/notion-update-db.sh --page "$page_id" --status "进行中"
done
```

### Notion MCP 工具

配置 MCP 后，Agent 可以直接使用以下工具：

```
query-data-source        # 查询数据库
create-a-data-source     # 创建数据库
update-a-data-source     # 更新数据库 schema
post-page                # 创建页面
patch-page               # 更新页面
get-page                 # 读取页面
post-search              # 搜索内容
get-block-children       # 读取块内容
post-comment             # 添加评论
```

### 数据库设计建议

#### 项目排期表

| 属性 | 类型 | 说明 |
|---|---|---|
| Name | Title | 项目名称 |
| Status | Select | 未开始 / 进行中 / 已完成 / 已暂停 |
| Priority | Select | 高 / 中 / 低 |
| Deadline | Date | 截止日期 |
| Owner | Person | 负责人 |
| Tags | Multi-select | 标签 |
| Progress | Number | 进度百分比 |
| COO Notes | Rich Text | COO 备注 |

#### 任务协同表

| 属性 | 类型 | 说明 |
|---|---|---|
| Name | Title | 任务名称 |
| Status | Select | 待办 / 进行中 / 已完成 |
| Priority | Select | 高 / 中 / 低 |
| Deadline | Date | 截止日期 |
| Assignee | Person | 执行人 |
| Project | Relation | 关联项目 |
| Source | Select | 会议 / 消息 / 文档 |

#### 内容管理表

| 属性 | 类型 | 说明 |
|---|---|---|
| Name | Title | 内容标题 |
| Type | Select | 文章 / 视频 / 播客 / 演讲 |
| Status | Select | 选题 / 撰写中 / 待发布 / 已发布 |
| Platform | Multi-select | 公众号 / 小红书 / X / 即刻 |
| Publish Date | Date | 发布日期 |
| Performance | Number | 数据表现 |

---

## Obsidian

### 适用场景

- 个人知识管理，本地优先
- Markdown 原生，完全控制数据
- 喜欢双向链接和图谱视图

### 核心工作流

#### 1. 每日复盘

```bash
# 扫描 Vault 中的今日修改
./scripts/obsidian-scan-daily.sh

# 查询未完成任务
./scripts/obsidian-query-tasks.sh --status todo

# 查询逾期任务
./scripts/obsidian-query-tasks.sh --overdue

# 查询特定项目的任务
./scripts/obsidian-query-tasks.sh --tag 项目A
```

#### 2. 笔记管理

```bash
# 读取战略文档
./scripts/obsidian-read-note.sh "Strategy/战略方向.md"

# 读取笔记内容（不含 frontmatter）
./scripts/obsidian-read-note.sh "Projects/项目A.md" --content

# 追加会议记录
./scripts/obsidian-update-note.sh --file "Meetings/周会-2026-05-17.md" \
  --content "## 新进展\n- 完成了功能A\n- 启动了功能B" \
  --append

# 创建新笔记
./scripts/obsidian-create-note.sh --folder "Projects" \
  --title "项目B" \
  --content "## 背景\n\n## 目标\n\n## 行动项" \
  --tags "项目,新产品"
```

#### 3. 日记和周期笔记

```bash
# 打开今日日记
obsidian daily

# 追加到日记
obsidian daily:append content="## 今日复盘\n- 完成了X\n- 发现了Y"

# 创建周回顾
obsidian create name="周回顾-2026-W20" content="## 本周成就\n\n## 下周计划"
```

### Obsidian CLI 常用命令

```bash
# 日记操作
obsidian daily                          # 打开/创建今日日记
obsidian daily:append content="..."     # 追加内容到日记

# 文件 CRUD
obsidian create name="标题" content="..."   # 创建笔记
obsidian read file="文件名"                 # 读取笔记
obsidian append file="文件名" content="..." # 追加内容
obsidian rename file="旧名" newName="新名"   # 重命名

# 搜索
obsidian search query="关键词"              # 路径搜索
obsidian search:context query="关键词"      # 带上下文的深度搜索

# 插件管理
obsidian plugin:reload id=my-plugin       # 重载插件
obsidian plugin:enable id=my-plugin       # 启用插件
```

### Vault 目录结构

```
Vault/
├── 00-Daily/                    # 每日日记和复盘
│   ├── 2026-05-17.md
│   └── 2026-05-18.md
├── 01-Projects/                 # 项目排期表
│   ├── 项目A.md
│   └── 项目B.md
├── 02-Tasks/                    # 任务协同表
│   ├── 任务A.md
│   └── 任务B.md
├── 03-Customers/                # 客户管理
│   ├── 客户A.md
│   └── 客户B.md
├── 04-Content/                  # 内容管理
│   ├── 文章选题.md
│   └── 视频脚本.md
├── 05-Intelligence/             # 情报与机会
│   ├── 行业趋势.md
│   └── 竞品分析.md
├── 06-Meetings/                 # 会议记录
│   ├── 周会-2026-05-17.md
│   └── 1对1-2026-05-18.md
├── 07-Services/                 # 服务交付
│   ├── SOP模板.md
│   └── 服务说明书.md
├── 08-Strategy/                 # 战略文档
│   ├── 战略方向.md
│   ├── CEO工作原则.md
│   └── 业务模型.md
└── 99-Templates/                # 模板
    ├── 项目模板.md
    ├── 会议模板.md
    └── 日报模板.md
```

### Frontmatter 规范

```yaml
---
id: project_001
name: 项目A
status: 进行中
priority: 高
deadline: 2026-06-01
tags: [项目, 产品迭代]
owner: 张三
created: 2026-05-17
updated: 2026-05-18
coo_notes: "需要关注进度"
---
```

### 推荐插件

| 插件 | 用途 |
|---|---|
| Dataview | 数据库查询，替代多维表格 |
| Tasks | 任务管理，支持筛选和统计 |
| Templater | 模板系统，自动化日报生成 |
| Periodic Notes | 周期笔记，自动创建日报/周报 |
| Calendar | 日历视图，快速跳转日记 |
| Graph Analysis | 图谱分析，发现知识关联 |

---

## 平台混用

### 场景：飞书 + Notion + Obsidian

```json
{
  "platform": {
    "primary": "feishu",
    "document_storage": "obsidian",
    "database": "notion",
    "calendar": "feishu",
    "meeting_notes": "obsidian"
  }
}
```

**分工**：
- **飞书**：日历、会议、IM、团队沟通
- **Notion**：项目数据库、客户管理、内容排期
- **Obsidian**：个人笔记、战略文档、知识沉淀

**数据流**：
1. 会议在飞书进行，会议纪要自动同步到 Obsidian
2. 项目进展在 Notion 更新，Obsidian 通过 Dataview 引用
3. 每日复盘扫描三个平台，生成统一日报

### 场景：Notion + Obsidian

```json
{
  "platform": {
    "primary": "notion",
    "document_storage": "obsidian",
    "database": "notion"
  }
}
```

**分工**：
- **Notion**：数据库、协作、进度跟踪
- **Obsidian**：深度思考、知识网络、个人笔记

**数据流**：
1. 项目数据在 Notion 管理
2. 深度分析和思考在 Obsidian 记录
3. 通过脚本双向同步关键信息

---

## 常见问题

### Q: 三个平台如何选择？

**选飞书**：
- 团队在中国
- 需要日历、会议、IM 一体化
- 权限管理严格

**选 Notion**：
- 团队在海外
- 喜欢数据库视图
- 需要灵活的页面结构

**选 Obsidian**：
- 个人使用为主
- 重视数据隐私
- 喜欢 Markdown 和双向链接

### Q: 可以同时使用多个平台吗？

可以。Agent COO 支持平台混用模式：
- 文档用 Obsidian（本地控制）
- 数据库用 Notion（强大视图）
- 日历用飞书（团队同步）

### Q: MCP 和脚本有什么区别？

| 方式 | 优点 | 缺点 |
|---|---|---|
| MCP | Agent 直接调用，语义化 | 需要配置 MCP 客户端 |
| 脚本 | 独立运行，不依赖 Agent | 需要手动执行 |

**建议**：日常使用 MCP，批量操作或自动化场景用脚本。

### Q: 数据如何迁移？

**飞书 → Notion**：
1. 飞书多维表格导出为 CSV
2. Notion 导入 CSV 为数据库

**Notion → Obsidian**：
1. Notion 导出为 Markdown
2. 复制到 Obsidian Vault

**Obsidian → 飞书**：
1. Obsidian 笔记复制到飞书文档
2. 手动整理为多维表格

### Q: 定时任务如何设置？

**macOS/Linux**：
```bash
# 编辑 crontab
crontab -e

# 每天 23:00 执行复盘
0 23 * * * cd /path/to/COO_Agent_Skill && ./scripts/coo-daily-review.sh
```

**Windows**：
使用任务计划程序，设置每天定时运行脚本。

---

## 下一步

1. 选择你的主平台，运行 `./scripts/coo-onboarding.sh`
2. 配置 MCP（Notion）或 CLI（飞书/Obsidian）
3. 创建你的第一个项目或笔记
4. 运行 `/coo-daily-review` 测试每日复盘
