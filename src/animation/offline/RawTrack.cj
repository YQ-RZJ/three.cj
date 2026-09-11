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
 * @file[zh-cn] RawTrack
 * @brief[zh-cn] 离线用户自定义通道数据
 * @explain[zh-cn] 提供 RawFloatTrack、RawQuaternionTrack、RawFloat3Track 三种类型，
 *                  存储按时间排序的关键帧列表，用于非骨骼动画的用户通道数据。
 *
 * @file[en] RawTrack
 * @brief[en] Offline user-defined channel data
 * @explain[en] Provides RawFloatTrack, RawQuaternionTrack, RawFloat3Track for non-skeletal user channel data.
 */
package three.animation.offline

import std.sort.*
import std.collection.*
import three.core.math.*
import three.animation.skeletal.TrackType

// ===== Float Track =====

/**
 * @brief[zh-cn] 离线浮点通道关键帧
 *
 * @brief[en] Offline float channel keyframe
 */
public struct RawFloatKeyframe {
    public let time: Float32
    public let value: Float32

    public init(time: Float32, value: Float32) {
        this.time = time
        this.value = value
    }
}

/**
 * @brief[zh-cn] 离线浮点通道数据
 *
 * @brief[en] Offline float channel data
 */
public class RawFloatTrack {
    public var name: String
    public var keyframes: ArrayList<RawFloatKeyframe>

    public init(name: String) {
        this.name = name
        this.keyframes = ArrayList<RawFloatKeyframe>()
    }

    /**
     * @brief[zh-cn] 添加关键帧
     *
     * @brief[en] Adds a keyframe
     */
    public func addKeyframe(time: Float32, value: Float32): Unit {
        this.keyframes.add(RawFloatKeyframe(time, value))
    }

    /**
     * @brief[zh-cn] 获取关键帧数量
     *
     * @brief[en] Returns the number of keyframes
     */
    public func numKeyframes(): Int {
        this.keyframes.size
    }

    /**
     * @brief[zh-cn] 排序关键帧（按时间升序）
     *
     * @brief[en] Sorts the keyframes by ascending time
     */
    public func sortKeyframes(): Unit {
        sort(this.keyframes, by: { a, b =>
            if (a.time < b.time) { Ordering.LT }
            else if (a.time > b.time) { Ordering.GT }
            else { Ordering.EQ }
        })
    }

    /**
     * @brief[zh-cn] 验证数据合法性
     * @return[zh-cn] true 表示合法
     *
     * @brief[en] Validates the data
     * @return[en] true if the data is valid
     */
    public func validate(): Bool {
        var prevTime: Float32 = -1.0f32
        for (kf in this.keyframes) {
            if (kf.time < prevTime) { return false }
            if (kf.value != kf.value) { return false }  // NaN check
            prevTime = kf.time
        }
        true
    }
}

// ===== Quaternion Track =====

/**
 * @brief[zh-cn] 离线四元数通道关键帧
 *
 * @brief[en] Offline quaternion channel keyframe
 */
public struct RawQuaternionKeyframe {
    public let time: Float32
    public let x: Float32
    public let y: Float32
    public let z: Float32
    public let w: Float32

    public init(time: Float32, x: Float32, y: Float32, z: Float32, w: Float32) {
        this.time = time
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }
}

/**
 * @brief[zh-cn] 离线四元数通道数据
 *
 * @brief[en] Offline quaternion channel data
 */
public class RawQuaternionTrack {
    public var name: String
    public var keyframes: ArrayList<RawQuaternionKeyframe>

    public init(name: String) {
        this.name = name
        this.keyframes = ArrayList<RawQuaternionKeyframe>()
    }

    /**
     * @brief[zh-cn] 添加关键帧
     *
     * @brief[en] Adds a keyframe
     */
    public func addKeyframe(time: Float32, x: Float32, y: Float32, z: Float32, w: Float32): Unit {
        this.keyframes.add(RawQuaternionKeyframe(time, x, y, z, w))
    }

    /**
     * @brief[zh-cn] 获取关键帧数量
     *
     * @brief[en] Returns the number of keyframes
     */
    public func numKeyframes(): Int {
        this.keyframes.size
    }

    /**
     * @brief[zh-cn] 排序关键帧（按时间升序）
     *
     * @brief[en] Sorts the keyframes by ascending time
     */
    public func sortKeyframes(): Unit {
        sort(this.keyframes, by: { a, b =>
            if (a.time < b.time) { Ordering.LT }
            else if (a.time > b.time) { Ordering.GT }
            else { Ordering.EQ }
        })
    }

    /**
     * @brief[zh-cn] 验证数据合法性
     * @return[zh-cn] true 表示合法
     *
     * @brief[en] Validates the data
     * @return[en] true if the data is valid
     */
    public func validate(): Bool {
        var prevTime: Float32 = -1.0f32
        for (kf in this.keyframes) {
            if (kf.time < prevTime) { return false }
            if (kf.x != kf.x || kf.y != kf.y || kf.z != kf.z || kf.w != kf.w) { return false }
            prevTime = kf.time
        }
        true
    }
}

// ===== Float3 Track =====

/**
 * @brief[zh-cn] 离线三分量向量通道关键帧
 *
 * @brief[en] Offline 3-component vector channel keyframe
 */
public struct RawFloat3Keyframe {
    public let time: Float32
    public let value: Vector3F

    public init(time: Float32, value: Vector3F) {
        this.time = time
        this.value = value
    }
}

/**
 * @brief[zh-cn] 离线三分量向量通道数据
 *
 * @brief[en] Offline 3-component vector channel data
 */
public class RawFloat3Track {
    public var name: String
    public var keyframes: ArrayList<RawFloat3Keyframe>

    public init(name: String) {
        this.name = name
        this.keyframes = ArrayList<RawFloat3Keyframe>()
    }

    /**
     * @brief[zh-cn] 添加关键帧
     *
     * @brief[en] Adds a keyframe
     */
    public func addKeyframe(time: Float32, value: Vector3F): Unit {
        this.keyframes.add(RawFloat3Keyframe(time, value))
    }

    /**
     * @brief[zh-cn] 获取关键帧数量
     *
     * @brief[en] Returns the number of keyframes
     */
    public func numKeyframes(): Int {
        this.keyframes.size
    }

    /**
     * @brief[zh-cn] 排序关键帧（按时间升序）
     *
     * @brief[en] Sorts the keyframes by ascending time
     */
    public func sortKeyframes(): Unit {
        sort(this.keyframes, by: { a, b =>
            if (a.time < b.time) { Ordering.LT }
            else if (a.time > b.time) { Ordering.GT }
            else { Ordering.EQ }
        })
    }

    /**
     * @brief[zh-cn] 验证数据合法性
     * @return[zh-cn] true 表示合法
     *
     * @brief[en] Validates the data
     * @return[en] true if the data is valid
     */
    public func validate(): Bool {
        var prevTime: Float32 = -1.0f32
        for (kf in this.keyframes) {
            if (kf.time < prevTime) { return false }
            if (kf.value.x != kf.value.x || kf.value.y != kf.value.y || kf.value.z != kf.value.z) { return false }
            prevTime = kf.time
        }
        true
    }
}
