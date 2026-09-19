/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 */

/**
 * @file[zh-cn] Profiler.cj three.profiler 运行时门面（无开关，直接使用即侵入）
 * @brief[zh-cn] Zone/Frame/Plot/Message/Memory/Gpu/Lock/Fiber/采样的高级封装，
 *               以及 GpuZone/LockZone/FiberScope 三个 Resource 作用域类
 * @package three.profiler
 *
 * @explain[zh-cn] 本包是**无条件的运行时门面**：用户直接调用这里的 API 即视为
 * 明确的剖析意图，无论任何环境变量如何设置都始终生效（必侵入）。
 *
 * 环境变量开关（THREE_PROFILER + 链路前缀匹配）只作用于**宏自动化侵入**——
 * 即 three.profiler.macros 子包的 @Zone/@Plot 等宏：宏在编译期读取
 * THREE_PROFILER，按属性声明的链路（如 "three.test.aaa.bbb"）与环境变量值做
 * **段级前缀匹配**，未命中时宏原样返回输入 Tokens（零侵入），命中时才展开为
 * 对本门面的调用。详见 three.profiler.macros 包文档。
 *
 * 作用域类（Zone/GpuZone/LockZone/FiberScope）均实现 std.core.Resource 接口，
 * 可直接用于 try-with-resources（`try (z = Zone(...)) { ... }`）或宏展开的
 * try{}finally{} 骨架，退出时自动 close() 结束区间。
 *
 * Zone 封装要点：tracy4cj 的静态源位置路径要求仓颉侧长期持有 C 字符串内存，
 * 不可靠；因此统一走 allocSrclocName_cj 动态源位置句柄（Tracy 内部按
 * (name,file,line) 永久缓存，同一键只分配一次），仓颉侧零 C 字符串生命周期负担。
 *
 * @file[en] Profiler.cj three.profiler runtime facade (always-on, no env gate)
 * @brief[en] High-level wrappers: Zone/Frame/Plot/Message/Memory/Gpu/Lock/Fiber/
 *            sampling, plus Resource scope classes GpuZone/LockZone/FiberScope
 * @explain[en] This package is an UNCONDITIONAL runtime facade: direct API use
 * means explicit profiling intent and is always instrumented. The environment
 * switch (THREE_PROFILER + link-path prefix matching) only governs macro-based
 * auto instrumentation in three.profiler.macros: macros read THREE_PROFILER at
 * expansion time, match the attribute's link path (e.g. "three.test.aaa.bbb")
 * against it with segment-level prefix matching, and return the input tokens
 * untouched (zero intrusion) on miss. Scope classes (Zone/GpuZone/LockZone/
 * FiberScope) implement std.core.Resource for try-with-resources and macro
 * try{}finally{} skeletons; close() ends the span automatically. Zones use
 * dynamic srcloc handles cached permanently inside Tracy, so the Cangjie side
 * holds no C-string memory.
 */
package three.profiler

import std.collection.*
import std.collection.concurrent.*
import std.sync.*
import tracy4cj.tracy.*

// =============================================================================
// Zone — 函数级耗时区间（Tracy zone）
// =============================================================================

/**
 * @brief[zh-cn] Zone 区间控制器 — 一次构造/close 对应 Tracy 一个耗时区间
 * @explain[zh-cn] 三种用法：
 *
 * 1. 手动 RAII：`let z = Zone(name, file, line, function); ...; z.close()`
 *    （close 前可附加 text/value/color/rename）；
 * 2. try-with-resources：`try (z = Zone(...)) { ... }`（实现 Resource 接口，
 *    退出自动 close）；
 * 3. 宏：`@Zone[three.test.aaa.bbb] func f(): Unit {...}` 或
 *    `@Zone[链路]( 代码 )`（推荐，编译期可零侵入裁剪）。
 *
 * 源位置采用动态句柄：Tracy 按 (name,file,line) 永久缓存，重复构造无重复分配。
 *
 * @brief[en] Zone scope controller — one construction/close pair is one Tracy
 * timing zone
 * @explain[en] Three usages:
 *
 * 1. Manual RAII: `let z = Zone(name, file, line, function); ...; z.close()`
 *    (attach text/value/color/rename before closing);
 * 2. try-with-resources: `try (z = Zone(...)) { ... }` (implements Resource,
 *    close is called automatically on exit);
 * 3. Macros: `@Zone[link] func f(): Unit {...}` or `@Zone[link]( code )`
 *    (recommended; compile-time prunable).
 *
 * Source locations use dynamic handles cached permanently inside Tracy keyed
 * by (name,file,line), so repeated construction costs no extra allocation.
 */
