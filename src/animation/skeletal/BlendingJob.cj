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
 * @file[zh-cn] BlendingJob
 * @brief[zh-cn] 多动画混合 Job
 * @explain[zh-cn] 将多个动画姿态按权重混合为单个输出姿态（对齐 ozz BlendingJob）。
 *                  普通层：加权累加后归一化（T/S 除以累积权重，R 归一化），累积权重低于
 *                  阈值的关节回退 rest pose；叠加层：在普通层混合结果上按差量复合
 *                  （t += w·dt，r = nlerp(r, dr·r, w)，s *= lerp(1, ds, w)）。
 *                  支持逐关节权重。
 *
 * @file[en] BlendingJob
 * @brief[en] Multi-animation blending job
 * @explain[en] Blends multiple animation poses by weight into a single output pose
 *              (aligned with ozz BlendingJob). Normal layers are weight-accumulated then
 *              normalized; joints below the weight threshold fall back to the rest pose.
 *              Additive layers composite deltas on top of the blended result.
 *              Additive layers composite deltas on top of the blended result
 *              (t += w·dt, r = nlerp(r, dr·r, w), s *= lerp(1, ds, w)).
 *              Supports per-joint weights.
 *
 * @brief[en] Blend layer
 * @explain[en] A blending input: weight + transform array + optional per-joint weights
 */
package three.animation.skeletal

import std.math.*
import three.core.math.*
import three.core.math.soa.*
import std.collection.*

/**
 * @brief[zh-cn] 混合层
 * @explain[zh-cn] 一个混合输入：权重 + 变换数组 + 可选的逐关节权重
 *
 * @brief[en] Blend layer
 * @explain[en] A blending input: weight + transform array + optional per-joint weights
 */
public class BlendLayer {
    /**
     * @brief[zh-cn] 层权重 [0, 1]
     *
     * @brief[en] Layer weight [0, 1]
     */
    public var weight: Float32

    /**
     * @brief[zh-cn] 该层的关节变换数组
     * @explain[zh-cn] 长度应为 (numJoints + 3) / 4
     *
     * @brief[en] Joint transform array of this layer
     * @explain[en] Length should be (numJoints + 3) / 4
     */
    public var transforms: Array<SoaTransform>

    /**
     * @brief[zh-cn] 逐关节权重（可选）
     * @explain[zh-cn] 长度为 numJoints，每个元素控制该关节的混合权重。
     *                  为 None 时表示所有关节权重相同（使用 layer weight）。
     *
     * @brief[en] Per-joint weights (optional)
     * @explain[en] Length is numJoints; each element controls the blending weight of that
     *                  joint. None means all joints share the same weight (the layer weight).
     */
    public var jointWeights: ?Array<Float32>

    public init() {
        this.weight = 0.0f32
        this.transforms = Array<SoaTransform>(0, { _ => SoaTransform() })
        this.jointWeights = None
    }

    /**
     * @brief[zh-cn] 设置层数据
     *
     * @brief[en] Sets the layer data
     */
    public func set(weight: Float32, transforms: Array<SoaTransform>, jointWeights!: ?Array<Float32> = None): Unit {
        this.weight = weight
        this.transforms = transforms
        this.jointWeights = jointWeights
    }
}

/**
 * @brief[zh-cn] 多动画混合 Job
 *
 * @brief[en] Multi-animation blending job
 */
public class BlendingJob {
    /**
     * @brief[zh-cn] 权重阈值：累积权重低于此值的关节使用 rest pose
     * @explain[zh-cn] 必须 > 0，典型值 0.001
     *
     * @brief[en] Weight threshold: joints whose accumulated weight is below this value use the rest pose
     * @explain[en] Must be > 0; typical value is 0.001
     */
    public var threshold: Float32

    /**
     * @brief[zh-cn] 普通混合层列表
     *
     * @brief[en] List of normal blending layers
     */
    public var layers: ArrayList<BlendLayer>

    /**
     * @brief[zh-cn] 叠加混合层列表
     * @explain[zh-cn] 叠加层的值为差量姿态，在普通层混合归一化后复合
     *
     * @brief[en] List of additive blending layers
     * @explain[en] Additive layer values are delta poses, composited after the normal
     * layers are blended and normalized
     */
    public var additiveLayers: ArrayList<BlendLayer>

