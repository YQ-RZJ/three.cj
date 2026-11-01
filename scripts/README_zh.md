# 辅助脚本

three.cj 工程辅助脚本（Python 3.9+，无第三方依赖，仅使用标准库）。

## 脚本一览

| 脚本 | 用途 | 适用场景 |
|------|------|----------|
| [`gen_exclude_rsp.py`](./gen_exclude_rsp.py) | 生成跨平台链接符号控制文件：Windows 用 `libs/exclude.rsp`（ld.lld response file）、Linux/OHOS 用 `libs/symbols_elf.map`（`--version-script`） | 第三方依赖增减/升级、C 库重编译后刷新链接符号列表 |
| [`check_so_deps.py`](./check_so_deps.py) | 递归分析 `.so` 的 `DT_NEEDED` 依赖链，输出 Markdown | 排查 OHOS HAP / Linux 跨平台 SDK 的 so 加载失败 |
| [`add_license_header.py`](./add_license_header.py) | 为 `src/**/*.cj` 的文件首 `/**...*/` 文档注释块插入（或新建）`@LICENSE` 版权头，幂等可重复执行 | 首次引入 LICENSE 头、或新增源文件后补齐版权注释 |
| [`generate_structure.py`](./generate_structure.py) | 生成目录的文件清单或树状层级 Markdown | 生成源码目录结构文档 |
| [`tracy_receiver.py`](./tracy_receiver.py) | 无 GUI 的 Tracy 协议接收端：主动连接被测进程，落盘原始流/解压流/结构化事件/元数据，并直接产出热点统计（调用次数、耗时、P50/P95/P99） | 无 Tracy GUI 环境下采集剖析数据、CI 性能基线、离线重放复现问题 |
| [`tracy_queue_table.py`](./tracy_queue_table.py) | Tracy 协议 QueueType 表（132 项负载长度、字符串类型、时间戳基准等），由上游 `TracyQueue.hpp` 转录 | 编写/校验协议解析器时作为唯一查表来源 |
| [`tracy_hotspots.py`](./tracy_hotspots.py) | 格式化 `stats.json`，打印帧统计与热点 Top N（调用次数/总耗时/均值/P50/P95） | 采集结束后快速看热点表 |
| [`tracy_selftime.py`](./tracy_selftime.py) | 按 zone 还原嵌套关系，输出调用次数 / 总耗时 / **自耗时**（扣除子区间）；客户端 zone 名失效时用源码行号兜底还原 | 定位引擎自身开销（区分"这层自己慢"与"子层慢"）、跨采集对比热点 |

所有脚本均支持 `-h` / `--help` 查看完整参数（`tracy_queue_table.py` 为被导入的常量表模块，不提供命令行入口）。

---

## gen_exclude_rsp.py

### 背景

cjpm 在 Windows（MinGW）下以 `--export-all-symbols` 把 three 的每个仓颉子包链接为独立 dll。
第三方仓颉 FFI 包（bgfx4cj / sdl4cj / jolt4cj 等）以静态归档链入各 dll 后，其 mangled 符号
被自动导出；下游 dll 链接时同一符号既从上游 dll 导入库解析为导入 thunk、又从本地静态归档
得到定义，ld.lld 报 `symbol was replaced`。C++ 静态库的 `_Z*` 内部符号同理。

MinGW flavor 的 ld.lld 不支持 `--exclude-libs` / `--version-script`，只支持
`--exclude-symbols <符号列表>` 与 `@response 文件`。本脚本扫描实际归档，一次运行同时
生成两个语义同构的平台控制文件：

1. `libs/exclude.rsp`（Windows MinGW ld.lld），内容包括：
   - `--exclude-symbols`：第三方仓颉 mangled 符号（`_C` 开头且含包名）+ 全部 C++ `_Z*` 符号，
     禁止自动导出，消除 `symbol was replaced`；
   - `-u <C API 符号>`：仓颉 FFI 归档的未定义引用 ∩ C 库归档中定义的非 `_C`/`_Z` 符号，
     强制拓扑最早的 dll 全量拉入并导出 C API（`bgfx_*` / `SDL_*` / `JPH_*` / `al*` / `ig*` /
     `lua_*` 等），下游 dll 一律经 IAT 解析到同一定义，保证 bgfx `g_ctx`、OpenAL current
     context 等 C 库全局状态跨 dll 单例共享。
