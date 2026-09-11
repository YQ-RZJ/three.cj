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
 * @file[zh-cn] AnimationOptimizer
 * @brief[zh-cn] 动画关键帧优化器
 * @explain[zh-cn] 在指定误差容忍度内删除冗余关键帧，减少运行时内存占用和采样开销。
 *                  采用 Ramer-Douglas-Peucker 算法的变体，对每个轨道独立优化。
 *
 * @file[en] AnimationOptimizer
 * @brief[en] Animation keyframe optimizer
 * @explain[en] Removes redundant keyframes within a configurable error tolerance.
 */
package three.animation.offline

import std.math.*
import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 动画优化器
 *
 * @brief[en] Animation optimizer
 */
public class AnimationOptimizer {
    /**
     * @brief[zh-cn] 平移优化误差容忍度（向量长度）
     *
     * @brief[en] Translation optimization error tolerance (vector length)
     */
    public var translationTolerance: Float32

    /**
     * @brief[zh-cn] 旋转优化误差容忍度（角度弧度）
     *
     * @brief[en] Rotation optimization error tolerance (angle in radians)
     */
    public var rotationTolerance: Float32

    /**
     * @brief[zh-cn] 缩放优化误差容忍度（向量长度）
     *
     * @brief[en] Scale optimization error tolerance (vector length)
     */
    public var scaleTolerance: Float32

    public init(
        translationTolerance!: Float32 = 0.001f32,
        rotationTolerance!: Float32 = 0.001f32,
        scaleTolerance!: Float32 = 0.001f32
    ) {
        this.translationTolerance = translationTolerance
        this.rotationTolerance = rotationTolerance
        this.scaleTolerance = scaleTolerance
    }

    /**
     * @brief[zh-cn] 优化离线动画数据（就地修改）
     * @param[zh-cn] input 输入/输出的离线动画数据
     * @explain[zh-cn] 对每个轨道的每个通道独立应用关键帧精简
     *
     * @brief[en] Optimizes offline animation data (in place)
     * @param[en] input The offline animation data to optimize (in/out)
     * @explain[en] Applies keyframe reduction independently to each channel of each track
     */
    public func optimize(input: RawAnimation): Unit {
        if (input.trackCount <= 0) {
            return
        }

        for (track in 0..input.trackCount) {
            // 优化平移通道
            if (input.translations[track].size > 2) {
                input.translations[track] = optimizeTranslationTrack(input.translations[track])
            }

            // 优化旋转通道
            if (input.rotations[track].size > 2) {
                input.rotations[track] = optimizeRotationTrack(input.rotations[track])
            }

            // 优化缩放通道
            if (input.scales[track].size > 2) {
                input.scales[track] = optimizeTranslationTrack(input.scales[track])
            }
        }
    }

    /**
     * @brief[zh-cn] 创建优化后的副本（不修改原始数据）
     * @param[zh-cn] input 原始离线动画数据
     * @return[zh-cn] 优化后的副本
     *
     * @brief[en] Creates an optimized copy (the original data is not modified)
     * @param[en] input The original offline animation data
     * @return[en] The optimized copy
     */
    public func optimizeCopy(input: RawAnimation): RawAnimation {
        let output = RawAnimation()
        output.duration = input.duration
        output.trackCount = input.trackCount
        output.name = input.name
        output.initTracks(input.trackCount)

        for (i in 0..input.trackCount) {
            output.translations[i] = optimizeTranslationTrack(input.translations[i])
            output.rotations[i] = optimizeRotationTrack(input.rotations[i])
            output.scales[i] = optimizeTranslationTrack(input.scales[i])
        }

        output
    }

    // ===== Private optimization methods =====

    /**
     * @brief[zh-cn] 优化平移/缩放关键帧（RDP 算法变体）
     *
     * @brief[en] Optimizes translation/scale keyframes (RDP algorithm variant)
     */
    private func optimizeTranslationTrack(keyframes: ArrayList<Float3Keyframe>): ArrayList<Float3Keyframe> {
        if (keyframes.size <= 2) {
            return keyframes
        }

        let result = ArrayList<Float3Keyframe>()
        result.add(keyframes[0])

        var i = 1
        while (i < keyframes.size - 1) {
            // 找到可以跳过的最长子序列
            var end = i + 1
            while (end < keyframes.size) {
                if (maxDeviation(keyframes, i - 1, end) > this.translationTolerance) {
                    break
                }
                end += 1
            }
            result.add(keyframes[end - 1])
            i = end
        }

        // 始终保留最后一个关键帧
        result.add(keyframes[keyframes.size - 1])
        result
    }

