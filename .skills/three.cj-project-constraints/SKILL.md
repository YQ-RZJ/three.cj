---
name: three.cj-project-constraints
description: "three.cj 项目的工程约束标准（长期维护规范）。在阅读/编写/审查 three.cj 代码、新增功能、重构、清理死代码、决定 public/protected/internal/private 可见性、处理资源释放、输出日志、埋点性能分析时使用；也用于 PR 审查与代码维护任务前的合规检查。包含可复用的审计脚本（scripts/）。"
---

# three.cj 工程约束（Project Constraints）

本 SKILL 是 three.cj 项目**长期维护的工程约束标准**。后续一切代码维护（新增、修改、审查、重构）都应以本约束为验收依据。

- 把**当前已加载的 `SKILL.md` 所在目录**记为 `<skill-root>`；所有审计脚本位于 `<skill-root>/scripts/`。
- 所有脚本均为只读分析，不修改源码；修改由执行者按判据人工决策后进行。
- 构建验证约定由用户提供构建命令，若未提供则不进行构建并告知用户；输出中的 `SymInitialize FAILED` 警告可忽略，以 `cjpm build success` 为准。

## 约束速查表

| # | 约束 | 一句话规则 | 审计脚本 |
|---|---|---|---|
| C1 | 死代码清理 | 引擎内部无引用且对外部开发者无用 → 删除，不冷藏 | `audit_deadcode.py` |
| C2 | 可见性修饰 | 恰当使用 public/protected/internal/private，公开面即承诺面 | `audit_visibility.py` |
| C3 | 基础类型统一 | 复用 `three.core.math` / `three.core.dsa`，禁止包内私造 | 人工 + `audit_deadcode.py` 交叉验证 |
| C4 | 原生指针 | 禁止 public 直接暴露 `CPointer<T>`；包装/智能指针可放宽 | `audit_pointers.py` |
| C5 | 资源释放 | 需手动释放的类必须实现 `IReleasable`（releasable + 幂等 release） | `audit_releasable.py` |
| C6 | 日志输出 | 一切输出走 `LogMacros.cj` 日志宏（@LogError/.../@LogTrace），禁止裸 println | `audit_logging.py` |
| C7 | 性能埋点 | 性能热点提前预埋 `ProfileMacros.cj` 的 `@Zone[链路]` 等宏 | `audit_profiler.py` |
| C8 | 常量集中 | 引擎内所有常量统一定义在 `src/utils/constants` 包内，禁止散落 | 人工 + grep 审查 |

## 两条总判定标准（一切判据的源头）

> **死代码判定**：代码引擎内部无引用，且其功能对外部开发者也没有用 → 死代码；若对开发者可起辅助作用 → 不是死代码。
>
> **误用 public 判定**：被 public 声明的代码实际仅用于引擎内部，其功能没必要或不可能被外部开发者依赖或使用，或其 public 声明本身不合理 → 误用 public。

由这两条派生出的**公开面保留豁免清单**（满足其一即保留 public，即使仓内零调用）：

1. **测试包阻断**：被 `test/` 下任意测试包（非子类）使用的成员不可降级（Cangjie 的 protected/internal 都会挡住跨包非子类访问）。
2. **接口契约**：公共接口声明的成员、以及实现外部接口（如 `IReleasable`、标准库 `Callback`）的方法必须 public。
3. **API parity**：对应 three.js 公开 API 的成员（如 `AnimationAction.fadeIn`、`BufferGeometry.setDrawRange`、`UniformsUtils`、`EffectComposer.insertPass`），即使仓内零调用也保留——外部开发者会用到。
4. **逃生舱/高级 API**：文档明确"经 XX 暴露给使用者"的低级通道（如 `ThreeRenderer` 的 bgfx encoder 系列、`UiDrawList`、`AudioBuffer.createChunk`、`StreamingAudio.updateStream`）。
5. **open 扩展点**：`open func` / `open class` 是为外部子类化设计的，降级前必须确认无跨包子类依赖（`audit_visibility.py` 会自动标记 OPEN 并建议保留）。
6. **对称 API 组**：与已公开成员成组的 getter/setter、工厂三件套（如 `addTranslation/addRotation/addScaleKeyframe`），单点降级会造成 API 畸形，整组保留并在报告中注明。

---

## C1 死代码清理