2. `libs/symbols_elf.map`（Linux / OHOS，ld.lld 与 GNU ld 的 `--version-script`）：
   - `local: _Z*; _C*<第三方包名>*;` —— 第三方仓颉符号与 C++ 内部符号不进入动态符号表，
     各 `.so` 使用静态归档本地副本（ELF 链接虽不像 MinGW 报 `symbol was replaced`，
     但重复导出会造成代码/包初始化 `_CGP` 多副本，依赖运行时 interposition 收敛有风险）；
   - three 自身符号（`_C*three*`）与 C API 不在 local 列表，保持全局导出，下游 `.so`
     经动态绑定（`UND`）解析到同一定义，C 库全局状态同样单例。

> 注意：ld.lld 的 version script 解析器不支持 `/* */` 注释，map 文件只写纯语法；
> `--exclude-libs,ALL` 方案会把 C API 也本地化、破坏单例，不能使用。
> macOS（ld64）为两阶段命名空间，行为与 ELF/PE 不同，cjpm.toml 暂保持默认配置。

### 何时需要重新运行

- 第三方仓颉依赖增减或升级（`cjpm.toml` dependencies 变化，或 `cjpm update` 拉取新版
  bgfx4cj / jolt4cj / sdl4cj / ...）后；
- `libs/` 下 C/C++ 静态库重新编译 / 升级后；
- Windows 链接重新出现 `symbol was replaced` 或 `undefined symbol` 时。

> three 引擎自身源码变更**不需要**重新生成：three 自身符号（`_CN5three...`）不在排除列表中。

### 前提

先成功执行过一次 `cjpm build`（依赖包归档 `target/release/<pkg>/*.a` 已产出；即使链接阶段
失败，编译归档通常也已生成）。

### 用法

```bash
# 在 three/ 目录下：先构建产出归档，再生成符号控制文件（rsp + map），然后重新构建
cjpm build
python scripts/gen_exclude_rsp.py
cjpm build

# 只统计不写文件（核对符号数量）
python scripts/gen_exclude_rsp.py --dry-run
```

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--root` | 脚本上级目录（`three/`） | 引擎根目录 |
| `--target-dir` | `<root>/target/release` | cjpm 编译产物目录（仓颉包归档所在） |
| `--libs-dir` | `<root>/libs` | C/C++ 静态库目录 |
| `--nm` | PATH 中的 `nm`，否则回退到内置 MinGW 路径 | `nm` 可执行文件路径 |
| `--output` | `<libs>/exclude.rsp` | 输出 rsp 路径（Windows） |
| `--map-output` | `<libs>/symbols_elf.map` | 输出 version script 路径（Linux/OHOS） |
| `--dry-run` | 关 | 只打印统计，不写文件 |

> 交叉编译 aarch64-w64-mingw32 后，可传 `--target-dir` 指向 ARM64 产物目录、
> `--nm` 指向对应工具链的 nm，生成 ARM64 专属 rsp。

---

## check_so_deps.py

### 背景

排查 OHOS HAP / 跨平台 SDK 的 so 加载问题时，需要看清某个 `.so` 的完整 `DT_NEEDED`
依赖链（例如 `libSDL3.so` 依赖哪些系统库、`libsdl4cj.sdl.so` 依赖 `libSDL3.so` 的哪个
SONAME 别名），以及是否有依赖在打包目录中缺失（会导致运行时 `dlopen` 失败 /
module not found）。

脚本基于 `readelf -d` 递归展开依赖树，自动区分：

- **[缺失]**：依赖库在所有搜索目录中都找不到（且非系统库）；
- **[系统]**：属于 OHOS / Linux 系统库白名单（`libc.so`、`libEGL.so`、`libhilog_ndk.z.so`
  等），由系统提供，无需随包打包；
- **[循环]**：检测到 A → B → A 循环引用，挂占位节点后不再递归；
- 支持 SONAME 别名解析（真实文件名为 `libfoo.so.0` / `libfoo.so.0.1.2` 等形式）。

### 用法

```bash
python scripts/check_so_deps.py \
    --root entry/libs/arm64-v8a/libSDL3.so entry/libs/arm64-v8a/libsdl4cj.sdl.so \
    --search-dirs entry/libs/arm64-v8a libs-link \
    --output so_deps.md
