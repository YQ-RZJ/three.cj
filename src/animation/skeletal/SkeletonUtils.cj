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
 * @file[zh-cn] SkeletonUtils
 * @brief[zh-cn] 骨骼工具函数集
 * @explain[zh-cn] 提供骨骼遍历、查找、拓扑信息等实用工具。
 *
 * @file[en] SkeletonUtils
 * @brief[en] Skeleton utility functions
 * @explain[en] Provides skeleton traversal, lookup, and topology utilities.
 */
package three.animation.skeletal

import std.collection.*

/**
 * @brief[zh-cn] 骨骼工具函数
 *
 * @brief[en] Skeleton utility functions
 */
public class SkeletonUtils {
    /**
     * @brief[zh-cn] 按名称查找关节索引
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] name 关节名称
     * @return[zh-cn] 关节索引，未找到返回 -1
     *
     * @brief[en] Finds a joint index by name
     * @param[en] skeleton The skeleton
     * @param[en] name The joint name
     * @return[en] The joint index, or -1 if not found
     */
    public static func findJointIndex(skeleton: SkeletonData, name: String): Int {
        skeleton.findJointIndex(name)
    }

    /**
     * @brief[zh-cn] 获取关节深度（到根关节的距离）
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] jointIndex 关节索引
     * @return[zh-cn] 深度值（根关节为 0）
     *
     * @brief[en] Returns the joint depth (distance to the root joint)
     * @param[en] skeleton The skeleton
     * @param[en] jointIndex The joint index
     * @return[en] The depth value (the root joint is 0)
     */
    public static func getJointDepth(skeleton: SkeletonData, jointIndex: Int): Int {
        skeleton.jointDepth(jointIndex)
    }

    /**
     * @brief[zh-cn] 获取关节的子关节列表
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] jointIndex 父关节索引
     * @return[zh-cn] 直接子关节的索引列表
     *
     * @brief[en] Returns the list of a joint's children
     * @param[en] skeleton The skeleton
     * @param[en] jointIndex The parent joint index
     * @return[en] The list of indices of the direct children
     */
    public static func getChildren(skeleton: SkeletonData, jointIndex: Int): ArrayList<Int> {
        let children = ArrayList<Int>()
        for (i in 0..skeleton.numJoints()) {
            if (skeleton.jointParent(i) == jointIndex) {
                children.add(i)
            }
        }
        children
    }

    /**
     * @brief[zh-cn] 获取从根到指定关节的路径
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] jointIndex 目标关节索引
     * @return[zh-cn] 路径数组（从根到目标关节，包含目标关节自身）
     *
     * @brief[en] Returns the path from the root to the specified joint
     * @param[en] skeleton The skeleton
     * @param[en] jointIndex The target joint index
     * @return[en] The path array (from the root to the target joint, including the target itself)
     */
    public static func getPathToJoint(skeleton: SkeletonData, jointIndex: Int): Array<Int> {
        let path = ArrayList<Int>()
        var idx = jointIndex
        while (idx >= 0) {
            path.add(idx)
            idx = skeleton.jointParent(idx)
        }
        // 反转路径（从根到目标）
        let result = Array<Int>(path.size, { i => path[path.size - 1 - i] })
        result
    }

    /**
     * @brief[zh-cn] 获取子树中的所有关节索引（包含自身）
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] rootIndex 子树根关节索引
     * @return[zh-cn] 子树中所有关节的索引（深度优先顺序）
     *
     * @brief[en] Returns all joint indices in the subtree (including itself)
     * @param[en] skeleton The skeleton
     * @param[en] rootIndex The subtree root joint index
     * @return[en] The indices of all joints in the subtree (depth-first order)
     */
    public static func getSubtree(skeleton: SkeletonData, rootIndex: Int): Array<Int> {
        let result = ArrayList<Int>()

        func collect(jointIdx: Int): Unit {
            result.add(jointIdx)
            for (i in 0..skeleton.numJoints()) {
                if (skeleton.jointParent(i) == jointIdx) {
                    collect(i)
                }
            }
        }

        collect(rootIndex)
        Array<Int>(result.size, { i => result[i] })
    }