public class ProfZone <: Resource {
    /**
     * @brief[zh-cn] 动态源位置缓存：键 "name\x1ffile\x1fline" → srcloc 句柄
     *               （Tracy 侧永久有效）
     *
     * @brief[en] Dynamic srcloc cache: key "name\x1ffile\x1fline" -> srcloc
     *            handle (valid permanently on the Tracy side)
     */
    private static let SRCLOC_CACHE = ConcurrentHashMap<String, UInt64>()

    /**
     * @brief[zh-cn] zone 上下文（active=0 表示未激活 / 已结束）
     *
     * @brief[en] Zone context (active=0 means inactive / already closed)
     */
    private var ctx: TracyCZoneCtx = TracyCZoneCtx(0, 0)

    /**
     * @brief[zh-cn] 本 zone 是否真正开始记录
     *
     * @brief[en] Whether this zone actually started recording
     */
    public prop active: Bool {
        get() { ctx.active != 0 }
    }

    /**
     * @brief[zh-cn] 开始一个命名 zone（手动 RAII 用法的入口，无颜色）
     *
     * @brief[en] Begin a named zone (manual RAII entry, default color)
     */
    public init(name: String, file: String, line: UInt32, function: String) {
        ctx = ProfZone.beginCtx(name, file, line, function, 0)
    }

    /**
     * @brief[zh-cn] 开始一个命名 zone（带颜色 0xAABBGGRR；0 = Tracy 默认配色）
     *
     * @brief[en] Begin a named zone with color 0xAABBGGRR (0 = Tracy default)
     */
    public init(name: String, color: UInt32, file: String, line: UInt32, function: String) {
        ctx = ProfZone.beginCtx(name, file, line, function, color)
    }

    /**
     * @brief[zh-cn] 开始一个命名 zone（无函数名版本，宏表达式形态用；
     *               函数名一栏以 zone 名兜底）
     *
     * @brief[en] Begin a named zone without a function name (macro expression
     *            form; the zone name doubles as the function label)
     */
    public init(name: String, color: UInt32, file: String, line: UInt32) {
        ctx = ProfZone.beginCtx(name, file, line, name, color)
    }

    /**
     * @brief[zh-cn] 取/分配动态源位置句柄并发射 zoneBegin
     *
     * @brief[en] Resolve the dynamic srcloc handle and emit zoneBegin
     */
    private static func beginCtx(name: String, file: String,
                                 line: UInt32, function: String, color: UInt32): TracyCZoneCtx {
        let srcloc = srclocHandle(name, file, line, function, color)
        return emitZoneBeginAlloc_cj(srcloc, true)
    }

    /**
     * @brief[zh-cn] 取/分配动态源位置句柄（Tracy 内部永久缓存，同一键只分配
     *               一次；包内可见：GpuZone 等作用域类复用）
     *
     * @brief[en] Resolve/allocate the dynamic srcloc handle (cached permanently
     *            inside Tracy, one allocation per key; package-visible for
     *            reuse by GpuZone and other scope classes)
     */
    protected static func srclocHandle(name: String, file: String, line: UInt32,
                             function: String, color: UInt32): UInt64 {
        let key = "${name}\u{1f}${file}\u{1f}${line}"
        // 快路径：已缓存
        // Fast path: cached
        match (SRCLOC_CACHE.get(key)) {
            case Some(v) => return v
            case None => ()
        }
        // 慢路径：分配后回填（allocSrclocName 幂等，重复分配仅浪费一次查询）
        // Slow path: allocate then backfill (allocSrclocName is idempotent; a
        // duplicate allocation only wastes one lookup)
        let h = allocSrclocName_cj(line, file, function, name, color)
        SRCLOC_CACHE.add(key, h)
        return h
    }

    /**
     * @brief[zh-cn] 附加文本说明（Tracy zone 面板显示）
     *
     * @brief[en] Attach a text note (shown in the Tracy zone panel)
     */
    public func text(txt: String): Unit {
        if (ctx.active == 0) {
            return
        }
        emitZoneText_cj(ctx, txt)
    }

    /**
     * @brief[zh-cn] 附加数值（zone 面板 mini 图，如顶点数/批次数）
     *
     * @brief[en] Attach a numeric value (zone panel mini-graph, e.g. vertex
     *            or batch count)
     */
    public func value(v: UInt64): Unit {
        if (ctx.active == 0) {
            return
        }
        emitZoneValue_cj(ctx, v)
    }

    /**
     * @brief[zh-cn] 覆盖 zone 颜色（0xAABBGGRR）
     *
     * @brief[en] Override the zone color (0xAABBGGRR)
     */
    public func color(c: UInt32): Unit {
        if (ctx.active == 0) {
            return
        }
        emitZoneColor_cj(ctx, c)
    }

    /**
     * @brief[zh-cn] 重命名 zone（覆盖源位置默认名）
     *
     * @brief[en] Rename the zone (overrides the default source-location name)
     */
    public func rename(txt: String): Unit {
        if (ctx.active == 0) {
            return
        }
        emitZoneName_cj(ctx, txt)
    }

