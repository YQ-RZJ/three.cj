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
 * @file[zh-cn] AdditiveAnimationBuilder
 * @brief[zh-cn] 叠加动画构建器
 * @explain[zh-cn] 从基础动画和目标动画生成叠加动画（delta = target 相对 base 的差量）。
 *                  叠加动画用于在基础动画之上叠加额外动作（如受伤晃动、呼吸起伏等）。
 *
 * @file[en] AdditiveAnimationBuilder
 * @brief[en] Additive animation builder
 * @explain[en] Generates additive animation (delta) from base and target animations.
 *              Additive animations layer on top of base animations for effects like
 *              injury sway, breathing, etc.
 */
package three.animation.offline

import std.math.*
import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 叠加动画构建器
 *
 * @brief[en] Additive animation builder
 */
public class AdditiveAnimationBuilder {
    /**
     * @brief[zh-cn] 从基础和目标动画构建叠加动画
     * @param[zh-cn] base 基础动画（休息姿势 / idle）
     * @param[zh-cn] target 目标动画（要叠加的动作）
     * @return[zh-cn] 叠加动画（delta）
     * @explain[zh-cn] 平移通道：delta = target - base（向量减法）
     *                  旋转通道：delta = base^(-1) * target（四元数逆 × 乘法）
     *                  缩放通道：delta = target / base（逐元素除法）
     *
     * @brief[en] Builds an additive animation from base and target animations
     * @param[en] base The base animation (rest pose / idle)
     * @param[en] target The target animation (the motion to layer on)
     * @return[en] The additive animation (delta)
     * @explain[en] Translation channels: delta = target - base (vector subtraction)
     *                  Rotation channels: delta = base^(-1) * target (quaternion inverse × multiply)
     *                  Scale channels: delta = target / base (element-wise division)
     */
    public func invoke(base: RawAnimation, target: RawAnimation): Option<RawAnimation> {
        if (!base.validate() || !target.validate()) {
            return None
        }

        if (base.trackCount != target.trackCount) {
            return None
        }

        let numTracks = base.trackCount
        if (numTracks == 0) {
            return Some(RawAnimation())
        }

        let output = RawAnimation()
        output.duration = target.duration
        output.trackCount = numTracks
        output.name = "additive_" + target.name
        output.initTracks(numTracks)

        for (track in 0..numTracks) {
            // 叠加平移通道：delta = target - base
            output.translations[track] = computeTranslationDelta(
                base.translations[track],
                target.translations[track]
            )

            // 叠加旋转通道：delta = base^(-1) * target
            output.rotations[track] = computeRotationDelta(
                base.rotations[track],
                target.rotations[track]
            )

            // 叠加缩放通道：delta = target / base
            output.scales[track] = computeScaleDelta(
                base.scales[track],
                target.scales[track]
            )
        }

        output.recalcDuration()
        Some(output)
    }

    /**
     * @brief[zh-cn] 计算平移 delta：在目标时间点上，target 值减去 base 插值
     *
     * @brief[en] Computes the translation delta: at each target time, the target value minus the interpolated base value
     */
    private func computeTranslationDelta(
        baseKeyframes: ArrayList<Float3Keyframe>,
        targetKeyframes: ArrayList<Float3Keyframe>
    ): ArrayList<Float3Keyframe> {
        let result = ArrayList<Float3Keyframe>()

        for (tkf in targetKeyframes) {
            let bv = sampleTranslation(baseKeyframes, tkf.time)
            result.add(Float3Keyframe(
                tkf.time,
                Vector3F(
                    tkf.value.x - bv.x,
                    tkf.value.y - bv.y,
                    tkf.value.z - bv.z
                )
            ))
        }

        result
    }

    /**
     * @brief[zh-cn] 计算旋转 delta：delta = base^(-1) * target
     *
     * @brief[en] Computes the rotation delta: delta = base^(-1) * target
     */
    private func computeRotationDelta(
        baseKeyframes: ArrayList<QuaternionKeyframe>,
        targetKeyframes: ArrayList<QuaternionKeyframe>
    ): ArrayList<QuaternionKeyframe> {
        let result = ArrayList<QuaternionKeyframe>()

        for (tkf in targetKeyframes) {
            let b = sampleRotation(baseKeyframes, tkf.time)

            // base 的逆四元数（共轭 / 模长平方）
            let bInvLenSq = b.x * b.x + b.y * b.y + b.z * b.z + b.w * b.w
            var bix: Float32
            var biy: Float32
            var biz: Float32
            var biw: Float32
            if (bInvLenSq > 1e-12f32) {
                let invLenSq = 1.0f32 / bInvLenSq
                bix = -b.x * invLenSq
                biy = -b.y * invLenSq
                biz = -b.z * invLenSq
                biw = b.w * invLenSq
            } else {
                bix = 0.0f32
                biy = 0.0f32
                biz = 0.0f32
                biw = 1.0f32
            }

            // delta = baseInverse * target（哈密顿积）
            let tx = tkf.x
            let ty = tkf.y
            let tz = tkf.z
            let tw = tkf.w

            result.add(QuaternionKeyframe(
                tkf.time,
                biw * tx + bix * tw + biy * tz - biz * ty,
                biw * ty + biy * tw + biz * tx - bix * tz,
                biw * tz + biz * tw + bix * ty - biy * tx,
                biw * tw - bix * tx - biy * ty - biz * tz
            ))
        }

        result
    }

