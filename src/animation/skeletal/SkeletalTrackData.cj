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
 * @file[zh-cn] SkeletalTrackData
 * @brief[zh-cn] 骨骼动画用户通道数据（嵌入动画管线内部）
 * @explain[zh-cn] 存储压缩后的用户通道数据（Float32、QuaternionF 或 Float32×3），
 *                  支持按时间比采样。由 TrackBuilder 从 Raw*Track 构建。
 *                  不与现有的 KeyframeTrack 冲突——KeyframeTrack 用于通用属性动画，
 *                  SkeletalTrackData 用于骨骼动画管线内部的通道采样。
 *
 * @file[en] SkeletalTrackData
 * @brief[en] Skeletal animation user channel data (internal to animation pipeline)
 * @explain[en] Stores compressed user channel data (Float32, QuaternionF or Float32×3)
 *                  and supports sampling by time ratio. Built from Raw*Track by TrackBuilder.
 *                  Does not conflict with the existing KeyframeTrack — KeyframeTrack is used
 *                  for general property animation, while SkeletalTrackData is used for
 *                  channel sampling inside the skeletal animation pipeline.
 */
package three.animation.skeletal

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] 通道类型枚举
 *
 * @brief[en] Track type enum
 */
public enum TrackType {
    | Float
    | Quaternion
    | Float3
}

/**
 * @brief[zh-cn] 骨骼动画用户通道数据
 *
 * @brief[en] Skeletal animation user channel data
 */
public class SkeletalTrackData {
    public var name: String
    public var trackType: TrackType
    public var times: Array<Float32>
    public var floatValues: Array<Float32>
    public var quatValues: Array<Float32>
    public var float3Values: Array<Float32>
    public var numKeyframes: Int

    public init() {
        this.name = ""
        this.trackType = TrackType.Float
        this.times = Array<Float32>(0, { _ => 0.0f32})
        this.floatValues = Array<Float32>(0, { _ => 0.0f32})
        this.quatValues = Array<Float32>(0, { _ => 0.0f32})
        this.float3Values = Array<Float32>(0, { _ => 0.0f32})
        this.numKeyframes = 0
    }

    public init(
        name!: String = "",
        trackType!: TrackType = TrackType.Float,
        times!: Array<Float32> = Array<Float32>(0, { _ => 0.0f32 }),
        floatValues!: Array<Float32> = Array<Float32>(0, { _ => 0.0f32 }),
        quatValues!: Array<Float32> = Array<Float32>(0, { _ => 0.0f32 }),
        float3Values!: Array<Float32> = Array<Float32>(0, { _ => 0.0f32 }),
        numKeyframes!: Int = 0
    ) {
        this.name = name
        this.trackType = trackType
        this.times = times
        this.floatValues = floatValues
        this.quatValues = quatValues
        this.float3Values = float3Values
        this.numKeyframes = numKeyframes
    }

    public func sampleFloat(ratio: Float32): Float32 {
        if (this.numKeyframes == 0) { return 0.0f32}
        if (this.numKeyframes == 1 || ratio <= 0.0f32) { return this.floatValues[0] }
        if (ratio >= 1.0f32) { return this.floatValues[this.numKeyframes - 1] }
        let idx = findKeyframeIndex(ratio)
        if (idx >= this.numKeyframes - 1) { return this.floatValues[this.numKeyframes - 1] }
        let t0 = this.times[idx]
        let t1 = this.times[idx + 1]
        let dt = t1 - t0
        if (dt <= 0.0f32) { return this.floatValues[idx] }
        let time = ratioToTime(ratio)
        let t = (time - t0) / dt
        this.floatValues[idx] + (this.floatValues[idx + 1] - this.floatValues[idx]) * t
    }

