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
 * @file[zh-cn] RawAnimation
 * @brief[zh-cn] 离线动画数据（可编辑关键帧列表）
 * @explain[zh-cn] 存储每个关节每个通道（平移/旋转/缩放）的有序关键帧列表。
 *                  通过 AnimationBuilder 可构建为运行时压缩格式。
 *
 * @file[en] RawAnimation
 * @brief[en] Offline animation data (editable keyframe lists)
 * @explain[en] Stores ordered keyframe lists per joint per channel (translation/rotation/scale).
 *              Can be built into runtime compressed format via AnimationBuilder.
 */
package three.animation.offline

import std.math.*
import std.sort.*
import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 离线关键帧：时间 + Vector3F 值
 *
 * @brief[en] Offline keyframe: time + Vector3F value
 */
public struct Float3Keyframe {
    public let time: Float32
    public let value: Vector3F

    public init(time: Float32, value: Vector3F) {
        this.time = time
        this.value = value
    }
}

/**
 * @brief[zh-cn] 离线关键帧：时间 + 四元数值
 *
 * @brief[en] Offline keyframe: time + quaternion value
 */
public struct QuaternionKeyframe {
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
 * @brief[zh-cn] 离线动画数据
 * @explain[zh-cn] 每个关节有3个通道：平移(translation)、旋转(rotation)、缩放(scale)。
 *                  每个通道存储按时间排序的关键帧列表。轨道数(trackCount)应与骨骼关节数匹配。
 *
 * @brief[en] Offline animation data with per-joint keyframe lists
 * @explain[en] Each joint has three channels: translation, rotation and scale.
 *                  Each channel stores a time-sorted keyframe list. The track count
 *                  should match the skeleton joint count.
 */
public class RawAnimation {
    /**
     * @brief[zh-cn] 动画时长（秒）
     *
     * @brief[en] Animation duration in seconds
     */
    public var duration: Float32

    /**
     * @brief[zh-cn] 轨道数（应等于骨骼关节数）
     *
     * @brief[en] Track count (should equal the skeleton joint count)
     */
    public var trackCount: Int

    /**
     * @brief[zh-cn] 动画名称
     *
     * @brief[en] Animation name
     */
    public var name: String

    /**
     * @brief[zh-cn] 每个轨道的平移关键帧
     * @explain[zh-cn] translations[i] 是第 i 个轨道的平移关键帧列表
     *
     * @brief[en] Translation keyframes per track
     * @explain[en] translations[i] is the translation keyframe list of track i
     */
    public var translations: ArrayList<ArrayList<Float3Keyframe>>

    /**
     * @brief[zh-cn] 每个轨道的旋转关键帧
     *
     * @brief[en] Rotation keyframes per track
     */
    public var rotations: ArrayList<ArrayList<QuaternionKeyframe>>

    /**
     * @brief[zh-cn] 每个轨道的缩放关键帧
     *
     * @brief[en] Scale keyframes per track
     */
    public var scales: ArrayList<ArrayList<Float3Keyframe>>

    public init() {
        this.duration = 0.0f32
        this.trackCount = 0
        this.name = ""
        this.translations = ArrayList<ArrayList<Float3Keyframe>>()
        this.rotations = ArrayList<ArrayList<QuaternionKeyframe>>()
        this.scales = ArrayList<ArrayList<Float3Keyframe>>()
    }

    /**
     * @brief[zh-cn] 初始化指定轨道数的空关键帧列表
     * @param[zh-cn] numTracks 轨道数
     *
     * @brief[en] Initializes empty keyframe lists for the given number of tracks
     * @param[en] numTracks The number of tracks
     */
    public func initTracks(numTracks: Int): Unit {
        this.trackCount = numTracks
        this.translations.clear()
        this.rotations.clear()
        this.scales.clear()
        for (_ in 0..numTracks) {
            this.translations.add(ArrayList<Float3Keyframe>())
            this.rotations.add(ArrayList<QuaternionKeyframe>())
            this.scales.add(ArrayList<Float3Keyframe>())
        }
    }

    /**
     * @brief[zh-cn] 为指定轨道添加平移关键帧
     * @param[zh-cn] track 轨道索引
     * @param[zh-cn] time 时间（秒）
     * @param[zh-cn] value 平移值
     *
     * @brief[en] Adds a translation keyframe to the given track
     * @param[en] track The track index
     * @param[en] time The time in seconds
     * @param[en] value The translation value
     */
    public func addTranslationKeyframe(track: Int, time: Float32, value: Vector3F): Unit {
        this.translations[track].add(Float3Keyframe(time, value))
    }

    /**
     * @brief[zh-cn] 为指定轨道添加旋转关键帧
     * @param[zh-cn] track 轨道索引
     * @param[zh-cn] time 时间（秒）
     * @param[zh-cn] x 四元数 x
     * @param[zh-cn] y 四元数 y
     * @param[zh-cn] z 四元数 z
     * @param[zh-cn] w 四元数 w
     *
     * @brief[en] Adds a rotation keyframe to the given track
     * @param[en] track The track index
     * @param[en] time The time in seconds
     * @param[en] x Quaternion x
     * @param[en] y Quaternion y
     * @param[en] z Quaternion z
     * @param[en] w Quaternion w
     */
    public func addRotationKeyframe(track: Int, time: Float32, x: Float32, y: Float32, z: Float32, w: Float32): Unit {
        this.rotations[track].add(QuaternionKeyframe(time, x, y, z, w))
    }