    /**
     * @brief[zh-cn] 计算缩放 delta：delta = target / base
     *
     * @brief[en] Computes the scale delta: delta = target / base
     */
    private func computeScaleDelta(
        baseKeyframes: ArrayList<Float3Keyframe>,
        targetKeyframes: ArrayList<Float3Keyframe>
    ): ArrayList<Float3Keyframe> {
        let result = ArrayList<Float3Keyframe>()

        for (tkf in targetKeyframes) {
            let bv = sampleTranslation(baseKeyframes, tkf.time)
            let sx = if (abs(bv.x) > 1e-6f32) { tkf.value.x / bv.x } else { 1.0f32 }
            let sy = if (abs(bv.y) > 1e-6f32) { tkf.value.y / bv.y } else { 1.0f32 }
            let sz = if (abs(bv.z) > 1e-6f32) { tkf.value.z / bv.z } else { 1.0f32 }
            result.add(Float3Keyframe(tkf.time, Vector3F(sx, sy, sz)))
        }

        result
    }

    /**
     * @brief[zh-cn] 在平移关键帧列表中按时间线性插值采样
     *
     * @brief[en] Samples the translation keyframe list with linear interpolation by time
     */
    private func sampleTranslation(keyframes: ArrayList<Float3Keyframe>, time: Float32): Vector3F {
        if (keyframes.size == 0) {
            return Vector3F()
        }
        if (keyframes.size == 1 || time <= keyframes[0].time) {
            return keyframes[0].value.clone()
        }
        if (time >= keyframes[keyframes.size - 1].time) {
            return keyframes[keyframes.size - 1].value.clone()
        }

        // 二分查找
        var lo = 0
        var hi = keyframes.size - 1
        while (lo < hi - 1) {
            let mid = (lo + hi) / 2
            if (keyframes[mid].time <= time) { lo = mid } else { hi = mid }
        }

        let a = keyframes[lo]
        let b = keyframes[hi]
        let dt = b.time - a.time
        if (dt <= 0.0f32) {
            return a.value.clone()
        }
        let t = (time - a.time) / dt
        Vector3F(
            a.value.x + (b.value.x - a.value.x) * t,
            a.value.y + (b.value.y - a.value.y) * t,
            a.value.z + (b.value.z - a.value.z) * t
        )
    }

    /**
     * @brief[zh-cn] 在旋转关键帧列表中按时间 nlerp 采样
     *
     * @brief[en] Samples the rotation keyframe list with nlerp by time
     */
    private func sampleRotation(keyframes: ArrayList<QuaternionKeyframe>, time: Float32): QuaternionKeyframe {
        if (keyframes.size == 0) {
            return QuaternionKeyframe(0.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32)
        }
        if (keyframes.size == 1 || time <= keyframes[0].time) {
            return keyframes[0]
        }
        if (time >= keyframes[keyframes.size - 1].time) {
            return keyframes[keyframes.size - 1]
        }

        var lo = 0
        var hi = keyframes.size - 1
        while (lo < hi - 1) {
            let mid = (lo + hi) / 2
            if (keyframes[mid].time <= time) { lo = mid } else { hi = mid }
        }

        let a = keyframes[lo]
        let b = keyframes[hi]
        let dt = b.time - a.time
        if (dt <= 0.0f32) { return a }

        let t = (time - a.time) / dt

        // 最短路径 nlerp
        let dot = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
        let sign = if (dot < 0.0f32) { -1.0f32 } else { 1.0f32 }
        let ix = a.x + (b.x * sign - a.x) * t
        let iy = a.y + (b.y * sign - a.y) * t
        let iz = a.z + (b.z * sign - a.z) * t
        let iw = a.w + (b.w * sign - a.w) * t
        let len = sqrt(ix * ix + iy * iy + iz * iz + iw * iw)
        if (len > 1e-12f32) {
            let inv = 1.0f32 / len
            QuaternionKeyframe(time, ix * inv, iy * inv, iz * inv, iw * inv)
        } else {
            QuaternionKeyframe(time, 0.0f32, 0.0f32, 0.0f32, 1.0f32)
        }
    }
}
