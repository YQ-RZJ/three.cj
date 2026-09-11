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
 * @file[zh-cn] SkeletalAnimationData
 * @brief[zh-cn] 骨骼动画运行时数据（嵌入 AnimationClip.skeletalData）
 * @explain[zh-cn] 存储骨骼动画的运行时关键帧数据：每个关节轨道（JointTrack）独立持有
 *                  平移/旋转/缩放通道的时间点与值数组。时间点按升序排列，值数组按
 *                  关键帧顺序平铺（平移/缩放每帧 3 分量，旋转每帧 4 分量）。
 *                  由 AnimationBuilder 从 RawAnimation 构建，通过 SamplingJob 按时间比采样。
 *                  缺失的通道在采样时回退到默认值（平移 0、旋转单位四元数、缩放 1）。
 *
 * @file[en] SkeletalAnimationData
 * @brief[en] Runtime skeletal animation data (embedded in AnimationClip.skeletalData)
 * @explain[en] Stores runtime keyframe data: each joint track (JointTrack) owns its own
 *              translation/rotation/scale time and value arrays. Times are ascending;
 *              value arrays are flattened per keyframe (3 components for T/S, 4 for R).
 *              Built from RawAnimation via AnimationBuilder, sampled by SamplingJob.
 *              Missing channels fall back to defaults (T=0, R=identity, S=1).
 */
package three.animation.skeletal

import three.core.math.soa.*
import three.core.math.*

/**
 * @brief[zh-cn] 单关节轨道的运行时关键帧数据
 * @explain[zh-cn] 一个 JointTrack 对应一个关节，包含三个通道：
 *                  - 平移：transTimes（升序）+ transValues（每帧 x,y,z 共 3n 个 Float32）
 *                  - 旋转：rotTimes（升序）+ rotValues（每帧 x,y,z,w 共 4n 个 Float32）
 *                  - 缩放：scaleTimes（升序）+ scaleValues（每帧 x,y,z 共 3n 个 Float32）
 *                  通道数组为空表示该通道无动画，采样时使用默认值。
 *
 * @brief[en] Runtime keyframe data for a single joint track
 * @explain[en] One JointTrack corresponds to one joint and contains three channels:
 *                  - Translation: transTimes (ascending) + transValues (3n Float32: x,y,z per keyframe)
 *                  - Rotation: rotTimes (ascending) + rotValues (4n Float32: x,y,z,w per keyframe)
 *                  - Scale: scaleTimes (ascending) + scaleValues (3n Float32: x,y,z per keyframe)
 *                  An empty channel array means the channel has no animation and the
 *                  default value is used when sampling.
 */
public class JointTrack {
    /**
     * @brief[zh-cn] 平移通道时间点（升序，秒）
     *
     * @brief[en] Translation channel time points (ascending, seconds)
     */
    public var transTimes: Array<Float32>
    /**
     * @brief[zh-cn] 平移通道值（每帧 3 分量，长度 = transTimes.size * 3）
     *
     * @brief[en] Translation channel values (3 components per keyframe, length = transTimes.size * 3)
     */
    public var transValues: Array<Float32>
    /**
     * @brief[zh-cn] 旋转通道时间点（升序，秒）
     *
     * @brief[en] Rotation channel time points (ascending, seconds)
     */
    public var rotTimes: Array<Float32>
    /**
     * @brief[zh-cn] 旋转通道值（每帧 4 分量，长度 = rotTimes.size * 4）
     *
     * @brief[en] Rotation channel values (4 components per keyframe, length = rotTimes.size * 4)
     */
    public var rotValues: Array<Float32>
    /**
     * @brief[zh-cn] 缩放通道时间点（升序，秒）
     *
     * @brief[en] Scale channel time points (ascending, seconds)
     */
    public var scaleTimes: Array<Float32>
    /**
     * @brief[zh-cn] 缩放通道值（每帧 3 分量，长度 = scaleTimes.size * 3）
     *
     * @brief[en] Scale channel values (3 components per keyframe, length = scaleTimes.size * 3)
     */
    public var scaleValues: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造（空通道）
     *
     * @brief[en] Default constructor (empty channels)
     */
    public init() {
        this.transTimes = Array<Float32>(0, { _ => 0.0f32 })
        this.transValues = Array<Float32>(0, { _ => 0.0f32 })
        this.rotTimes = Array<Float32>(0, { _ => 0.0f32 })
        this.rotValues = Array<Float32>(0, { _ => 0.0f32 })
        this.scaleTimes = Array<Float32>(0, { _ => 0.0f32 })
        this.scaleValues = Array<Float32>(0, { _ => 0.0f32 })
    }