```

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--root` | （必填） | 起始 so 文件，可传多个（空格分隔） |
| `--search-dirs` | （必填） | 依赖库搜索目录，可传多个，按序查找 |
| `--readelf` | PATH 中的 `llvm-readelf`/`readelf`，否则回退 DevEco SDK 路径 | readelf 可执行文件 |
| `--output` | `so_deps.md` | 输出 Markdown 路径 |
| `--max-depth` | `32` | 最大递归深度（防止意外深链） |

输出 Markdown 含两部分：依赖树（含 SONAME 标注与缺失/系统/循环标记）、缺失依赖汇总表
（缺失库名 → 被哪些库依赖）。

---

## add_license_header.py

为 `src/**/*.cj` 源码文件的文件首 `/**...*/` 文档注释块自动插入 `@LICENSE` 版权信息
（Apache 2.0 + Runtime Library Exception），保证 `@LICENSE` 位于文档注释的最前面。

行为规则：

- 文件首部已有 `/**...*/` 注释块：将 LICENSE 信息插入块内部最前面（`/**` 行之后、
  `@file` 等其它标签之前）；
- 文件首部没有注释块（如直接以 `package` 开头）：在文件最顶部新建只含 LICENSE 的注释块；
- **幂等**：注释块内已含 `@LICENSE` 则跳过，重复执行安全；
- 自动检测并保持原文件的行尾风格（CRLF/LF）与 BOM 状态，除插入行外不修改任何内容。

### 用法

```bash
# 处理 src/ 目录（默认根目录）
python scripts/add_license_header.py

# 显式指定根目录
python scripts/add_license_header.py --root src

# 只统计不写入
python scripts/add_license_header.py --dry-run
```

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--root` | `src` | 扫描根目录（递归处理所有 `.cj` 文件） |
| `--dry-run` | 关 | 只打印统计与变更文件清单，不写文件 |

---

## generate_structure.py

生成指定目录的文件清单（checkbox 形式）或树状层级图，写入 Markdown 文件。常用于生成源码
目录结构文档。

### 用法

```bash
# 生成 src/ 的文件清单（默认输出 File List.md）
python scripts/generate_structure.py --mode 1

# 生成 src/ 的树状层级（默认输出 Tree structure.md）
python scripts/generate_structure.py --mode tree

# 扫描其他目录并指定输出
python scripts/generate_structure.py --mode 2 --root D:/other/src -o structure.md
```

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--mode` | （必填） | `1`/`list`：文件清单（`- [ ]` 形式）；`2`/`tree`：树状层级（`├──`/`└──` 连接线） |
| `--root` | 脚本同级的 `../src`（即引擎 `src/`） | 要扫描的根目录 |
| `-o`, `--output` | 模式 1 → `File List.md`；模式 2 → `Tree structure.md` | 输出 Markdown 路径 |

---

## tracy_receiver.py

### 背景

Tracy GUI 需要人工交互查看数据，无法进入 CI 流水线。被测进程静态链接 `libtracyc.a` 后本身就是
Tracy 服务端并监听 TCP 端口，本脚本扮演 Tracy GUI/Worker 的角色**主动连接**被测进程，
按协议解析并把完整数据落盘，同时直接产出可读的热点统计。

协议事实来源（上游源码，已逐项核对）：

- `tracy/public/common/TracyProtocol.hpp` / `TracyQueue.hpp`
- `tracy/public/client/TracyProfiler.cpp/.hpp`
- `tracy/server/TracyWorker.cpp`

关键协议点：