    /**
     * @brief[zh-cn] 骨骼休息姿势
     * @explain[zh-cn] 长度为 (numJoints + 3) / 4，作为未达阈值关节的 fallback
     *
     * @brief[en] Skeleton rest pose
     * @explain[en] Length is (numJoints + 3) / 4; used as the fallback for joints below the threshold
     */
    public var restPose: Array<SoaTransform>

    /**
     * @brief[zh-cn] 输出缓冲区
     *
     * @brief[en] Output buffer
     */
    public var output: Array<SoaTransform>

    public init() {
        this.threshold = 0.001f32
        this.layers = ArrayList<BlendLayer>()
        this.additiveLayers = ArrayList<BlendLayer>()
        this.restPose = Array<SoaTransform>(0, { _ => SoaTransform() })
        this.output = Array<SoaTransform>(0, { _ => SoaTransform() })
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        if (this.threshold <= 0.0f32) { return false }
        if (this.restPose.size == 0) { return false }
        if (this.output.size < this.restPose.size) { return false }

        for (layer in this.layers) {
            if (layer.transforms.size < this.restPose.size) { return false }
        }
        for (layer in this.additiveLayers) {
            if (layer.transforms.size < this.restPose.size) { return false }
        }

        true
    }

    /**
     * @brief[zh-cn] 计算某层某关节的有效权重
     *
     * @brief[en] Computes the effective weight of a joint in a layer
     */
    private func jointWeight(layer: BlendLayer, joint: Int): Float32 {
        var w = layer.weight
        match (layer.jointWeights) {
            case Some(jw) =>
                if (joint < jw.size) {
                    w *= jw[joint]
                }
            case None => ()
        }
        w
    }

