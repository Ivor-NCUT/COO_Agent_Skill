# 核心理念
创业之后找的第一个人是谁？COO

COO 也就是运营合伙人，是对公司至关重要，又特别难招的一个人。

这个人需要有很前面的能力，比如：
ta 在战略上需要和你能够有共鸣同时身兼多职；
需要补位很多公司暂时没招到的职能；
需要做很多的管理工作，确立团队协作的各种机制，并且搭建出对应的业务系统；

还等甘愿做很多创始人不想做的脏活累活，比如维护数十张多维表格。

但是这个角色对公司是至关重要的，ta 几乎直接决定了早期团队的速度和执行力。

大家都说，要把 Agent 变成你的数字员工或实习生，那便意味着，你需要花非常多的时间检查给 ta 足够清晰的需求，而这其实是一件比大家想象中花很多时间的人。

因为有的时候业务需求本身就是模糊的，这和提示词技巧无关，创业就是这样。

但如果，你让 Agent 成为你的 COO，那你和 ta 的协同方式会完全不同。

我基于对这个方向的探索，写了一个 Agent skill；

ta 的 Demo 版本是基于 Agent skill + 定时任务 + 飞书 cli 来实现的。

首先，我们有一个飞书知识库，这个知识库里，有公司经营常见的文档和业务管理系统，比如表格有项目排期表、任务协同表、CRM；文档有服务交付说明书、会议记录合集等。

以前搭建这套系统很难，但是维护这套系统更难。

所以，我们通过定时任务 + Agent skill 的方式，让我们的 Codex 或别的 Agent，能够每天晚上定时查看完当天所有的会议记录、文档创建与编辑记录、消息记录，从而获得工作当天的上下文，并且将其整理到管理系统中。

这还不够，上述工作实习生也能做，COO 还需要更主动一些：

比如，ta 会告诉你：

1. 你昨天做的某个工作，应该以后还会重复，可以写成一个 Agent skill，来减少重复劳动。

2. ta 会发觉你在和某个合作方开会的过程中，分享了一些特别精彩的洞察，帮你记录到你的选题排期表里，发到社媒上，一定成为爆款。

3. ta 会检查你所有承诺过、记录过，但没有执行的遗留待办，检查自己的 memory 和已装好的 skill、插件、MCP 和 cli，思考有没有可以直接帮你做掉的。

4. ta 会查看你的文档编辑记录和会议记录时，会发觉你说出或写下的某个观点，和战略文档上得大方向存在很多的逻辑冲突，会主动问你是不是战略要调整。

这才是 COO，这才是 Agent 该为每个创业者做的事情。


## 三平台支持

Agent COO 支持飞书、Notion、Obsidian 三个平台，用户 onboarding 时选择主平台：

| 平台 | 技术方案 | 适用场景 |
|---|---|---|
| **飞书** | lark-cli + lark-* skills | 中国企业、已有飞书生态、需要日历/会议/IM 集成 |
| **Notion** | Notion MCP Remote (OAuth) | 海外团队、喜欢数据库视图、需要灵活页面结构 |
| **Obsidian** | Obsidian CLI (v1.12+) + MCP 搜索增强 | 个人知识管理、本地优先、Markdown 原生 |

### 平台选择建议

- **选飞书**：如果你在中国，团队用飞书，需要日历、会议、IM 一体化
- **选 Notion**：如果你在海外，喜欢数据库视图，需要灵活的页面结构
- **选 Obsidian**：如果你重视本地控制，喜欢 Markdown，以个人知识管理为主

## 安装

### 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/Ivor-NCUT/COO_Agent_Skill.git
cd COO_Agent_Skill

# 2. 运行 onboarding（选择平台）
./scripts/coo-onboarding.sh

# 3. 安装 skill
npx skills add Ivor-NCUT/COO_Agent_Skill
```

### 手动安装

将本仓库的 `skills/` 目录复制到你的 Agent skills 目录：

- Codex: `~/.codex/skills/`
- Claude Code: `~/.claude/skills/`

### 平台特定安装

#### 飞书

```bash
# 安装飞书 CLI
npm install -g @larksuiteoapi/lark-cli

