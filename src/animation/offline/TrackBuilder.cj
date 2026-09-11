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
 * @file[zh-cn] TrackBuilder
 * @brief[zh-cn] Raw*Track → 运行时 Track 构建器
 * @explain[zh-cn] 将离线通道数据压缩为运行时格式。
 *
 * @file[en] TrackBuilder
 * @brief[en] Raw*Track → runtime Track builder
 * @explain[en] Compresses offline track data into the runtime format.
 */
package three.animation.offline

import three.animation.skeletal.*

/**
 * @brief[zh-cn] 通道构建器
 *
 * @brief[en] Track builder
 */
public class TrackBuilder {
    /**
     * @brief[zh-cn] 构建浮点通道
     * @param[zh-cn] input 离线浮点通道数据
     * @return[zh-cn] Some(SkeletalTrackData) 或 None
     *
     * @brief[en] Builds a float track
     * @param[en] input The offline float track data
     * @return[en] Some(SkeletalTrackData) or None
     */
    public func invoke(input: RawFloatTrack): Option<SkeletalTrackData> {
        if (!input.validate()) {
            return None
        }
        if (input.keyframes.size == 0) {
            return Some(SkeletalTrackData(name: input.name, trackType: TrackType.Float))
        }
        let times = Array<Float32>(input.keyframes.size, { i => input.keyframes[i].time })
        let values = Array<Float32>(input.keyframes.size, { i => input.keyframes[i].value })
        Some(SkeletalTrackData(
            name: input.name,
            trackType: TrackType.Float,
            times: times,
            floatValues: values,
            numKeyframes: input.keyframes.size
        ))
    }

    /**
     * @brief[zh-cn] 构建四元数通道
     * @param[zh-cn] input 离线四元数通道数据
     * @return[zh-cn] Some(SkeletalTrackData) 或 None
     *
     * @brief[en] Builds a quaternion track
     * @param[en] input The offline quaternion track data
     * @return[en] Some(SkeletalTrackData) or None
     */
    public func invokeQuaternion(input: RawQuaternionTrack): Option<SkeletalTrackData> {
        if (!input.validate()) { return None }
        if (input.keyframes.size == 0) {
            return Some(SkeletalTrackData(name: input.name, trackType: TrackType.Quaternion))
        }
        let times = Array<Float32>(input.keyframes.size, { i => input.keyframes[i].time })
        let values = Array<Float32>(input.keyframes.size * 4, { i =>
            let kfIdx = i / 4
            let comp = i % 4
            match (comp) {
                case 0 => input.keyframes[kfIdx].x
                case 1 => input.keyframes[kfIdx].y
                case 2 => input.keyframes[kfIdx].z
                case _ => input.keyframes[kfIdx].w
            }
        })
        Some(SkeletalTrackData(
            name: input.name, trackType: TrackType.Quaternion,
            times: times, quatValues: values, numKeyframes: input.keyframes.size
        ))
    }

    /**
     * @brief[zh-cn] 构建三分量向量通道
     * @param[zh-cn] input 离线三分量向量通道数据
     * @return[zh-cn] Some(SkeletalTrackData) 或 None
     *
     * @brief[en] Builds a 3-component vector track
     * @param[en] input The offline 3-component vector track data
     * @return[en] Some(SkeletalTrackData) or None
     */
    public func invokeFloat3(input: RawFloat3Track): Option<SkeletalTrackData> {
        if (!input.validate()) { return None }
        if (input.keyframes.size == 0) {
            return Some(SkeletalTrackData(name: input.name, trackType: TrackType.Float3))
        }
        let times = Array<Float32>(input.keyframes.size, { i => input.keyframes[i].time })
        let values = Array<Float32>(input.keyframes.size * 3, { i =>
            let kfIdx = i / 3
            let comp = i % 3
            match (comp) {
                case 0 => input.keyframes[kfIdx].value.x
                case 1 => input.keyframes[kfIdx].value.y
                case _ => input.keyframes[kfIdx].value.z
            }
        })
        Some(SkeletalTrackData(
            name: input.name, trackType: TrackType.Float3,
            times: times, float3Values: values, numKeyframes: input.keyframes.size
        ))
    }
}
