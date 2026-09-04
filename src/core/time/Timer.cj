/**
 * @file[zh-cn] 计时器
 * @brief[zh-cn] 替代 Clock 的高性能计时器
 * @explain[zh-cn] Timer 相比 Clock 的改进：使用 update() 方法更新内部状态，使得 getDelta() 和 getElapsed() 在同一帧内多次调用返回相同值；支持时间缩放（timescale）；支持固定时间步长（useFixedDelta）；在 bgfx 环境下不使用 Page Visibility API（无 DOM 依赖）。
 *
 * @file[en] Timer
 * @brief[en] High-performance timer replacing Clock
 * @explain[en] Improvements over Clock: uses update() to refresh internal state, so getDelta() and getElapsed() return the same value within a single frame; supports time scaling (timescale); supports fixed time step (useFixedDelta); no Page Visibility API dependency in bgfx environments (no DOM dependency).
 */
package three.core.time

import std.time.*

/**
 * @brief[zh-cn] 高性能计时器类
 * @explain[zh-cn] Timer 是 Clock 的替代方案，具有不同的 API 设计和行为：使用 update() 方法更新内部状态，使得 getDelta() 和 getElapsed() 在同一模拟步骤中多次调用返回相同值；支持时间缩放（timescale），可控制时间流速；支持固定时间步长模式。
 *
 * @brief[en] High-performance timer class
 * @explain[en] Timer is a replacement for Clock with a different API design and behavior: uses update() to refresh internal state, so getDelta() and getElapsed() return the same value within a single simulation step; supports time scaling (timescale) to control time flow; supports fixed time step mode.
 */
public class Timer {
    /** 上一次时间（毫秒偏移量） */
    private var _previousTime: Float64

    /** 当前时间（毫秒偏移量） */
    private var _currentTime: Float64

    /** 起始时间戳（MonoTime） */
    private var _startTime: MonoTime

    /** 时间增量（毫秒） */
    private var _delta: Float64

    /** 累计经过时间（毫秒） */
    private var _elapsed: Float64

    /** 时间缩放因子，默认为 1.0 */
    private var _timescale: Float64

    /**
     * @brief[zh-cn] 是否使用固定时间步长
     *
     * @brief[en] Whether to use fixed time step
     */
    public var useFixedDelta: Bool

    /**
     * @brief[zh-cn] 固定时间步长值（秒）
     *
     * @brief[en] Fixed time step value (in seconds)
     */
    public var fixedDelta: Float64

    /**
     * @brief[zh-cn] 构造一个新的计时器
     *
     * @brief[en] Construct a new timer
     */
    public init() {
        this._startTime = MonoTime.now()
        this._previousTime = 0.0
        this._currentTime = 0.0
        this._delta = 0.0
        this._elapsed = 0.0
        this._timescale = 1.0
        this.useFixedDelta = false
        this.fixedDelta = 1.0 / 60.0
    }

    /**
     * @brief[zh-cn] 获取时间增量（秒）
     * @return[zh-cn] 自上次 update() 以来的时间增量（秒）
     *
     * @brief[en] Get the time delta (in seconds)
     * @return[en] Time delta since the last update() call (in seconds)
     */
    public func getDelta(): Float64 {
        return this._delta / 1000.0
    }

    /**
     * @brief[zh-cn] 获取累计经过时间（秒）
     * @return[zh-cn] 自计时器启动以来的累计时间（秒）
     *
     * @brief[en] Get the cumulative elapsed time (in seconds)
     * @return[en] Cumulative time since the timer started (in seconds)
     */
    public func getElapsed(): Float64 {
        return this._elapsed / 1000.0
    }

    /**
     * @brief[zh-cn] 获取时间缩放因子
     * @return[zh-cn] 当前的时间缩放因子
     *
     * @brief[en] Get the time scaling factor
     * @return[en] Current time scaling factor
     */
    public func getTimescale(): Float64 {
        return this._timescale
    }

