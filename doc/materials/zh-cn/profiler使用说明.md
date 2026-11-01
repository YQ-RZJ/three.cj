# three.profiler 性能剖析模块使用说明与约束规范

`three.cj` 引擎内置性能剖析模块 `src/profiler`（包 `three.profiler` 及其宏包 `three.profiler.macros`），基于 [Tracy](https://github.com/wolfpld/tracy)（tracy4cj 绑定）实现，可采集函数耗时区间、帧标记、曲线图、消息、内存事件、GPU 时间域、锁竞争与调用栈采样等性能数据。示例项目位于 `test/general/test_profile`。

> **注意** <br/>
> - 剖析数据通过 Tracy 协议发送，需启动 Tracy GUI（tracy4cj 仓库内）后运行程序才能查看；无 GUI 时程序照常运行，数据被静默丢弃。
> - 在执行示例项目前，需要先下载依赖库文件置入 `three/libs` 目录下。

---

## 目录

- [一、两层设计](#一两层设计)
- [二、THREE_PROFILER 环境变量](#二three_profiler-环境变量)
- [三、运行时门面 API（无条件侵入）](#三运行时门面-api无条件侵入)
- [四、宏自动化侵入（编译期可裁剪）](#四宏自动化侵入编译期可裁剪)
- [五、使用约束规范](#五使用约束规范)
- [六、示例项目 test_profile](#六示例项目-test_profile)
- [七、无 GUI 采集与性能基线](#七无-gui-采集与性能基线)

---

## 一、两层设计

| 层 | 包 | 门控 | 适用场景 |
|---|---|---|---|
| 运行时门面 | `three.profiler` | 无环境变量门控，调用即侵入 | 手动、精细的剖析点 |
| 宏自动化侵入 | `three.profiler.macros` | 编译期读取 `THREE_PROFILER`，未命中零侵入 | 声明式打点，可整体开关 |

宏在展开后引用门面类型（`ProfZone` / `ProfFrame` / `ProfPlot` 等），因此**使用宏的文件必须同时导入两个包**：

```cangjie
import three.profiler.*         // 门面（类型均带 Prof 前缀，与宏名不冲突）
import three.profiler.macros.*  // 宏包
```

---

## 二、THREE_PROFILER 环境变量

宏在**编译期（宏展开进程）**读取环境变量 `THREE_PROFILER`，与属性声明的**链路**（如 `three.test.aaa.bbb`）做**段级前缀匹配**（按 `.` 分段，`three.b` 不是 `three.bbb` 的前缀）：

```
THREE_PROFILER=off                      # 全部零侵入（默认，未设置同 off）
THREE_PROFILER=all                      # 全部侵入（on / full 等价）
THREE_PROFILER=three                    # 链路以 "three" 开头的侵入
THREE_PROFILER=three.test               # 前缀 "three.test" 的侵入
THREE_PROFILER=three.render,three.test  # 逗号分隔多链路，任一命中即侵入
```

- 未命中时宏**原样返回输入 Tokens**（零侵入），等价于宏不存在，产物与非剖析版本一致。
- 属性省略链路时默认链路为 `three`。

> **注意** <br/>
> 环境变量在**构建时**生效而非运行时：修改 `THREE_PROFILER` 后需重新编译才会改变侵入档位。该开关**只作用于宏**；直接调用门面 API 永远生效。

---

## 三、运行时门面 API（无条件侵入）

包 `three.profiler`，直接调用即视为明确的剖析意图，任何环境变量下都生效。

### ProfZone — 耗时区间

三种用法：

```cangjie
// 1. 手动 RAII（close 前可附加 text/value/color/rename）
let z = ProfZone("myZone", file, line, funcName)
z.text("vertexCount=1024")
z.value(1024)
z.close()

// 2. try-with-resources（实现 Resource 接口，退出自动 close）
try (z = ProfZone("myZone", file, line, funcName)) {
    // 区间内代码
}

// 3. 宏（推荐，编译期可零侵入裁剪，见第四节）
```

颜色参数为 `0xAABBGGRR`，`0` 表示 Tracy 默认配色。

源位置采用**静态路径**（与 Tracy 官方宏 `TRACY_ZONE_SCOPED` 等效）：每个 `(name, file, line)` 键在仓颉侧一次性分配长生命周期的 `TracySourceLocationData` 结构体与 C 字符串并永久缓存，每次 zone begin 仅以指针发射，重复进入同一 zone 无额外分配开销。

### 其他门面 API 一览

| 类 | 用途 | 常用入口 |
|---|---|---|
| `ProfFrame` | 帧标记：主循环每帧 `mark()`；子帧流用同名 `start(name)`/`finish(name)` 配对 | `mark` / `start` / `finish` / `image` |
| `ProfPlot` | 随时间绘制的数值曲线（同名点聚为一条曲线） | `point` / `pointF32` / `pointI64` / `config` |
| `ProfMessage` | Tracy 消息面板文本（`severity` 决定级别与颜色） | `logTrace`…`logFatal` / `appInfo` |
| `ProfMemory` | 手动标注分配/释放（包装自管内存池） | `alloc` / `free` / `discard` |
| `Gpu` | GPU 上下文注册与时间戳上报 | `newContext` / `zoneBegin` / `zoneEnd` / `time` |
| `Lock` | 锁竞争跟踪（登记 lockable 上下文 + before/after 事件） | `announce` / `beforeLock` / `afterLock` / `afterUnlock` |
| `ProfFiber` | 纤维/协程切换标记（`enter`/`leave` 严格配对） | `enter` / `leave` |
| `Sampling` | 调用栈采样启停 | `start` / `stop` |
| `ProfilerState` | 连接状态、时钟、线程名 | `isConnected` / `now` / `threadName` |

另有三个实现 `Resource` 接口的作用域类，可用于 try-with-resources（也是宏的展开目标）：`ProfGpuZone`（GPU 命令区间）、`ProfLockZone`（作用域锁语义：进入即持有，退出上报 unlock）、`FiberScope`（纤维作用域）。

---

## 四、宏自动化侵入（编译期可裁剪）

包 `three.profiler.macros`。全部宏均声明了属性参数，**调用必须带 `[链路]` 属性**。两种调用形态：

1. **函数级**（仅 `@Zone`）：修饰函数声明，函数体重写为 `try{}finally{}` 包裹，异常/`return` 都正确结束计时；
2. **区间/表达式级**（全部宏）：`@X[链路]( 代码 )` 括号包裹任意代码，语句/表达式位置均可用。

| 宏 | 展开行为 | 备注 |
|---|---|---|
| `@Zone` | `Zone` 区间包裹，显示名取链路末段 | 可选 `color=0xAABBGGRR` |
| `@FrameMark` | `代码; Frame.mark(name)` | 主帧标记 |
| `@FrameStart` / `@FrameEnd` | 代码前/后插入命名帧流 start/finish | 同名配对 |
| `@Plot` | 表达式求值 → 上报 Float64 曲线点 → 原值透传 | 表达式须可隐式转换 Float64 |
| `@PlotI64` | 同 `@Plot`，Int64 | |
| `@Message` | 表达式求值 → 上报为消息 → 原值透传 | 可选 `severity=trace\|debug\|info\|warning\|error\|fatal`（默认 info），类型须实现 ToString |
| `@Fiber` | `enter`/`leave` 包裹 | |
| `@MemAlloc` | 求值指针 → 上报分配事件 → 指针透传 | 表达式须为 CPointer；可选 `size=<表达式>`（默认 0） |
| `@MemFree` | 求值指针 → 上报释放事件 → 指针透传 | 表达式须为 CPointer |
| `@GpuZone` | `GpuZone` 作用域包裹（begin/end 自动配对） | 可选 `context=<表达式>`（默认 0）；时间戳仍由渲染 backend 在 fence 回读后经 `Gpu.time(gpuTime, gz.query, gz.ctx)` 上报 |
| `@LockTrack` | 临界区包装为锁时间线 | 作用域锁语义：进入即持有；真正的 lock/unlock 粒度请用 `Lock` 静态 API 手写 |

### 用法示例

```cangjie
import three.profiler.*
import three.profiler.macros.*

// 函数级：整个函数体包进 zone（链路 three.render.shadow）
@Zone[three.render.shadow]
func renderShadow(): Unit { ... }

// 区间级（括号内任意代码）
@Zone[three.render.culling]( cullPass() )
@Fiber[three.jobs.worker]( workerLoop() )
@GpuZone[three.gpu.pass, context=0]( recordPass() )
@FrameStart[three.frame.render]( renderScene() )
@FrameMark( stepSimulation() )

// 值透传（表达式位置，原值照常参与外层运算）
let fps = @Plot[three.plot.fps]( computeFps() )
let n   = @PlotI64[three.plot.batch]( batchCount() )
let s   = @Message[three.msg.state, severity=debug]( currentState() )
let p   = @MemAlloc[three.pool.geo, size=n*64]( pool.alloc(n) )
@MemFree[three.pool.geo]( pool.free(p) )
```

---

## 五、使用约束规范

1. **双包导入**：使用任何宏的文件必须同时 `import three.profiler.*` 与 `import three.profiler.macros.*`。宏展开代码引用门面类型名（`ProfZone` 等），由门面通配导入补齐；门面类带 `Prof` 前缀，与宏名不冲突。
2. **宏属性必填**：本宏包全部宏都声明了属性参数，调用必须带 `[链路]`（如 `@Zone[three]`）；属性中第一个不带 `=` 的段作为链路，其余按 `k=v` 解析（`color` / `severity` / `size` / `context`）。
3. **宏形态不可混用**：`@Zone` 既可修饰函数声明也可包裹代码；`@Plot`/`@PlotI64`/`@Message`/`@MemAlloc`/`@MemFree` 是表达式宏，**不能修饰声明**，只能用于表达式位置。
4. **表达式类型约束**：`@Plot` 结果须可隐式转换为 `Float64`；`@PlotI64` 为 `Int64`；`@Message` 类型须实现 `ToString`；`@MemAlloc`/`@MemFree` 表达式须为 CPointer。
5. **门面作用域类须配对关闭**：`ProfZone` / `ProfGpuZone` / `ProfLockZone` / `FiberScope` 均实现 `Resource`，推荐 try-with-resources 或宏包裹，避免手写 `close()` 漏调（`close()` 幂等，漏调即区间永不结束）。
6. **帧与纤维严格配对**：`ProfFrame.start(name)`/`finish(name)` 必须同名配对，可多条流并行；`ProfFiber.enter(name)`/`leave()` 必须严格配对，否则事件归属错乱。
7. **内存事件成对上报**：`ProfMemory.alloc`/`free` 按 `(ptr, size)` 成对上报；整池销毁用 `discard(name)` 按 name 归零，无需逐个 free。
8. **锁语义区分**：`@LockTrack` 是"作用域锁"语义（进入即持有、退出上报 unlock）；需要真正 lock/unlock 粒度时用 `Lock` 静态 API 手写，且 `announce` 返回的句柄须长期保存（Tracy 仅持有指针，不拷贝）。
9. **GPU 流程依赖 backend**：`@GpuZone`/`Gpu` 只发射 begin/end 与查询配对，GPU 时间戳必须由渲染 backend 在 fence/query 回读后调用 `Gpu.time` 上报，否则 GPU 面板无数据。
10. **侵入档位在编译期固定**：`THREE_PROFILER` 影响构建产物，切换档位（`off` ↔ `all` ↔ 链路）需重新编译；对发布版本建议保持 `off`（默认），宏零展开无任何运行时开销。
11. **链路命名规范**：链路建议按模块分层命名（如 `three.render.shadow`、`three.test.zone.func`），配合段级前缀匹配可按模块整体开关剖析；显示名取链路末段，应保证同模块内末段可区分。
12. **数据查看**：需先启动 Tracy GUI（tracy4cj 仓库构建），再运行被测程序即自动连接；可用 `ProfilerState.isConnected()` 判断连接状态。无 GUI 时程序照常运行；若需要落盘与自动化统计，使用第七节的 `scripts/tracy_receiver.py`。
13. **源位置（srcloc）一律走静态路径**：`ProfZone` / `ProfGpuZone` 内部按 `(name, file, line)` 缓存长生命周期的 `TracySourceLocationData` 结构体并以指针发射，与 Tracy 官方宏等效；**禁止**把动态 alloc 句柄缓存下来跨 zone 复用——worker 每消费一条 `ZoneBeginAllocSrcLoc` 即释放该指针（一次性消耗语义），复用已释放指针会引发 use-after-free / double-free，并在线上数据中表现为 zone 名乱码、`line=0`、长度异常等脏数据。`Gpu.zoneBegin(srcloc, ...)` 的 `srcloc` 同理，只能传入静态 srcloc 指针地址。

---

## 六、示例项目 test_profile

示例项目位于 [`test/general/test_profile`](../../../test/general/test_profile/)，覆盖 `three.profiler.macros` 全部常用宏：函数级/区间级 `@Zone`、`@FrameMark`/`@FrameStart`/`@FrameEnd`、`@Plot`/`@PlotI64`、`@Message`、`@Fiber`、`@MemAlloc`/`@MemFree`、`@LockTrack`。

运行方式（链路由编译期环境变量 `THREE_PROFILER` 决定）：

```bash
set THREE_PROFILER=all        # 全部侵入
set THREE_PROFILER=three.test # 仅 three.test.* 链路侵入
set THREE_PROFILER=off        # 全部零侵入（默认）
cjpm run
```

程序同时输出控制台剖析测试报告（zone 计时对照 + 耗时统计）；连接 Tracy GUI 可见上述全部链路。

---

## 七、无 GUI 采集与性能基线

Tracy GUI 需要人工交互查看，无法进入 CI 流水线。工程内提供 `scripts/tracy_receiver.py`：它扮演 Tracy GUI/Worker 的角色主动连接被测进程，把线上协议流完整落盘并直接产出统计结果。

### 7.1 接收端

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

产物（`--out` 目录）：

| 文件 | 内容 |
|---|---|
| `raw_stream.bin` | 线上原始流，逐块写入 `[uint32 size][compressed bytes]` |
| `decompressed_stream.bin` | LZ4 流式解压后的连续队列流（跨块共享 64KiB 字典） |
| `events.jsonl` | 结构化事件（zone / plot / frame / message） |
| `metadata.json` | 握手、Welcome、协议版本、线程名、源码位置与名称缓存 |
| `stats.json` | 热点统计：调用次数 / 总耗时 / 均值 / P50 / P95 / P99，含帧耗时统计 |

接收端在客户端退出后自动收尾、落盘 `stats.json` 并自行退出（退出码 0），全程无需人工干预。

### 7.2 性能基线测试项目

[`test/windows/perf_render`](../../../test/windows/perf_render/) 是配合接收端使用的真实渲染路径性能测试程序：

- **真实管线**：走 `ThreeRenderer.render(scene, camera)` 完整链路（`_render` → `_collectRenderObjects` → `RenderList.sort/finish` → `BgfxBackend.draw`），插桩点全部位于 `three.rendering.*` 真实热路径；
- **确定性**：固定相机（位置/朝向恒定）、固定对象规模（FEW=25 / MANY=800 立方体，确定性网格排布）、固定测量方案（每阶段 60 预热帧 + 240 计测帧），全程自动推进阶段并自动退出；
- **帧标记**：每帧 `ProfFrame.mark()`，接收端据此统计帧耗时。

运行（PowerShell）：

```bash
$env:EXTEDN_LIBS_PATH_WIN_X64="<three.cj>/libs"
$env:THREE_PROFILER="three.rendering,three.perf"   # 编译期档位，切换需重编译
cd test/windows/perf_render
cjpm build
# 另开一个终端启动接收端，再运行被测程序
python ../../../scripts/tracy_receiver.py --out captures/perf_run --port 8086 --scan-timeout 120
```

> 注意：`THREE_PROFILER` 是**编译期**开关，切换档位后必须重新 `cjpm build`；接收端与被测程序需并行运行。

### 7.3 基线样本

`captures/perf_run3/stats.json`（修复 srcloc 生命周期问题后的干净采集，21 个 zone 条目、`errors` 为空）：

| 指标 | 数值 |
|---|---|
| 采集时长 | 79.2 s（1841 块，原始/解压 25.3 MB / 39.8 MB，压缩比 0.63） |
| 帧样本 | 587 |
| 帧耗时 | 均值 122.4 ms / P50 17.1 ms / P95 324.3 ms / P99 392.2 ms |
| `render` | 1178 次 / 147.0 s |
| `_execBgfx` | 591 次 / 74.0 s |
| `draw` | 149687 次 / 14.8 s（均值 99 µs） |
| `_getOrCreateProgram` | 149686 次 / 3.0 s |
| `_createVB` / `_createIB` | 149686 次 / 0.75 s、0.30 s |

热点集中在每帧的 draw 提交与 uniform/纹理绑定（`draw` / `_drawRenderObject` / `bindShadowUniforms`），是后续性能调优的主要切入点。