**规则**：按总判定标准，死代码必须删除（连同其 doc 注释、专属常量与私有辅助）；"可能以后有用"不是保留理由，版本控制即历史。

**正面影响**：降低维护面与阅读噪音；减少 public API 契约面积（死代码一旦公开，就会在不知不觉中被外部依赖）；减小审计与编译负担；避免"僵尸 API"在后续重构中被当作既有契约继承。

**负面影响与权衡**：
- 动态/反射/script 绑定调用静态分析看不见，存在误删风险 → **删除前人工核判据**：是否被脚本系统（`three.script`）、序列化（`*Json` 属性）、宏展开代码（`ecs/macros` 生成的调用）以字符串或间接方式引用。
- 刚完成、尚未接线的新功能（如示例/文档尚未覆盖）会被误判 → 对新模块（`@since`、近期 commit 引入且属路线图功能）标注保留，不要机械执行脚本结论。
- 零引用≠无价值：对外部开发者有辅助意义的库设施（数学、dsa、SystemInfo、ImGui 绑定等）**永不判死**。

**执行判据**：`audit_deadcode.py <模块>` 输出零引用清单 → 逐项过"豁免清单"（见上）→ 确认死代码后直接删除；不确定时列入报告而不是删除。删除属结构性改动，建议按总约定（见开头）验证构建：用户提供了构建命令或其组成部分则执行，未提供则跳过并告知用户"未做编译验证"。

---

## C2 可见性修饰（public / protected / internal / private）

**规则**（按声明位置与用途选择最小可见性）：

| 场景 | 修饰 |
|---|---|
| 外部开发者会使用（含 API parity、逃生舱） | `public` |
| 仅同包使用，且**子类可能需要访问/重写**（跨包子类扩展点） | `protected` |
| 仅同包使用，无子类语义（引擎内部管道、后端实现、工具内部） | `internal`（顶层与成员皆可） |
| 仅声明类型内部使用（同文件、同类型，如 `_init` 类构造期辅助） | `private` |
| 枚举成员 | 不能 protected（枚举不可子类化）；包内用 internal，类型内用 private |

**选择顺序**：private > internal > protected > public，取**能通过编译与测试的最小可见性**。

**正面影响**：public 即对外的承诺面——每收窄一处，未来重构自由度就大一分；internal/protected 让"引擎内部"在 API 文档与补全中消失，外部开发者不会误用不稳定接口；protected 精确保留子类扩展点（如 `Interpolant.interpolate_`）而不放大到全局。

**负面影响与权衡**：
- 收窄是有编译风险的改动：测试包、宏展开代码、跨包子类都可能被挡 → 收窄后**建议做构建验证**（含测试目标）；构建命令由用户提供（完整命令或其组成部分），未提供则跳过验证并在结果中明确告知"未编译验证"。
- 过度收窄（该 public 的改 internal）会切断外部合法用法，伤害与 API parity 豁免冲突 → 以豁免清单为准，存疑即保留 public 并记录在审计报告中。
- Cangjie 中子类 override 可放宽可见性（protected 基类 + public override 合法），但收紧不行；重写链上的成员以**基类声明**为准判断。
- 顶层声明没有 protected；死代码顶层类用 internal 收敛只是止血，根治是删除（C1）。

**执行判据**：`audit_visibility.py <模块...>` 对每个 public 声明做全库交叉引用（含 `test/`），输出五类：`KEEP-EXTERNAL`（模块外使用，保留）、`KEEP-TEST`（测试包使用，保留）、`KEEP-PARITY?`（零引用，需人工过豁免清单）、`CANDIDATE-PROTECTED`（仅同包使用且在 open 类中）、`CANDIDATE-INTERNAL`（仅同包使用且无子类语义）、`CANDIDATE-PRIVATE`（仅声明文件内使用）。收窄后按总约定验证构建（用户未提供命令则跳过并告知）。

---

## C3 基础类型统一（three.core.math / three.core.dsa）

**规则**：全项目可复用的基础类型必须来自公共基础包，禁止在业务包内私造平行实现：
- **数学**：`three.core.math`（Vector2/3/4、Matrix、Quaternion、Color、Box2/3、Sphere、Plane、Ray、Frustum、Triangle、Euler、MathUtils、Interpolant 及 soa 变体）。任何包需要向量/矩阵/四元数运算时 import 它，不允许私写 `Vec3`/`Mat4`/`点积函数`。
- **数据结构与算法**：`three.core.dsa`（BinaryHeap、CircularQueue、RingBuffer、LinkedList、LruCache、SpatialHashGrid、UnionFind、FenwickTree、噪声等）。需要堆/环形缓冲/空间哈希时先查这里。
- 确需新增强度较高的基础类型时，**先下沉到 core 包并公开**，再在业务包使用；不允许"先私造、以后再说"。

