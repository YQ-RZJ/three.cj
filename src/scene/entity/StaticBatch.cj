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
 * @file[zh-cn] StaticBatch CPU 静态合批
 * @brief[zh-cn] 将同材质、同属性签名的静态网格在 CPU 侧烘焙合并为单个网格，减少 draw call
 * @explain[zh-cn] 静态合批适用于永不移动（isStatic=true）的重复网格（如砖墙、岩石、静态装饰）：
 * 各成员的 matrixWorld 直接烘焙进顶点数据（position 乘世界矩阵、normal 乘法线矩阵），
 * 索引偏移累加，合并为一个 BufferGeometry。合并后原网格 visible=false 保留原位（可逆），
 * 合并网格位于世界原点（matrixWorld = 单位阵）。
 * 与 InstancedMesh（同几何多实例、GPU 侧实例化）互补：本类面向异几何同材质的静态组合。
 * 兜底：含 morph/skin、属性签名不一致的网格自动跳过不参与合并。
 *
 * @file[en] StaticBatch CPU static batching
 * @brief[en] Bakes and merges static meshes with the same material and attribute signature into a single mesh on CPU, reducing draw calls
 * @explain[en] Static batching suits never-moving (isStatic=true) repeated meshes (brick walls, rocks, static decorations):
 * each member's matrixWorld is baked into vertex data (position multiplied by world matrix, normal by normal matrix),
 * index offsets accumulated, merged into one BufferGeometry. After merging, original meshes keep visible=false in place (reversible),
 * and the merged mesh sits at the world origin (matrixWorld = identity).
 * Complementary to InstancedMesh (same geometry, multiple instances, GPU-side instancing): this class targets static combinations of different geometries sharing one material.
 * Fallback: meshes with morph/skin or mismatched attribute signatures are skipped automatically.
 */
package three.scene.entity

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.math.*
import three.rendering.materials.*
import std.collection.*
import std.sort.*

/**
 * @brief[zh-cn] CPU 静态合批工具（纯静态方法集）
 * @explain[zh-cn] 用法：`let batches = StaticBatcher.process(scene)`，返回值中的新网格需自行 add 到场景，
 * 原网格已被置 visible=false 保留原位。仅处理 isStatic=true 的普通 Mesh
 * （排除 SkinnedMesh/BatchedMesh/InstancedMesh 与含 morph/skin 属性的几何）。
 *
 * @brief[en] CPU static batching utility (pure static method set)
 * @explain[en] Usage: `let batches = StaticBatcher.process(scene)`; the returned new meshes must be added to the scene manually,
 * original meshes are set visible=false and kept in place. Only processes isStatic=true plain Meshes
 * (excluding SkinnedMesh/BatchedMesh/InstancedMesh and geometries with morph/skin attributes).
 */
public class StaticBatcher {

    // 纯静态工具类，禁止实例化
    private init() {}

    /**
     * @brief[zh-cn] 遍历场景子树，自动分组合并静态网格
     * @explain[zh-cn] 按 (material.uuid, 顶点属性签名) 分组 isStatic 的普通 Mesh，
     * 组内 ≥2 成员时调用 mergeMeshes 合并；合并网格 isStatic=true、位于世界原点，
     * 原网格 visible=false（保留可逆）。属性签名不一致/含 morph/skin 的网格跳过。
     * @param[zh-cn] root 遍历根节点（通常为 Scene 或 Group）
     * @return[zh-cn] 合并生成的新 Mesh 列表（未加入场景，需调用方自行 add）
     *
     * @brief[en] Traverse the scene subtree and auto-group/merge static meshes
     * @explain[en] Groups isStatic plain Meshes by (material.uuid, vertex attribute signature);
     * groups with ≥2 members are merged via mergeMeshes; merged meshes are isStatic=true at world origin,
     * original meshes set visible=false (kept reversible). Meshes with mismatched signatures or morph/skin are skipped.
     * @param[en] root Traversal root node (usually Scene or Group)
     * @return[en] Newly merged Mesh list (not added to scene; caller must add them manually)
     */
    public static func process(root: Object3D): ArrayList<Mesh> {
        // 烘焙依赖 matrixWorld，先确保全树矩阵已更新
        root.updateMatrixWorld(true)

        // 递归收集候选网格
        let candidates = ArrayList<Mesh>()
        _collectCandidates(root, candidates)

        // 按 (material.uuid, 属性签名) 分组（签名不一致的网格 _signature 返回 None，自然跳过）
        let groups = HashMap<String, ArrayList<Mesh>>()
        for (mesh in candidates) {
            if (let Some(sig) <- _signature(mesh)) {
                let key = "${mesh.material.uuid}|${sig}"
                if (let Some(list) <- groups.get(key)) {
                    list.add(mesh)
                } else {
                    let list = ArrayList<Mesh>()
                    list.add(mesh)
                    groups.add(key, list)
                }
            }  // 含 morph/skin，跳过
        }

        // 组内 ≥2 成员才合并，输出新网格并隐藏原网格
        let result = ArrayList<Mesh>()
        for ((_, members) in groups) {
            if (members.size < 2) { continue }
            result.add(mergeMeshes(members))
            for (mesh in members) {
                mesh.visible = false
            }
        }
        return result
    }

