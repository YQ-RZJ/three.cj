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
 * @file[zh-cn] AnimationBuilder
 * @brief[zh-cn] RawAnimation → 运行时 SkeletalAnimationData 构建器
 * @explain[zh-cn] 将离线动画数据构建为运行时数据：
 *                  1. 验证并排序关键帧（按时间升序）
 *                  2. 每个关节轨道的 T/R/S 关键帧拷贝到 JointTrack 的 6 个平铺数组
 *                  3. 空通道保留为空数组（采样时回退默认值）
 *
 * @file[en] AnimationBuilder
 * @brief[en] RawAnimation → runtime SkeletalAnimationData builder
 * @explain[en] Builds offline animation data into runtime data:
 *                  1. Validates and sorts keyframes (by time, ascending)
 *                  2. Copies the T/R/S keyframes of each joint track into the
 *                     6 flattened arrays of JointTrack
 *                  3. Empty channels are kept as empty arrays (default values
 *                     are used as fallback when sampling)
 */
package three.animation.offline

import std.collection.*
import three.animation.skeletal.*
import three.core.math.soa.*
import three.core.math.*

/**
 * @brief[zh-cn] 动画构建器
 *
 * @brief[en] Animation builder
 */
public class AnimationBuilder {
    /**
     * @brief[zh-cn] 构建运行时 SkeletalAnimationData
     * @param[zh-cn] input 离线动画数据
     * @return[zh-cn] Some(SkeletalAnimationData) 构建成功，None 表示输入无效
     *
     * @brief[en] Builds runtime SkeletalAnimationData
     * @param[en] input The offline animation data
     * @return[en] Some(SkeletalAnimationData) on success; None when the input is invalid
     */
    public func invoke(input: RawAnimation): Option<SkeletalAnimationData> {
        if (!input.validate()) {
            return None
        }

        let numTracks = input.trackCount
        if (numTracks == 0) {
            return Some(SkeletalAnimationData())
        }

        // 确保关键帧按时间升序
        input.sortKeyframes()
        // 若未显式设置时长，则按关键帧最大时间重算
        if (input.duration <= 0.0f32) {
            input.recalcDuration()
        }

        var tracks = Array<JointTrack>(numTracks, { _ => JointTrack() })
        for (t in 0..numTracks) {
            // ===== 平移通道 =====
            let tkfs = input.translations[t]
            let transTimes = Array<Float32>(tkfs.size, { i => tkfs[i].time })
            let transValues = Array<Float32>(tkfs.size * 3, { _ => 0.0f32 })
            for (i in 0..tkfs.size) {
                let v = tkfs[i].value
                transValues[i * 3] = v.x
                transValues[i * 3 + 1] = v.y
                transValues[i * 3 + 2] = v.z
            }

            // ===== 旋转通道 =====
            let rkfs = input.rotations[t]
            let rotTimes = Array<Float32>(rkfs.size, { i => rkfs[i].time })
            let rotValues = Array<Float32>(rkfs.size * 4, { _ => 0.0f32 })
            for (i in 0..rkfs.size) {
                rotValues[i * 4] = rkfs[i].x
                rotValues[i * 4 + 1] = rkfs[i].y
                rotValues[i * 4 + 2] = rkfs[i].z
                rotValues[i * 4 + 3] = rkfs[i].w
            }

            // ===== 缩放通道 =====
            let skfs = input.scales[t]
            let scaleTimes = Array<Float32>(skfs.size, { i => skfs[i].time })
            let scaleValues = Array<Float32>(skfs.size * 3, { _ => 0.0f32 })
            for (i in 0..skfs.size) {
                let v = skfs[i].value
                scaleValues[i * 3] = v.x
                scaleValues[i * 3 + 1] = v.y
                scaleValues[i * 3 + 2] = v.z
            }

            tracks[t] = JointTrack(transTimes, transValues, rotTimes, rotValues, scaleTimes, scaleValues)
        }

        Some(SkeletalAnimationData(input.duration, numTracks, tracks))
    }
}
