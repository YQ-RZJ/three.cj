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
 * @file[zh-cn] SamplingJob
 * @brief[zh-cn] 动画采样 Job
 * @explain[zh-cn] 在给定时间比 [0,1] 采样骨骼动画，输出局部空间关节变换（SoaTransform）。
 *                  平移/缩放通道做线性插值，旋转通道做最短路径 nlerp；通道缺失时回退默认值
 *                  （平移 0、旋转单位四元数、缩放 1）。支持 Context 帧间缓存。
 *
 * @file[en] SamplingJob
 * @brief[en] Animation sampling job
 * @explain[en] Samples a skeletal animation at a given time ratio and produces local-space
 *              joint transforms (SoaTransform). Translation/scale use linear interpolation,
 *              rotation uses shortest-path nlerp; missing channels fall back to defaults.
 * @explain[en] Missing channels fall back to defaults (translation 0, identity quaternion
 *              for rotation, scale 1). Supports inter-frame caching through the Context.
 */
package three.animation.skeletal

import std.math.*
import three.core.math.soa.*
import three.core.math.*

/**
 * @brief[zh-cn] 采样上下文（帧间缓存）
 * @explain[zh-cn] 存储上一帧的采样状态，利用帧间时间连续性加速当前帧采样。
 *
 * @brief[en] Sampling context (inter-frame cache)
 * @explain[en] Stores the sampling state of the previous frame, accelerating sampling of
 * the current frame by exploiting temporal continuity between frames.
 */
public class SamplingContext {
    /**
     * @brief[zh-cn] 上一帧的动画
     *
     * @brief[en] The animation of the previous frame
     */
    public var lastAnimation: ?SkeletalAnimationData

    /**
     * @brief[zh-cn] 上一帧的时间比
     *
     * @brief[en] The time ratio of the previous frame
     */
    public var lastRatio: Float32

    /**
     * @brief[zh-cn] 每轨道平移的上一帧关键帧索引
     *
     * @brief[en] Previous-frame keyframe index of each track's translation
     */
    public var lastTransKeyframe: Array<Int>

    /**
     * @brief[zh-cn] 每轨道旋转的上一帧关键帧索引
     *
     * @brief[en] Previous-frame keyframe index of each track's rotation
     */
    public var lastRotKeyframe: Array<Int>

    /**
     * @brief[zh-cn] 每轨道缩放的上一帧关键帧索引
     *
     * @brief[en] Previous-frame keyframe index of each track's scale
     */
    public var lastScaleKeyframe: Array<Int>

    /**
     * @brief[zh-cn] 最大支持的轨道数
     *
     * @brief[en] Maximum supported number of tracks
     */
    public var maxTracks: Int

    public init() {
        this.lastAnimation = None
        this.lastRatio = 0.0f32
        this.lastTransKeyframe = Array<Int>(0, { _ => 0 })
        this.lastRotKeyframe = Array<Int>(0, { _ => 0 })
        this.lastScaleKeyframe = Array<Int>(0, { _ => 0 })
        this.maxTracks = 0
    }

    /**
     * @brief[zh-cn] 调整缓存大小以匹配轨道数
     *
     * @brief[en] Resizes the cache to match the number of tracks
     */
    public func resize(numTracks: Int): Unit {
        if (numTracks > this.maxTracks) {
            this.maxTracks = numTracks
            this.lastTransKeyframe = Array<Int>(numTracks, { _ => 0 })
            this.lastRotKeyframe = Array<Int>(numTracks, { _ => 0 })
            this.lastScaleKeyframe = Array<Int>(numTracks, { _ => 0 })
        }
    }

    /**
     * @brief[zh-cn] 使缓存失效（切换动画时调用）
     *
     * @brief[en] Invalidates the cache (call when switching animations)
     */
    public func invalidate(): Unit {
        this.lastAnimation = None
    }
}

/**
 * @brief[zh-cn] 动画采样 Job
 * @explain[zh-cn] 输入 SkeletalAnimationData + ratio，输出 SoaTransform[]。
 *
 * @brief[en] Animation sampling job
 * @explain[en] Takes SkeletalAnimationData + ratio as input and outputs SoaTransform[].
 */
