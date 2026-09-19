package threeProfileTest

/**
 * profile 测试项目：three.profiler 宏自动化侵入验证
 *
 * 测试内容（覆盖 three.profiler.macros 全部常用宏）：
 * - @Zone        函数级（修饰函数声明）+ 区间级（包裹代码块）
 * - @FrameMark   主帧标记
 * - @Plot/@PlotI64 值透传曲线
 * - @Message     值透传消息（severity 分级）
 * - @Fiber       纤维执行流包裹
 * - @MemAlloc/@MemFree 内存事件
 * - @LockTrack   临界区锁时间线
 *
 * 运行方式（链路由编译期环境变量 THREE_PROFILER 决定，见 README）：
 *   set THREE_PROFILER=all      → 全部侵入
 *   set THREE_PROFILER=three.test → 仅 three.test.* 链路侵入
 *   set THREE_PROFILER=off      → 全部零侵入（默认）
 *
 * 剖析数据查看：启动 Tracy GUI（tracy4cj 仓库）后运行本程序即可连接；
 * 无 GUI 时程序照常运行（Tracy 客户端静默丢弃数据）。
 * 本项目同时输出控制台剖析测试报告（zone 计时对照 + 耗时统计）。
 */

import std.time.*
// 通配导入门面 + 宏包：门面类已加 Prof 前缀（ProfZone/ProfPlot/...），与宏名不冲突；
// 宏展开代码引用门面类型名（ProfZone 等），由本通配导入补齐
import three.profiler.*
import three.profiler.macros.*

// =============================================================================
// 被测函数：函数级 @Zone / 值透传宏
// =============================================================================

/**
 * @brief 函数级 @Zone：函数体重写为 try{}finally{} 包裹的 zone
 *        链路 three.test.zone.func
 */
@Zone[three.test.zone.func]
func simulateFrameWork(): Unit {
    // 模拟一帧的逻辑负载（纯计算）
    var acc: Float64 = 0.0
    for (i in 0..200000) {
        acc += Float64(i) * 0.001 + 0.5
    }
}

/**
 * @brief 函数级 @Zone（显式链路 "three"）
 *        注：本宏包全部宏都声明了属性参数，调用必须带 [链路]
 */
@Zone[three]
func defaultLinkWork(): Unit {
    var acc: Float64 = 0.0
    for (i in 0..100000) {
        acc += Float64(i) * 0.5
    }
}

/**
 * @brief 普通函数：被 @Plot 包裹求值（@Plot 是表达式宏，不能修饰声明）
 */
func computeFps(frameIndex: Int64): Float64 {
    return 1000.0 / 16.67 + Float64(frameIndex % 7)
}

/**
 * @brief 普通函数：被 @PlotI64 包裹求值
 */
func computeBatchCount(): Int64 {
    // 简单扰动，避免每次点值相同（Tracy 曲线更直观）
    return 128 + Int64(computeFps(0)) % 64
}

/**
 * @brief 普通函数：被 @Message 包裹求值
 */
func currentState(): String {
    return "running"
}

// =============================================================================
// 主流程：区间级宏 + 帧标记 + 报告输出
// =============================================================================

main(): Int64 {
    let startTime = MonoTime.now()
    println("===== three.profiler 宏自动化侵入测试 =====")
    println("THREE_PROFILER 在编译期读取；本产物档位见 README（off=零侵入 / all=全侵入 / 链路=按段级前缀）")
    println("")

    // ---- 1. 函数级 @Zone ----
    println("[1] 函数级 @Zone（three.test.zone.func / 默认链路）")
    for (i in 0..30) {
        simulateFrameWork()
        defaultLinkWork()
    }

    // ---- 2. 区间级 @Zone + @FrameMark/@FrameStart/@FrameEnd ----
    println("[2] 区间级 @Zone + 帧标记")
    for (i in 0..30) {
        @FrameStart[three.test.frame.render]( @Zone[three.test.zone.block]( simulateFrameWork() ) )
        @FrameMark[three.test.frame]( simulateFrameWork() )
        @FrameEnd[three.test.frame.render]( simulateFrameWork() )
    }

    // ---- 3. 值透传宏（@Plot/@PlotI64/@Message）----
    println("[3] 值透传宏（@Plot/@PlotI64/@Message）")
    var fpsSum: Float64 = 0.0
    for (i in 0..30) {
        // 宏展开后原值照常参与外层运算（表达式位置）
        fpsSum += @Plot[three.test.plot.fps]( computeFps(i) )
        let batches = @PlotI64[three.test.plot.batch]( computeBatchCount() )
        let state = @Message[three.test.msg.state]( currentState() )
        if (i == 0) {
            println("    fps(0)=${fpsSum}  batches=${batches}  state=${state}")
        }
    }

    // ---- 4. @Fiber 纤维流 + @LockTrack 锁时间线 ----
    println("[4] @Fiber + @LockTrack")
    for (i in 0..10) {
        @Fiber[three.test.fiber.worker]( simulateFrameWork() )
        @LockTrack[three.test.lock.registry]( simulateFrameWork() )
    }

    // ---- 5. @MemAlloc/@MemFree 内存事件 ----
    println("[5] @MemAlloc/@MemFree")
    for (i in 0..10) {
        let p = @MemAlloc[three.test.pool.geo, size=4096]( mallocBlock(4096) )
        @MemFree[three.test.pool.geo]( freeBlock(p) )
    }

    // ---- 报告输出 ----
    let elapsed: Duration = MonoTime.now() - startTime
    let elapsedMs = Float64(elapsed.toMilliseconds())
    println("")
    println("===== 剖析测试报告 =====")
    println("总耗时        : ${elapsedMs} ms")
    println("函数级 @Zone  : 30 次 simulateFrameWork + 30 次 defaultLinkWork")
    println("区间级 @Zone  : 30 次（three.test.zone.block）")
    println("帧标记        : FrameStart/FrameEnd(three.test.frame.render) x30, FrameMark x30")
    println("Plot 曲线     : fps 30 点(均值 ${(fpsSum / 30.0)}) + batch 30 点")
    println("消息/纤维/锁  : Message x30, Fiber x10, LockTrack x10")
    println("内存事件      : MemAlloc/MemFree(three.test.pool.geo) x10 (4096B/次)")
    println("")
    println("若 THREE_PROFILER=all 构建：连接 Tracy GUI 可见上述全部链路；")
    println("若 off 构建：以上宏全部零展开，本报告耗时与非剖析版本一致。")
    return 0
}

// =============================================================================
// FFI 辅助：malloc/free 一块内存（供 @MemAlloc/@MemFree 测试）
// =============================================================================

/**
 * @brief 分配 size 字节内存块（返回任意类型指针）
 *
 * @brief Allocate a block of size bytes
 */
func mallocBlock(size: Int64): CPointer<UInt8> {
    let p = unsafe { LibC.malloc<UInt8>(count: size) }
    if (unsafe { p.isNull() }) {
        throw Exception("mallocBlock failed")
    }
    return p
}

/**
 * @brief 释放内存块（透传指针，宏在其后上报 free 事件）
 *
 * @brief Free the block (pointer passes through for the macro to report)
 */
func freeBlock(p: CPointer<UInt8>): CPointer<UInt8> {
    unsafe { LibC.free(p) }
    return p
}