    /**
     * @brief[zh-cn] 设置时间缩放因子
     * @param[zh-cn] timescale 时间缩放因子，1.0 为正常速度
     * @return[zh-cn] 当前计时器实例（支持链式调用）
     *
     * @brief[en] Set the time scaling factor
     * @param[en] timescale Time scaling factor, 1.0 for normal speed
     * @return[en] Current timer instance (supports chaining)
     */
    public func setTimescale(timescale: Float64): Timer {
        this._timescale = timescale
        return this
    }

    /**
     * @brief[zh-cn] 重置计时器，将当前时间重置为 0
     * @return[zh-cn] 当前计时器实例（支持链式调用）
     *
     * @brief[en] Reset the timer, setting the current time to 0
     * @return[en] Current timer instance (supports chaining)
     */
    public func reset(): Timer {
        this._currentTime = Float64((MonoTime.now() - this._startTime).toMilliseconds())
        return this
    }

    /**
     * @brief[zh-cn] 释放资源
     * @explain[zh-cn] bgfx 环境下无 DOM 依赖，无需额外清理。
     *
     * @brief[en] Release resources
     * @explain[en] No DOM dependency in bgfx environments, no additional cleanup needed.
     */
    public func dispose(): Unit {
        // bgfx 环境下无 DOM 依赖，无需额外清理
    }

    /**
     * @brief[zh-cn] 更新计时器内部状态
     * @explain[zh-cn] 此方法应在每个模拟步骤中调用一次，在查询 getDelta() 或 getElapsed() 之前调用。如果使用固定时间步长模式（useFixedDelta = true），则使用 fixedDelta 作为时间增量。
     * @param[zh-cn] timestamp 可选的时间戳（毫秒），如果不提供则使用当前时间
     * @return[zh-cn] 当前计时器实例（支持链式调用）
     *
     * @brief[en] Update the timer's internal state
     * @explain[en] This method should be called once per simulation step, before querying getDelta() or getElapsed(). If fixed time step mode is enabled (useFixedDelta = true), fixedDelta is used as the time delta.
     * @param[en] timestamp Optional timestamp (in milliseconds); if not provided, current time is used
     * @return[en] Current timer instance (supports chaining)
     */
    public func update(timestamp!: Float64 = -1.0): Timer {
        if (this.useFixedDelta) {
            this._delta = this.fixedDelta * 1000.0 * this._timescale
        } else {
            this._previousTime = this._currentTime
            if (timestamp >= 0.0) {
                this._currentTime = timestamp - Float64((MonoTime.now() - this._startTime).toMilliseconds()) + this._currentTime
                // 使用提供的时间戳
                this._currentTime = timestamp
            } else {
                this._currentTime = Float64((MonoTime.now() - this._startTime).toMilliseconds())
            }
            this._delta = (this._currentTime - this._previousTime) * this._timescale
        }
        this._elapsed += this._delta
        return this
    }

    /**
     * @brief[zh-cn] 启动计时器（旧版兼容）
     * @explain[zh-cn] 此方法为向后兼容保留，推荐使用 update() 代替。
     *
     * @brief[en] Start the timer (legacy compatibility)
     * @explain[en] This method is retained for backward compatibility; use update() instead.
     */
    public func start(): Unit {
        this._startTime = MonoTime.now()
        this._previousTime = 0.0
        this._currentTime = 0.0
        this._delta = 0.0
        this._elapsed = 0.0
    }

    /**
     * @brief[zh-cn] 停止计时器（旧版兼容）
     * @explain[zh-cn] 此方法为向后兼容保留。Timer 不需要显式停止，不调用 update() 即可。
     *
     * @brief[en] Stop the timer (legacy compatibility)
     * @explain[en] This method is retained for backward compatibility. Timer does not need explicit stopping; simply not calling update() suffices.
     */
    public func stop(): Unit {
        // Timer 不需要显式停止，不调用 update() 即可
    }
}