| 环节 | 说明 |
|---|---|
| 握手 | 接收端先发 `"TracyPrf"` + `uint32(82)`，再读 1 字节 HandshakeStatus，再读 1170 字节 WelcomeMessage |
| 数据块 | `uint32 compressedSize` + compressed bytes；LZ4 有状态流，跨块共享 64KiB 字典，不能当独立 block 解压 |
| 时间戳 | 客户端写盘时对 TSC 差值做偏移改写（32 位事件减 `ProtocolOffset32Bit`、16 位事件减 `ProtocolOffset16Bit`），最终纳秒 = `(ref - welcome.initBegin) * welcome.timerMul` |
| 文本 | `SingleStringData = uint16 sz(+256) + 文本`；`SingleStringData8 = uint8 sz + 文本`；文本事件本身不携带内容，`ZoneText`/`ZoneName`/`Message*` 消费"前一条" pending single string |

### 用法

```bash
# 等待被测进程出现并自动连接（缺省先 UDP 广播发现，再扫描 8086-8105）
python scripts/tracy_receiver.py --out captures/run1

# 固定端口 + 采集时长上限 + 等待被测进程出现的超时
python scripts/tracy_receiver.py --out captures/run1 --port 8086 --max-seconds 120 --scan-timeout 120

# 离线路自测：伪造协议流验证解析器，无需被测进程
python scripts/tracy_receiver.py --self-test

# 离线重放已采集的原始流（目标目录须已有 metadata.json）
python scripts/tracy_receiver.py --replay captures/run1/raw_stream.bin --out captures/run1_replay
```

> 离线重放是复现与定位解析问题的主要手段：把一次采集的 `raw_stream.bin` 重放若干次，
> 可稳定复现只有在特定收尾时序下才出现的现象。

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--host` | `127.0.0.1` | 被测进程地址 |
| `--port` | 自动发现 | 固定数据端口；缺省先 UDP 发现再扫描 8086-8105 |
| `--out` | `captures/run1` | 产物目录 |
| `--max-seconds` | `0`（不限） | 最长采集时长 |
| `--scan-timeout` | `60.0` | 等待被测进程出现的最长时间（秒） |
| `--self-test` | 关 | 离线路自测，伪造协议流 |
| `--replay` | 无 | 离线重放指定的 `raw_stream.bin` |

### 产物

| 文件 | 内容 |
|------|------|
| `raw_stream.bin` | 线上原始流，逐块写入 `[uint32 size][compressed bytes]` |
| `decompressed_stream.bin` | LZ4 流式解压后的连续队列流 |
| `events.jsonl` | 结构化事件（zone / plot / frame / message） |
| `metadata.json` | 握手、Welcome、协议版本、线程名、源码位置与名称缓存 |
| `stats.json` | 热点统计：调用次数 / 总耗时 / 均值 / P50 / P95 / P99，含帧耗时统计 |

客户端退出后接收端自动收尾、落盘 `stats.json` 并自行退出（退出码 0），全程无需人工干预。

> **注意** <br/>
> 大体积流文件（`raw_stream.bin` / `decompressed_stream.bin` / `events.jsonl`）是可再生产物，
> 长期存档只需保留 `stats.json` 与 `metadata.json`。

---

## tracy_queue_table.py

Tracy 协议 QueueType 表，由上游 `tracy/public/common/TracyQueue.hpp` 转录而来，
是 `tracy_receiver.py` 解析器的唯一查表来源。

- `PROTOCOL_VERSION = 82`；`QUEUE_TYPE_ORDER` 下标即 QueueType 数值；
- `QUEUE_DATA_SIZE`：各类型的线上基础负载字节数（含 1 字节 QueueHeader）；
- `STRING_TYPES` / `STRING_LEN_OFFSET` / `STRING_LEN_KIND` / `STRING_LEN_BIAS`：
  哪些类型在固定负载之后追加变长字符串、长度字段偏移与类型、`SingleStringData` 的 +256 偏置；
- `TIME_REF_KIND`：各类型的时间戳还原基准（`thread` / `serial` / `context` / `gpu` / 绝对时间）。

上游协议变更时（Tracy 升版本）需同步更新本表，并复核 `tracy_receiver.py` 的解析分支。

---

## tracy_selftime.py

按 zone 还原嵌套关系，输出每个 zone 的调用次数、总耗时与**自耗时**（总耗时扣除子区间）。

### 背景

`stats.json` 里的 zone 总耗时**包含所有子区间**，无法区分"这一层自己慢"与"子层慢"。
例如 `finishRender` 独占一整帧，而 `drawLoop` 的总耗时里大部分来自 `draw`——
只看总耗时会把父层的开销误记到子层头上。本脚本按每条 zone 事件的
(起始时刻, 时长, 线程) 还原嵌套栈，算出每个 zone 的自耗时。

聚合键为 `名字@行号`：同名不同处的 zone（如 `ThreeRenderer.render` / `Renderer.render` /
`EffectComposer.render` 三处都叫 render）不会混在一起。

部分采集里客户端上报的 zone **名字符串会失效**（显示成 `0x...` 地址）：Tracy 的静态
源位置是"服务端按指针回查客户端内存"，字符串缓冲一旦被复用到就取不回名字。事件流中
**源位置行号仍然完好**，故脚本扫描引擎源码里的 `@Zone` 声明建立"声明行号 → zone 名"
映射，用它给失效的名字兜底。

### 用法

```bash
# 热点 + 自耗时（Top 25）
python scripts/tracy_selftime.py captures/t_audio/events.jsonl 25

