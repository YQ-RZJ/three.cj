/**
 * @file[zh-cn] 时钟
 * @brief[zh-cn] 用于跟踪时间的时钟类
 * @explain[zh-cn] Clock 可用于跟踪经过的时间。如果 autoStart 为 true，则在第一次调用 getDelta() 或 getElapsedTime() 时自动启动。自 r183 起已废弃，推荐使用 Timer 替代。
 *
 * @file[en] Clock
 * @brief[en] Clock class for tracking time
 * @explain[en] Clock can be used to track elapsed time. If autoStart is true, it automatically starts on the first call to getDelta() or getElapsedTime(). Deprecated since r183, use Timer instead.
 */
package three.core.time

import std.time.*

/**
 * @brief[zh-cn] 用于跟踪时间的时钟类
 * @explain[zh-cn] Clock 可用于跟踪经过的时间。如果 autoStart 为 true，则会在第一次调用 getDelta() 或 getElapsedTime() 时自动启动。自 r183 起已废弃，推荐使用 Timer 替代。
 *
 * @brief[en] Clock class for tracking time
 * @explain[en] Clock can be used to track elapsed time. If autoStart is true, it automatically starts on the first call to getDelta() or getElapsedTime(). Deprecated since r183, use Timer instead.
 */
public class Clock {
    /**
     * @brief[zh-cn] 是否在第一次调用 getDelta() 时自动启动时钟
     *
     * @brief[en] Whether to automatically start the clock on the first call to getDelta()
     */
    public var autoStart: Bool

    /** 上次调用 start()、getElapsedTime() 或 getDelta() 时的时间戳 */
    private var startTime: MonoTime

    /** 上次调用 start()、getElapsedTime() 或 getDelta() 时的时间戳 */
    private var oldTime: MonoTime

    /** 时钟运行的总时间（秒） */
    private var elapsedTime: Float64

    /** 时钟是否正在运行 */
    private var running: Bool

    /**
     * @brief[zh-cn] 构造一个新的时钟
     * @param[zh-cn] autoStart 是否在第一次调用 getDelta() 时自动启动，默认为 true
     *
     * @brief[en] Construct a new clock
     * @param[en] autoStart Whether to automatically start on the first call to getDelta(), defaults to true
     *
     * @deprecated 推荐使用 Timer 替代
     */
    public init(autoStart!: Bool = true) {
        this.autoStart = autoStart
        this.startTime = MonoTime.now()
        this.oldTime = this.startTime
        this.elapsedTime = 0.0
        this.running = false
    }

    /**
     * @brief[zh-cn] 启动时钟
     * @explain[zh-cn] 当 autoStart 为 true 时，此方法会在第一次调用 getDelta() 时自动调用。
     *
     * @brief[en] Start the clock
     * @explain[en] When autoStart is true, this method is automatically called on the first call to getDelta().
     */
    public func start(): Unit {
        this.startTime = MonoTime.now()
        this.oldTime = this.startTime
        this.elapsedTime = 0.0
        this.running = true
    }

    /**
     * @brief[zh-cn] 停止时钟
     *
     * @brief[en] Stop the clock
     */
    public func stop(): Unit {
        this.getElapsedTime()
        this.running = false
    }

    /**
     * @brief[zh-cn] 获取自时钟启动以来经过的总时间（秒）
     * @explain[zh-cn] 如果 autoStart 为 true 且时钟未运行，则会自动启动时钟。
     * @return[zh-cn] 经过的总时间（秒）
     *
     * @brief[en] Get the total elapsed time since the clock started (in seconds)
     * @explain[en] If autoStart is true and the clock is not running, it will automatically start the clock.
     * @return[en] Total elapsed time (in seconds)
     */
    public func getElapsedTime(): Float64 {
        this.getDelta()
        return this.elapsedTime
    }

    /**
     * @brief[zh-cn] 获取自上次调用 getDelta() 以来的时间增量（秒）
     * @explain[zh-cn] 如果 autoStart 为 true 且时钟未运行，则会自动启动时钟并返回 0。如果时钟已停止，则返回 0。
     * @return[zh-cn] 时间增量（秒）
     *
     * @brief[en] Get the time delta since the last call to getDelta() (in seconds)
     * @explain[en] If autoStart is true and the clock is not running, it will automatically start and return 0. If the clock has been stopped, it returns 0.
     * @return[en] Time delta (in seconds)
     */
    public func getDelta(): Float64 {
        var diff: Float64 = 0.0

        if (this.autoStart && !this.running) {
            this.start()
            return 0.0
        }

        if (this.running) {
            let now = MonoTime.now()
            diff = Float64((now - this.oldTime).toMilliseconds()) / 1000.0
            this.oldTime = now
            this.elapsedTime += diff
        }

        return diff
    }
}