    /**
     * @brief[zh-cn] 优化旋转关键帧
     *
     * @brief[en] Optimizes rotation keyframes
     */
    private func optimizeRotationTrack(keyframes: ArrayList<QuaternionKeyframe>): ArrayList<QuaternionKeyframe> {
        if (keyframes.size <= 2) {
            return keyframes
        }

        let result = ArrayList<QuaternionKeyframe>()
        result.add(keyframes[0])

        var i = 1
        while (i < keyframes.size - 1) {
            var end = i + 1
            while (end < keyframes.size) {
                if (maxRotationDeviation(keyframes, i - 1, end) > this.rotationTolerance) {
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

    /**
     * @brief[zh-cn] 计算线性插值的最大偏差
     *
     * @brief[en] Computes the maximum deviation from linear interpolation
     */
    private func maxDeviation(keyframes: ArrayList<Float3Keyframe>, start: Int, end: Int): Float32 {
        let ax = keyframes[start].value.x
        let ay = keyframes[start].value.y
        let az = keyframes[start].value.z
        let bx = keyframes[end].value.x
        let by = keyframes[end].value.y
        let bz = keyframes[end].value.z
        let dt = keyframes[end].time - keyframes[start].time

        if (dt <= 0.0f32) {
            return 0.0f32
        }

        var maxDev: Float32 = 0.0f32
        for (k in (start + 1)..end) {
            let t = (keyframes[k].time - keyframes[start].time) / dt
            let ix = ax + (bx - ax) * t
            let iy = ay + (by - ay) * t
            let iz = az + (bz - az) * t
            let dx = keyframes[k].value.x - ix
            let dy = keyframes[k].value.y - iy
            let dz = keyframes[k].value.z - iz
            let dev = sqrt(dx * dx + dy * dy + dz * dz)
            if (dev > maxDev) { maxDev = dev }
        }
        maxDev
    }

    /**
     * @brief[zh-cn] 计算旋转线性插值的最大角度偏差
     *
     * @brief[en] Computes the maximum angular deviation from linear rotation interpolation
     */
    private func maxRotationDeviation(keyframes: ArrayList<QuaternionKeyframe>, start: Int, end: Int): Float32 {
        let dt = keyframes[end].time - keyframes[start].time
        if (dt <= 0.0f32) {
            return 0.0f32
        }

        var maxDev: Float32 = 0.0f32
        for (k in (start + 1)..end) {
            let t = (keyframes[k].time - keyframes[start].time) / dt

            // 线性插值四元数
            let sx = keyframes[start].x
            let sy = keyframes[start].y
            let sz = keyframes[start].z
            let sw = keyframes[start].w
            let ex = keyframes[end].x
            let ey = keyframes[end].y
            let ez = keyframes[end].z
            let ew = keyframes[end].w

            // 确保最短路径
            let dot = sx * ex + sy * ey + sz * ez + sw * ew
            let sign = if (dot < 0.0f32) { -1.0f32 } else { 1.0f32 }

            let ix = sx + (ex * sign - sx) * t
            let iy = sy + (ey * sign - sy) * t
            let iz = sz + (ez * sign - sz) * t
            let iw = sw + (ew * sign - sw) * t

            // 归一化插值结果
            let len = sqrt(ix * ix + iy * iy + iz * iz + iw * iw)
            if (len > 1e-12f32) {
                let invLen = 1.0f32/ len
                let nix = ix * invLen
                let niy = iy * invLen
                let niz = iz * invLen
                let niw = iw * invLen

                // 计算与实际值的角度差
                let kx = keyframes[k].x
                let ky = keyframes[k].y
                let kz = keyframes[k].z
                let kw = keyframes[k].w

                var dotProd = nix * kx + niy * ky + niz * kz + niw * kw
                dotProd = min(1.0f32, abs(dotProd))
                let angle = 2.0f32* acos(dotProd)
                if (angle > maxDev) { maxDev = angle }
            }
        }
        maxDev
    }
}