    // ---- Resource（try-with-resources / close 自动结束 zone）----

    /**
     * @brief[zh-cn] Resource.isClosed：zone 已结束/未激活即视为已关闭
     *
     * @brief[en] Resource.isClosed: the zone counts as closed once ended or
     *            never activated
     */
    public func isClosed(): Bool {
        return ctx.active == 0
    }

    /**
     * @brief[zh-cn] 结束 zone（幂等：重复调用/未激活均安全；
     *               try-with-resources 自动调用）
     *
     * @brief[en] Close the zone (idempotent and safe when inactive or already
     *            closed; called automatically by try-with-resources)
     */
    public func close(): Unit {
        if (ctx.active == 0) {
            return
        }
        emitZoneEnd_cj(ctx)
        ctx = TracyCZoneCtx(0, 0)
    }
}

// =============================================================================
// Frame — 帧标记
// =============================================================================

/**
 * @brief[zh-cn] 帧标记 — 主帧/命名帧的 start/finish
 * @explain[zh-cn] Tracy 的帧（Frame）是面板顶层的分帧单位。主循环每帧调
 * [mark]；子帧流（如渲染线程、模拟线程）用 [start]/[finish] 对（同名配对）。
 *
 * @brief[en] Frame marks — main/named frame boundaries
 * @explain[en] Frames are the top-level time slices in the Tracy UI. Call
 * [mark] once per main-loop iteration; use [start]/[finish] pairs for
 * secondary frame streams (render thread, simulation thread, ...).
 */
public class ProfFrame {
    /**
     * @brief[zh-cn] 主帧结束标记（主循环每帧一次）
     *
     * @brief[en] End-of-main-frame mark (once per main-loop iteration)
     */
    public static func mark(): Unit {
        frameMark_cj()
    }

    /**
     * @brief[zh-cn] 命名帧结束标记（独立帧流，如 "Render"）
     *
     * @brief[en] End-of-named-frame mark (independent frame stream, e.g.
     *            "Render")
     */
    public static func mark(name: String): Unit {
        frameMarkNamed_cj(name)
    }

    /**
     * @brief[zh-cn] 开始一个命名帧流（与 finish 同名配对；可多条流并行）
     *
     * @brief[en] Start a named frame stream (paired with finish by name;
     *            multiple streams may run in parallel)
     */
    public static func start(name: String): Unit {
        frameMarkStart_cj(name)
    }

    /**
     * @brief[zh-cn] 结束一个命名帧流
     *
     * @brief[en] Finish a named frame stream
     */
    public static func finish(name: String): Unit {
        frameMarkEnd_cj(name)
    }

    /**
     * @brief[zh-cn] 发送帧图像预览（Tracy GUI 帧列表缩略图）
     *
     * @brief[en] Send a frame image preview (thumbnail in the Tracy frame list)
     */
    public static func image(image: CPointer<Unit>, width: UInt16, height: UInt16,
                             offset: UInt8, flip: Bool): Unit {
        frameImage_cj(image, width, height, offset, flip)
    }
}

// =============================================================================
// Plot — 曲线图
// =============================================================================

/**
 * @brief[zh-cn] Plot 曲线 — 随时间绘制的数值曲线（FPS/内存/队列深度等）
 * @explain[zh-cn] 同名数据点聚为一条曲线；首次发射前可用 [config] 定制格式。
 *
 * @brief[en] Plots — time-series value curves (FPS, memory, queue depth, ...)
 * @explain[en] Points with the same name form one curve; call [config] first
 * to customize the display format.
 */
public class ProfPlot {
    /**
     * @brief[zh-cn] 配置曲线显示（首次发射前调用一次即可）
     *
     * @brief[en] Configure the plot display (call once before first emission)
     */
    public static func config(name: String, format: TracyPlotFormat, step: Bool,
                              fill: Bool, color: UInt32): Unit {
        plotConfig_cj(name, format, step, fill, color)
    }

    /**
     * @brief[zh-cn] 发射浮点数据点
     *
     * @brief[en] Emit a Float64 data point
     */
    public static func point(name: String, v: Float64): Unit {
        plot_cj(name, v)
    }

    /**
     * @brief[zh-cn] 发射单精度数据点
     *
     * @brief[en] Emit a Float32 data point
     */
    public static func pointF32(name: String, v: Float32): Unit {
        plotFloat_cj(name, v)
    }

    /**
     * @brief[zh-cn] 发射整型数据点
     *
     * @brief[en] Emit an Int64 data point
     */
    public static func pointI64(name: String, v: Int64): Unit {
        plotInt_cj(name, v)
    }
}

// =============================================================================
// Message — 消息与 AppInfo
// =============================================================================

