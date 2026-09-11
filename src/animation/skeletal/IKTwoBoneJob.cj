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
 * @file[zh-cn] IKTwoBoneJob
 * @brief[zh-cn] 双关节 IK Job
 * @explain[zh-cn] 解决两个连接关节（如上臂+前臂、大腿+小腿）到达目标位置的问题。
 *                  典型用于角色手臂/腿部的 IK 解算。
 *
 * @file[en] IKTwoBoneJob
 * @brief[en] Two-joint IK job
 * @explain[en] Solves two connected joints (e.g., upper arm + forearm, thigh + shin)
 *              to reach a target position. Typical for character arm/leg IK.
 *
 * @brief[en] Two-joint IK job
 */
package three.animation.skeletal

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] 双关节 IK Job
 *
 * @brief[en] Two-joint IK job
 */
public class IKTwoBoneJob {
    /**
     * @brief[zh-cn] 目标位置（模型空间）
     *
     * @brief[en] Target position (model space)
     */
    public var target: Vector3F

    /**
     * @brief[zh-cn] Mid-joint pole vector（模型空间）
     * @explain[zh-cn] 控制中间关节的弯曲方向（如膝盖/肘部朝向）
     *
     * @brief[en] Mid-joint pole vector (model space)
     * @explain[en] Controls the bending direction of the mid joint (e.g. knee/elbow orientation)
     */
    public var midJointPoleVector: ?Vector3F

    /**
     * @brief[zh-cn] 第一个关节（近端，如肩/髋）的模型空间矩阵
     * @explain[zh-cn] 16 个 Float32（列主序 4x4）
     *
     * @brief[en] Model-space matrix of the first joint (proximal, e.g. shoulder/hip)
     * @explain[en] 16 Float32 (column-major 4x4)
     */
    public var startJointMatrix: Array<Float32>

    /**
     * @brief[zh-cn] 第二个关节（中间，如肘/膝）的模型空间矩阵
     *
     * @brief[en] Model-space matrix of the second joint (mid, e.g. elbow/knee)
     */
    public var midJointMatrix: Array<Float32>

    /**
     * @brief[zh-cn] 末端效应器（如手腕/脚踝）的模型空间位置
     *
     * @brief[en] Model-space position of the end effector (e.g. wrist/ankle)
     */
    public var endEffectorPosition: Vector3F

    /**
     * @brief[zh-cn] 第一个关节的校正四元数（输出，局部空间）
     *
     * @brief[en] Correction quaternion of the first joint (output, local space)
     */
    public var startJointCorrection: ?QuaternionF

    /**
     * @brief[zh-cn] 第二个关节的校正四元数（输出，局部空间）
     *
     * @brief[en] Correction quaternion of the second joint (output, local space)
     */
    public var midJointCorrection: ?QuaternionF

    /**
     * @brief[zh-cn] IK 权重 [0, 1]
     *
     * @brief[en] IK weight [0, 1]
     */
    public var weight: Float32