**正面影响**：单点优化与调试（SIMD、soa、缓存友好布局只改一处）；类型互转零成本（不会出现 Vec3↔Vector3 的转换层）；行为一致（欧拉序、slerp 语义、舍入策略全项目统一）。

**负面影响与权衡**：
- core 包成为公共依赖面，改动影响全项目 → 对 core 的修改要求更严格的验证（全量构建 + 相关测试），且新增 API 同样受 C2 约束。
- 个别热点路径需要专用内存布局（如渲染侧 SoA、bgfx 句柄包装）→ 允许**布局特化**，但运算语义必须复用 core 的数学函数，且特化类型应放公共包而非散落业务包。
- 历史遗留的平行实现按"先接入、后删除"处理：接入点迁移完再按 C1 删除旧实现。

**执行判据**：人工审查为主；`audit_deadcode.py` 的零引用清单可反向暴露"私造后无人用"的类型。新增代码 review 时先问一句：core 里有没有？

---

## C4 禁止直接 public 暴露原生指针

**规则**：`CPointer<T>` 等**原生指针类型不得出现在 public 声明（prop/func 参数/返回值）中**。替代方案：
- 首选：包装为引擎类型（`Box<T>`、句柄包装类如 `BgfxTypes` 的 handle 包装、`BgfxMemory` 等）；
- 次选（确有 FFI 需求时）：`internal`/`protected` 暴露，并在注释中写明生命周期责任；
- 返回裸 `CPointer` 的 public prop（如 `AudioContext.device` 这类存量）属**历史豁免**，新代码不得效仿，存量在重构时逐步收敛。

**正面影响**：外部开发者不可能因误持指针而制造 use-after-free/悬垂崩溃；生命周期责任收敛在引擎内部（释放统一走 IReleasable/C5）；API 更稳定（指针布局变化不破坏外部代码）。

**负面影响与权衡**：
- 包装有成本：一次 Box/句柄间接层、少量拷贝或锁 → 仅在**边界**（public API）强制；纯 internal 的热路径 FFI 代码允许直接用指针，不做无谓包装。
- 高级用户的逃生舱需求（如自写 OpenAL 调用）会被挡 → 若确属有意暴露（如 `AudioBuffer.createChunk` 的指针参数属于**入参**而非持久暴露），允许入参用指针，但返回值/属性仍禁止；并在 doc 中写明调用方责任。
- 收敛存量时可能破坏已依赖指针的外部代码 → 存量改 internal 前先查测试包与示例使用（同 C2 流程）。

**执行判据**：`audit_pointers.py <模块...>` 扫描 public 声明签名中的 `CPointer<`、`Ptr`、`UnsafePointer` 等，报告 `EXPOSED`（public 暴露，须处理）/`INTERNAL-OK`（internal 及以下，放行）/`PARAM-OK`（仅入参，放行但提示补 doc）。

---

## C5 需手动释放的类必须实现 IReleasable

**规则**：凡是持有需要**手动释放**的底层资源的类（OpenAL buffer/source/context、bgfx handle/framebuffer/程序、动态内存、文件句柄、子资源聚合器），必须实现 `src/utils/safe/safe.cj` 的 `IReleasable`：
- 实现 `releasable` prop：未释放且仍持有底层资源时为 true；`release()` 后为 false（GPU 设备丢失等"失效但未释放"不算释放，详见接口注释）；
- 实现 `release()`：幂等（重复调用安全返回），释放全部底层资源并清空句柄；
- 聚合器（如持有多个子资源的容器）负责级联释放其拥有的子资源。

**正面影响**：释放路径统一，外部开发者"看到 IReleasable 就知道怎么释放"；`releasable` 使防御性调用与资源池回收（如 `three.utils.pool`）可以统一实现；幂等约定消除 double-free 一类崩溃；接口可被 `for` 资源清点、泄漏检测工具遍历。