/**
 * @brief[zh-cn] 消息 — Tracy 消息面板的运行时文本（区别于编译期日志）
 * @explain[zh-cn] severity 决定面板中的级别与颜色映射；logTrace/logDebug/
 * logInfo/logWarning/logError/logFatal 为 @Message 宏的展开目标。
 *
 * @brief[en] Messages — runtime text in the Tracy message panel
 * @explain[en] Severity maps to level and color in the message panel; the
 * logTrace/.../logFatal shortcuts are the expansion targets of the @Message
 * macro.
 */
public class ProfMessage {
    /**
     * @brief[zh-cn] 发送一条消息（severity/color 全参数版）
     *
     * @brief[en] Send a message (full severity/color form)
     */
    public static func log(txt: String, severity: TracyMessageSeverity): Unit {
        emitLogStringL_cj(severity, 0, txt)
    }

    /**
     * @brief[zh-cn] 发送 Trace 级消息（@Message 宏 severity=trace）
     *
     * @brief[en] Send a Trace-level message (@Message macro severity=trace)
     */
    public static func logTrace(txt: String): Unit {
        emitLogStringL_cj(TracyMessageSeverity.Trace, 0, txt)
    }

    /**
     * @brief[zh-cn] 发送 Debug 级消息（@Message 宏 severity=debug）
     *
     * @brief[en] Send a Debug-level message (@Message macro severity=debug)
     */
    public static func logDebug(txt: String): Unit {
        emitLogStringL_cj(TracyMessageSeverity.Debug, 0, txt)
    }

    /**
     * @brief[zh-cn] 发送 Info 级消息（@Message 宏默认级别）
     *
     * @brief[en] Send an Info-level message (@Message macro default)
     */
    public static func logInfo(txt: String): Unit {
        emitLogStringL_cj(TracyMessageSeverity.Info, 0, txt)
    }

    /**
     * @brief[zh-cn] 发送 Warning 级消息（@Message 宏 severity=warning）
     *
     * @brief[en] Send a Warning-level message (@Message macro severity=warning)
     */
    public static func logWarning(txt: String): Unit {
        emitLogStringL_cj(TracyMessageSeverity.Warning, 0, txt)
    }

    /**
     * @brief[zh-cn] 发送 Error 级消息（@Message 宏 severity=error）
     *
     * @brief[en] Send an Error-level message (@Message macro severity=error)
     */
    public static func logError(txt: String): Unit {
        emitLogStringL_cj(TracyMessageSeverity.Error, 0, txt)
    }

    /**
     * @brief[zh-cn] 发送 Fatal 级消息（@Message 宏 severity=fatal）
     *
     * @brief[en] Send a Fatal-level message (@Message macro severity=fatal)
     */
    public static func logFatal(txt: String): Unit {
        emitLogStringL_cj(TracyMessageSeverity.Fatal, 0, txt)
    }

    /**
     * @brief[zh-cn] 应用信息（profiler 窗口标题旁一次性显示）
     *
     * @brief[en] Application info (shown once next to the profiler window title)
     */
    public static func appInfo(txt: String): Unit {
        messageAppInfo_cj(txt)
    }
}

// =============================================================================
// Memory — 内存事件
// =============================================================================

/**
 * @brief[zh-cn] 内存事件 — 手动标注分配/释放（Tracy 内存曲线与泄漏视图）
 * @explain[zh-cn] 用于包装自管内存池：alloc/free 按 (ptr,size) 成对上报；
 * [discard] 用于销毁整池（按 name 归零，无需逐个 free）。
 *
 * @brief[en] Memory events — manual alloc/free annotations
 * @explain[en] Wrap custom pools: report alloc/free pairs by (ptr,size);
 * use [discard] to zero out a named pool without per-pointer frees.
 */
public class ProfMemory {
    /**
     * @brief[zh-cn] 上报一次分配（@MemAlloc 宏的展开目标）
     *
     * @brief[en] Report an allocation (expansion target of @MemAlloc)
     */
    public static func alloc(ptr: CPointer<Unit>, size: UIntNative, name: String): Unit {
        emitMemoryAllocNamed_cj(ptr, size, name)
    }

    /**
     * @brief[zh-cn] 上报一次释放（@MemFree 宏的展开目标）
     *
     * @brief[en] Report a free (expansion target of @MemFree)
     */
    public static func free(ptr: CPointer<Unit>, name: String): Unit {
        emitMemoryFreeNamed_cj(ptr, name)
    }

    /**
     * @brief[zh-cn] 按名丢弃整池（该 name 的全部已分配字节归零）
     *
     * @brief[en] Discard a whole named pool (zeroes all bytes booked to name)
     */
    public static func discard(name: String): Unit {
        emitMemoryDiscard_cj(name)
    }
}

// =============================================================================
// Gpu — GPU 时间域
// =============================================================================

