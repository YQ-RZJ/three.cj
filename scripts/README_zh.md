# 辅助脚本

three.cj 工程辅助脚本（Python 3.9+，无第三方依赖，仅使用标准库）。

## 脚本一览

| 脚本 | 用途 | 适用场景 |
|------|------|----------|
| [`gen_exclude_rsp.py`](./gen_exclude_rsp.py) | 生成跨平台链接符号控制文件：Windows 用 `libs/exclude.rsp`（ld.lld response file）、Linux/OHOS 用 `libs/symbols_elf.map`（`--version-script`） | 第三方依赖增减/升级、C 库重编译后刷新链接符号列表 |
| [`check_so_deps.py`](./check_so_deps.py) | 递归分析 `.so` 的 `DT_NEEDED` 依赖链，输出 Markdown | 排查 OHOS HAP / Linux 跨平台 SDK 的 so 加载失败 |
| [`add_license_header.py`](./add_license_header.py) | 为 `src/**/*.cj` 的文件首 `/**...*/` 文档注释块插入（或新建）`@LICENSE` 版权头，幂等可重复执行 | 首次引入 LICENSE 头、或新增源文件后补齐版权注释 |
| [`generate_structure.py`](./generate_structure.py) | 生成目录的文件清单或树状层级 Markdown | 生成源码目录结构文档 |

所有脚本均支持 `-h` / `--help` 查看完整参数。

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
