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
 * @file[zh-cn] AnimationEventSystem
 * @brief[zh-cn] 骨骼动画事件系统
 * @explain[zh-cn] 支持在动画片段的特定时间比注册事件，播放时检测时间穿越并触发回调。
 *                  支持帧事件（单次触发）和动画完成回调。
 *
 * @file[en] AnimationEventSystem
 * @brief[en] Skeletal animation event system
 * @explain[en] Supports registering events at specific time ratios on animation clips,
 *              detecting time crossings during playback and triggering callbacks.
 * @explain[en] Supports frame events (single trigger) and animation completion callbacks.
 */
package three.animation.skeletal

import std.collection.*

/**
 * @brief[zh-cn] 动画事件定义
 *
 * @brief[en] Animation event definition
 */
public class AnimationEvent {
    /**
     * @brief[zh-cn] 事件名称
     *
     * @brief[en] Event name
     */
    public let name: String

    /**
     * @brief[zh-cn] 触发时间比 [0, 1]
     *
     * @brief[en] Trigger time ratio [0, 1]
     */
    public let ratio: Float32

    /**
     * @brief[zh-cn] 事件回调
     *
     * @brief[en] Event callback
     */
    public let callback: (String) -> Unit

    /**
     * @brief[zh-cn] 是否已触发（防止单帧内重复触发）
     *
     * @brief[en] Whether the event has been triggered (prevents repeated triggering within a single frame)
     */
    public var triggered: Bool

    public init(name: String, ratio: Float32, callback: (String) -> Unit) {
        this.name = name
        this.ratio = ratio
        this.callback = callback
        this.triggered = false
    }
}

/**
 * @brief[zh-cn] 动画完成回调
 *
 * @brief[en] Animation completion callback
 */
public class AnimationCompleteCallback {
    public let clipName: String
    public let callback: (String) -> Unit

    public init(clipName: String, callback: (String) -> Unit) {
        this.clipName = clipName
        this.callback = callback
    }
}

/**
 * @brief[zh-cn] 动画事件系统
 * @explain[zh-cn] 管理动画事件注册和触发。在 AnimationMixer.updateSkeletal 中调用
 *                  checkEvents 来检测时间穿越并触发回调。
 *
 * @brief[en] Animation event system
 * @explain[en] Manages animation event registration and triggering. checkEvents is called
 *                  in AnimationMixer.updateSkeletal to detect time crossings and trigger
 *                  callbacks.
 */
public class AnimationEventSystem {
    /**
     * @brief[zh-cn] 按 clip 名称分组的事件列表
     *
     * @brief[en] Event list grouped by clip name
     */
    private var _events: HashMap<String, ArrayList<AnimationEvent>>

    /**
     * @brief[zh-cn] 动画完成回调列表
     *
     * @brief[en] List of animation completion callbacks
     */
    private var _completeCallbacks: ArrayList<AnimationCompleteCallback>

    /**
     * @brief[zh-cn] 上一帧的时间比（按 clip 名称记录）
     *
     * @brief[en] Time ratios of the previous frame (recorded by clip name)
     */
    private var _lastRatios: HashMap<String, Float32>

    public init() {
        this._events = HashMap<String, ArrayList<AnimationEvent>>()
        this._completeCallbacks = ArrayList<AnimationCompleteCallback>()
        this._lastRatios = HashMap<String, Float32>()
    }

    /**
     * @brief[zh-cn] 注册帧事件
     * @param[zh-cn] clipName 动画片段名称
     * @param[zh-cn] eventName 事件名称
     * @param[zh-cn] ratio 触发时间比 [0, 1]
     * @param[zh-cn] callback 回调函数
     *
     * @brief[en] Registers a frame event
     * @param[en] clipName The animation clip name
     * @param[en] eventName The event name
     * @param[en] ratio Trigger time ratio [0, 1]
     * @param[en] callback The callback function
     */
    public func addEvent(clipName: String, eventName: String, ratio: Float32, callback: (String) -> Unit): Unit {
        let event = AnimationEvent(eventName, ratio, callback)

        match (this._events.get(clipName)) {
            case Some(eventList) =>
                eventList.add(event)
            case None =>
                let newList = ArrayList<AnimationEvent>()
                newList.add(event)
                this._events.add(clipName, newList)
        }
    }