**负面影响与权衡**：
- 实现义务：每个类要正确维护 released 状态与级联释放，写漏子资源即泄漏 → 审查 release() 时逐句柄核对；`audit_releasable.py` 列出"疑似持有资源但未实现接口"的类作为检查清单。
- 幂等 + 状态跟踪有微量开销 → 仅布尔判断，可忽略；不要为省这点开销绕过接口。
- 引用计数类资源（多所有者）不适合简单 release 语义 → 引用计数封装放在实现内部，对外仍呈现 IReleasable 语义（最后一次 release 真正释放）。
- 栈上/值语义轻量类型（无底层资源）**不要**实现本接口，避免"处处可 release"的噪音。

**执行判据**：`audit_releasable.py <模块...>` 用启发式（类内含 `CPointer` 字段 / 含 `*Handle` 字段 / 已有 `func release`）找出候选，报告 `MISSING-IRELEASEABLE`（须补实现）/`OK`。已见正确样例：`AudioContext/AudioBuffer/PropertyMixer/AudioEffectSlot` 等。

---

## C6 日志输出统一走日志宏

**规则**：一切诊断/状态/错误输出必须通过 `src/utils/log/macros/LogMacros.cj` 的表达式宏：`@LogError` / `@LogWarn` / `@LogWarnOnce` / `@LogInfo` / `@LogDebug` / `@LogTrace`（参数为 `["标签", "内容..."]` 形式）。**禁止**在 `src/` 业务代码中出现裸 `println` / `print` / 直接构造 console 输出。豁免：`Logger` 本体与日志宏包自身的实现、`main.cj` 启动早期。

**正面影响**：编译期档位门控（`THREE_LOG_LEVEL`），release 构建日志**零开销**——宏展开为空 Tokens，连参数求值与字符串插值都不生成；裸 println 无法享受这一点，且会在性能敏感路径留下隐形热点；统一通道后宿主可经 `Logger.setConsoleFunction` 接平台 sink，日志可被收集/过滤。

**负面影响与权衡**：
- 宏按编译期档位裁剪，运行期动态开关粒度受限（off 后日志彻底不存在）→ 需要运行期可开关的极少场景（用户可见的诊断输出）走 UI/调试面板，不走日志。
- `@LogWarnOnce` 用于防刷屏；循环内高频路径慎用 `@LogTrace` 以外的级别（release 虽零开销，debug 构建会刷屏）。
- 字符串插值在 debug/trace 档位仍有构造成本 → 热循环内日志降级为聚合统计（计数、采样输出）。

**执行判据**：`audit_logging.py` 扫描 `src/` 中裸 `println(`/`print(`，按豁免清单过滤后输出违规位置；新代码 review 时输出语句一律要求宏形式。

---

## C7 性能热点预埋剖面宏

**规则**：可能成为性能热点的函数，在**编写时**就预埋 `src/profiler/macros/ProfileMacros.cj` 的宏：函数级用 `@Zone[链路路径]`（如 `@Zone[three.rendering.ThreeRenderer.render]`，链路用"包路径.类名.方法名"命名）；帧边界用 `@FrameStart/@FrameMark/@FrameEnd`；计数与数值曲线用 `@Plot/@PlotI64/@Message`。宏受 `THREE_PROFILER` 环境变量按链路前缀门控，未命中链路时零开销。

**正面影响**：热点定位无需事后翻代码补埋点（补埋点 = 重新编译 + 重新复现场景，代价高）；链路门控使常驻埋点不拖累平时开发；命名规整的链路（`包.类.方法`）可直接与 Tracy 等后端的时间线、火焰图对齐（`scripts/tracy_*.py` 已有配套工具）。

**负面影响与权衡**：
- 埋点有编译期展开与（命中时）运行期开销 → 未启用链路时零开销，启用时仅毫秒级；但**不要**给微小函数（几行、无循环）埋 Zone，标签噪音大于信息量。
- 链路命名是长期契约：改名/移动方法时同步改 `@Zone` 字符串，否则时间线出现孤儿段 → 与方法名保持字面一致可降低漂移。
- 过度埋点（每个 getter 一个 Zone）会放大时间线 → 以"函数可能含循环/FFI/锁/递归/大对象操作"为埋点门槛。