# 带源码行号兜底（客户端 zone 名失效时必需）
python scripts/tracy_selftime.py captures/t_audio/events.jsonl 25 src
```

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `events.jsonl` | （必填） | `tracy_receiver.py` 产出的结构化事件文件 |
| `topN` | 25 | 按总耗时排序输出的条目数 |
| `src_root` | 空 | 引擎源码根目录；给出时启用行号兜底还原 zone 名 |

### 输出

```
zone@line                                 count    total(ms)    mean(us)     self(ms)    self(us)
----------------------------------------------------------------------------------------------------
execBgfxQueued@370                         3596   10352.552     2878.91    10352.552     2878.91
render@403                                 3585    9586.484     2674.05       22.779        6.35
finishRender@2237                          3584    3232.564      901.94     3232.564      901.94
beginRender@552                            3585     135.259       37.73      135.259       37.73
```

`self(us)` 为该 zone 扣除子区间后的平均自耗时——**引擎自身开销以自耗时为准**。

---

## tracy_hotspots.py

格式化 `tracy_receiver.py` 产出的 `stats.json`，打印帧统计与热点 Top N。

### 背景

`stats.json` 已按 zone 聚合好调用次数与耗时分位数（由接收端在收尾时算好），
本脚本只做格式化输出——采集结束后想立刻看一张热点表时用它，无需再解析事件流。

与 [`tracy_selftime.py`](./tracy_selftime.py) 的分工：
本脚本看**总耗时**（含子区间，附带 P50/P95 分位数），`tracy_selftime.py` 看
**自耗时**（扣除子区间，并能在客户端 zone 名失效时按源码行号还原名字）。
排查"到底是谁在慢"时，先用本脚本定位大块，再用 `tracy_selftime.py` 拆到具体层。

### 用法

```bash
# 热点 Top 25（标签 run）
python scripts/tracy_hotspots.py captures/t_base/stats.json run 25

# 默认 Top 25
python scripts/tracy_hotspots.py captures/t_base/stats.json
```

### 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `stats.json` | （必填） | `tracy_receiver.py` 产出的热点统计文件 |
| 标签 | `run` | 打印在标题里的采集名（如项目名） |
| `topN` | 25 | 热点表输出条目数 |

### 输出

```
==== [base] frames=31851 mean=0.42ms p50=0.18ms p95=1.02ms p99=0.00ms ====
zone                              count    total(ms)    mean(us)     p50(us)     p95(us)
----------------------------------------------------------------------------------------
render                            31850    23326.827      732.40      493.31     2696.59
finishRender                      15924    8088.433      507.94      286.71     2417.07
beginRender                       15924     860.380       54.03       48.46       83.99
```
