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
 * @file[zh-cn] RawAnimationUtils
 * @brief[zh-cn] 离线动画工具函数
 * @explain[zh-cn] 提供离线动画数据的常用操作：重定向（retarget）、重采样、叠加差值计算等。
 *
 * @file[en] RawAnimationUtils
 * @brief[en] Offline animation utility functions
 * @explain[en] Provides common operations on offline animation data: retargeting, resampling, additive delta.
 */
package three.animation.offline

import std.collection.*
import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] 离线动画工具函数集
 *
 * @brief[en] Offline animation utility collection
 */
public class RawAnimationUtils {
    /**
     * @brief[zh-cn] 重定向动画到不同的骨骼结构
     * @param[zh-cn] source 源动画
     * @param[zh-cn] sourceJointNames 源骨骼关节名称列表
     * @param[zh-cn] targetJointNames 目标骨骼关节名称列表
     * @return[zh-cn] 重定向后的动画（只保留目标骨骼中存在的轨道）
     * @explain[zh-cn] 根据关节名称匹配，将源动画的轨道映射到目标骨骼。
     *                  不匹配的轨道会被跳过。
     *
     * @brief[en] Retargets an animation to a different skeleton structure
     * @param[en] source The source animation
     * @param[en] sourceJointNames The list of source skeleton joint names
     * @param[en] targetJointNames The list of target skeleton joint names
     * @return[en] The retargeted animation (only tracks present in the target skeleton are kept)
     * @explain[en] Maps the source animation tracks onto the target skeleton by matching
     *                  joint names. Unmatched tracks are skipped.
     */
    public static func retarget(
        source: RawAnimation,
        sourceJointNames: Array<String>,
        targetJointNames: Array<String>
    ): RawAnimation {
        let output = RawAnimation()
        output.duration = source.duration
        output.name = source.name + "_retargeted"

        // 构建源关节名 → 源轨道索引的映射
        let sourceNameToTrack = HashMap<String, Int>()
        for (i in 0..sourceJointNames.size) {
            sourceNameToTrack.add(sourceJointNames[i], i)
        }

        // 构建目标轨道列表：按目标骨骼顺序，匹配源动画轨道
        let targetTracks = ArrayList<Int>()
        for (i in 0..targetJointNames.size) {
            let name = targetJointNames[i]
            match (sourceNameToTrack.get(name)) {
                case Some(srcTrack) =>
                    if (srcTrack < source.trackCount) {
                        targetTracks.add(srcTrack)
                    }
                case None => ()
            }
        }

        output.initTracks(targetTracks.size)

        for (outTrack in 0..targetTracks.size) {
            let srcTrack = targetTracks[outTrack]

            // 复制平移关键帧
            for (kf in source.translations[srcTrack]) {
                output.translations[outTrack].add(kf)
            }

            // 复制旋转关键帧
            for (kf in source.rotations[srcTrack]) {
                output.rotations[outTrack].add(kf)
            }

            // 复制缩放关键帧
            for (kf in source.scales[srcTrack]) {
                output.scales[outTrack].add(kf)
            }
        }

        output
    }

    /**
     * @brief[zh-cn] 重采样动画到新的帧率
     * @param[zh-cn] source 源动画
     * @param[zh-cn] newFps 新帧率（每秒帧数）
     * @return[zh-cn] 重采样后的动画（每个轨道每帧一个关键帧）
     * @explain[zh-cn] 在时间轴上均匀采样，生成固定帧率的关键帧。
     *                  适用于需要确定性采样的场景。
     *
     * @brief[en] Resamples the animation to a new frame rate
     * @param[en] source The source animation
     * @param[en] newFps The new frame rate (frames per second)
     * @return[en] The resampled animation (one keyframe per frame per track)
     * @explain[en] Uniformly samples the time axis to produce fixed-rate keyframes.
     *                  Suitable when deterministic sampling is required.
     */
    public static func resample(source: RawAnimation, newFps: Float32): RawAnimation {
        if (source.trackCount <= 0 || newFps <= 0.0f32 || source.duration <= 0.0f32) {
            return source
        }

        let output = RawAnimation()
        output.duration = source.duration
        output.name = source.name + "_resampled"
        output.initTracks(source.trackCount)

        let frameDuration = 1.0f32 / newFps
        var time: Float32 = 0.0f32

        while (time <= source.duration) {
            for (track in 0..source.trackCount) {
                // 采样平移
                let tv = sampleTranslation(source.translations[track], time)
                output.translations[track].add(Float3Keyframe(time, tv))

                // 采样旋转
                let rv = sampleRotation(source.rotations[track], time)
                output.rotations[track].add(rv)

                // 采样缩放
                let sv = sampleTranslation(source.scales[track], time)
                output.scales[track].add(Float3Keyframe(time, sv))
            }
            time += frameDuration
        }

        output
    }

