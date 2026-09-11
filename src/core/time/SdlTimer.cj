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
 *
 * @file[zh-cn] SdlTimer
 * @brief[zh-cn] 基于 SDL_timer 的高精度定时器工具
 * @explain[zh-cn] 基于 sdl4cj 库做高级封装（对应 SDL_timer.h），与 core/time 内已有的 Clock / Timer（Three.js 风格，基于 MonoTime）互补：Clock / Timer 用于引擎内帧计时、时间缩放、固定步长；SdlTimer 用于低层 SDL 计时原语（自 SDL 初始化起的 tick、高精度性能计数器、延时）。全部为静态方法，无需实例化。
 *
 * @file[en] SdlTimer
 * @brief[en] High-precision timer utility based on SDL_timer
 * @explain[en] High-level wrapper based on sdl4cj library (corresponding to SDL_timer.h), complementing the existing Clock / Timer in core/time (Three.js style, based on MonoTime): Clock / Timer for engine frame timing, time scaling, fixed step; SdlTimer for low-level SDL timing primitives (ticks since SDL init, high-precision performance counter, delay). All methods are static, no instantiation needed.
 */
package three.core.time

import std.core.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] SDL 定时器工具（静态方法）
 * @explain[zh-cn] 提供基于 SDL 的低层计时原语，包括获取自 SDL 初始化以来的毫秒/纳秒数、高精度性能计数器及其频率、以及毫秒/纳秒级延时。全部为静态方法，无需实例化。
 *
 * @brief[en] SDL timer utility (static methods)
 * @explain[en] Provides SDL-based low-level timing primitives, including getting milliseconds/nanoseconds since SDL initialization, high-precision performance counter and its frequency, and millisecond/nanosecond delays. All methods are static, no instantiation needed.
 */
public class SdlTimer {
    /**
     * @brief[zh-cn] 获取自 SDL 初始化以来的毫秒数
     * @return[zh-cn] 自 SDL 初始化以来的毫秒数
     *
     * @brief[en] Get milliseconds since SDL initialization
     * @return[en] Milliseconds since SDL initialization
     */
    public static func getTicks(): UInt64 {
        return SDL_GetTicks_cj()
    }

    /**
     * @brief[zh-cn] 获取自 SDL 初始化以来的纳秒数
     * @return[zh-cn] 自 SDL 初始化以来的纳秒数
     *
     * @brief[en] Get nanoseconds since SDL initialization
     * @return[en] Nanoseconds since SDL initialization
     */
    public static func getTicksNS(): UInt64 {
        return SDL_GetTicksNS_cj()
    }

    /**
     * @brief[zh-cn] 获取高精度性能计数器值
     * @explain[zh-cn] 与 getPerformanceFrequency 配合使用，可计算精确的时间间隔。
     * @return[zh-cn] 性能计数器当前值
     *
     * @brief[en] Get high-precision performance counter value
     * @explain[en] Used together with getPerformanceFrequency to calculate precise time intervals.
     * @return[en] Current performance counter value
     */
    public static func getPerformanceCounter(): UInt64 {
        return SDL_GetPerformanceCounter_cj()
    }

    /**
     * @brief[zh-cn] 获取性能计数器频率（每秒计数次数）
     * @return[zh-cn] 性能计数器频率
     *
     * @brief[en] Get performance counter frequency (counts per second)
     * @return[en] Performance counter frequency
     */
    public static func getPerformanceFrequency(): UInt64 {
        return SDL_GetPerformanceFrequency_cj()
    }

    /**
     * @brief[zh-cn] 延时指定毫秒数
     * @param[zh-cn] ms 延时的毫秒数
     *
     * @brief[en] Delay for the specified milliseconds
     * @param[en] ms Number of milliseconds to delay
     */
    public static func delay(ms: UInt32): Unit {
        SDL_Delay_cj(ms)
    }

    /**
     * @brief[zh-cn] 延时指定纳秒数
     * @param[zh-cn] ns 延时的纳秒数
     *
     * @brief[en] Delay for the specified nanoseconds
     * @param[en] ns Number of nanoseconds to delay
     */
    public static func delayNS(ns: UInt64): Unit {
        SDL_DelayNS_cj(ns)
    }
}
