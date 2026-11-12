# three.cj-project-guide

three.cj 项目的 RAG 知识库 SKILL。把项目的全部 markdown 文档（API 文档、参考手册、项目导览等）压缩进单文件 SQLite，并提供命令行检索工具——**易于分享、重建和检索查阅**。

## 目录结构

```
three.cj-project-guide/
├── SKILL.md                      # 供 Agent/模型读取的引导（渐进披露检索规范）
├── README.md                     # 本文件：工程说明
├── scripts/
│   ├── search_docs.py            # 检索入口：matches / indexes / leaves 三种视图
│   ├── build_kb.py               # 重建知识库、漂移检测
│   └── kb_engine/                # 引擎核心：schema / tokenizer / backend
└── references/
    └── knowledge.sqlite3         # 知识库（正文 zlib 压缩 + 中英文路由索引）
```

## 支持的能力

| 能力 | 命令示例 |
|---|---|
| 批量摘要查询（多符号一次进程） | `python scripts/search_docs.py --query "Vector3 addScalar" --query "矩阵 求逆" --max-results 3` |
| 符号名精确定位 | `python scripts/search_docs.py --query "Box3" --max-results 1` |
| 浏览包索引树 | `python scripts/search_docs.py --node three.utils.memory --view indexes` |
| 浏览域索引 | `python scripts/search_docs.py --node domain:references --view indexes` |
| 读取叶子正文（签名/参数/示例） | `python scripts/search_docs.py --node three.core.math/class:Vector3 --view leaves` |
| 尺寸预估 | `python scripts/search_docs.py --node three.core.math --view leaves --estimate` |
| 域/包/类型过滤 | `--domain api|references|guide`、`--package three.core.math`、`--kind class` |
| 输出保护 | `--max-pages 20`、`--max-chars 24000`（超限拒绝，`--force` 显式放开） |

`.skills/three.cj-project-guide/SKILL.md` 是检索规范与工作流的正本；本 README 面向工程维护与移植。

## 依赖环境

- **Python 3.8+**（仅标准库：`sqlite3` / `zlib` / `gzip` / `json` / `re` / `argparse`），无第三方包。
- Windows PowerShell / 任意 shell 均可运行，无需激活虚拟环境。
- 中文检索依赖系统默认 UTF-8（脚本已对 stdout/stderr 做 UTF-8 重配置；Linux/macOS 原生 UTF-8）。

## 重新生成知识库

知识库由项目目录下的全部 `*.md` 扫描生成。项目文档变更后执行：

```bash
# 默认 --source 为 skill 的上级上级目录（即 three.cj 工程根）
python scripts/build_kb.py --source C:\workspace\Web\24w\three.cj\three.cj

# 只检测漂移，不写库
python scripts/build_kb.py --source C:\workspace\Web\24w\three.cj\three.cj --check
```

建库规则：
- 覆盖 `doc/api/zh-cn/**`、`doc/references/**`、根/`test`/`captures` 等全部 md；
- **排除** `doc/api/en`（zh-cn 的冗余副本）、`target`、`.skills`、`.git`、`.github`、`node_modules`、`__pycache__` 等目录；
- 正文 zlib 压缩入库，标题/摘要/包名/正文词频建成路由索引（含中文单字 + bigram、英文驼峰拆分）。

## 分享与移植

1. 整个 `three.cj-project-guide` 目录可整体拷贝到其他环境，`knowledge.sqlite3` 单文件即知识本体。
2. 目标环境若工程结构相同，直接可用；工程根不同时，用 `build_kb.py --source <目标根>` 重建。
3. 知识库文件头带 `application_id` 与 `schema_version` 校验，`kb_engine` 与库版本不匹配时会明确报错，不会读坏数据。

## 检索细节备忘

- `--node` 可解析：精确 id（`three.core.math/class:Box3`）、相对路径、标题、包名（`three.core.math`，整包）、`domain:xxx` 或 `pkg:xxx`。
- 无结果时先缩短查询、改用精确符号、加 `--domain` 过滤；不要枚举知识库文件。
- 索引词构建与查询共用同一分词算法（`kb_engine/tokenizer.py`），保证命中一致。