    /**
     * @brief[zh-cn] 为指定轨道添加缩放关键帧
     * @param[zh-cn] track 轨道索引
     * @param[zh-cn] time 时间（秒）
     * @param[zh-cn] value 缩放值
     *
     * @brief[en] Adds a scale keyframe to the given track
     * @param[en] track The track index
     * @param[en] time The time in seconds
     * @param[en] value The scale value
     */
    public func addScaleKeyframe(track: Int, time: Float32, value: Vector3F): Unit {
        this.scales[track].add(Float3Keyframe(time, value))
    }

    /**
     * @brief[zh-cn] 获取指定轨道的平移关键帧数量
     *
     * @brief[en] Returns the number of translation keyframes of the given track
     */
    public func numTranslationKeyframes(track: Int): Int {
        this.translations[track].size
    }

    /**
     * @brief[zh-cn] 获取指定轨道的旋转关键帧数量
     *
     * @brief[en] Returns the number of rotation keyframes of the given track
     */
    public func numRotationKeyframes(track: Int): Int {
        this.rotations[track].size
    }

    /**
     * @brief[zh-cn] 获取指定轨道的缩放关键帧数量
     *
     * @brief[en] Returns the number of scale keyframes of the given track
     */
    public func numScaleKeyframes(track: Int): Int {
        this.scales[track].size
    }

    /**
     * @brief[zh-cn] 验证动画数据合法性
     * @return[zh-cn] true 表示数据合法
     * @explain[zh-cn] 检查：trackCount > 0、duration >= 0、关键帧时间已排序、无 NaN 值
     *
     * @brief[en] Validates the animation data
     * @return[en] true if the data is valid
     * @explain[en] Checks that trackCount > 0, duration >= 0, keyframe times are sorted,
     * and no values are NaN
     */
    public func validate(): Bool {
        if (this.trackCount <= 0) {
            return true  // 空动画合法
        }

        if (this.duration < 0.0f32) {
            return false
        }

        if (this.translations.size != this.trackCount ||
            this.rotations.size != this.trackCount ||
            this.scales.size != this.trackCount) {
            return false
        }

        for (i in 0..this.trackCount) {
            // 验证平移关键帧
            if (!validateTranslationTrack(this.translations[i])) {
                return false
            }
            // 验证旋转关键帧
            if (!validateRotationTrack(this.rotations[i])) {
                return false
            }
            // 验证缩放关键帧
            if (!validateTranslationTrack(this.scales[i])) {
                return false
            }
        }

        true
    }

    /**
     * @brief[zh-cn] 排序所有轨道的关键帧（按时间升序）
     *
     * @brief[en] Sorts the keyframes of all tracks by ascending time
     */
    public func sortKeyframes(): Unit {
        for (i in 0..this.trackCount) {
            sort(this.translations[i], by: { a, b =>
                if (a.time < b.time) { Ordering.LT }
                else if (a.time > b.time) { Ordering.GT }
                else { Ordering.EQ }
            })
            sort(this.rotations[i], by: { a, b =>
                if (a.time < b.time) { Ordering.LT }
                else if (a.time > b.time) { Ordering.GT }
                else { Ordering.EQ }
            })
            sort(this.scales[i], by: { a, b =>
                if (a.time < b.time) { Ordering.LT }
                else if (a.time > b.time) { Ordering.GT }
                else { Ordering.EQ }
            })
        }
    }

    /**
     * @brief[zh-cn] 重新计算动画时长（取所有关键帧的最大时间）
     *
     * @brief[en] Recalculates the animation duration (the maximum time of all keyframes)
     */
    public func recalcDuration(): Unit {
        var maxTime: Float32 = 0.0f32
        for (i in 0..this.trackCount) {
            for (kf in this.translations[i]) {
                if (kf.time > maxTime) { maxTime = kf.time }
            }
            for (kf in this.rotations[i]) {
                if (kf.time > maxTime) { maxTime = kf.time }
            }
            for (kf in this.scales[i]) {
                if (kf.time > maxTime) { maxTime = kf.time }
            }
        }
        this.duration = maxTime
    }

    // ===== Private helpers =====

    private func validateTranslationTrack(keyframes: ArrayList<Float3Keyframe>): Bool {
        var prevTime: Float32 = -1.0f32
        for (kf in keyframes) {
            // 时间必须升序
            if (kf.time < prevTime) {
                return false
            }
            prevTime = kf.time

            // 无 NaN 检查
            if (kf.value.x != kf.value.x || kf.value.y != kf.value.y || kf.value.z != kf.value.z) {
                return false
            }
        }
        true
    }

    private func validateRotationTrack(keyframes: ArrayList<QuaternionKeyframe>): Bool {
        var prevTime: Float32 = -1.0f32
        for (kf in keyframes) {
            if (kf.time < prevTime) {
                return false
            }
            prevTime = kf.time

            // 无 NaN 检查
            if (kf.x != kf.x || kf.y != kf.y || kf.z != kf.z || kf.w != kf.w) {
                return false
            }
        }
        true
    }
}
