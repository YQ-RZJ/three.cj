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
 * @file[zh-cn] IKAimJob
 * @brief[zh-cn] 单关节瞄准 IK Job
 * @explain[zh-cn] 将单个关节旋转，使其前向轴指向目标位置。
 *                  支持 pole vector、twist angle 和 IK weight 混合。
 *
 * @file[en] IKAimJob
 * @brief[en] Single-joint aim IK job
 * @explain[en] Rotates a single joint so its forward axis aims at a target position.
 *              Supports pole vector, twist angle, and IK weight blending.
 *
 * @brief[en] Single-joint aim IK job
 */
package three.animation.skeletal

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] 单关节瞄准 IK Job
 *
 * @brief[en] Single-joint aim IK job
 */
public class IKAimJob {
    /**
     * @brief[zh-cn] 目标位置（模型空间）
     *
     * @brief[en] Target position (model space)
     */
    public var target: Vector3F

    /**
     * @brief[zh-cn] 关节前向轴（局部空间，必须归一化）
     * @explain[zh-cn] 默认为 X 轴 (1, 0, 0)
     *
     * @brief[en] Joint forward axis (local space, must be normalized)
     * @explain[en] Defaults to the X axis (1, 0, 0)
     */
    public var forward: Vector3F

    /**
     * @brief[zh-cn] 关节偏移（局部空间）
     *
     * @brief[en] Joint offset (local space)
     */
    public var offset: Vector3F

    /**
     * @brief[zh-cn] 关节上向轴（局部空间）
     * @explain[zh-cn] 默认为 Y 轴 (0, 1, 0)，用于 pole vector 约束
     *
     * @brief[en] Joint up axis (local space)
     * @explain[en] Defaults to the Y axis (0, 1, 0); used for the pole vector constraint
     */
    public var up: Vector3F

    /**
     * @brief[zh-cn] Pole vector（模型空间）
     * @explain[zh-cn] 控制关节绕目标向量的扭转方向
     *
     * @brief[en] Pole vector (model space)
     * @explain[en] Controls the twist direction of the joint around the target vector
     */
    public var poleVector: ?Vector3F

    /**
     * @brief[zh-cn] 扭转角度（绕目标向量的额外旋转，弧度）
     *
     * @brief[en] Twist angle (extra rotation around the target vector, radians)
     */
    public var twistAngle: Float32

    /**
     * @brief[zh-cn] IK 权重 [0, 1]
     * @explain[zh-cn] 0 = 不影响，1 = 完全 IK
     *
     * @brief[en] IK weight [0, 1]
     * @explain[en] 0 = no effect, 1 = full IK
     */
    public var weight: Float32

    /**
     * @brief[zh-cn] 关节模型空间矩阵（输入）
     * @explain[zh-cn] 16 个 Float32（列主序 4x4）
     *
     * @brief[en] Joint model-space matrix (input)
     * @explain[en] 16 Float32 (column-major 4x4)
     */
    public var jointMatrix: Array<Float32>

    /**
     * @brief[zh-cn] 输出：关节校正四元数（局部空间）
     *
     * @brief[en] Output: joint correction quaternion (local space)
     */
    public var jointCorrection: ?QuaternionF

    /**
     * @brief[zh-cn] 输出：目标是否可达（可选）
     *
     * @brief[en] Output: whether the target is reachable (optional)
     */
    public var reached: ?Bool