public class SamplingJob {
    /**
     * @brief[zh-cn] 时间比 [0, 1]
     *
     * @brief[en] Time ratio [0, 1]
     */
    public var ratio: Float32

    /**
     * @brief[zh-cn] 要采样的动画数据
     *
     * @brief[en] The animation data to sample
     */
    public var animation: ?SkeletalAnimationData

    /**
     * @brief[zh-cn] 采样上下文（帧间缓存）
     *
     * @brief[en] Sampling context (inter-frame cache)
     */
    public var context: SamplingContext

    /**
     * @brief[zh-cn] 输出缓冲区
     * @explain[zh-cn] 长度应为 numSoaJoints = (numTracks + 3) / 4
     *
     * @brief[en] Output buffer
     * @explain[en] Length should be numSoaJoints = (numTracks + 3) / 4
     */
    public var output: Array<SoaTransform>

    public init() {
        this.ratio = 0.0f32
        this.animation = None
        this.context = SamplingContext()
        this.output = Array<SoaTransform>(0, { _ => SoaTransform() })
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     * @return[zh-cn] true 表示可以执行
     *
     * @brief[en] Validates the inputs
     * @return[en] true if the job can run
     */
    public func validate(): Bool {
        let a = match (this.animation) {
            case Some(a) => a
            case None => return false
        }
        if (a.numTracks <= 0) {
            return true  // 空动画合法
        }
        let requiredSize = a.numSoaJoints()
        if (this.output.size < requiredSize) {
            return false
        }
        if (this.ratio < 0.0f32 || this.ratio > 1.0f32) {
            return false
        }
        true
    }

    /**
     * @brief[zh-cn] 执行采样
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 核心采样逻辑：
     *                  1. 将 ratio 转换为时间点
     *                  2. 对每个轨道的每个通道（T/R/S）二分查找相邻关键帧
     *                  3. 线性插值（旋转为最短路径 nlerp）得到局部变换
     *                  4. 打包为 SoaTransform 输出
     *
     * @brief[en] Runs the sampling
     * @return[en] true on success
     * @explain[en] Core sampling logic:
     *                  1. Converts the ratio into a time point
     *                  2. Binary-searches the neighbouring keyframes for each channel
     *                     (T/R/S) of each track
     *                  3. Linearly interpolates (shortest-path nlerp for rotation) to get
     *                     the local transform
     *                  4. Packs the results into SoaTransform outputs
     */
    public func run(): Bool {
        let clip = match (this.animation) {
            case Some(a) => a
            case None => return false
        }
        let numTracks = clip.numTracks
        if (numTracks <= 0) { return true }

        this.context.resize(numTracks)

        let time = this.ratio * clip.duration
        let numSoa = clip.numSoaJoints()

        for (soaIdx in 0..numSoa) {
            let baseJoint = soaIdx * 4

            // 为 4 个槽位采样
            var tx = Array<Float32>(4, { _ => 0.0f32 })
            var ty = Array<Float32>(4, { _ => 0.0f32 })
            var tz = Array<Float32>(4, { _ => 0.0f32 })
            var rx = Array<Float32>(4, { _ => 0.0f32 })
            var ry = Array<Float32>(4, { _ => 0.0f32 })
            var rz = Array<Float32>(4, { _ => 0.0f32 })
            var rw = Array<Float32>(4, { _ => 1.0f32 })
            var sx = Array<Float32>(4, { _ => 1.0f32 })
            var sy = Array<Float32>(4, { _ => 1.0f32 })
            var sz = Array<Float32>(4, { _ => 1.0f32 })

            for (slot in 0..4) {
                let track = baseJoint + slot
                if (track >= numTracks) { break }

                // 采样平移
                let pt = sampleTranslation(clip, track, time)
                tx[slot] = pt.x
                ty[slot] = pt.y
                tz[slot] = pt.z

                // 采样旋转
                let pr = sampleRotation(clip, track, time)
                rx[slot] = pr.x
                ry[slot] = pr.y
                rz[slot] = pr.z
                rw[slot] = pr.w

                // 采样缩放
                let ps = sampleScale(clip, track, time)
                sx[slot] = ps.x
                sy[slot] = ps.y
                sz[slot] = ps.z
            }

            this.output[soaIdx] = SoaTransform.fromFour(
                tx[0], ty[0], tz[0], rx[0], ry[0], rz[0], rw[0], sx[0], sy[0], sz[0],
                tx[1], ty[1], tz[1], rx[1], ry[1], rz[1], rw[1], sx[1], sy[1], sz[1],
                tx[2], ty[2], tz[2], rx[2], ry[2], rz[2], rw[2], sx[2], sy[2], sz[2],
                tx[3], ty[3], tz[3], rx[3], ry[3], rz[3], rw[3], sx[3], sy[3], sz[3]
            )
        }

        this.context.lastAnimation = clip
        this.context.lastRatio = this.ratio

        true
    }

    // ===== Private sampling helpers =====

    /**
     * @brief[zh-cn] 在升序时间数组中二分查找 time 所在区间 [lo, hi]
     * @return[zh-cn] 区间左关键帧索引（右索引为 lo+1；time 超出范围时返回边界）
     *
     * @brief[en] Binary-searches the interval [lo, hi] containing time in an ascending time array
     * @return[en] The index of the left keyframe of the interval (the right one is lo+1; returns a boundary when time is out of range)
     */
    private func findInterval(times: Array<Float32>, num: Int, time: Float32): Int {
        if (time <= times[0]) { return 0 }
        if (time >= times[num - 1]) { return num - 1 }
        var lo = 0
        var hi = num - 1
        while (hi - lo > 1) {
            let mid = (lo + hi) / 2
            if (times[mid] <= time) {
                lo = mid
            } else {
                hi = mid
            }
        }
        lo
    }

    /**
     * @brief[zh-cn] 采样平移通道（线性插值，缺失时返回零向量）
     *
     * @brief[en] Samples the translation channel (linear interpolation; returns the zero vector when missing)
     */
    private func sampleTranslation(clip: SkeletalAnimationData, track: Int, time: Float32): Vector3F {
        let jt = clip.tracks[track]
        let n = jt.transTimes.size
        if (n == 0) { return Vector3F(0.0f32, 0.0f32, 0.0f32) }
        if (n == 1) {
            return Vector3F(jt.transValues[0], jt.transValues[1], jt.transValues[2])
        }
        let lo = findInterval(jt.transTimes, n, time)
        let i0 = lo * 3
        if (time >= jt.transTimes[n - 1] || lo == n - 1) {
            return Vector3F(jt.transValues[i0], jt.transValues[i0 + 1], jt.transValues[i0 + 2])
        }
        let t0 = jt.transTimes[lo]
        let t1 = jt.transTimes[lo + 1]
        var alpha = (time - t0) / (t1 - t0)
        if (alpha < 0.0f32) { alpha = 0.0f32 }
        if (alpha > 1.0f32) { alpha = 1.0f32 }
        let i1 = i0 + 3
        Vector3F(
            jt.transValues[i0] + (jt.transValues[i1] - jt.transValues[i0]) * alpha,
            jt.transValues[i0 + 1] + (jt.transValues[i1 + 1] - jt.transValues[i0 + 1]) * alpha,
            jt.transValues[i0 + 2] + (jt.transValues[i1 + 2] - jt.transValues[i0 + 2]) * alpha
        )
    }

    /**
     * @brief[zh-cn] 采样旋转通道（最短路径 nlerp，缺失时返回单位四元数）
     *
     * @brief[en] Samples the rotation channel (shortest-path nlerp; returns the identity quaternion when missing)
     */
    private func sampleRotation(clip: SkeletalAnimationData, track: Int, time: Float32): QuaternionF {
        let jt = clip.tracks[track]
        let n = jt.rotTimes.size
        if (n == 0) { return QuaternionF(0.0f32, 0.0f32, 0.0f32, 1.0f32) }
        if (n == 1) {
            return QuaternionF(jt.rotValues[0], jt.rotValues[1], jt.rotValues[2], jt.rotValues[3])
        }
        let lo = findInterval(jt.rotTimes, n, time)
        let i0 = lo * 4
        if (time >= jt.rotTimes[n - 1] || lo == n - 1) {
            return QuaternionF(jt.rotValues[i0], jt.rotValues[i0 + 1], jt.rotValues[i0 + 2], jt.rotValues[i0 + 3])
        }
        let t0 = jt.rotTimes[lo]
        let t1 = jt.rotTimes[lo + 1]
        var alpha = (time - t0) / (t1 - t0)
        if (alpha < 0.0f32) { alpha = 0.0f32 }
        if (alpha > 1.0f32) { alpha = 1.0f32 }
        let i1 = i0 + 4
        let q0x = jt.rotValues[i0]
        let q0y = jt.rotValues[i0 + 1]
        let q0z = jt.rotValues[i0 + 2]
        let q0w = jt.rotValues[i0 + 3]
        // 最短路径：点积为负时翻转终点
        var q1x = jt.rotValues[i1]
        var q1y = jt.rotValues[i1 + 1]
        var q1z = jt.rotValues[i1 + 2]
        var q1w = jt.rotValues[i1 + 3]
        let dot = q0x * q1x + q0y * q1y + q0z * q1z + q0w * q1w
        if (dot < 0.0f32) {
            q1x = -q1x
            q1y = -q1y
            q1z = -q1z
            q1w = -q1w
        }
        // nlerp
        var rx = q0x + (q1x - q0x) * alpha
        var ry = q0y + (q1y - q0y) * alpha
        var rz = q0z + (q1z - q0z) * alpha
        var rw = q0w + (q1w - q0w) * alpha
        let len = sqrt(rx * rx + ry * ry + rz * rz + rw * rw)
        if (len > 1e-12f32) {
            let inv = 1.0f32 / len
            rx *= inv
            ry *= inv
            rz *= inv
            rw *= inv
        } else {
            rx = 0.0f32
            ry = 0.0f32
            rz = 0.0f32
            rw = 1.0f32
        }
        QuaternionF(rx, ry, rz, rw)
    }

    /**
     * @brief[zh-cn] 采样缩放通道（线性插值，缺失时返回 (1,1,1)）
     *
     * @brief[en] Samples the scale channel (linear interpolation; returns (1,1,1) when missing)
     */
    private func sampleScale(clip: SkeletalAnimationData, track: Int, time: Float32): Vector3F {
        let jt = clip.tracks[track]
        let n = jt.scaleTimes.size
        if (n == 0) { return Vector3F(1.0f32, 1.0f32, 1.0f32) }
        if (n == 1) {
            return Vector3F(jt.scaleValues[0], jt.scaleValues[1], jt.scaleValues[2])
        }
        let lo = findInterval(jt.scaleTimes, n, time)
        let i0 = lo * 3
        if (time >= jt.scaleTimes[n - 1] || lo == n - 1) {
            return Vector3F(jt.scaleValues[i0], jt.scaleValues[i0 + 1], jt.scaleValues[i0 + 2])
        }
        let t0 = jt.scaleTimes[lo]
        let t1 = jt.scaleTimes[lo + 1]
        var alpha = (time - t0) / (t1 - t0)
        if (alpha < 0.0f32) { alpha = 0.0f32 }
        if (alpha > 1.0f32) { alpha = 1.0f32 }
        let i1 = i0 + 3
        Vector3F(
            jt.scaleValues[i0] + (jt.scaleValues[i1] - jt.scaleValues[i0]) * alpha,
            jt.scaleValues[i0 + 1] + (jt.scaleValues[i1 + 1] - jt.scaleValues[i0 + 1]) * alpha,
            jt.scaleValues[i0 + 2] + (jt.scaleValues[i1 + 2] - jt.scaleValues[i0 + 2]) * alpha
        )
    }
}
