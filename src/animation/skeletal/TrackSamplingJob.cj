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
 * @file[zh-cn] TrackSamplingJob
 * @brief[zh-cn] 通道采样 Job
 * @explain[zh-cn] 采样一个 Track 在给定时间比的值，输出浮点数、四元数或三分量向量。
 *
 * @file[en] TrackSamplingJob
 * @brief[en] Track sampling job
 * @explain[en] Samples a Track at a given time ratio and outputs the interpolated value.
 */
package three.animation.skeletal

import three.core.math.*

/**
 * @brief[zh-cn] 通道采样输出
 *
 * @brief[en] Track sampling output
 */
public class TrackSampleOutput {
    /**
     * @brief[zh-cn] 浮点值（Float 通道）
     *
     * @brief[en] Float value (Float track)
     */
    public var floatValue: Float32

    /**
     * @brief[zh-cn] 四元数值（Quaternion 通道）：x, y, z, w
     *
     * @brief[en] Quaternion value (Quaternion track): x, y, z, w
     */
    public var quatX: Float32
    public var quatY: Float32
    public var quatZ: Float32
    public var quatW: Float32

    /**
     * @brief[zh-cn] 三分量向量值（Float3 通道）：x, y, z
     *
     * @brief[en] 3-component vector value (Float3 track): x, y, z
     */
    public var float3X: Float32
    public var float3Y: Float32
    public var float3Z: Float32

    public init() {
        this.floatValue = 0.0f32
        this.quatX = 0.0f32
        this.quatY = 0.0f32
        this.quatZ = 0.0f32
        this.quatW = 1.0f32
        this.float3X = 0.0f32
        this.float3Y = 0.0f32
        this.float3Z = 0.0f32
    }
}

/**
 * @brief[zh-cn] 通道采样 Job
 *
 * @brief[en] Track sampling job
 */
public class TrackSamplingJob {
    /**
     * @brief[zh-cn] 时间比 [0, 1]
     *
     * @brief[en] Time ratio [0, 1]
     */
    public var ratio: Float32

    /**
     * @brief[zh-cn] 要采样的通道
     *
     * @brief[en] The track to sample
     */
    public var track: ?SkeletalTrackData

    /**
     * @brief[zh-cn] 输出
     *
     * @brief[en] Output
     */
    public var output: TrackSampleOutput

    public init() {
        this.ratio = 0.0f32
        this.track = None
        this.output = TrackSampleOutput()
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        match (this.track) {
            case Some(_) => true
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 执行采样
     * @return[zh-cn] true 表示成功
     *
     * @brief[en] Runs the sampling
     * @return[en] true on success
     */
    public func run(): Bool {
        let track = match (this.track) {
            case Some(t) => t
            case None => return false
        }
        let ratio = this.ratio

        match (track.trackType) {
            case TrackType.Float =>
                this.output.floatValue = track.sampleFloat(ratio)
            case TrackType.Quaternion =>
                let q = track.sampleQuaternion(ratio)
                this.output.quatX = q.x
                this.output.quatY = q.y
                this.output.quatZ = q.z
                this.output.quatW = q.w
            case TrackType.Float3 =>
                let v = track.sampleFloat3(ratio)
                this.output.float3X = v.x
                this.output.float3Y = v.y
                this.output.float3Z = v.z
        }

        true
    }
}