**执行判据**：`audit_profiler.py <模块...>` 按启发式（public/open 的 `update|run|render|execute|simulate|step|process|tick|dispatch|flush` 等成员函数，且函数体非平凡）列出**未带 `@Zone` 的热点候选**，输出建议链路名；人工确认后补埋。已有埋点密度可参考 `three.rendering.ThreeRenderer`、`three.audio` 各 Job 的 `run` 等。

---

## C8 常量集中定义（src/utils/constants）

**规则**：引擎内所有常量（`public let`/`const` 形式的具名常量——魔法数字、枚举值、字符串标签、默认配置、格式掩码等）统一定义在 `src/utils/constants` 包（现有 `constants.cj`，如 `MOUSE_LEFT`、`CullFaceNone`、`RGBA_ASTC_*`），使用方 `import three.utils.constants`。**禁止**在业务包内新设散落常量：
- 业务包内不得新增 `public let/const` 形式的跨包常量；
- 包内 private 的小型局部常量（仅单文件使用的辅助值）允许留在原地，但出现第二个使用者时必须迁入 constants 包；
- 迁移存量常量时保留原名的 `public let` 于 constants 包，使用点改为 import——不允许"复制一份进 constants、原处照旧"的双份状态。

**正面影响**：单一事实来源——改一个值全引擎生效，杜绝"同一阈值在两处不一致"的隐性 bug；常量即文档，新开发者通读 constants.cj 即可掌握引擎的可配置面；避免循环依赖（常量下沉到最底层包，任何包都能安全 import，这正是 C3 的基础类型思路在常量上的延伸）；便于后续做配置化/热更（常量入口唯一）。

**负面影响与权衡**：
- constants 包成为全项目公共依赖面（现有 63 个文件已依赖）→ 改动常量**值**影响面大，需按用户提供的构建命令验证（未提供则跳过并告知）；但新增常量是纯追加，风险低。
- "所有常量入包"可能造成 constants.cj 单文件膨胀、业务语境割裂（读代码时看不到字面值）→ 允许按域拆分文件（如 `constants.cj` / 未来按渲染/音频分文件），但**包必须唯一**；命名须自解释并带域前缀（如 `RGBA_ASTC_*`），避免裸 `MAX_SIZE` 这类无语境名字。
- 真正的"编译期宏常量"（`macro` 包内部使用的编译期配置）属于宏包实现细节，不属本约束管辖。
- 频繁调参的调试用魔法数字不值得入包 → 调参结束、值稳定后再按 C1/C8 收敛。

**执行判据**：人工审查为主——新增代码中见到 `public let/const` 不在 `src/utils/constants` 内即违规；可用 `grep -rn "public let\|public const" src --include="*.cj"` 辅助定位散落常量（排除 constants 包与宏包）。迁移时同步清理旧定义（避免双份），完成后按总约定验证构建。


---

## 维护审查工作流

**新增/修改代码时（快速合规）**：
1. 逐条过速查表：可见性选最小（C2 判据表）、无裸指针暴露（C4）、无裸输出（C6）、热点已埋 @Zone（C7）、持资源类已实现 IReleasable（C5）、基础类型先查 core（C3）、常量入 `three.utils.constants`（C8）。
2. 涉及结构性的改动（删代码、收窄可见性）后：按总约定验证构建——构建命令由用户提供（完整命令或其组成部分，如环境变量前缀 + `cjpm build`）；用户未提供则**跳过编译验证**，并在结果中明确告知"未验证，建议本地构建确认"。

**模块级审计（定期/大改动后）**：
1. `python <skill-root>/scripts/audit_visibility.py <模块...>` → 可见性候选清单。
2. `python <skill-root>/scripts/audit_deadcode.py <模块...>` → 死代码候选清单。
3. `python <skill-root>/scripts/audit_pointers.py <模块...>`、`audit_releasable.py <模块...>`、`audit_logging.py`、`audit_profiler.py <模块...>`。
4. 每个候选逐项过"豁免清单"（总判定标准之下）：测试包阻断 > 接口契约 > API parity > 逃生舱 > open 扩展点 > 对称 API 组。
5. 决策后执行修改 → 按总约定验证构建（用户提供了命令则执行，未提供则跳过并告知）→ 在变更说明中列出"改了什么、保留了什么、依据哪条豁免"。**报告保留项与修改项同等重要**——豁免是显式决策，不是默认。

**脚本通用约定**：所有脚本只读；参数为 `src/` 下的模块名（如 `animation`、`rendering/bgfx`）；输出 `file:line` 与分类标签，退出码 0 表示脚本正常（不代表合规），合规与否以人工判定为准。