    /**
     * @brief[zh-cn] 执行混合
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 混合算法（对齐 ozz）：
     *                  1. 零初始化加权累加器（T/R/S 分量与累积权重）
     *                  2. 遍历普通层，按权重累加
     *                  3. 归一化：T/S 除以累积权重，R 归一化；低于阈值的关节回退 rest pose
     *                  4. 遍历叠加层，按差量复合到混合结果
     *
     * @brief[en] Runs the blending
     * @return[en] true on success
     * @explain[en] Blending algorithm (aligned with ozz):
     *                  1. Zero-initializes the weighted accumulators (T/R/S components and accumulated weights)
     *                  2. Iterates over the normal layers and accumulates by weight
     *                  3. Normalizes: T/S divided by the accumulated weight, R normalized;
     *                     joints below the threshold fall back to the rest pose
     *                  4. Iterates over the additive layers and composites the deltas onto the blended result
     */
    public func run(): Bool {
        if (!this.validate()) { return false }

        let numSoa = this.restPose.size
        let numJoints = numSoa * 4

        // 加权累加器（按关节平铺）
        var accW = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accTx = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accTy = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accTz = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accRx = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accRy = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accRz = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accRw = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accSx = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accSy = Array<Float32>(numJoints, { _ => 0.0f32 })
        var accSz = Array<Float32>(numJoints, { _ => 0.0f32 })

        // 1. 累加普通层
        for (layer in this.layers) {
            if (layer.weight <= 0.0f32) { continue }

            for (soaIdx in 0..numSoa) {
                let baseJoint = soaIdx * 4
                for (slot in 0..4) {
                    let joint = baseJoint + slot
                    if (joint >= numJoints) { break }

                    let w = jointWeight(layer, joint)
                    if (w <= 0.0f32) { continue }

                    accW[joint] += w

                    let t = layer.transforms[soaIdx].getTranslation(slot)
                    accTx[joint] += t.x * w
                    accTy[joint] += t.y * w
                    accTz[joint] += t.z * w

                    let r = layer.transforms[soaIdx].getRotation(slot)
                    accRx[joint] += r.x * w
                    accRy[joint] += r.y * w
                    accRz[joint] += r.z * w
                    accRw[joint] += r.w * w

                    let s = layer.transforms[soaIdx].getScale(slot)
                    accSx[joint] += s.x * w
                    accSy[joint] += s.y * w
                    accSz[joint] += s.z * w
                }
            }
        }

        // 2. 归一化并写入输出（低于阈值回退 rest pose）
        for (soaIdx in 0..numSoa) {
            let baseJoint = soaIdx * 4
            for (slot in 0..4) {
                let joint = baseJoint + slot
                if (joint >= numJoints) { break }

                let aw = accW[joint]
                if (aw < this.threshold) {
                    let rt = this.restPose[soaIdx].getTranslation(slot)
                    let rr = this.restPose[soaIdx].getRotation(slot)
                    let rs = this.restPose[soaIdx].getScale(slot)
                    this.output[soaIdx].setTranslation(slot, rt.x, rt.y, rt.z)
                    this.output[soaIdx].setRotation(slot, rr.x, rr.y, rr.z, rr.w)
                    this.output[soaIdx].setScale(slot, rs.x, rs.y, rs.z)
                } else {
                    let invW = 1.0f32 / aw
                    this.output[soaIdx].setTranslation(slot,
                        accTx[joint] * invW, accTy[joint] * invW, accTz[joint] * invW)
                    this.output[soaIdx].setScale(slot,
                        accSx[joint] * invW, accSy[joint] * invW, accSz[joint] * invW)

                    // 四元数归一化
                    var rx = accRx[joint]
                    var ry = accRy[joint]
                    var rz = accRz[joint]
                    var rw = accRw[joint]
                    let len = sqrt(rx * rx + ry * ry + rz * rz + rw * rw)
                    if (len > 1e-12f32) {
                        let inv = 1.0f32 / len
                        this.output[soaIdx].setRotation(slot,
                            rx * inv, ry * inv, rz * inv, rw * inv)
                    } else {
                        this.output[soaIdx].setRotation(slot, 0.0f32, 0.0f32, 0.0f32, 1.0f32)
                    }
                }
            }
        }

        // 3. 叠加层：在归一化结果上按差量复合
        for (layer in this.additiveLayers) {
            if (layer.weight <= 0.0f32) { continue }

            for (soaIdx in 0..numSoa) {
                let baseJoint = soaIdx * 4
                for (slot in 0..4) {
                    let joint = baseJoint + slot
                    if (joint >= numJoints) { break }

                    let w = jointWeight(layer, joint)
                    if (w <= 0.0f32) { continue }

                    // 平移差量：t += w * dt
                    let dt = layer.transforms[soaIdx].getTranslation(slot)
                    let curT = this.output[soaIdx].getTranslation(slot)
                    this.output[soaIdx].setTranslation(slot,
                        curT.x + dt.x * w, curT.y + dt.y * w, curT.z + dt.z * w)

                    // 旋转差量：r = nlerp(r, dr * r, w)（dr 为 base⁻¹·target 差量）
                    let dr = layer.transforms[soaIdx].getRotation(slot)
                    let curR = this.output[soaIdx].getRotation(slot)
                    let targetR = QuaternionF()
                    targetR.multiplyQuaternions(dr, curR)
                    // 最短路径
                    var tx = targetR.x
                    var ty = targetR.y
                    var tz = targetR.z
                    var tw = targetR.w
                    let dot = curR.x * tx + curR.y * ty + curR.z * tz + curR.w * tw
                    if (dot < 0.0f32) {
                        tx = -tx
                        ty = -ty
                        tz = -tz
                        tw = -tw
                    }
                    var nrx = curR.x + (tx - curR.x) * w
                    var nry = curR.y + (ty - curR.y) * w
                    var nrz = curR.z + (tz - curR.z) * w
                    var nrw = curR.w + (tw - curR.w) * w
                    let len = sqrt(nrx * nrx + nry * nry + nrz * nrz + nrw * nrw)
                    if (len > 1e-12f32) {
                        let inv = 1.0f32 / len
                        this.output[soaIdx].setRotation(slot,
                            nrx * inv, nry * inv, nrz * inv, nrw * inv)
                    }

                    // 缩放差量：s *= lerp(1, ds, w)（ds 为 target/base 比率）
                    let ds = layer.transforms[soaIdx].getScale(slot)
                    let curS = this.output[soaIdx].getScale(slot)
                    this.output[soaIdx].setScale(slot,
                        curS.x * (1.0f32 + (ds.x - 1.0f32) * w),
                        curS.y * (1.0f32 + (ds.y - 1.0f32) * w),
                        curS.z * (1.0f32 + (ds.z - 1.0f32) * w)
                    )
                }
            }
        }

        true
    }
}