    /**
     * @brief[zh-cn] 获取所有根关节（无父关节的关节）
     * @param[zh-cn] skeleton 骨骼
     * @return[zh-cn] 根关节索引列表
     *
     * @brief[en] Returns all root joints (joints with no parent)
     * @param[en] skeleton The skeleton
     * @return[en] The list of root joint indices
     */
    public static func getRootJoints(skeleton: SkeletonData): ArrayList<Int> {
        let roots = ArrayList<Int>()
        for (i in 0..skeleton.numJoints()) {
            if (skeleton.jointParent(i) < 0) {
                roots.add(i)
            }
        }
        roots
    }

    /**
     * @brief[zh-cn] 获取关节的祖先链（从自身到根，包含自身）
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] jointIndex 关节索引
     * @return[zh-cn] 祖先链（从自身到根）
     *
     * @brief[en] Returns the ancestor chain of a joint (from itself to the root, including itself)
     * @param[en] skeleton The skeleton
     * @param[en] jointIndex The joint index
     * @return[en] The ancestor chain (from itself to the root)
     */
    public static func getAncestors(skeleton: SkeletonData, jointIndex: Int): ArrayList<Int> {
        let ancestors = ArrayList<Int>()
        var idx = jointIndex
        while (idx >= 0) {
            ancestors.add(idx)
            idx = skeleton.jointParent(idx)
        }
        ancestors
    }

    /**
     * @brief[zh-cn] 检查 jointA 是否是 jointB 的祖先
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] jointA 可能的祖先关节
     * @param[zh-cn] jointB 可能的后代关节
     * @return[zh-cn] true 表示 jointA 是 jointB 的祖先（或就是 jointB 自身）
     *
     * @brief[en] Checks whether jointA is an ancestor of jointB
     * @param[en] skeleton The skeleton
     * @param[en] jointA The possible ancestor joint
     * @param[en] jointB The possible descendant joint
     * @return[en] true if jointA is an ancestor of jointB (or jointA is jointB itself)
     */
    public static func isAncestor(skeleton: SkeletonData, jointA: Int, jointB: Int): Bool {
        var idx = jointB
        while (idx >= 0) {
            if (idx == jointA) { return true }
            idx = skeleton.jointParent(idx)
        }
        false
    }

    /**
     * @brief[zh-cn] 获取两个关节的最近公共祖先
     * @param[zh-cn] skeleton 骨骼
     * @param[zh-cn] jointA 关节 A
     * @param[zh-cn] jointB 关节 B
     * @return[zh-cn] 最近公共祖先索引，如果没有公共祖先返回 -1
     *
     * @brief[en] Returns the lowest common ancestor of two joints
     * @param[en] skeleton The skeleton
     * @param[en] jointA Joint A
     * @param[en] jointB Joint B
     * @return[en] The lowest common ancestor index, or -1 if there is no common ancestor
     */
    public static func getLowestCommonAncestor(skeleton: SkeletonData, jointA: Int, jointB: Int): Int {
        // 收集 A 的所有祖先
        let ancestorsA = HashSet<Int>()
        var idx = jointA
        while (idx >= 0) {
            ancestorsA.add(idx)
            idx = skeleton.jointParent(idx)
        }

        // 从 B 向上遍历，找到第一个也在 A 祖先集中的
        idx = jointB
        while (idx >= 0) {
            if (ancestorsA.contains(idx)) {
                return idx
            }
            idx = skeleton.jointParent(idx)
        }

        -1
    }

    /**
     * @brief[zh-cn] 获取骨骼的统计信息
     * @param[zh-cn] skeleton 骨骼
     * @return[zh-cn] 字符串描述：关节数、最大深度、根关节数
     *
     * @brief[en] Returns skeleton statistics
     * @param[en] skeleton The skeleton
     * @return[en] A string description: joint count, maximum depth, root joint count
     */
    public static func getStats(skeleton: SkeletonData): String {
        let numJoints = skeleton.numJoints()
        let maxDepth = skeleton.maxDepth()
        let numRoots = getRootJoints(skeleton).size
        "Skeleton: ${numJoints} joints, max depth ${maxDepth}, ${numRoots} root(s)"
    }
}
