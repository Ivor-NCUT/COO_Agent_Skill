# 原子库说明

COO Agent Skill 的原子库，存储从工作实践中提炼的结构化知识原子。

## 字段说明

| 字段 | 说明 |
|---|---|
| `id` | 原子唯一标识 |
| `knowledge` | 提炼后的知识点 |
| `original` | 原始表述（上下文） |
| `source` | 来源 |
| `date` | 日期 |
| `topics` | 主题分类（可多选） |
| `skills` | 关联的 Skill |
| `type` | principle / method / case / anti-pattern / insight / tool |
| `confidence` | high / medium / low |

## 主题分类

- 系统维护
- 知识沉淀
- Skill迭代
- 战略对齐
- 待办清理
- 日报
- Build in Public
- 方法论
- 写作
- 平台无关
- 冲突识别
- 承诺管理
- Agent COO
- 协同方式

## 使用场景

1. **RAG 知识库**：导入向量数据库，支持语义检索
2. **Skill 增强**：Skill 运行时读取关联原子作为深度参考
3. **学习研究**：按主题过滤，快速了解 Agent COO 方法论