    public init() {
        this.target = Vector3F()
        this.midJointPoleVector = None
        this.startJointMatrix = Array<Float32>(16, { i => if (i % 5 == 0) { 1.0f32} else { 0.0f32} })
        this.midJointMatrix = Array<Float32>(16, { i => if (i % 5 == 0) { 1.0f32} else { 0.0f32} })
        this.endEffectorPosition = Vector3F()
        this.startJointCorrection = None
        this.midJointCorrection = None
        this.weight = 1.0f32
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        match (this.startJointCorrection) {
            case Some(_) => match (this.midJointCorrection) {
                case Some(_) => true
                case None => false
            }
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 执行双关节 IK 解算
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 算法（Law of Cosines）：
     *                  1. 计算 start→mid 和 mid→end 的骨骼长度
     *                  2. 计算 start→target 的距离
     *                  3. 用余弦定理求解 mid 关节的弯曲角度
     *                  4. 计算旋转平面（由 start、mid、target 定义）
     *                  5. 分解为两个关节的校正四元数
     *                  6. 应用 pole vector 约束
     *                  7. 按 weight 混合
     *
     * @brief[en] Runs the two-joint IK solve
     * @return[en] true on success
     * @explain[en] Algorithm (Law of Cosines):
     *                  1. Computes the bone lengths of start→mid and mid→end
     *                  2. Computes the start→target distance
     *                  3. Uses the law of cosines to solve the mid joint's bending angle
     *                  4. Computes the rotation plane (defined by start, mid, target)
     *                  5. Decomposes into correction quaternions for the two joints
     *                  6. Applies the pole vector constraint
     *                  7. Blends by weight
     */
    public func run(): Bool {
        if (!this.validate()) { return false }

        let startCorrection = match (this.startJointCorrection) {
            case Some(q) => q
            case None => return false
        }
        let midCorrection = match (this.midJointCorrection) {
            case Some(q) => q
            case None => return false
        }

        // 提取关节位置
        let startPos = extractPosition(this.startJointMatrix)
        let midPos = extractPosition(this.midJointMatrix)

        // 骨骼长度
        let boneLen1 = distance(startPos, midPos)
        let boneLen2 = distance(midPos, this.endEffectorPosition)
        let totalLen = boneLen1 + boneLen2

        if (boneLen1 < 1e-6f32|| boneLen2 < 1e-6f32) {
            startCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            midCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            return true
        }

        // start → target 距离
        let startToTarget = Vector3F(
            this.target.x - startPos.x,
            this.target.y - startPos.y,
            this.target.z - startPos.z
        )
        let distToTarget = sqrt(startToTarget.x * startToTarget.x + startToTarget.y * startToTarget.y + startToTarget.z * startToTarget.z)

        // 无法到达：手臂完全伸直
        if (distToTarget >= totalLen) {
            // 指向目标方向
            let dir = normalize(startToTarget)
            let targetMid = Vector3F(
                startPos.x + dir.x * boneLen1,
                startPos.y + dir.y * boneLen1,
                startPos.z + dir.z * boneLen1
            )
            computeStartCorrection(startPos, midPos, targetMid, startCorrection)
            midCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            applyWeight(startCorrection, midCorrection)
            return true
        }

        // 完全折叠：目标太近
        if (distToTarget + boneLen1 < boneLen2 || distToTarget + boneLen2 < boneLen1) {
            // 折叠到极限
            let dir = normalize(startToTarget)
            let targetMid = Vector3F(
                startPos.x + dir.x * (distToTarget * 0.5f32),
                startPos.y + dir.y * (distToTarget * 0.5f32),
                startPos.z + dir.z * (distToTarget * 0.5f32)
            )
            computeStartCorrection(startPos, midPos, targetMid, startCorrection)
            // mid 关节完全折叠
            midCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            applyWeight(startCorrection, midCorrection)
            return true
        }

        // 余弦定理求解 mid 关节角度
        let a = boneLen2  // mid→end
        let b = boneLen1  // start→mid
        let c = distToTarget  // start→target

        // cos(angle at mid joint) = (a² + b² - c²) / (2ab)
        let cosMidAngle = (a * a + b * b - c * c) / (2.0f32* a * b)
        let clampedCos = max(-1.0f32, min(1.0f32, cosMidAngle))
        let midAngle = acos(clampedCos)

        // cos(angle at start joint) = (b² + c² - a²) / (2bc)
        let cosStartAngle = (b * b + c * c - a * a) / (2.0f32* b * c)
        let clampedStartCos = max(-1.0f32, min(1.0f32, cosStartAngle))
        let startAngle = acos(clampedStartCos)

        // 计算旋转平面
        // start→mid 方向
        let smDir = normalize(Vector3F(
            midPos.x - startPos.x,
            midPos.y - startPos.y,
            midPos.z - startPos.z
        ))

        // start→target 方向
        let stDir = normalize(startToTarget)

        // 旋转轴 = smDir × stDir
        let rotAxis = cross(smDir, stDir)
        let rotAxisLen = sqrt(rotAxis.x * rotAxis.x + rotAxis.y * rotAxis.y + rotAxis.z * rotAxis.z)

        if (rotAxisLen < 1e-6f32) {
            // 共线，无法确定旋转平面
            startCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            midCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            applyWeight(startCorrection, midCorrection)
            return true
        }

        let invRotLen = 1.0f32/ rotAxisLen
        let axisX = rotAxis.x * invRotLen
        let axisY = rotAxis.y * invRotLen
        let axisZ = rotAxis.z * invRotLen

        // Start 关节校正：旋转 (π - startAngle) 绕旋转轴
        let startRotAngle = Float32(PI) - startAngle
        let startHalfAngle = startRotAngle * 0.5f32
        let startSinHalf = sin(startHalfAngle)
        startCorrection.set(
            axisX * startSinHalf,
            axisY * startSinHalf,
            axisZ * startSinHalf,
            cos(startHalfAngle)
        )

        // Mid 关节校正：需要在 start 旋转后的空间中
        // 先将 mid 关节轴变换到 start 旋转空间
        // 简化：直接计算 mid 关节的旋转
        // mid 关节弯曲方向：从 mid 指向 end 的方向旋转 (π - midAngle)
        let meDir = normalize(Vector3F(
            this.endEffectorPosition.x - midPos.x,
            this.endEffectorPosition.y - midPos.y,
            this.endEffectorPosition.z - midPos.z
        ))

        // 应用 pole vector 约束
        match (this.midJointPoleVector) {
            case Some(poleVec) =>
                // mid 关节的弯曲方向应朝向 pole vector
                let poleDir = normalize(poleVec)
                let midRotAxis = cross(meDir, poleDir)
                let midRotAxisLen = sqrt(midRotAxis.x * midRotAxis.x + midRotAxis.y * midRotAxis.y + midRotAxis.z * midRotAxis.z)
                if (midRotAxisLen > 1e-6f32) {
                    let midInvLen = 1.0f32/ midRotAxisLen
                    let midAxisX = midRotAxis.x * midInvLen
                    let midAxisY = midRotAxis.y * midInvLen
                    let midAxisZ = midRotAxis.z * midInvLen

                    // 计算 meDir 与 poleDir 的夹角
                    let meDotPole = meDir.x * poleDir.x + meDir.y * poleDir.y + meDir.z * poleDir.z
                    let midRotAngle = acos(max(-1.0f32, min(1.0f32, meDotPole)))
                    let midHalfAngle = midRotAngle * 0.5f32
                    let midSinHalf = sin(midHalfAngle)

                    midCorrection.set(
                        midAxisX * midSinHalf,
                        midAxisY * midSinHalf,
                        midAxisZ * midSinHalf,
                        cos(midHalfAngle)
                    )
                } else {
                    midCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
                }
            case None =>
                midCorrection.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
        }

        applyWeight(startCorrection, midCorrection)
        true
    }

    // ===== Private helpers =====

    private func extractPosition(m: Array<Float32>): Vector3F {
        Vector3F(m[12], m[13], m[14])
    }

    private func distance(a: Vector3F, b: Vector3F): Float32 {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let dz = b.z - a.z
        sqrt(dx * dx + dy * dy + dz * dz)
    }

    private func normalize(v: Vector3F): Vector3F {
        let len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
        if (len > 1e-12f32) {
            let inv = 1.0f32/ len
            Vector3F(v.x * inv, v.y * inv, v.z * inv)
        } else {
            Vector3F(1.0f32, 0.0f32, 0.0f32)
        }
    }

    private func cross(a: Vector3F, b: Vector3F): Vector3F {
        Vector3F(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        )
    }

    private func computeStartCorrection(startPos: Vector3F, midPos: Vector3F, targetMid: Vector3F, correction: QuaternionF): Unit {
        let smDir = normalize(Vector3F(midPos.x - startPos.x, midPos.y - startPos.y, midPos.z - startPos.z))
        let stDir = normalize(Vector3F(targetMid.x - startPos.x, targetMid.y - startPos.y, targetMid.z - startPos.z))

        let dot = smDir.x * stDir.x + smDir.y * stDir.y + smDir.z * stDir.z
        if (dot < -0.999f32) {
            // 180度旋转
            let p = findPerpendicular(smDir)
            correction.set(p.x, p.y, p.z, 0.0f32)
            return
        }

        let rotAxis = cross(smDir, stDir)
        let rotAxisLen = sqrt(rotAxis.x * rotAxis.x + rotAxis.y * rotAxis.y + rotAxis.z * rotAxis.z)
        if (rotAxisLen < 1e-6f32) {
            correction.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            return
        }

        let invLen = 1.0f32/ rotAxisLen
        let halfAngle = atan2(rotAxisLen, dot) * 0.5f32
        let sinHalf = sin(halfAngle) * invLen
        correction.set(rotAxis.x * sinHalf, rotAxis.y * sinHalf, rotAxis.z * sinHalf, cos(halfAngle))
    }

    private func findPerpendicular(v: Vector3F): Vector3F {
        let ax = abs(v.x)
        let ay = abs(v.y)
        let az = abs(v.z)
        if (ax <= ay && ax <= az) {
            Vector3F(0.0f32, -v.z, v.y)
        } else if (ay <= az) {
            Vector3F(v.z, 0.0f32, -v.x)
        } else {
            Vector3F(-v.y, v.x, 0.0f32)
        }
    }

    private func applyWeight(startCorrection: QuaternionF, midCorrection: QuaternionF): Unit {
        if (this.weight < 1.0f32) {
            // nlerp with identity
            let t = this.weight
            startCorrection.x *= t
            startCorrection.y *= t
            startCorrection.z *= t
            startCorrection.w = startCorrection.w + (1.0f32- startCorrection.w) * t
            var len = sqrt(startCorrection.x * startCorrection.x + startCorrection.y * startCorrection.y + startCorrection.z * startCorrection.z + startCorrection.w * startCorrection.w)
            if (len > 1e-12f32) {
                let inv = 1.0f32/ len
                startCorrection.x *= inv; startCorrection.y *= inv; startCorrection.z *= inv; startCorrection.w *= inv
            }

            midCorrection.x *= t
            midCorrection.y *= t
            midCorrection.z *= t
            midCorrection.w = midCorrection.w + (1.0f32- midCorrection.w) * t
            len = sqrt(midCorrection.x * midCorrection.x + midCorrection.y * midCorrection.y + midCorrection.z * midCorrection.z + midCorrection.w * midCorrection.w)
            if (len > 1e-12f32) {
                let inv = 1.0f32/ len
                midCorrection.x *= inv; midCorrection.y *= inv; midCorrection.z *= inv; midCorrection.w *= inv
            }
        }
    }
}
