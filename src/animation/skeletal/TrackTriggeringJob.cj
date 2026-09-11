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
 * @file[zh-cn] TrackTriggeringJob
 * @brief[zh-cn] 通道事件触发 Job
 * @explain[zh-cn] 检测通道值穿越阈值的事件（从下到上或从上到下），
 *                  输出触发时间点。用于游戏逻辑触发（如脚步声、动画事件）。
 *
 * @file[en] TrackTriggeringJob
 * @brief[en] Track event triggering job
 * @explain[en] Detects when a track's value crosses a threshold and outputs trigger times.
 * @explain[en] Detects events where a track's value crosses a threshold (rising or falling)
 *              and outputs the trigger time points. Used for gameplay triggers
 *              (e.g. footstep sounds, animation events).
 */
package three.animation.skeletal

import std.math.*
import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 触发事件
 *
 * @brief[en] Trigger event
 */
public struct TriggerEvent {
    /**
     * @brief[zh-cn] 触发时间（0-1 ratio）
     *
     * @brief[en] Trigger time (0-1 ratio)
     */
    public let ratio: Float32

    /**
     * @brief[zh-cn] 触发时的值
     *
     * @brief[en] The value at trigger time
     */
    public let value: Float32

    /**
     * @brief[zh-cn] 触发方向：true = 从下到上穿越，false = 从上到下穿越
     *
     * @brief[en] Trigger direction: true = rising crossing (bottom-up), false = falling crossing (top-down)
     */
    public let rising: Bool

    public init(ratio: Float32, value: Float32, rising: Bool) {
        this.ratio = ratio
        this.value = value
        this.rising = rising
    }
}

/**
 * @brief[zh-cn] 通道事件触发 Job
 * @explain[zh-cn] 在当前帧和上一帧之间检测浮点通道值是否穿越了指定阈值。
 *                  支持单向检测（仅上升/仅下降）或双向检测。
 *
 * @brief[en] Track event triggering job
 * @explain[en] Detects whether the value of a float track crossed the specified threshold
 *                  between the current and previous frames. Supports one-way detection
 *                  (rising only / falling only) or two-way detection.
 */
public class TrackTriggeringJob {
    /**
     * @brief[zh-cn] 阈值
     *
     * @brief[en] Threshold
     */
    public var threshold: Float32

    /**
     * @brief[zh-cn] 当前帧的时间比 [0, 1]
     *
     * @brief[en] Time ratio of the current frame [0, 1]
     */
    public var currentRatio: Float32

    /**
     * @brief[zh-cn] 上一帧的时间比 [0, 1]
     * @explain[zh-cn] 用于确定检测区间
     *
     * @brief[en] Time ratio of the previous frame [0, 1]
     * @explain[en] Used to determine the detection interval
     */
    public var previousRatio: Float32

    /**
     * @brief[zh-cn] 要检测的浮点通道
     *
     * @brief[en] The float track to check
     */
    public var track: ?SkeletalTrackData

    /**
     * @brief[zh-cn] 是否只检测上升穿越（从下到上）
     *
     * @brief[en] Whether to detect only rising crossings (bottom-up)
     */
    public var risingOnly: Bool

    /**
     * @brief[zh-cn] 是否只检测下降穿越（从上到下）
     *
     * @brief[en] Whether to detect only falling crossings (top-down)
     */
    public var fallingOnly: Bool

    /**
     * @brief[zh-cn] 输出：触发事件列表
     *
     * @brief[en] Output: the list of trigger events
     */
    public var events: ArrayList<TriggerEvent>

    public init() {
        this.threshold = 0.0f32
        this.currentRatio = 0.0f32
        this.previousRatio = 0.0f32
        this.track = None
        this.risingOnly = false
        this.fallingOnly = false
        this.events = ArrayList<TriggerEvent>()
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        match (this.track) {
            case Some(_) => true
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 执行触发检测
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 算法：
     *                  1. 在 previousRatio → currentRatio 区间内均匀采样
     *                  2. 检查相邻采样点是否跨越阈值
     *                  3. 用二分法精确定位穿越点
     *                  4. 按 risingOnly/fallingOnly 过滤
     *
     * @brief[en] Runs the trigger detection
     * @return[en] true on success
     * @explain[en] Algorithm:
     *                  1. Samples uniformly in the interval from previousRatio to currentRatio
     *                  2. Checks whether adjacent samples cross the threshold
     *                  3. Uses bisection to precisely locate the crossing point
     *                  4. Filters by risingOnly/fallingOnly
     */
    public func run(): Bool {
        let track = match (this.track) {
            case Some(t) => t
            case None => return false
        }

        this.events.clear()

        let isFloatTrack = match (track.trackType) {
            case TrackType.Float => true
            case _ => false
        }
        if (!isFloatTrack) {
            return false  // 仅支持浮点通道
        }

        let startRatio = min(this.previousRatio, this.currentRatio)
        let endRatio = max(this.previousRatio, this.currentRatio)
        let direction = if (this.currentRatio >= this.previousRatio) { 1.0f32 } else { -1.0f32 }

        if (endRatio - startRatio < 1e-6f32) {
            return true  // 区间太小
        }

        // 均匀采样检测
        let numSamples = 32
        let step = (endRatio - startRatio) / Float32(numSamples)

        var prevValue = track.sampleFloat(startRatio)
        var prevAbove = prevValue >= this.threshold

        for (i in 1..=numSamples) {
            let ratio = startRatio + step * Float32(i)
            let clampedRatio = min(1.0f32, max(0.0f32, ratio))
            let currentValue = track.sampleFloat(clampedRatio)
            let currentAbove = currentValue >= this.threshold

            // 检测穿越
            if (prevAbove != currentAbove) {
                let isRising = currentAbove  // 从下到上

                // 过滤方向
                if (this.risingOnly && !isRising) { continue }
                if (this.fallingOnly && isRising) { continue }

                // 二分法精确定位穿越点
                var lo = if (direction > 0.0f32) { ratio - step } else { ratio }
                var hi = ratio
                if (direction < 0.0f32) {
                    lo = ratio
                    hi = ratio + step
                }
                lo = max(0.0f32, lo)
                hi = min(1.0f32, hi)

                for (_ in 0..8) {  // 8 次二分
                    let mid = (lo + hi) * 0.5f32
                    let midValue = track.sampleFloat(mid)
                    if ((midValue >= this.threshold) == prevAbove) {
                        lo = mid
                    } else {
                        hi = mid
                    }
                }

                let triggerRatio = (lo + hi) * 0.5f32
                let triggerValue = track.sampleFloat(triggerRatio)
                this.events.add(TriggerEvent(triggerRatio, triggerValue, isRising))
            }

            prevValue = currentValue
            prevAbove = currentAbove
        }

        true
    }
}