    /**
     * @brief[zh-cn] 从通道数组构造
     *
     * @brief[en] Constructs from channel arrays
     */
    public init(
        transTimes: Array<Float32>, transValues: Array<Float32>,
        rotTimes: Array<Float32>, rotValues: Array<Float32>,
        scaleTimes: Array<Float32>, scaleValues: Array<Float32>
    ) {
        this.transTimes = transTimes
        this.transValues = transValues
        this.rotTimes = rotTimes
        this.rotValues = rotValues
        this.scaleTimes = scaleTimes
        this.scaleValues = scaleValues
    }

    /**
     * @brief[zh-cn] 平移通道关键帧数量
     *
     * @brief[en] Number of translation channel keyframes
     */
    public func numTransKeyframes(): Int {
        this.transTimes.size
    }

    /**
     * @brief[zh-cn] 旋转通道关键帧数量
     *
     * @brief[en] Number of rotation channel keyframes
     */
    public func numRotKeyframes(): Int {
        this.rotTimes.size
    }

    /**
     * @brief[zh-cn] 缩放通道关键帧数量
     *
     * @brief[en] Number of scale channel keyframes
     */
    public func numScaleKeyframes(): Int {
        this.scaleTimes.size
    }
}

/**
 * @brief[zh-cn] 骨骼动画运行时数据
 * @explain[zh-cn] 作为 AnimationClip 的内部字段，存储每个关节轨道的关键帧数据。
 *                  duration 为动画时长（秒），numTracks 为轨道数（应等于骨骼关节数）。
 *                  采样入口为 SamplingJob。
 *
 * @brief[en] Runtime skeletal animation data
 * @explain[en] Stored as an internal field of AnimationClip, holding the keyframe data of
 *                  each joint track. duration is the animation length in seconds and
 *                  numTracks is the number of tracks (should equal the number of skeleton
 *                  joints). Sampling entry point is SamplingJob.
 */
public class SkeletalAnimationData {
    /**
     * @brief[zh-cn] 动画时长（秒）
     *
     * @brief[en] Animation duration in seconds
     */
    public var duration: Float32

    /**
     * @brief[zh-cn] 轨道数（等于骨骼关节数）
     *
     * @brief[en] Number of tracks (equal to the number of skeleton joints)
     */
    public var numTracks: Int

    /**
     * @brief[zh-cn] 每关节轨道数据（长度 = numTracks）
     *
     * @brief[en] Per-joint track data (length = numTracks)
     */
    public var tracks: Array<JointTrack>

    /**
     * @brief[zh-cn] 默认构造函数（空数据）
     *
     * @brief[en] Default constructor (empty data)
     */
    public init() {
        this.duration = 0.0f32
        this.numTracks = 0
        this.tracks = Array<JointTrack>(0, { _ => JointTrack() })
    }

    /**
     * @brief[zh-cn] 从构建数据构造（供 AnimationBuilder 使用）
     *
     * @brief[en] Constructs from build data (used by AnimationBuilder)
     */
    public init(duration: Float32, numTracks: Int, tracks: Array<JointTrack>) {
        this.duration = duration
        this.numTracks = numTracks
        this.tracks = tracks
    }

    /**
     * @brief[zh-cn] 获取 SoA 元素数量（每 4 个关节一个 SoaTransform）
     *
     * @brief[en] Returns the number of SoA elements (one SoaTransform per 4 joints)
     */
    public func numSoaJoints(): Int {
        (this.numTracks + 3) / 4
    }

    /**
     * @brief[zh-cn] 获取指定轨道
     *
     * @brief[en] Returns the specified track
     */
    public func track(track: Int): JointTrack {
        this.tracks[track]
    }
}