# 登录
lark-cli auth login

# 运行飞书 onboarding
./scripts/lark-onboarding.sh
```

#### Notion

```bash
# 方式 1: Notion MCP Remote（推荐）
# 在 Notion 设置 → Connections → MCP 中授权

# 方式 2: Local MCP Server
# 配置 MCP 客户端:
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "ntn_****"
      }
    }
  }
}

# 运行 Notion onboarding
./scripts/notion-onboarding.sh
```

#### Obsidian

```bash
# 确保 Obsidian >= v1.12（内置 CLI）
# 运行 Obsidian onboarding
./scripts/obsidian-onboarding.sh
```

## 工具箱

### COO 主入口

| Skill | 做什么 |
|---|---|
| `/coo` | 主入口，自动路由到对的子 skill |

### 每日工作流

| Skill | 做什么 |
|---|---|
| `/coo-daily-review` | 每日复盘。扫描上下文 + 系统维护 + 知识沉淀 + 待办清理 + 战略对齐 |
| `/coo-todo-cleanup` | 待办清理。扫描承诺、检查逾期、识别可自动完成的待办 |
| `/coo-knowledge-ingestion` | 知识沉淀。识别重复工作、捕捉洞察、建议写成 Skill/SOP |
| `/coo-strategy-alignment` | 战略对齐。对比当日工作与战略文档，发现逻辑冲突 |

### Skill 迭代

| Skill | 做什么 |
|---|---|
| `/coo-skill-iteration` | Skill 迭代。版本对比 + 六维分析框架 + 优化建议 |

### 工具路径图

```
每日工作
  ↓
coo-daily-review（扫描 + 四类维护动作）
  ↓
├── 发现重复工作 → coo-knowledge-ingestion（建议写成 Skill/SOP）
├── 发现精彩洞察 → coo-knowledge-ingestion（建议做成选题）
├── 发现待办问题 → coo-todo-cleanup（清理逾期、自动完成）
└── 发现战略冲突 → coo-strategy-alignment（对齐检查）

Skill 使用
  ↓
coo-skill-iteration（三轮迭代）
  ↓
├── 第一轮：对话中总结 bad case
├── 第二轮：版本对比 + 六维分析框架
└── 第三轮：外部输入学习
```

## 知识库

Agent COO 的知识库是完全开放的。你不需要安装整套 Skill 才能用——可以只拿走你需要的部分。

### 目录结构

```
知识库/
├── 原子库/                    # 结构化知识数据库
│   ├── atoms.jsonl            # 知识原子（全量）
│   └── README.md              # 字段说明
│
├── Skill知识包/               # 提炼后的方法论文档
│   ├── daily-review_工作流与日报模板.md
│   ├── skill-iteration_六维分析框架.md
│   ├── strategy-alignment_战略对齐检查清单.md
│   ├── todo-cleanup_承诺识别模式.md
│   └── knowledge-ingestion_沉淀判断标准.md
│
└── 方法论/                    # 核心理念文档
    └── Agent-COO-核心理念.md