    /**
     * @brief[zh-cn] 合并多个网格为单个静态网格
     * @explain[zh-cn] position 用成员 matrixWorld 烘焙（8 自由度全变换）、normal 用法线矩阵
     * （逆转置，非均匀缩放正确）、其余属性原样拷贝；索引按成员顶点数偏移累加（无索引几何生成顺序索引）。
     * 输出几何 computeBoundingBox/computeBoundingSphere，材质沿用首成员材质。
     * 前置条件：所有成员同材质、同属性签名（process 分组已保证；直接调用者自行负责）。
     * @param[zh-cn] meshes 待合并网格列表（非空）
     * @return[zh-cn] 合并后的新 Mesh（位于世界原点，isStatic=true）
     *
     * @brief[en] Merge multiple meshes into a single static mesh
     * @explain[en] position is baked with member matrixWorld (full transform), normal with the normal matrix
     * (inverse-transpose, correct under non-uniform scale), other attributes copied as-is; indices accumulate
     * by member vertex offset (indexed-free geometry generates sequential indices).
     * Output geometry runs computeBoundingBox/computeBoundingSphere; material comes from the first member.
     * Precondition: all members share the same material and attribute signature (guaranteed by process grouping; direct callers are responsible).
     * @param[en] meshes Mesh list to merge (non-empty)
     * @return[en] Merged new Mesh (at world origin, isStatic=true)
     */
    public static func mergeMeshes(meshes: ArrayList<Mesh>): Mesh {
        let first = meshes[0]
        let refGeom = first.geometry

        // 参考属性名（排序保证合并顺序稳定）
        let refNames = ArrayList<String>()
        for (name in refGeom.attributes.keys()) {
            refNames.add(name)
        }
        sort(refNames, by: { a, b => a.compare(b) })

        // 统计总顶点数/总索引数
        var totalVerts: Int64 = 0
        var totalIndices: Int64 = 0
        for (mesh in meshes) {
            let posCount = _vertexCount(mesh.geometry)
            totalVerts += posCount
            if (let Some(idx) <- mesh.geometry.index) {
                totalIndices += idx.count
            } else {
                totalIndices += posCount  // 无索引：生成顺序索引
            }
        }

        // 逐属性合并：position 烘焙世界矩阵、normal 烘焙法线矩阵、其余原样拷贝
        let merged = BufferGeometry()
        let normalMatrix = Matrix3()
        let vertex = Vector3()
        for (name in refNames) {
            let refAttr = refGeom.attributes.get(name).getOrThrow()
            let itemSize = refAttr.itemSize
            let normalized = refAttr.normalized
            let isPosition = name == "position"
            let isNormal = name == "normal"
            let out = Array<Float64>(totalVerts * itemSize, { _ => 0.0 })
            var vertOffset: Int64 = 0
            for (mesh in meshes) {
                let attr = mesh.geometry.attributes.get(name).getOrThrow()
                let vc = attr.count
                if ((isPosition || isNormal) && itemSize == 3) {
                    if (isNormal) {
                        // 法线矩阵 = 世界矩阵的逆转置（非均匀缩放下法线才正确）
                        normalMatrix.getNormalMatrix(mesh.matrixWorld)
                    }
                    for (i in 0..vc) {
                        vertex.fromArray(attr.array, offset: i * 3)
                        if (isPosition) {
                            vertex.applyMatrix4(mesh.matrixWorld)
                        } else {
                            vertex.applyMatrix3(normalMatrix)
                            vertex.normalize()
                        }
                        vertex.toArray(out, offset: (vertOffset + i) * 3)
                    }
                } else {
                    // 其余属性（uv/color 等）不做变换，原样拷贝
                    for (i in 0..(vc * itemSize)) {
                        out[vertOffset * itemSize + i] = attr.array[i]
                    }
                }
                vertOffset += vc
            }
            merged.setAttribute(name, BufferAttribute(out, itemSize, normalized: normalized))
        }

        // 索引合并：偏移累加（无索引几何生成顺序索引）
        let outIndex = Array<Float64>(totalIndices, { _ => 0.0 })
        var indexOffset: Int64 = 0
        var vertOffset: Int64 = 0
        for (mesh in meshes) {
            let vc = _vertexCount(mesh.geometry)
            if (let Some(idx) <- mesh.geometry.index) {
                for (i in 0..idx.count) {
                    outIndex[indexOffset + i] = idx.array[i] + Float64(vertOffset)
                }
                indexOffset += idx.count
            } else {
                for (i in 0..vc) {
                    outIndex[indexOffset + i] = Float64(vertOffset + i)
                }
                indexOffset += vc
            }
            vertOffset += vc
        }
        merged.setIndex(BufferAttribute(outIndex, 1))

        // 重建包围体（剔除与射线检测依赖）
        merged.computeBoundingBox()
        merged.computeBoundingSphere()

        // 合并网格位于世界原点（顶点数据已烘焙世界变换，自身 matrixWorld 保持单位阵）
        let batchMesh = Mesh(geometry: merged, material: first.material)
        batchMesh.isStatic = true
        batchMesh.name = "StaticBatch(${meshes.size} meshes)"
        return batchMesh
    }