/**
 * @brief[zh-cn] GPU 时间域 — GPU 上下文注册与 zone 时间戳上报
 * @explain[zh-cn] 典型流程：backend 初始化后 [newContext] 注册上下文 → 渲染
 * 命令处 [zoneBegin]/[zoneEnd]（与 queryId 配对）→ fence/查询回读后 [time]。
 * 周期 period=0 表示时间戳单位为纳秒。
 *
 * @brief[en] GPU timing domain — context registration and timestamp reporting
 * @explain[en] Typical flow: [newContext] after backend init, [zoneBegin]/
 * [zoneEnd] around GPU work (paired by queryId), then [time] after readback.
 * period=0 means timestamps are in nanoseconds.
 */
public class Gpu {
    /**
     * @brief[zh-cn] 注册 GPU 上下文（context 即上下文 id，0-255）
     *
     * @brief[en] Register a GPU context (context is the context id, 0-255)
     */
    public static func newContext(gpuTime: Int64, period: Float32, context: UInt8,
                                  flags: UInt8, kind: UInt8): Unit {
        emitGpuNewContext_cj(TracyGpuNewContextData(gpuTime, period, context, flags, kind))
    }

    /**
     * @brief[zh-cn] GPU zone 开始（queryId 与 zoneEnd/time 配对）
     *
     * @brief[en] Begin a GPU zone (queryId pairs with zoneEnd/time)
     */
    public static func zoneBegin(srcloc: UInt64, queryId: UInt16, context: UInt8): Unit {
        emitGpuZoneBeginAlloc_cj(TracyGpuZoneBeginData(srcloc, queryId, context))
    }

    /**
     * @brief[zh-cn] GPU zone 结束（queryId 与 zoneBegin 配对）
     *
     * @brief[en] End a GPU zone (queryId pairs with zoneBegin)
     */
    public static func zoneEnd(queryId: UInt16, context: UInt8): Unit {
        emitGpuZoneEnd_cj(TracyGpuZoneEndData(queryId, context))
    }

    /**
     * @brief[zh-cn] 上报 GPU 时间戳（fence/查询回读后）
     *
     * @brief[en] Report a GPU timestamp (after fence/query readback)
     */
    public static func time(gpuTime: Int64, queryId: UInt16, context: UInt8): Unit {
        emitGpuTime_cj(TracyGpuTimeData(gpuTime, queryId, context))
    }

    /**
     * @brief[zh-cn] 命名 GPU 上下文（Tracy GPU 面板显示）
     *
     * @brief[en] Name a GPU context (shown in the Tracy GPU panel)
     */
    public static func contextName(context: UInt8, name: String): Unit {
        let bytes = name.toArray()
        let p = unsafe { LibC.malloc<UInt8>(count: bytes.size + 1) }
        if (unsafe { p.isNull() }) {
            return
        }
        for (i in 0..bytes.size) {
            unsafe { (p + i).write(bytes[i]) }
        }
        unsafe { (p + bytes.size).write(0) }
        emitGpuContextName_cj(TracyGpuContextNameData(context, p, UInt16(bytes.size)))
        unsafe { LibC.free(p) }
    }

    /**
     * @brief[zh-cn] 时钟校准（CPU/GPU 时钟域漂移修正）
     *
     * @brief[en] Clock calibration (CPU/GPU clock-domain drift correction)
     */
    public static func calibration(gpuTime: Int64, cpuDelta: Int64, context: UInt8): Unit {
        emitGpuCalibration_cj(TracyGpuCalibrationData(gpuTime, cpuDelta, context))
    }

    /**
     * @brief[zh-cn] GPU 时间同步点
     *
     * @brief[en] GPU time sync point
     */
    public static func timeSync(gpuTime: Int64, context: UInt8): Unit {
        emitGpuTimeSync_cj(TracyGpuTimeSyncData(gpuTime, context))
    }
}

// =============================================================================
// Lock — 锁竞争跟踪
// =============================================================================

/**
 * @brief[zh-cn] 锁竞争跟踪 — lockable/shared-lockable 上下文的登记与事件
 * @explain[zh-cn] 登记后的 lockdata 句柄须传给后续 before/after 事件；Tracy
 * 锁面板据此展示等待/持有时间线。典型用法是封装进自定义 Mutex/RwLock 内部。
 *
 * @brief[en] Lock contention tracking — lockable/shared-lockable contexts
 * @explain[en] Keep the announced lockdata handle and feed before/after events;
 * the Tracy lock panel renders wait/hold timelines. Typical use is embedding
 * into custom Mutex/RwLock implementations.
 */
public class Lock {
    /**
     * @brief[zh-cn] 登记互斥锁跟踪上下文（返回句柄，须保存）
     *
     * @brief[en] Announce a lockable tracking context (keep the returned handle)
     */
    public static func announce(name: String, file: String, line: UInt32,
                                function: String): CPointer<Unit> {
        let data = buildSrcloc(name, file, line, function)
        return announceLockableCtx_cj(data)
    }

