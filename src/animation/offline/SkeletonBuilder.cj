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
 * @file[zh-cn] SkeletonBuilder
 * @brief[zh-cn] RawSkeleton → 运行时 Skeleton 构建器
 * @explain[zh-cn] 将离线骨骼定义转换为运行时压缩格式：深度优先排序关节、构建 SoA 休息姿势、
 *                  压缩父索引为 Int16。
 *
 * @file[en] SkeletonBuilder
 * @brief[en] RawSkeleton → runtime Skeleton builder
 * @explain[en] Converts offline skeleton definition to runtime compressed format:
 *              depth-first joint ordering, SoA rest poses, Int16 parent indices.
 */
package three.animation.offline

import std.collection.*
import three.animation.skeletal.*
import three.core.math.soa.*
import three.core.math.*

/**
 * @brief[zh-cn] 骨骼构建器
 * @explain[zh-cn] 将 RawSkeleton 转换为运行时 Skeleton。构建过程：
 *                  1. 验证输入数据
 *                  2. 拓扑排序（深度优先）
 *                  3. 重建关节索引映射
 *                  4. 构建 SoA 休息姿势
 *                  5. 构建 Int16 父索引数组
 *
 * @brief[en] Skeleton builder - converts RawSkeleton to runtime Skeleton
 * @explain[en] Build steps:
 *                  1. Validate the input data
 *                  2. Topological sort (depth-first)
 *                  3. Rebuild the joint index mapping
 *                  4. Build the SoA rest poses
 *                  5. Build the Int16 parent index array
 */
public class SkeletonBuilder {
    /**
     * @brief[zh-cn] 构建运行时 SkeletonData
     * @param[zh-cn] input 离线骨骼数据
     * @return[zh-cn] Some(SkeletonData) 构建成功，None 表示输入无效
     *
     * @brief[en] Builds runtime SkeletonData
     * @param[en] input The offline skeleton data
     * @return[en] Some(SkeletonData) on success; None when the input is invalid
     */
    public func invoke(input: RawSkeleton): Option<SkeletonData> {
        // 验证输入
        if (!input.validate()) {
            return None
        }

        let numJoints = input.joints.size

        // 空骨骼
        if (numJoints == 0) {
            return Some(SkeletonData())
        }

        // 拓扑排序：深度优先遍历，确保父关节索引小于子关节
        let sortedIndices = topologicalSort(input)
        let indexMap = buildIndexMap(sortedIndices)

        // 构建关节名称数组
        let jointNames = Array<String>(numJoints, { i => input.joints[sortedIndices[i]].name })

        // 构建父索引数组（Int16，-1 表示无父）
        let parentIndices = Array<Int16>(numJoints, { i =>
            let origParent = input.joints[sortedIndices[i]].parentIndex
            if (origParent < 0) {
                -1i16
            } else {
                Int16(indexMap[origParent])
            }
        })

        // 构建 SoA 休息姿势：将 4 个关节的 T/R/S 打包为 SoaTransform
        let numSoaElements = (numJoints + 3) / 4
        let restPoses = Array<SoaTransform>(numSoaElements, { soaIdx =>
            let baseJoint = soaIdx * 4
            let t0 = if (baseJoint < numJoints) { input.joints[sortedIndices[baseJoint]].localTranslation } else { Vector3F() }
            let r0 = if (baseJoint < numJoints) { input.joints[sortedIndices[baseJoint]].localRotation } else { QuaternionF() }
            let s0 = if (baseJoint < numJoints) { input.joints[sortedIndices[baseJoint]].localScale } else { Vector3F(1.0f32, 1.0f32, 1.0f32) }

            let t1 = if (baseJoint + 1 < numJoints) { input.joints[sortedIndices[baseJoint + 1]].localTranslation } else { Vector3F() }
            let r1 = if (baseJoint + 1 < numJoints) { input.joints[sortedIndices[baseJoint + 1]].localRotation } else { QuaternionF() }
            let s1 = if (baseJoint + 1 < numJoints) { input.joints[sortedIndices[baseJoint + 1]].localScale } else { Vector3F(1.0f32, 1.0f32, 1.0f32) }

            let t2 = if (baseJoint + 2 < numJoints) { input.joints[sortedIndices[baseJoint + 2]].localTranslation } else { Vector3F() }
            let r2 = if (baseJoint + 2 < numJoints) { input.joints[sortedIndices[baseJoint + 2]].localRotation } else { QuaternionF() }
            let s2 = if (baseJoint + 2 < numJoints) { input.joints[sortedIndices[baseJoint + 2]].localScale } else { Vector3F(1.0f32, 1.0f32, 1.0f32) }

            let t3 = if (baseJoint + 3 < numJoints) { input.joints[sortedIndices[baseJoint + 3]].localTranslation } else { Vector3F() }
            let r3 = if (baseJoint + 3 < numJoints) { input.joints[sortedIndices[baseJoint + 3]].localRotation } else { QuaternionF() }
            let s3 = if (baseJoint + 3 < numJoints) { input.joints[sortedIndices[baseJoint + 3]].localScale } else { Vector3F(1.0f32, 1.0f32, 1.0f32) }

            SoaTransform.fromFour(
                t0.x, t0.y, t0.z, r0.x, r0.y, r0.z, r0.w, s0.x, s0.y, s0.z,
                t1.x, t1.y, t1.z, r1.x, r1.y, r1.z, r1.w, s1.x, s1.y, s1.z,
                t2.x, t2.y, t2.z, r2.x, r2.y, r2.z, r2.w, s2.x, s2.y, s2.z,
                t3.x, t3.y, t3.z, r3.x, r3.y, r3.z, r3.w, s3.x, s3.y, s3.z
            )
        })

        Some(SkeletonData(restPoses, parentIndices, jointNames))
    }

    /**
     * @brief[zh-cn] 深度优先拓扑排序
     * @explain[zh-cn] 确保父关节始终排在子关节之前
     *
     * @brief[en] Depth-first topological sort
     * @explain[en] Ensures that parent joints always come before child joints
     */
    private func topologicalSort(input: RawSkeleton): Array<Int> {
        let n = input.joints.size
        let result = ArrayList<Int>()
        let visited = Array<Bool>(n, { _ => false })

        func visit(index: Int): Unit {
            if (visited[index]) {
                return
            }
            visited[index] = true
            // 先访问父关节
            let parent = input.joints[index].parentIndex
            if (parent >= 0) {
                visit(parent)
            }
            result.add(index)
        }

        for (i in 0..n) {
            visit(i)
        }

        Array<Int>(result.size, { i => result[i] })
    }

    /**
     * @brief[zh-cn] 构建旧索引 → 新索引的映射
     *
     * @brief[en] Builds the old-index → new-index mapping
     */
    private func buildIndexMap(sortedIndices: Array<Int>): HashMap<Int, Int> {
        let map = HashMap<Int, Int>()
        for (newIdx in 0..sortedIndices.size) {
            map.add(sortedIndices[newIdx], newIdx)
        }
        map
    }
}