    // ===== 内部工具 =====

    // 递归收集候选网格：isStatic 的普通 Mesh（排除 SkinnedMesh/BatchedMesh/InstancedMesh）。
    private static func _collectCandidates(node: Object3D, out: ArrayList<Mesh>): Unit {
        let isMesh = if (let Some(_) <- (node as Mesh)) { true } else { false }
        if (isMesh && node.isStatic) {
            let isSkinned = if (let Some(_) <- (node as SkinnedMesh)) { true } else { false }
            let isBatched = if (let Some(_) <- (node as BatchedMesh)) { true } else { false }
            let isInstanced = if (let Some(_) <- (node as InstancedMesh)) { true } else { false }
            if (!isSkinned && !isBatched && !isInstanced) {
                out.add((node as Mesh).getOrThrow())
            }
        }
        for (child in node.children) {
            _collectCandidates(child, out)
        }
    }

    // 计算属性签名："名称:itemSize:norm" 逗号串（名称排序后拼接），供分组判同。
    // 含 morph/skin 的几何返回 None（跳过合并）。
    private static func _signature(mesh: Mesh): Option<String> {
        let geom = mesh.geometry
        // morph target 网格各实例变形状态独立，无法静态烘焙
        if (geom.morphAttributes.size > 0) { return None }
        // 蒙皮属性（骨骼权重）依赖每帧骨骼矩阵，无法静态烘焙
        if (geom.attributes.contains("skinIndex") || geom.attributes.contains("skinWeight")) {
            return None
        }
        let names = ArrayList<String>()
        for (name in geom.attributes.keys()) {
            names.add(name)
        }
        sort(names, by: { a, b => a.compare(b) })
        let sb = StringBuilder()
        for (name in names) {
            let attr = geom.attributes.get(name).getOrThrow()
            sb.append("${name}:${attr.itemSize}:${attr.normalized}")
        }
        return Some(sb.toString())
    }

    // 取几何顶点数（position.count；无 position 视为 0）。
    private static func _vertexCount(geom: BufferGeometry): Int64 {
        if (let Some(pos) <- geom.getAttribute("position")) {
            return pos.count
        }
        return 0
    }
}