    /**
     * @brief[zh-cn] 登记读写锁跟踪上下文
     *
     * @brief[en] Announce a shared-lockable tracking context
     */
    public static func announceShared(name: String, file: String, line: UInt32,
                                      function: String): CPointer<Unit> {
        let data = buildSrcloc(name, file, line, function)
        return announceSharedLockableCtx_cj(data)
    }

    /**
     * @brief[zh-cn] 构造静态源位置结构（name/function/file 三段 C 字符串打包
     *               在一段缓冲内，缓冲生命周期 = Tracy 锁上下文生命周期，
     *               故意不释放）
     *
     * @brief[en] Build the static source-location struct (name/function/file
     *            packed into one buffer; the buffer intentionally lives as long
     *            as the Tracy lock context and is never freed)
     */
    private static func buildSrcloc(name: String, file: String, line: UInt32,
                                    function: String): TracySourceLocationData {
        // 打包 "name\0function\0file\0"，三段指针指向各自段首
        // Pack "name\0function\0file\0"; the three pointers target segment heads
        let packed = "${name}\u{0}${function}\u{0}${file}"
        let bytes = packed.toArray()
        let p = unsafe { LibC.malloc<UInt8>(count: bytes.size + 1) }
        if (unsafe { p.isNull() }) {
            return TracySourceLocationData(CPointer<UInt8>(), CPointer<UInt8>(),
                                           CPointer<UInt8>(), line, 0)
        }
        for (i in 0..bytes.size) {
            unsafe { (p + i).write(bytes[i]) }
        }
        unsafe { (p + bytes.size).write(0) }
        // 扫描缓冲定位三个段首（\0 分隔）
        // Scan the buffer for the three segment heads (\0 separated)
        var segs = ArrayList<CPointer<UInt8>>()
        segs.add(p)
        for (i in 0..bytes.size) {
            if (unsafe { (p + i).read() } == 0 && segs.size < 3) {
                segs.add(unsafe { p + i + 1 })
            }
        }
        return TracySourceLocationData(segs[0], segs[1], segs[2], line, 0)
    }

    /**
     * @brief[zh-cn] 注销互斥锁跟踪上下文
     *
     * @brief[en] Terminate a lockable tracking context
     */
    public static func terminate(lockdata: CPointer<Unit>): Unit {
        if (lockdata.isNull()) {
            return
        }
        terminateLockableCtx_cj(lockdata)
    }

    /**
     * @brief[zh-cn] 注销读写锁跟踪上下文
     *
     * @brief[en] Terminate a shared-lockable tracking context
     */
    public static func terminateShared(lockdata: CPointer<Unit>): Unit {
        if (lockdata.isNull()) {
            return
        }
        terminateSharedLockableCtx_cj(lockdata)
    }

    /**
     * @brief[zh-cn] 加锁前（Tracy 语义转发：返回是否应继续）
     *
     * @brief[en] Before lock (Tracy semantics forwarded: whether to proceed)
     */
    public static func beforeLock(lockdata: CPointer<Unit>): Bool {
        if (lockdata.isNull()) {
            return true
        }
        return beforeLockLockableCtx_cj(lockdata)
    }

    /**
     * @brief[zh-cn] 加锁成功后
     *
     * @brief[en] After a successful lock
     */
    public static func afterLock(lockdata: CPointer<Unit>): Unit {
        if (lockdata.isNull()) {
            return
        }
        afterLockLockableCtx_cj(lockdata)
    }

    /**
     * @brief[zh-cn] 解锁后
     *
     * @brief[en] After unlock
     */
    public static func afterUnlock(lockdata: CPointer<Unit>): Unit {
        if (lockdata.isNull()) {
            return
        }
        afterUnlockLockableCtx_cj(lockdata)
    }

    /**
     * @brief[zh-cn] try-lock 后（acquired = 是否成功）
     *
     * @brief[en] After try-lock (acquired = whether it succeeded)
     */
    public static func afterTryLock(lockdata: CPointer<Unit>, acquired: Bool): Unit {
        if (lockdata.isNull()) {
            return
        }
        afterTryLockLockableCtx_cj(lockdata, acquired)
    }
}

// =============================================================================
// Fiber — 纤维/协程切换标记
// =============================================================================

/**
 * @brief[zh-cn] 纤维标记 — 自定义调度器/协程切换时告知 Tracy 当前执行流
 * @explain[zh-cn] enter/leave 必须严格配对；Tracy 据此把事件归到正确的
 * 逻辑执行流（fiber）而非物理线程。
 *
 * @brief[en] Fiber marks — logical execution flow for custom schedulers
 * @explain[en] enter/leave must be strictly paired; events are attributed to
 * the logical flow instead of the physical thread.
 */
public class ProfFiber {
    /**
     * @brief[zh-cn] 进入纤维
     *
     * @brief[en] Enter the fiber
     */
    public static func enter(name: String): Unit {
        fiberEnter_cj(name)
    }