    /**
     * @brief[zh-cn] 创建叠加差值动画
     * @param[zh-cn] base 基础动画
     * @param[zh-cn] target 目标动画
     * @return[zh-cn] 叠加动画（delta = target 相对 base 的差量）
     * @explain[zh-cn] 便捷方法，内部委托给 AdditiveAnimationBuilder
     *
     * @brief[en] Creates an additive delta animation
     * @param[en] base The base animation
     * @param[en] target The target animation
     * @return[en] The additive animation (delta = target relative to base)
     * @explain[en] Convenience method that delegates to AdditiveAnimationBuilder internally
     */
    public static func makeAdditiveDelta(base: RawAnimation, target: RawAnimation): Option<RawAnimation> {
        let builder = AdditiveAnimationBuilder()
        builder.invoke(base, target)
    }

    /**
     * @brief[zh-cn] 合并两个动画（串联）
     * @param[zh-cn] first 第一段动画
     * @param[zh-cn] second 第二段动画
     * @return[zh-cn] 合并后的动画（first 紧接 second）
     * @explain[zh-cn] 将 second 的所有关键帧时间偏移 first.duration 后拼接到 first 之后。
     *                  要求两者轨道数相同。
     *
     * @brief[en] Concatenates two animations
     * @param[en] first The first animation
     * @param[en] second The second animation
     * @return[en] The merged animation (first followed by second)
     * @explain[en] All keyframe times of second are shifted by first.duration and appended
     *                  after first. Both animations must have the same track count.
     */
    public static func concatenate(first: RawAnimation, second: RawAnimation): Option<RawAnimation> {
        if (first.trackCount != second.trackCount || first.trackCount == 0) {
            return None
        }

        let output = RawAnimation()
        output.duration = first.duration + second.duration
        output.name = first.name + "_" + second.name
        output.initTracks(first.trackCount)

        for (track in 0..first.trackCount) {
            // 复制 first 的关键帧
            for (kf in first.translations[track]) {
                output.translations[track].add(kf)
            }
            for (kf in first.rotations[track]) {
                output.rotations[track].add(kf)
            }
            for (kf in first.scales[track]) {
                output.scales[track].add(kf)
            }

            // 复制 second 的关键帧（时间偏移）
            let timeOffset = first.duration
            for (kf in second.translations[track]) {
                output.translations[track].add(Float3Keyframe(kf.time + timeOffset, kf.value.clone()))
            }
            for (kf in second.rotations[track]) {
                output.rotations[track].add(QuaternionKeyframe(kf.time + timeOffset, kf.x, kf.y, kf.z, kf.w))
            }
            for (kf in second.scales[track]) {
                output.scales[track].add(Float3Keyframe(kf.time + timeOffset, kf.value.clone()))
            }
        }

        Some(output)
    }

    // ===== Private sampling helpers =====

    private static func sampleTranslation(keyframes: ArrayList<Float3Keyframe>, time: Float32): Vector3F {
        if (keyframes.size == 0) { return Vector3F() }
        if (keyframes.size == 1 || time <= keyframes[0].time) { return keyframes[0].value.clone() }
        if (time >= keyframes[keyframes.size - 1].time) { return keyframes[keyframes.size - 1].value.clone() }

        var lo = 0
        var hi = keyframes.size - 1
        while (lo < hi - 1) {
            let mid = (lo + hi) / 2
            if (keyframes[mid].time <= time) { lo = mid } else { hi = mid }
        }

        let a = keyframes[lo]
        let b = keyframes[hi]
        let dt = b.time - a.time
        if (dt <= 0.0f32) { return a.value.clone() }
        let t = (time - a.time) / dt
        Vector3F(
            a.value.x + (b.value.x - a.value.x) * t,
            a.value.y + (b.value.y - a.value.y) * t,
            a.value.z + (b.value.z - a.value.z) * t
        )
    }

    private static func sampleRotation(keyframes: ArrayList<QuaternionKeyframe>, time: Float32): QuaternionKeyframe {
        if (keyframes.size == 0) { return QuaternionKeyframe(0.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32) }
        if (keyframes.size == 1 || time <= keyframes[0].time) { return keyframes[0] }
        if (time >= keyframes[keyframes.size - 1].time) { return keyframes[keyframes.size - 1] }

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
        let dot = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
        let sign = if (dot < 0.0f32) { -1.0f32 } else { 1.0f32 }
        var ix = a.x + (b.x * sign - a.x) * t
        var iy = a.y + (b.y * sign - a.y) * t
        var iz = a.z + (b.z * sign - a.z) * t
        var iw = a.w + (b.w * sign - a.w) * t
        let len = sqrt(ix * ix + iy * iy + iz * iz + iw * iw)
        if (len > 1e-12f32) {
            let inv = 1.0f32 / len
            ix *= inv; iy *= inv; iz *= inv; iw *= inv
        }
        QuaternionKeyframe(time, ix, iy, iz, iw)
    }
}