    /**
     * @brief[zh-cn] 注册动画完成回调
     * @param[zh-cn] clipName 动画片段名称
     * @param[zh-cn] callback 完成时的回调
     *
     * @brief[en] Registers an animation completion callback
     * @param[en] clipName The animation clip name
     * @param[en] callback The callback invoked on completion
     */
    public func onComplete(clipName: String, callback: (String) -> Unit): Unit {
        this._completeCallbacks.add(AnimationCompleteCallback(clipName, callback))
    }

    /**
     * @brief[zh-cn] 检测事件触发
     * @param[zh-cn] clipName 当前播放的动画名称
     * @param[zh-cn] currentRatio 当前时间比 [0, 1]
     * @param[zh-cn] previousRatio 上一帧时间比 [0, 1]
     * @param[zh-cn] looping 是否循环播放
     * @explain[zh-cn] 检测 previousRatio → currentRatio 区间内是否穿越了注册的事件时间点。
     *                  循环播放时会处理从尾到首的穿越。
     *
     * @brief[en] Detects event triggering
     * @param[en] clipName The name of the currently playing animation
     * @param[en] currentRatio The current time ratio [0, 1]
     * @param[en] previousRatio The time ratio of the previous frame [0, 1]
     * @param[en] looping Whether the animation loops
     * @explain[en] Detects whether the interval from previousRatio to currentRatio crossed
     *                  any registered event time point. When looping, crossings from the end
     *                  back to the start are also handled.
     */
    public func checkEvents(clipName: String, currentRatio: Float32, previousRatio: Float32, looping: Bool): Unit {
        match (this._events.get(clipName)) {
            case Some(eventList) =>
                for (event in eventList) {
                    if (event.triggered) {
                        // 重置：如果时间比回到事件之前（循环或重播）
                        if (currentRatio < event.ratio || previousRatio > currentRatio) {
                            event.triggered = false
                        }
                    }

                    if (!event.triggered) {
                        var crossed = false

                        if (previousRatio <= currentRatio) {
                            // 正常前进：事件在 previousRatio 和 currentRatio 之间
                            crossed = event.ratio >= previousRatio && event.ratio <= currentRatio
                        } else if (looping) {
                            // 循环穿越：从尾到首
                            crossed = event.ratio >= previousRatio || event.ratio <= currentRatio
                        }

                        if (crossed) {
                            event.triggered = true
                            event.callback(event.name)
                        }
                    }
                }
            case None => ()
        }

        // 检测动画完成（非循环模式下，时间比从 <1 到 >=1）
        if (!looping && previousRatio < 1.0f32 && currentRatio >= 1.0f32) {
            for (cb in this._completeCallbacks) {
                if (cb.clipName == clipName) {
                    cb.callback(clipName)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 清除指定 clip 的所有事件
     * @param[zh-cn] clipName 动画片段名称
     *
     * @brief[en] Clears all events of the specified clip
     * @param[en] clipName The animation clip name
     */
    public func clearEvents(clipName: String): Unit {
        this._events.remove(clipName)
    }

    /**
     * @brief[zh-cn] 清除所有事件和回调
     *
     * @brief[en] Clears all events and callbacks
     */
    public func clearAll(): Unit {
        this._events.clear()
        this._completeCallbacks.clear()
        this._lastRatios.clear()
    }

    /**
     * @brief[zh-cn] 重置指定 clip 的事件触发状态
     * @explain[zh-cn] 当动画重新播放时调用，确保事件可以再次触发
     *
     * @brief[en] Resets the triggered state of events for the specified clip
     * @explain[en] Called when an animation is replayed, ensuring events can be triggered again
     */
    public func resetTriggered(clipName: String): Unit {
        match (this._events.get(clipName)) {
            case Some(eventList) =>
                for (event in eventList) {
                    event.triggered = false
                }
            case None => ()
        }
    }
}