```

### 原子库是什么

每个知识原子是一条从工作实践中提炼的知识点，结构化为 JSON：

```json
{
  "id": "coo_001",
  "knowledge": "Agent COO 的核心不是执行任务，而是维护系统...",
  "original": "AI 每次执行，不只完成任务，还要维护系统...",
  "source": "Agent COO 核心原则",
  "date": "2026-05-17",
  "topics": ["系统维护", "知识沉淀", "Skill迭代"],
  "skills": ["coo", "coo-daily-review"],
  "type": "principle",
  "confidence": "high"
}
```

**字段说明：**

| 字段 | 说明 |
|---|---|
| `knowledge` | 提炼后的知识点 |
| `original` | 原始表述 |
| `topics` | 主题分类（可多选） |
| `skills` | 关联的 Skill |
| `type` | principle / method / case / anti-pattern / insight / tool |
| `confidence` | high / medium / low |

### 怎么在你自己的项目里用

**场景 1：给你的 AI 加运营能力**

把 `知识库/Skill知识包/daily-review_工作流与日报模板.md` 的内容粘贴到你的 system prompt 里。

**场景 2：做 RAG 知识库**

把 `知识库/原子库/atoms.jsonl` 导入你的向量数据库。结构化知识点，自带主题标签，天然适合检索。

**场景 3：学习 Agent COO 方法论**

按 `topics` 过滤，只看你感兴趣的领域。

## Scripts

`scripts/` 目录包含各平台的辅助脚本：

### 统一 Onboarding

| 脚本 | 用途 |
|---|---|
| `coo-onboarding.sh` | 统一入口，引导用户选择平台（飞书/Notion/Obsidian） |

### 飞书

| 脚本 | 用途 |
|---|---|
| `lark-onboarding.sh` | 飞书 CLI 初始化配置向导 |
| `lark-scan-daily.sh` | 每日扫描工作上下文 |
| `lark-update-sheet.sh` | 更新飞书多维表格 |
| `lark-create-doc.sh` | 创建飞书文档 |
| `coo-daily-review.sh` | 每日复盘主编排脚本 |

### Notion

| 脚本 | 用途 |
|---|---|
| `notion-onboarding.sh` | Notion MCP 配置向导 |
| `notion-scan-daily.sh` | 每日扫描 Notion 工作区 |
| `notion-create-page.sh` | 创建 Notion 页面/数据库记录 |
| `notion-update-db.sh` | 更新数据库记录状态 |
| `notion-query-db.sh` | 查询数据库（支持过滤和排序） |

### Obsidian

| 脚本 | 用途 |
|---|---|
| `obsidian-onboarding.sh` | Obsidian CLI 配置向导 |
| `obsidian-scan-daily.sh` | 每日扫描 Vault |
| `obsidian-create-note.sh` | 创建结构化笔记 |

## 六维分析框架

Skill 迭代的核心工具。对比修改前后版本时，从六个维度拆解：

1. **开头方式**：陈述事实 vs 制造冲突
2. **概念处理**：大词 vs 具体定义
3. **抽象 vs 具体**：抽象概括 vs 具体案例
4. **叙事视角**：第三方观察 vs 第一人称亲历
5. **情绪节奏**：平铺直叙 vs 冲突→解决→升华
6. **结尾力度**：描述状态 vs 召唤行动

## 平台混用（进阶）

Agent COO 支持分功能使用不同平台：

```json
{
  "platform": {
    "primary": "obsidian",
    "document_storage": "obsidian",
    "database": "notion",
    "calendar": "feishu"
  }
}
```

例如：
- 文档和笔记用 Obsidian（Markdown 原生）
- 数据库用 Notion（强大的视图和筛选）
- 日历和会议用飞书（团队已在使用）

## 技术架构

```
Agent COO
├── skills/
│   ├── coo/                    # 主入口（路由 + 平台适配）
│   ├── coo-daily-review/       # 每日复盘
│   ├── coo-todo-cleanup/       # 待办清理
│   ├── coo-knowledge-ingestion/ # 知识沉淀
│   ├── coo-strategy-alignment/  # 战略对齐
│   └── coo-skill-iteration/    # Skill 迭代
├── scripts/
│   ├── coo-onboarding.sh       # 统一 onboarding
│   ├── lark-*.sh              # 飞书脚本
│   ├── notion-*.sh            # Notion 脚本
│   └── obsidian-*.sh          # Obsidian 脚本
└── 知识库/
    ├── 原子库/
    ├── Skill知识包/
    └── 方法论/
```

## 路线图

- [x] 飞书生态支持（lark-cli）
- [x] Notion MCP 支持
- [x] Obsidian CLI 支持
- [x] 统一 onboarding 流程
- [ ] 多平台混用配置
- [ ] 定时任务自动执行
- [ ] 更多平台（Google Workspace、钉钉等）

## 贡献

欢迎提交 Issue 和 PR。特别是：
- 新的平台适配
- 更好的 onboarding 体验
- 更多的知识原子
- 六维分析框架的 case 补充

## 许可证

本项目采用 MIT 许可证。