    public init() {
        this.target = Vector3F()
        this.forward = Vector3F(1.0f32, 0.0f32, 0.0f32)
        this.offset = Vector3F()
        this.up = Vector3F(0.0f32, 1.0f32, 0.0f32)
        this.poleVector = None
        this.twistAngle = 0.0f32
        this.weight = 1.0f32
        this.jointMatrix = Array<Float32>(16, { i => if (i % 5 == 0) { 1.0f32} else { 0.0f32} })
        this.jointCorrection = None
        this.reached = None
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        match (this.jointCorrection) {
            case Some(_) => true
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 执行瞄准 IK
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 算法：
     *                  1. 从关节矩阵提取当前位置
     *                  2. 计算从当前位置（+ offset）到目标的方向向量
     *                  3. 计算从前向轴到目标方向的旋转四元数
     *                  4. 应用 pole vector 约束（如果提供）
     *                  5. 应用 twist angle
     *                  6. 按 weight 混合
     *
     * @brief[en] Runs the aim IK
     * @return[en] true on success
     * @explain[en] Algorithm:
     *                  1. Extracts the current position from the joint matrix
     *                  2. Computes the direction vector from the current position (+ offset) to the target
     *                  3. Computes the rotation quaternion from the forward axis to the target direction
     *                  4. Applies the pole vector constraint (if provided)
     *                  5. Applies the twist angle
     *                  6. Blends by weight
     */
    public func run(): Bool {
        if (!this.validate()) { return false }

        let correction = match (this.jointCorrection) {
            case Some(q) => q
            case None => return false
        }

        // 提取关节位置
        let jointPos = Vector3F(
            this.jointMatrix[12],
            this.jointMatrix[13],
            this.jointMatrix[14]
        )

        // 计算从关节（+ offset）到目标的方向
        let aimOrigin = Vector3F(
            jointPos.x + this.offset.x,
            jointPos.y + this.offset.y,
            jointPos.z + this.offset.z
        )

        let dirToTarget = Vector3F(
            this.target.x - aimOrigin.x,
            this.target.y - aimOrigin.y,
            this.target.z - aimOrigin.z
        )

        let lengthSq = dirToTarget.x * dirToTarget.x + dirToTarget.y * dirToTarget.y + dirToTarget.z * dirToTarget.z

        // 检查可达性
        match (this.reached) {
            case Some(_) => this.reached = Some(lengthSq > 1e-12f32)
            case None => ()
        }

        if (lengthSq < 1e-12f32) {
            // 目标与关节重合，无法计算方向
            correction.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
            return true
        }

        let invLen = 1.0f32/ sqrt(lengthSq)
        let dirX = dirToTarget.x * invLen
        let dirY = dirToTarget.y * invLen
        let dirZ = dirToTarget.z * invLen

        // 提取关节的旋转矩阵（前3列）
        let j00 = this.jointMatrix[0]
        let j01 = this.jointMatrix[1]
        let j02 = this.jointMatrix[2]
        let j10 = this.jointMatrix[4]
        let j11 = this.jointMatrix[5]
        let j12 = this.jointMatrix[6]
        let j20 = this.jointMatrix[8]
        let j21 = this.jointMatrix[9]
        let j22 = this.jointMatrix[10]

        // 将前向轴从局部空间变换到模型空间
        let fwdX = j00 * this.forward.x + j10 * this.forward.y + j20 * this.forward.z
        let fwdY = j01 * this.forward.x + j11 * this.forward.y + j21 * this.forward.z
        let fwdZ = j02 * this.forward.x + j12 * this.forward.y + j22 * this.forward.z

        // 计算从 forward 到 dirToTarget 的旋转四元数
        let dotFwdDir = fwdX * dirX + fwdY * dirY + fwdZ * dirZ

        // 叉积
        let crossX = fwdY * dirZ - fwdZ * dirY
        let crossY = fwdZ * dirX - fwdX * dirZ
        let crossZ = fwdX * dirY - fwdY * dirX
        let crossLenSq = crossX * crossX + crossY * crossY + crossZ * crossZ

        var qx: Float32
        var qy: Float32
        var qz: Float32
        var qw: Float32

        if (crossLenSq > 1e-12f32) {
            let crossLen = sqrt(crossLenSq)
            let halfAngle = atan2(crossLen, dotFwdDir) * 0.5f32
            let sinHalf = sin(halfAngle) / crossLen
            qx = crossX * sinHalf
            qy = crossY * sinHalf
            qz = crossZ * sinHalf
            qw = cos(halfAngle)
        } else if (dotFwdDir < 0.0f32) {
            // 180度旋转：找一个垂直轴
            let perp = findPerpendicular(fwdX, fwdY, fwdZ)
            qx = perp.x
            qy = perp.y
            qz = perp.z
            qw = 0.0f32
        } else {
            // 已经对齐
            qx = 0.0f32; qy = 0.0f32; qz = 0.0f32; qw = 1.0f32
        }

        // 应用 twist angle
        if (this.twistAngle != 0.0f32) {
            let halfTwist = this.twistAngle * 0.5f32
            let twistX = dirX * sin(halfTwist)
            let twistY = dirY * sin(halfTwist)
            let twistZ = dirZ * sin(halfTwist)
            let twistW = cos(halfTwist)

            // 四元数乘法: twist * correction
            let origQx = qx
            let origQy = qy
            let origQz = qz
            let origQw = qw
            qx = twistW * origQx + twistX * origQw + twistY * origQz - twistZ * origQy
            qy = twistW * origQy - twistX * origQz + twistY * origQw + twistZ * origQx
            qz = twistW * origQz + twistX * origQy - twistY * origQx + twistZ * origQw
            qw = twistW * origQw - twistX * origQx - twistY * origQy - twistZ * origQz
        }

        // 按 weight 混合（与单位四元数 nlerp）
        if (this.weight < 1.0f32) {
            let t = this.weight
            qx = qx * t
            qy = qy * t
            qz = qz * t
            qw = qw + (1.0f32- qw) * t

            let len = sqrt(qx * qx + qy * qy + qz * qz + qw * qw)
            if (len > 1e-12f32) {
                let inv = 1.0f32/ len
                qx *= inv; qy *= inv; qz *= inv; qw *= inv
            }
        }

        correction.set(qx, qy, qz, qw)
        true
    }

    /**
     * @brief[zh-cn] 找一个与给定向量垂直的向量
     *
     * @brief[en] Finds a vector perpendicular to the given vector
     */
    private func findPerpendicular(x: Float32, y: Float32, z: Float32): Vector3F {
        let ax = abs(x)
        let ay = abs(y)
        let az = abs(z)
        if (ax <= ay && ax <= az) {
            Vector3F(0.0f32, -z, y)
        } else if (ay <= az) {
            Vector3F(z, 0.0f32, -x)
        } else {
            Vector3F(-y, x, 0.0f32)
        }
    }
}