---

## 仓颉官方工具链（开发 / 约束审查 / 排查时按需使用）

以下工具来自仓颉 SDK（位于 SDK 的 `cangjie/tools/bin`），与本项目约束的对应关系见各条目。更完整的选项与规则明细可查阅 `perler_beads/.trae/skills/cangjie-coding` 技能的知识库（`references/tools/cjlint|cjpm|cjdb|cjprof|cjtrace-recover`）。

### cjlint —— 代码静态检查（约束审查的机检补充）

- **用法**：`cjlint -f <dir>` 检查目录（多目录空格分隔、双引号包裹）；`-h` 帮助、`-v` 版本。
- **能力**：规则分类检查（命名/代码风格/内存与安全等，如 `G.CHK.01` 跨信任边界数据须校验、`G.CHK.02` 禁止直接使用外部数据记日志）、告警屏蔽（源码注释 `cjlint-ignore`，`-start`/`-end` 与规则名须同行）、语法禁用检查。
- **与本 SKILL 的关系**：C1–C7 中可机械判定的部分（命名、未使用变量、危险语法）优先交给 cjlint 扫描；本 SKILL 的脚本负责 cjlint 覆盖不了的**语义级**判据（交叉引用、可见性、死代码）。两者结论冲突时以本 SKILL 判据人工裁决，屏蔽告警须写明理由。

### cjpm —— 项目管理/构建（编译验证的标准入口）

- **用法**：`cjpm init --name <包名> --type=executable` 新建模块；`cjpm build` / `cjpm test` / `cjpm run` 构建、测试、运行；依赖与工作区经 `cjpm.toml` 管理（`[script-dependencies]` 配置构建脚本依赖）。
- **构建命令来源**：本项目曾使用的完整命令形如 `$env:EXTEND_LIBS_PATH_WIN_X64=".\libs"; $env:THREE_LOG_LEVEL="info"; $env:THREE_PROFILER="off"; cjpm clean; cjpm update ; cjpm build -j 8;`（`SymInitialize FAILED` 警告可忽略，以 `cjpm build success` 为准），仅供参考——**实际执行时以用户当前提供的构建命令或其组成部分为准**，未提供则跳过（见开头总约定）。
- **与本 SKILL 的关系**：C1/C2 的结构性修改（删代码、收窄可见性）建议以 cjpm 构建 + 相关测试通过做验收，但执行与否取决于用户是否提供命令。

### cjdb —— 调试器（问题排查）

- **用法**：基于 lldb 的命令行调试器；启动/附加目标进程，源码断点 `b <file>:<line>`、函数断点 `b <func>`（均支持简写），单步、查看变量、表达式求值、观察点、多线程调试。
- **与本 SKILL 的关系**：排查 C5（释放顺序/悬垂）、C4（指针生命周期）类问题的首选——在 release/destroy 路径下断点核对调用序；并发问题（如 audio 线程栅栏）用线程调试能力。

### cjprof —— 性能分析（C7 的验证闭环）

- **用法**：CPU 热点采样分析，`report` 生成文本报告（总占比/自身占比降序），`-F/--flame-graph` 生成火焰图 SVG（默认 `FlameGraph.svg`，`-o` 指定输出）；支持堆内存分析、堆导出、引用分析、线程栈。
- **与本 SKILL 的关系**：C7 埋点是否有效的验证闭环——先 `audit_profiler.py` 列候选并补 `@Zone`，再用 cjprof 采样确认热点归属与埋点密度合理；火焰图与 `@Zone` 链路名（`包.类.方法`）对照阅读，孤儿段即命名漂移信号。`scripts/tracy_*.py`（项目根 scripts/）是本项目配套的 Tracy 后端工具，两者互补。

### cjtrace-recover —— 异常堆栈还原（release 崩溃排查）

- **用法**：`cjtrace-recover -f <stacktrace-file> -m <map-file,...>` 使用混淆编译生成的符号映射文件，把异常堆栈中的混淆符号还原为函数名与源码路径，结果写标准输出。
- **与本 SKILL 的关系**：release 版（混淆构建）线上崩溃排查的必备步骤；项目若启用混淆发布，必须把符号映射文件归档到构建产物旁，否则该工具无从还原——属于 C1（清理）与发布流程的衔接约定。





