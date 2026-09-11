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
 * @file[zh-cn] TrackOptimizer
 * @brief[zh-cn] 通道数据优化器
 * @explain[zh-cn] 在指定误差容忍度内删除冗余关键帧，减少运行时内存占用。
 *
 * @file[en] TrackOptimizer
 * @brief[en] Track data optimizer
 * @explain[en] Removes redundant keyframes within a configurable error tolerance.
 */
package three.animation.offline

import std.math.*
import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 通道优化器
 *
 * @brief[en] Track optimizer
 */
public class TrackOptimizer {
    /**
     * @brief[zh-cn] 浮点值优化误差容忍度
     *
     * @brief[en] Float value optimization error tolerance
     */
    public var floatTolerance: Float32

    /**
     * @brief[zh-cn] 三分量向量优化误差容忍度
     *
     * @brief[en] 3-component vector optimization error tolerance
     */
    public var float3Tolerance: Float32

    /**
     * @brief[zh-cn] 旋转优化误差容忍度（弧度）
     *
     * @brief[en] Rotation optimization error tolerance (radians)
     */
    public var rotationTolerance: Float32

    public init(
        floatTolerance!: Float32 = 0.001f32,
        float3Tolerance!: Float32 = 0.001f32,
        rotationTolerance!: Float32 = 0.001f32
    ) {
        this.floatTolerance = floatTolerance
        this.float3Tolerance = float3Tolerance
        this.rotationTolerance = rotationTolerance
    }

    /**
     * @brief[zh-cn] 优化浮点通道
     * @param[zh-cn] input 离线浮点通道数据（就地修改）
     *
     * @brief[en] Optimizes a float track
     * @param[en] input The offline float track data (modified in place)
     */
    public func optimizeFloat(input: RawFloatTrack): Unit {
        if (input.keyframes.size <= 2) {
            return
        }
        input.keyframes = optimizeFloatTrack(input.keyframes)
    }

    /**
     * @brief[zh-cn] 优化四元数通道
     * @param[zh-cn] input 离线四元数通道数据（就地修改）
     *
     * @brief[en] Optimizes a quaternion track
     * @param[en] input The offline quaternion track data (modified in place)
     */
    public func optimizeQuaternion(input: RawQuaternionTrack): Unit {
        if (input.keyframes.size <= 2) {
            return
        }
        input.keyframes = optimizeQuaternionTrack(input.keyframes)
    }

    /**
     * @brief[zh-cn] 优化三分量向量通道
     * @param[zh-cn] input 离线三分量向量通道数据（就地修改）
     *
     * @brief[en] Optimizes a 3-component vector track
     * @param[en] input The offline 3-component vector track data (modified in place)
     */
    public func optimizeFloat3(input: RawFloat3Track): Unit {
        if (input.keyframes.size <= 2) {
            return
        }
        input.keyframes = optimizeFloat3Track(input.keyframes)
    }

    /**
     * @brief[zh-cn] 创建优化后的浮点通道副本
     *
     * @brief[en] Creates an optimized copy of a float track
     */
    public func optimizeFloatCopy(input: RawFloatTrack): RawFloatTrack {
        let output = RawFloatTrack(input.name)
        output.keyframes = optimizeFloatTrack(input.keyframes)
        output
    }

    /**
     * @brief[zh-cn] 创建优化后的四元数通道副本
     *
     * @brief[en] Creates an optimized copy of a quaternion track
     */
    public func optimizeQuaternionCopy(input: RawQuaternionTrack): RawQuaternionTrack {
        let output = RawQuaternionTrack(input.name)
        output.keyframes = optimizeQuaternionTrack(input.keyframes)
        output
    }

    /**
     * @brief[zh-cn] 创建优化后的三分量向量通道副本
     *
     * @brief[en] Creates an optimized copy of a 3-component vector track
     */
    public func optimizeFloat3Copy(input: RawFloat3Track): RawFloat3Track {
        let output = RawFloat3Track(input.name)
        output.keyframes = optimizeFloat3Track(input.keyframes)
        output
    }

    // ===== Private optimization methods =====

    private func optimizeFloatTrack(keyframes: ArrayList<RawFloatKeyframe>): ArrayList<RawFloatKeyframe> {
        if (keyframes.size <= 2) {
            return keyframes
        }

        let result = ArrayList<RawFloatKeyframe>()
        result.add(keyframes[0])

        var i = 1
        while (i < keyframes.size - 1) {
            var end = i + 1
            while (end < keyframes.size) {
                if (maxFloatDeviation(keyframes, i - 1, end) > this.floatTolerance) {
                    break
                }
                end += 1
            }
            result.add(keyframes[end - 1])
            i = end
        }

        result.add(keyframes[keyframes.size - 1])
        result
    }

