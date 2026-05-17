# Agent COO Skill

你的数字运营合伙人。主动扫描工作上下文、维护业务系统、沉淀知识资产、对齐战略方向。

可在 Claude Code、Codex、Cursor、Trae 等任意支持 skill / system prompt 的 Agent 上使用。

## 核心理念

创业之后找的第一个人是谁？COO。

COO 也就是运营合伙人，是对公司至关重要，又特别难招的一个人。但如果，你让 Agent 成为你的 COO，那你和 ta 的协同方式会完全不同。

Agent COO 不是执行者，而是运营合伙人。核心职责：

1. **维护业务系统**：让创业者的业务系统持续运转
2. **沉淀知识资产**：让知识资产持续沉淀
3. **对齐战略方向**：让战略方向持续对齐

## 安装

### 通用安装方式（适用于 Codex / Claude Code）

```bash
npx skills add Ivor-NCUT/COO_Agent_Skill
```

### 手动安装

将本仓库的 `skills/` 目录复制到你的 Agent skills 目录：

- Codex: `~/.codex/skills/`
- Claude Code: `~/.claude/skills/`

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

`scripts/` 目录包含飞书 CLI 相关的辅助脚本：

| 脚本 | 用途 |
|---|---|
| `lark-onboarding.sh` | 飞书 CLI 初始化配置向导 |
| `lark-scan-daily.sh` | 每日扫描工作上下文 |
| `lark-update-sheet.sh` | 更新飞书多维表格 |
| `lark-create-doc.sh` | 创建飞书文档 |
| `coo-daily-review.sh` | 每日复盘主编排脚本 |

## 六维分析框架

Skill 迭代的核心工具。对比修改前后版本时，从六个维度拆解：

1. **开头方式**：陈述事实 vs 制造冲突
2. **概念处理**：大词 vs 具体定义
3. **抽象 vs 具体**：抽象概括 vs 具体案例
4. **叙事视角**：第三方观察 vs 第一人称亲历
5. **情绪节奏**：平铺直叙 vs 冲突→解决→升华
6. **结尾力度**：描述状态 vs 召唤行动

## 许可证

本项目采用 MIT 许可证。