    /**
     * @brief[zh-cn] 离开纤维
     *
     * @brief[en] Leave the fiber
     */
    public static func leave(): Unit {
        fiberLeave_cj()
    }
}

// =============================================================================
// GpuZone / LockZone / FiberScope — Resource 作用域类（宏与 try-with-resources 用）
// =============================================================================

/**
 * @brief[zh-cn] GPU zone 作用域 — try/finally 或宏包裹 GPU 命令区间
 * @explain[zh-cn] 构造时取一个 queryId 并发射 gpuZoneBegin；close 时发射
 * gpuZoneEnd。时间戳由渲染 backend 在 fence 回读后用 Gpu.time 上报。
 * queryId 全局自增（AtomicInt64），context 默认 0。
 *
 * @brief[en] GPU zone scope — wraps GPU command recording
 * @explain[en] Constructor grabs a queryId and emits gpuZoneBegin; close emits
 * gpuZoneEnd. Timestamps are reported later via Gpu.time after fence readback.
 */
public class ProfGpuZone <: Resource {
    /**
     * @brief[zh-cn] queryId 全局自增计数器（跨线程安全）
     *
     * @brief[en] Global auto-increment queryId counter (thread-safe)
     */
    private static let NEXT_QUERY = AtomicInt64(0)

    /**
     * @brief[zh-cn] 本 zone 的查询 id（与 gpuZoneEnd/Gpu.time 配对）
     *
     * @brief[en] Query id of this zone (pairs with gpuZoneEnd/Gpu.time)
     */
    private let queryId: UInt16

    /**
     * @brief[zh-cn] 所属 GPU 上下文 id
     *
     * @brief[en] Owning GPU context id
     */
    private let context: UInt8

    /**
     * @brief[zh-cn] 源位置句柄（Tracy 内部缓存）
     *
     * @brief[en] Source-location handle (cached inside Tracy)
     */
    private let srcloc: UInt64

    /**
     * @brief[zh-cn] 是否已发射 gpuZoneEnd
     *
     * @brief[en] Whether gpuZoneEnd has been emitted
     */
    private var ended: Bool

    /**
     * @brief[zh-cn] 开始一个 GPU zone（name 为显示名，context 为 GPU 上下文 id）
     *
     * @brief[en] Begin a GPU zone (name is the display label, context the GPU
     *            context id)
     */
    public init(name: String, context: UInt8, file: String, line: UInt32) {
        this.queryId = UInt16(NEXT_QUERY.fetchAdd(1) & 0xFFFF)
        this.context = context
        this.srcloc = ProfZone.srclocHandle(name, file, line, name, 0)
        emitGpuZoneBeginAlloc_cj(TracyGpuZoneBeginData(srcloc, queryId, context))
        this.ended = false
    }

    /**
     * @brief[zh-cn] 本 zone 的 queryId（渲染 backend fence 回读后传给 Gpu.time）
     *
     * @brief[en] Query id of this zone (pass to Gpu.time after fence readback)
     */
    public prop query: UInt16 {
        get() { queryId }
    }

    /**
     * @brief[zh-cn] 本 zone 所属 GPU 上下文 id
     *
     * @brief[en] GPU context id this zone belongs to
     */
    public prop ctx: UInt8 {
        get() { context }
    }

    /**
     * @brief[zh-cn] 发射 gpuZoneEnd（幂等；try-with-resources 自动调用）
     *
     * @brief[en] Emit gpuZoneEnd (idempotent; auto-called by try-with-resources)
     */
    public func close(): Unit {
        if (ended) {
            return
        }
        emitGpuZoneEnd_cj(TracyGpuZoneEndData(queryId, context))
        ended = true
    }

    /**
     * @brief[zh-cn] Resource.isClosed
     *
     * @brief[en] Resource.isClosed
     */
    public func isClosed(): Bool {
        return ended
    }
}

/**
 * @brief[zh-cn] 锁跟踪作用域 — 登记 lockable 上下文并在退出时上报 unlock
 * @explain[zh-cn] 构造时 announce（同名链路只登记一次）并发射 beforeLock；
 * close 时发射 afterUnlock。用于宏把自定义临界区包装成 Tracy 锁时间线。
 * 注意：这是"作用域锁"语义（进入即持有），真正的 lock/unlock 粒度请用
 * Lock 静态 API 手写。
 *
 * @brief[en] Lock-tracking scope — announces a lockable context and reports
 * unlock on exit. Scope-lock semantics: enter = held, close = afterUnlock.
 */
public class ProfLockZone <: Resource {
    /**
     * @brief[zh-cn] 已登记的锁上下文缓存：键 name → lockdata 句柄
     *               （Tracy 侧长期持有）
     *
     * @brief[en] Announced lock-context cache: name -> lockdata handle
     *            (held long-term on the Tracy side)
     */
    private static let ANNOUNCED = ConcurrentHashMap<String, CPointer<Unit>>()

