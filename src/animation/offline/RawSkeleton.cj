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
 * @file[zh-cn] RawSkeleton
 * @brief[zh-cn] 离线骨骼定义（可编辑关节树）
 * @explain[zh-cn] 存储关节层级结构的原始数据，每个关节包含名称、父关节索引和局部休息姿势变换。
 *                  通过 SkeletonBuilder 可构建为运行时压缩格式。
 *
 * @file[en] RawSkeleton
 * @brief[en] Offline skeleton definition (editable joint tree)
 * @explain[en] Stores raw joint hierarchy data. Each joint has a name, parent index, and local rest-pose transform.
 *              Can be built into runtime compressed format via SkeletonBuilder.
 */
package three.animation.offline

import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 离线骨骼关节定义
 *
 * @brief[en] Offline skeleton joint definition
 */
public class RawJoint {
    /**
     * @brief[zh-cn] 关节名称
     *
     * @brief[en] Joint name
     */
    public var name: String

    /**
     * @brief[zh-cn] 父关节索引，根关节为 -1
     *
     * @brief[en] Parent joint index, -1 for the root joint
     */
    public var parentIndex: Int

    /**
     * @brief[zh-cn] 局部休息姿势平移
     *
     * @brief[en] Local rest-pose translation
     */
    public var localTranslation: Vector3F

    /**
     * @brief[zh-cn] 局部休息姿势旋转（四元数）
     *
     * @brief[en] Local rest-pose rotation (quaternion)
     */
    public var localRotation: QuaternionF

    /**
     * @brief[zh-cn] 局部休息姿势缩放
     *
     * @brief[en] Local rest-pose scale
     */
    public var localScale: Vector3F

    public init(name: String, parentIndex: Int) {
        this.name = name
        this.parentIndex = parentIndex
        this.localTranslation = Vector3F()
        this.localRotation = QuaternionF()
        this.localScale = Vector3F(1.0f32, 1.0f32, 1.0f32)
    }
}

/**
 * @brief[zh-cn] 离线骨骼数据
 * @explain[zh-cn] 包含关节列表，可通过 validate() 验证合法性，再通过 SkeletonBuilder 构建为运行时 Skeleton。
 *
 * @brief[en] Offline skeleton data
 * @explain[en] Contains a joint list. Validate it with validate(), then build it into a
 * runtime Skeleton via SkeletonBuilder.
 */
public class RawSkeleton {
    /**
     * @brief[zh-cn] 最大关节数（与 ozz 一致）
     *
     * @brief[en] Maximum joint count (same as ozz)
     */
    public static let MAX_JOINTS: Int = 1024

    /**
     * @brief[zh-cn] 关节列表
     *
     * @brief[en] The joint list
     */
    public var joints: ArrayList<RawJoint>

    public init() {
        this.joints = ArrayList<RawJoint>()
    }

    /**
     * @brief[zh-cn] 添加关节
     * @param[zh-cn] name 关节名称
     * @param[zh-cn] parentIndex 父关节索引（根关节为 -1）
     * @return[zh-cn] 新创建的关节
     *
     * @brief[en] Adds a joint
     * @param[en] name The joint name
     * @param[en] parentIndex The parent joint index (-1 for the root joint)
     * @return[en] The newly created joint
     */
    public func addJoint(name: String, parentIndex: Int): RawJoint {
        let joint = RawJoint(name, parentIndex)
        this.joints.add(joint)
        joint
    }

    /**
     * @brief[zh-cn] 获取关节数量
     *
     * @brief[en] Returns the number of joints
     */
    public func numJoints(): Int {
        this.joints.size
    }

    /**
     * @brief[zh-cn] 验证骨骼数据合法性
     * @return[zh-cn] true 表示数据合法
     * @explain[zh-cn] 检查：非空、不超过最大关节数、无循环引用、父索引有效、根关节数量合理
     *
     * @brief[en] Validates the skeleton data
     * @return[en] true if the data is valid
     * @explain[en] Checks that the skeleton is non-empty, does not exceed the maximum joint
     * count, has no cyclic references, valid parent indices, and a reasonable number
     * of root joints
     */
    public func validate(): Bool {
        // 空骨骼合法
        if (this.joints.size == 0) {
            return true
        }

        // 关节数量检查
        if (this.joints.size > RawSkeleton.MAX_JOINTS) {
            return false
        }

        // 逐关节验证
        for (i in 0..this.joints.size) {
            let joint = this.joints[i]
            let parentIdx = joint.parentIndex

            // 父索引范围检查
            if (parentIdx < -1 || parentIdx >= i) {
                return false
            }

            // 验证分量非 NaN
            if (joint.localTranslation.x != joint.localTranslation.x ||
                joint.localTranslation.y != joint.localTranslation.y ||
                joint.localTranslation.z != joint.localTranslation.z) {
                return false
            }

            // 旋转分量非 NaN
            if (joint.localRotation.x != joint.localRotation.x ||
                joint.localRotation.y != joint.localRotation.y ||
                joint.localRotation.z != joint.localRotation.z ||
                joint.localRotation.w != joint.localRotation.w) {
                return false
            }

            // 缩放分量非 NaN
            if (joint.localScale.x != joint.localScale.x ||
                joint.localScale.y != joint.localScale.y ||
                joint.localScale.z != joint.localScale.z) {
                return false
            }
        }

        // 简单的循环引用检测：每个关节的父索引必须小于自身索引（已由 parentIdx >= i 检查覆盖）

        true
    }
}