    private func optimizeFloat3Track(keyframes: ArrayList<RawFloat3Keyframe>): ArrayList<RawFloat3Keyframe> {
        if (keyframes.size <= 2) {
            return keyframes
        }

        let result = ArrayList<RawFloat3Keyframe>()
        result.add(keyframes[0])

        var i = 1
        while (i < keyframes.size - 1) {
            var end = i + 1
            while (end < keyframes.size) {
                if (maxFloat3Deviation(keyframes, i - 1, end) > this.float3Tolerance) {
                    break
                }
                end += 1
            }
            result.add(keyframes[end - 1])
            i = end
        }

        result.add(keyframes[keyframes.size - 1])
        result
    }

    private func optimizeQuaternionTrack(keyframes: ArrayList<RawQuaternionKeyframe>): ArrayList<RawQuaternionKeyframe> {
        if (keyframes.size <= 2) {
            return keyframes
        }

        let result = ArrayList<RawQuaternionKeyframe>()
        result.add(keyframes[0])

        var i = 1
        while (i < keyframes.size - 1) {
            var end = i + 1
            while (end < keyframes.size) {
                if (maxQuaternionDeviation(keyframes, i - 1, end) > this.rotationTolerance) {
                    break
                }
                end += 1
            }
            result.add(keyframes[end - 1])
            i = end
        }

        result.add(keyframes[keyframes.size - 1])
        result
    }

    private func maxFloatDeviation(keyframes: ArrayList<RawFloatKeyframe>, start: Int, end: Int): Float32 {
        let a = keyframes[start].value
        let b = keyframes[end].value
        let dt = keyframes[end].time - keyframes[start].time
        if (dt <= 0.0f32) { return 0.0f32 }

        var maxDev: Float32 = 0.0f32
        for (k in (start + 1)..end) {
            let t = (keyframes[k].time - keyframes[start].time) / dt
            let iv = a + (b - a) * t
            let dev = abs(keyframes[k].value - iv)
            if (dev > maxDev) { maxDev = dev }
        }
        maxDev
    }

    private func maxFloat3Deviation(keyframes: ArrayList<RawFloat3Keyframe>, start: Int, end: Int): Float32 {
        let ax = keyframes[start].value.x
        let ay = keyframes[start].value.y
        let az = keyframes[start].value.z
        let bx = keyframes[end].value.x
        let by = keyframes[end].value.y
        let bz = keyframes[end].value.z
        let dt = keyframes[end].time - keyframes[start].time
        if (dt <= 0.0f32) { return 0.0f32 }

        var maxDev: Float32 = 0.0f32
        for (k in (start + 1)..end) {
            let t = (keyframes[k].time - keyframes[start].time) / dt
            let dx = keyframes[k].value.x - (ax + (bx - ax) * t)
            let dy = keyframes[k].value.y - (ay + (by - ay) * t)
            let dz = keyframes[k].value.z - (az + (bz - az) * t)
            let dev = sqrt(dx * dx + dy * dy + dz * dz)
            if (dev > maxDev) { maxDev = dev }
        }
        maxDev
    }

    private func maxQuaternionDeviation(keyframes: ArrayList<RawQuaternionKeyframe>, start: Int, end: Int): Float32 {
        let dt = keyframes[end].time - keyframes[start].time
        if (dt <= 0.0f32) { return 0.0f32 }

        var maxDev: Float32 = 0.0f32
        for (k in (start + 1)..end) {
            let t = (keyframes[k].time - keyframes[start].time) / dt

            let sx = keyframes[start].x
            let sy = keyframes[start].y
            let sz = keyframes[start].z
            let sw = keyframes[start].w
            let ex = keyframes[end].x
            let ey = keyframes[end].y
            let ez = keyframes[end].z
            let ew = keyframes[end].w

            let dot = sx * ex + sy * ey + sz * ez + sw * ew
            let sign = if (dot < 0.0f32) { -1.0f32 } else { 1.0f32 }

            var ix = sx + (ex * sign - sx) * t
            var iy = sy + (ey * sign - sy) * t
            var iz = sz + (ez * sign - sz) * t
            var iw = sw + (ew * sign - sw) * t

            let len = sqrt(ix * ix + iy * iy + iz * iz + iw * iw)
            if (len > 1e-12f32) {
                let invLen = 1.0f32/ len
                ix *= invLen
                iy *= invLen
                iz *= invLen
                iw *= invLen
            }

            let kx = keyframes[k].x
            let ky = keyframes[k].y
            let kz = keyframes[k].z
            let kw = keyframes[k].w

            var dotProd = ix * kx + iy * ky + iz * kz + iw * kw
            dotProd = min(1.0f32, abs(dotProd))
            let angle = 2.0f32* acos(dotProd)
            if (angle > maxDev) { maxDev = angle }
        }
        maxDev
    }
}