    /**
     * @brief[zh-cn] 本锁的跟踪句柄
     *
     * @brief[en] Tracking handle of this lock
     */
    private let lockdata: CPointer<Unit>

    /**
     * @brief[zh-cn] 锁显示名
     *
     * @brief[en] Lock display name
     */
    private let name: String

    /**
     * @brief[zh-cn] 是否已发射 afterUnlock
     *
     * @brief[en] Whether afterUnlock has been emitted
     */
    private var done: Bool

    /**
     * @brief[zh-cn] 登记并进入锁作用域（beforeLock + afterLock）
     *
     * @brief[en] Announce and enter the lock scope (beforeLock + afterLock)
     */
    public init(name: String, file: String, line: UInt32) {
        // 慢路径登记（announce 幂等开销小，快路径查缓存）
        // Slow path announces; fast path reads the cache
        match (ANNOUNCED.get(name)) {
            case Some(h) =>
                this.lockdata = h
            case None =>
                let h = Lock.announce(name, file, line, name)
                ANNOUNCED.add(name, h)
                this.lockdata = h
        }
        this.name = name
        this.done = false
        Lock.beforeLock(lockdata)
        Lock.afterLock(lockdata)
    }

    /**
     * @brief[zh-cn] 释放（发射 afterUnlock，幂等；try-with-resources 自动调用）
     *
     * @brief[en] Release (emits afterUnlock; idempotent; auto-called by
     *            try-with-resources)
     */
    public func close(): Unit {
        if (done) {
            return
        }
        Lock.afterUnlock(lockdata)
        done = true
    }

    /**
     * @brief[zh-cn] Resource.isClosed
     *
     * @brief[en] Resource.isClosed
     */
    public func isClosed(): Bool {
        return done
    }
}

/**
 * @brief[zh-cn] 纤维作用域 — try/finally 或宏包裹纤维主体
 * @explain[zh-cn] 构造时 ProfFiber.enter(name)，close 时 ProfFiber.leave()；
 * enter/leave 严格配对，把区间内事件归属到该逻辑执行流。
 *
 * @brief[en] Fiber scope — wraps a fiber body; enter on construction,
 * leave on close (strictly paired).
 */
public class FiberScope <: Resource {
    /**
     * @brief[zh-cn] 是否已离开纤维
     *
     * @brief[en] Whether the fiber has been left
     */
    private var done: Bool

    /**
     * @brief[zh-cn] 进入纤维作用域
     *
     * @brief[en] Enter the fiber scope
     */
    public init(name: String) {
        ProfFiber.enter(name)
        this.done = false
    }

    /**
     * @brief[zh-cn] 离开纤维（幂等；try-with-resources 自动调用）
     *
     * @brief[en] Leave the fiber (idempotent; auto-called by try-with-resources)
     */
    public func close(): Unit {
        if (done) {
            return
        }
        ProfFiber.leave()
        done = true
    }

    /**
     * @brief[zh-cn] Resource.isClosed
     *
     * @brief[en] Resource.isClosed
     */
    public func isClosed(): Bool {
        return done
    }
}

// =============================================================================
// Sampling / 状态查询
// =============================================================================

/**
 * @brief[zh-cn] 采样剖析 — 调用栈采样的启停控制
 *
 * @brief[en] Sampling — start/stop control of call-stack sampling.
 */
public class Sampling {
    /**
     * @brief[zh-cn] 启动调用栈采样（成功返回 true）
     *
     * @brief[en] Start call-stack sampling (true on success)
     */
    public static func start(): Bool {
        return beginSamplingProfiling_cj()
    }

    /**
     * @brief[zh-cn] 停止采样
     *
     * @brief[en] Stop sampling
     */
    public static func stop(): Unit {
        endSamplingProfiling_cj()
    }
}

/**
 * @brief[zh-cn] 状态查询 — 连接状态/时钟/线程名
 *
 * @brief[en] State queries — connection status, clock, thread name.
 */
public class ProfilerState {
    /**
     * @brief[zh-cn] profiler GUI 是否已连接
     *
     * @brief[en] Whether the profiler GUI is connected
     */
    public static func isConnected(): Bool {
        return isConnected_cj()
    }

    /**
     * @brief[zh-cn] Tracy 高精度时钟当前值
     *
     * @brief[en] Current value of the Tracy high-resolution clock
     */
    public static func now(): Int64 {
        return getTime_cj()
    }

    /**
     * @brief[zh-cn] 设置当前线程显示名（Tracy 线程面板）
     *
     * @brief[en] Set the display name of the current thread (Tracy thread panel)
     */
    public static func threadName(name: String): Unit {
        setThreadName_cj(name)
    }
}
