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
 * @file[zh-cn] SkeletonData
 * @brief[zh-cn] 骨骼动画运行时数据（嵌入 scene/entity/Skeleton）
 * @explain[zh-cn] 存储关节层级的不可变运行时数据：SoA 休息姿势、Int16 父索引、关节名。
 *                  由 SkeletonBuilder 从 RawSkeleton 构建，深度优先排序（父索引恒小于子索引）。
 *                  作为 scene/entity/Skeleton 的内部计算数据，不单独使用。
 *
 * @file[en] SkeletonData
 * @brief[en] Runtime skeleton data (embedded in scene/entity/Skeleton)
 * @explain[en] Immutable runtime data for joint hierarchy: SoA rest poses, Int16 parent
 *              indices, joint names. Built from RawSkeleton via SkeletonBuilder, ordered
 *              depth-first (parent index always smaller than child index).
 * @explain[en] Stored as internal computation data of scene/entity/Skeleton, not used standalone.
 */
package three.animation.skeletal

import three.core.math.soa.*

/**
 * @brief[zh-cn] 骨骼运行时数据
 * @explain[zh-cn] 存储关节数量、SoA 格式的休息姿势、父索引和关节名称。
 *                  所有数组以深度优先顺序排列，确保父关节索引始终小于子关节索引。
 *
 * @brief[en] Skeleton runtime data
 * @explain[en] Stores the joint count, the SoA-format rest pose, parent indices and joint
 *                  names. All arrays are ordered depth-first so that a parent joint index
 *                  is always smaller than its child index.
 */
public class SkeletonData {
    /**
     * @brief[zh-cn] 最大关节数（与 ozz 一致）
     *
     * @brief[en] Maximum number of joints (consistent with ozz)
     */
    public static let MAX_JOINTS: Int = 1024

    /**
     * @brief[zh-cn] 最大 SoA 块数
     *
     * @brief[en] Maximum number of SoA blocks
     */
    public static let MAX_SOA_JOINTS: Int = 256

    /**
     * @brief[zh-cn] 无父关节标记
     *
     * @brief[en] No-parent marker
     */
    public static let NO_PARENT: Int = -1

    /**
     * @brief[zh-cn] 关节数量
     *
     * @brief[en] Number of joints
     */
    public var numJoints_: Int

    /**
     * @brief[zh-cn] SoA 休息姿势（长度 = (numJoints + 3) / 4）
     *
     * @brief[en] SoA rest poses (length = (numJoints + 3) / 4)
     */
    public var jointRestPoses_: Array<SoaTransform>

    /**
     * @brief[zh-cn] 父关节索引（Int16，-1 表示无父关节）
     *
     * @brief[en] Parent joint indices (Int16, -1 means no parent)
     */
    public var jointParents_: Array<Int16>

    /**
     * @brief[zh-cn] 关节名称
     *
     * @brief[en] Joint names
     */
    public var jointNames_: Array<String>

    /**
     * @brief[zh-cn] 默认构造（空骨骼）
     *
     * @brief[en] Default constructor (empty skeleton)
     */
    public init() {
        this.numJoints_ = 0
        this.jointRestPoses_ = Array<SoaTransform>(0, { _ => SoaTransform() })
        this.jointParents_ = Array<Int16>(0, { _ => -1i16 })
        this.jointNames_ = Array<String>(0, { _ => "" })
    }

    /**
     * @brief[zh-cn] 从休息姿势、父索引和名称构造
     *
     * @brief[en] Constructs from rest poses, parent indices and names
     */
    public init(restPoses: Array<SoaTransform>, parents: Array<Int16>, names: Array<String>) {
        this.numJoints_ = parents.size
        this.jointRestPoses_ = restPoses
        this.jointParents_ = parents
        this.jointNames_ = names
    }

    /**
     * @brief[zh-cn] 关节数量
     *
     * @brief[en] Returns the number of joints
     */
    public func numJoints(): Int {
        this.numJoints_
    }

    /**
     * @brief[zh-cn] SoA 块数量（每块 4 个关节）
     *
     * @brief[en] Returns the number of SoA blocks (4 joints per block)
     */
    public func numSoaJoints(): Int {
        (this.numJoints_ + 3) / 4
    }

    /**
     * @brief[zh-cn] 获取父关节索引（-1 表示根关节）
     *
     * @brief[en] Returns the parent joint index (-1 means root joint)
     */
    public func jointParent(jointIndex: Int): Int {
        Int64(this.jointParents_[jointIndex])
    }

    /**
     * @brief[zh-cn] 获取 SoA 休息姿势数组
     *
     * @brief[en] Returns the SoA rest pose array
     */
    public func jointRestPoses(): Array<SoaTransform> {
        this.jointRestPoses_
    }

    /**
     * @brief[zh-cn] 获取关节名称
     *
     * @brief[en] Returns the joint name
     */
    public func jointName(jointIndex: Int): String {
        this.jointNames_[jointIndex]
    }

    /**
     * @brief[zh-cn] 按名称查找关节索引，未找到返回 -1
     *
     * @brief[en] Finds a joint index by name; returns -1 if not found
     */
    public func findJointIndex(name: String): Int {
        for (i in 0..this.numJoints_) {
            if (this.jointNames_[i] == name) {
                return i
            }
        }
        -1
    }

    /**
     * @brief[zh-cn] 获取关节深度（到根关节的边数，根关节为 0）
     *
     * @brief[en] Returns the joint depth (number of edges to the root joint; the root joint is 0)
     */
    public func jointDepth(jointIndex: Int): Int {
        var depth = 0
        var idx = jointIndex
        while (this.jointParents_[idx] >= 0) {
            idx = Int64(this.jointParents_[idx])
            depth += 1
        }
        depth
    }

    /**
     * @brief[zh-cn] 获取骨骼的最大深度
     *
     * @brief[en] Returns the maximum depth of the skeleton
     */
    public func maxDepth(): Int {
        var maxD = 0
        for (i in 0..this.numJoints_) {
            let d = this.jointDepth(i)
            if (d > maxD) { maxD = d }
        }
        maxD
    }
}