    public func sampleQuaternion(ratio: Float32): QuaternionF {
        if (this.numKeyframes == 0) { return QuaternionF(0.0f32, 0.0f32, 0.0f32, 1.0f32) }
        if (this.numKeyframes == 1 || ratio <= 0.0f32) {
            return QuaternionF(this.quatValues[0], this.quatValues[1], this.quatValues[2], this.quatValues[3])
        }
        if (ratio >= 1.0f32) {
            let base = (this.numKeyframes - 1) * 4
            return QuaternionF(this.quatValues[base], this.quatValues[base + 1], this.quatValues[base + 2], this.quatValues[base + 3])
        }
        let idx = findKeyframeIndex(ratio)
        if (idx >= this.numKeyframes - 1) {
            let base = (this.numKeyframes - 1) * 4
            return QuaternionF(this.quatValues[base], this.quatValues[base + 1], this.quatValues[base + 2], this.quatValues[base + 3])
        }
        let t0 = this.times[idx]
        let t1 = this.times[idx + 1]
        let dt = t1 - t0
        if (dt <= 0.0f32) {
            let base = idx * 4
            return QuaternionF(this.quatValues[base], this.quatValues[base + 1], this.quatValues[base + 2], this.quatValues[base + 3])
        }
        let time = ratioToTime(ratio)
        let t = (time - t0) / dt
        let aBase = idx * 4
        let bBase = (idx + 1) * 4
        let ax = this.quatValues[aBase]; let ay = this.quatValues[aBase + 1]; let az = this.quatValues[aBase + 2]; let aw = this.quatValues[aBase + 3]
        let bx = this.quatValues[bBase]; let by = this.quatValues[bBase + 1]; let bz = this.quatValues[bBase + 2]; let bw = this.quatValues[bBase + 3]
        let dot = ax * bx + ay * by + az * bz + aw * bw
        let sign = if (dot < 0.0f32) { -1.0f32 } else { 1.0f32 }
        var ix = ax + (bx * sign - ax) * t; var iy = ay + (by * sign - ay) * t; var iz = az + (bz * sign - az) * t; var iw = aw + (bw * sign - aw) * t
        let len = sqrt(ix * ix + iy * iy + iz * iz + iw * iw)
        if (len > 1e-12f32) { let inv = 1.0f32 / len; ix *= inv; iy *= inv; iz *= inv; iw *= inv }
        QuaternionF(ix, iy, iz, iw)
    }

    public func sampleFloat3(ratio: Float32): Vector3F {
        if (this.numKeyframes == 0) { return Vector3F(0.0f32, 0.0f32, 0.0f32) }
        if (this.numKeyframes == 1 || ratio <= 0.0f32) {
            return Vector3F(this.float3Values[0], this.float3Values[1], this.float3Values[2])
        }
        if (ratio >= 1.0f32) {
            let base = (this.numKeyframes - 1) * 3
            return Vector3F(this.float3Values[base], this.float3Values[base + 1], this.float3Values[base + 2])
        }
        let idx = findKeyframeIndex(ratio)
        if (idx >= this.numKeyframes - 1) {
            let base = (this.numKeyframes - 1) * 3
            return Vector3F(this.float3Values[base], this.float3Values[base + 1], this.float3Values[base + 2])
        }
        let t0 = this.times[idx]
        let t1 = this.times[idx + 1]
        let dt = t1 - t0
        if (dt <= 0.0f32) {
            let base = idx * 3
            return Vector3F(this.float3Values[base], this.float3Values[base + 1], this.float3Values[base + 2])
        }
        let time = ratioToTime(ratio)
        let t = (time - t0) / dt
        let aBase = idx * 3
        let bBase = (idx + 1) * 3
        Vector3F(
            this.float3Values[aBase] + (this.float3Values[bBase] - this.float3Values[aBase]) * t,
            this.float3Values[aBase + 1] + (this.float3Values[bBase + 1] - this.float3Values[aBase + 1]) * t,
            this.float3Values[aBase + 2] + (this.float3Values[bBase + 2] - this.float3Values[aBase + 2]) * t
        )
    }

    private func ratioToTime(ratio: Float32): Float32 {
        if (this.times.size == 0) { return 0.0f32}
        this.times[0] + ratio * (this.times[this.times.size - 1] - this.times[0])
    }

    private func findKeyframeIndex(ratio: Float32): Int {
        let time = ratioToTime(ratio)
        var lo = 0; var hi = this.times.size - 1
        while (lo < hi) { let mid = (lo + hi + 1) / 2; if (this.times[mid] <= time) { lo = mid } else { hi = mid - 1 } }
        lo
    }
}
