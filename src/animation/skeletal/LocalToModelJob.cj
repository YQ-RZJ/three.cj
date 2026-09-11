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
 * @file[zh-cn] LocalToModelJob
 * @brief[zh-cn] 局部→模型空间转换 Job
 * @explain[zh-cn] 将局部空间的 SoaTransform 数组转换为模型空间的 Matrix4F 数组，
 *                  通过遍历骨骼父子层级逐级累乘变换矩阵。
 *                  支持部分层级更新和可选的根矩阵。
 *
 * @file[en] LocalToModelJob
 * @brief[en] Local-to-model space conversion job
 * @explain[en] Converts local-space SoaTransform arrays to model-space Matrix4F arrays
 *              by walking the skeleton's parent-child hierarchy.
 * @explain[en] Supports partial hierarchy updates and an optional root matrix.
 */
package three.animation.skeletal

import three.core.math.soa.*
import three.core.math.*

/**
 * @brief[zh-cn] 局部→模型空间转换 Job
 *
 * @brief[en] Local-to-model space conversion job
 */
public class LocalToModelJob {
    /**
     * @brief[zh-cn] 骨骼层级
     *
     * @brief[en] Skeleton hierarchy
     */
    public var skeleton: ?SkeletonData

    /**
     * @brief[zh-cn] 可选的根矩阵（应用到所有关节的模型空间结果上）
     * @explain[zh-cn] 为 None 时使用单位矩阵
     *
     * @brief[en] Optional root matrix (applied to the model-space result of all joints)
     * @explain[en] The identity matrix is used when None
     */
    public var rootMatrix: ?Matrix4F

    /**
     * @brief[zh-cn] 更新起始关节索引（默认 0 = 全部更新）
     *
     * @brief[en] Starting joint index of the update (default 0 = update all)
     */
    public var from: Int

    /**
     * @brief[zh-cn] 更新结束关节索引（不包含，<= 0 表示更新到最后一个关节）
     *
     * @brief[en] Ending joint index of the update (exclusive; <= 0 means update to the last joint)
     */
    public var to: Int

    /**
     * @brief[zh-cn] 是否排除 from 关节本身（只更新其子关节）
     *
     * @brief[en] Whether to exclude the `from` joint itself (only update its children)
     */
    public var fromExcluded: Bool

    /**
     * @brief[zh-cn] 输入：局部空间变换
     * @explain[zh-cn] 长度为 (numJoints + 3) / 4
     *
     * @brief[en] Input: local-space transforms
     * @explain[en] Length is (numJoints + 3) / 4
     */
    public var input: Array<SoaTransform>

    /**
     * @brief[zh-cn] 输出：模型空间 4x4 矩阵
     * @explain[zh-cn] 长度应为 numJoints，每个关节一个 Matrix4F
     *
     * @brief[en] Output: model-space 4x4 matrices
     * @explain[en] Length should be numJoints, one Matrix4F per joint
     */
    public var output: Array<Matrix4F>

    public init() {
        this.skeleton = None
        this.rootMatrix = None
        this.from = 0
        this.to = 0
        this.fromExcluded = false
        this.input = Array<SoaTransform>(0, { _ => SoaTransform() })
        this.output = Array<Matrix4F>(0, { _ => Matrix4F() })
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        let s = match (this.skeleton) {
            case Some(s) => s
            case None => return false
        }

        let endJoint = if (this.to <= 0) { s.numJoints() } else { this.to }
        if (this.from < 0 || this.from >= s.numJoints()) { return false }
        if (endJoint <= this.from || endJoint > s.numJoints()) { return false }
        if (this.output.size < s.numJoints()) { return false }

        let requiredInput = s.numSoaJoints()
        if (this.input.size < requiredInput) { return false }

        true
    }

    /**
     * @brief[zh-cn] 执行局部→模型空间转换
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 对每个关节：
     *                  1. 从 SoaTransform 提取局部 T/R/S
     *                  2. 构建局部 4x4 矩阵
     *                  3. 乘以父关节的模型空间矩阵
     *                  4. 存入输出数组
     *
     * @brief[en] Runs the local-to-model space conversion
     * @return[en] true on success
     * @explain[en] For each joint:
     *                  1. Extracts the local T/R/S from the SoaTransform
     *                  2. Builds the local 4x4 matrix
     *                  3. Multiplies by the parent joint's model-space matrix
     *                  4. Stores the result in the output array
     */
    public func run(): Bool {
        let s = match (this.skeleton) {
            case Some(s) => s
            case None => return false
        }

        let numJoints = s.numJoints()
        let endJoint = if (this.to <= 0) { numJoints } else { this.to }
        let startJoint = if (this.fromExcluded) { this.from + 1 } else { this.from }

        for (joint in startJoint..endJoint) {
            let soaIdx = joint / 4
            let slot = joint % 4

            // 从 SoaTransform 提取局部变换
            let lt = this.input[soaIdx].getTranslation(slot)
            let lr = this.input[soaIdx].getRotation(slot)
            let ls = this.input[soaIdx].getScale(slot)

            // 构建局部 4x4 矩阵（T * R * S）
            let localMatrix = Matrix4F()
            localMatrix.compose(
                lt.x, lt.y, lt.z,
                lr.x, lr.y, lr.z, lr.w,
                ls.x, ls.y, ls.z
            )

            // 获取父关节的模型空间矩阵
            let parentIdx = s.jointParent(joint)
            if (parentIdx >= 0) {
                // model = parent * local
                this.output[joint].multiplyMatrices(this.output[parentIdx], localMatrix)
            } else {
                // 根关节：应用可选根矩阵
                match (this.rootMatrix) {
                    case Some(root) =>
                        this.output[joint].multiplyMatrices(root, localMatrix)
                    case None =>
                        this.output[joint].copy(localMatrix)
                }
            }
        }

        true
    }
}
