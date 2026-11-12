---
name: three.cj-project-guide
description: "提供 three.cj 项目的完备知识库及辅助工具，覆盖 three.cj 特性、结构、API、工具链、概况等全类型信息，渐进披露、按需查询，助你高效学习 three.cj 知识、完成 three.cj 项目开发。"
---

# three.cj Project Guide

本 SKILL 内置 three.cj 项目的 RAG 知识库：全量 markdown（`doc/api` API 文档、`doc/references` 参考手册、`README`/`CHANGELOG`/`test` 等向导文档）已压缩进单文件 SQLite（`references/knowledge.sqlite3`），并附带中英文路由索引。知识库采用“摘要命中 → 包索引 / 叶子正文”的渐进披露结构：先读能作出决定的最小信息，再实现和验证。

## 必须遵守

- 把**当前已加载的 `SKILL.md` 所在目录**记为 `<skill-root>`，按需调用 `<skill-root>/scripts/search_docs.py`，不要绕过脚本直接读取知识库文件。
- 第一次知识访问使用一个脚本进程中的批量查询，每个独立符号或意图各写一个 `--query`；只有必须共同出现的“类型 + 操作”才放在同一查询中。摘要足够时停止，不为简单成员再展开正文。
- 域名（`--domain`）与包过滤（`--package`）能显著缩小候选，遇到噪音结果优先加过滤器，不要枚举知识库文件。
- three.cj 的 API 文档按项目工作语言以中文（`zh-cn`）为主，`doc/api/en` 为冗余副本，不建索引；冲突以 `src/`、`test/` 源码实现为准。

## 工作流

1. 读取任务、清单、相关源码和测试，确认涉及的包（如 `three.core.math`）、类/函数符号、文档域（`api` / `references` / `guide`）及验收命令。
2. 汇总真正不确定的符号和概念：明确目标用批量 `--query`；不熟悉的领域先 `--node <包名> --view indexes` 浏览该包成员。
3. 根据结果中的标题、摘要和命中表项编码；需要签名、参数、边界或完整示例时，把选定的符号（先看命中行给出的 id，如 `three.core.math/class:Vector3`）改为一次 `--view leaves` 读取正文。
4. 无结果时依次：缩短查询、改用精确符号名、限定 `--domain api`，或从最窄相关包索引浏览；不要枚举知识库文件。
5. 知识库未覆盖（或与源码不一致）时，直接读取 `src/`、`test/` 源码作证据，并在交付中指出知识缺口，不凭其他语言经验猜写 API。
6. 执行任务要求的 build/test/run 与专用工具门禁；完成后重新执行完整验收。

## 检索

下列命令从 `<skill-root>` 执行；在项目目录中调用时使用脚本绝对路径。

### 1. 批量摘要查询

```text
python scripts/search_docs.py --query "Vector3 addScalar" --query "矩阵 求逆" --query "Mesh clone" --max-results 3
```

每个查询独立排序，跨查询重复页只完整输出一次。默认每项返回 5 个候选；精确符号可用 `--max-results 1`，歧义时再扩大。可用 `--domain api|references|guide`、`--package three.core.math`、`--kind class|interface|function|…` 限域。不要把互不相关的符号塞进一个长查询。

### 2. 浏览索引树

```text
python scripts/search_docs.py --node three.utils.memory --view indexes
python scripts/search_docs.py --node domain:references --view indexes --max-pages 30
```

`indexes` 返回解析节点下的全部成员页（readme + 类/接口/枚举/结构体/函数/宏/类型别名/变量与常量）。`--node` 可接受：精确 id（如 `three.core.math/class:Box3`）、相对路径（`doc/api/zh-cn/three.core.math/类/Box3.md`）、标题、包名（`three.core.math`，列出整包）或 `domain:xxx`。

### 3. 批量读取叶子

```text
python scripts/search_docs.py --query "Vector3 addScalar" --query "three.utils.memory/function-list" --view leaves
python scripts/search_docs.py --node three.rendering/class:ThreeRenderer --view leaves
```

`leaves` 输出选中页的完整正文（含签名、参数、返回、示例）。默认受 `--max-pages 20` 与 `--max-chars 24000` 保护，超限会被拒绝——先用 `--node` 锁定单个符号，必要时用 `--force` 显式放开；`--estimate` 可先查看展开规模。

### 4. 无结果与知识缺口

无结果时依次缩短查询、用仓颉精确符号、添加 `--domain`/`--package`，或从最窄相关包索引选择叶子；不要枚举知识库文件。知识库缺内容时以源码为最终证据（见“证据与验证”）。

## 证据与验证

冲突时依次采用：`src/`、`test/` 源码实现、`doc/` 文档正文、模型记忆。精确 API 同时确认包名、签名、参数、返回值与约束，不套用其他语言或版本的相似写法。

- 类型、重载、依赖与链接以 `cjpm build` 的实际产物为准。
- 文档由 `scripts/build_kb.py` 从 markdown 生成，构建于固定源码快照；若怀疑仓库有增量变更，先执行 `--check` 判读漂移。

## 维护与分享

- **重建**（项目 markdown 有变更后）：`python scripts/build_kb.py --source <three.cj 根目录>`；漂移检测：`python scripts/build_kb.py --source <根目录> --check`。
- **依赖**：仅 Python 3 标准库（sqlite3/zlib/gzip/json），无第三方包。
- **分享**：把整个 `three.cj-project-guide` 目录（含 `SKILL.md`、`scripts/`、`references/knowledge.sqlite3`）拷到目标环境即可，知识库单文件、可脱离源码重建。