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
 * otherwise be required by Sections 4(a), 5(b) and 6(d) of the License.
 *
 * @file[zh-cn] 帧级场景网格缓存
 * @brief[zh-cn] 为后期处理 pass 与阴影 pass 提供"本帧场景中全部 Mesh"的共享列表
 * @explain[zh-cn] 历史上 Bokeh/GTAO/Mask/Outline/RenderPixelated/SAO/SSAO/SSR
 *             共 8 个后期处理 pass 各自复制了一份 `_collectMeshes` 递归遍历，
 *             一次合成链中最多触发 17 次全场景树遍历（每遍历一个节点还要做一次
 *             `child.kind == "Mesh"` 字符串比较），并且每遍历到一个 Mesh 就
 *             `new RenderObject(...)` —— 而 RenderObject 的构造器会连带分配
 *             RenderContext / Camera / Scene / Matrix4×2 / Matrix3 / Vector3 /
 *             ArrayList×2，单个对象约 10 次堆分配。
 *
 *             本类把这些重复遍历合并为一次：
 *             1. 列表按"帧号 + 场景结构版本"缓存，帧内所有 pass 复用同一份；
 *             2. RenderObject 走对象池复用，每帧只重置字段，不再分配；
 *             3. 几何体/材质引用每帧快路径同步一次，保证运行时替换材质立即生效。
 *
 * @file[en] Frame-level scene mesh cache
 * @brief[en] Shared list of all Meshes in the scene for post-processing and shadow passes
 * @explain[en] Historically 8 post-processing passes (Bokeh/GTAO/Mask/Outline/
 *             RenderPixelated/SAO/SSAO/SSR) each carried their own copy of a
 *             `_collectMeshes` recursive walk, so a single composer chain triggered up
 *             to 17 full scene-tree walks (each node visit costing a
 *             `child.kind == "Mesh"` string comparison), and every Mesh found created a
 *             fresh `RenderObject` — whose constructor also allocates a RenderContext,
 *             Camera, Scene, 2 Matrix4s, a Matrix3, a Vector3 and 2 ArrayLists
 *             (roughly 10 heap allocations per object).
 *
 *             This class collapses those duplicate walks into one:
 *             1. The list is cached by (frame index, scene structure version) and shared
 *                by every pass within a frame.
 *             2. RenderObjects come from a pool: only fields are reset, nothing is
 *                allocated per frame.
 *             3. Geometry/material references are re-synced on the fast path so
 *                runtime material swaps take effect immediately.
 */

package three.rendering.common

import std.collection.*
import three.scene.objects.*
import three.scene.entity.*

/**
 * @brief[zh-cn] 帧级场景网格缓存
 * @explain[zh-cn] 按 (帧号, 场景结构版本, 场景 id) 缓存"场景中全部 Mesh"的
 *             RenderObject 列表，供同一帧内多个消费者（后期处理 pass、阴影 pass）
 *             共享，避免重复的全场景树遍历与逐 Mesh 的对象分配。
 *
 * @brief[en] Frame-level scene mesh cache
 * @explain[en] Caches the RenderObject list of "all Meshes in the scene" by
 *             (frame index, scene structure version, scene id), so several consumers
 *             within one frame (post-processing passes, shadow passes) share it and no
 *             duplicate full scene-tree walk or per-Mesh allocation happens.
 */
public class SceneMeshCache {
    /**
     * @brief[zh-cn] 缓存的 Mesh 渲染对象列表（内部引用，调用方只读）
     *
     * @brief[en] Cached mesh render object list (internal reference, read-only for callers)
     */
    private var _meshes: ArrayList<RenderObject> = ArrayList<RenderObject>(256)
    /**
     * @brief[zh-cn] 仅含可见 Mesh 的子集列表（与 _meshes 共享同一批 RenderObject）
     * @explain[zh-cn] SSR 等 pass 在收集时需要跳过不可见对象（防止反射面自反射），
     *               单独维护一份子集即可，无需二次遍历场景树。
     *
     * @brief[en] Subset list containing only visible Meshes (shares the same RenderObjects as _meshes)
     * @explain[en] Passes such as SSR need to skip invisible objects when collecting
     *               (to avoid self-reflection); keeping a separate subset avoids a
     *               second scene-tree walk.
     */
    private var _visibleMeshes: ArrayList<RenderObject> = ArrayList<RenderObject>(256)
    /**
     * @brief[zh-cn] RenderObject 对象池
     *
     * @brief[en] RenderObject pool
     */
    private var _pool: ArrayList<RenderObject> = ArrayList<RenderObject>(256)
    /**
     * @brief[zh-cn] 对象池游标（下一待复用位置）
     *
     * @brief[en] Pool cursor (next slot to reuse)
     */
    private var _poolCursor: Int64 = 0
    /**
     * @brief[zh-cn] 缓存对应的帧号
     *
     * @brief[en] Frame index the cache was built for
     */
    private var _frame: Int64 = -1
    /**
     * @brief[zh-cn] 缓存对应的场景结构版本号
     *
     * @brief[en] Scene structure version the cache was built for
     */
    private var _version: Int64 = -1
    /**
     * @brief[zh-cn] 缓存对应的场景 id
     *
     * @brief[en] Scene id the cache was built for
     */
    private var _sceneId: Int64 = 0

    /**
     * @brief[zh-cn] 构造空的场景网格缓存
     *
     * @brief[en] Constructs an empty scene mesh cache
     */
    public init() {}

    /**
     * @brief[zh-cn] 获取本帧场景中的 Mesh 渲染对象列表
     * @explain[zh-cn] 命中缓存时只做引用同步（几何体/材质可能被运行时替换），
     *               未命中时重新遍历场景树并复用池中的 RenderObject。
     * @param[zh-cn] scene 场景根节点
     * frame 帧号（由 Renderer 维护，每帧自增）
     * @return[zh-cn] Mesh 渲染对象列表（内部引用，调用方只读）
     *
     * @brief[en] Get this frame's list of Mesh render objects
     * @explain[en] On a cache hit only the references are re-synced (geometry/material
     *               may have been swapped at runtime); on a miss the scene tree is
     *               walked again and pooled RenderObjects are reused.
     * @param[en] scene Scene root node
     * frame Frame index (maintained by the Renderer, incremented every frame)
     * @return[en] Mesh render object list (internal reference, read-only for callers)
     */
    public func get(scene: Object3D, frame: Int64, visibleOnly!: Bool = false): ArrayList<RenderObject> {
        let version = Object3D.structureVersion
        if (this._frame != frame || this._version != version || this._sceneId != scene.id) {
            this._meshes.clear()
            this._visibleMeshes.clear()
            this._poolCursor = 0
            this._collect(scene)
            this._frame = frame
            this._version = version
            this._sceneId = scene.id
        } else {
            // 快路径：结构与帧都没变，只同步可能被替换的几何体/材质引用
            // （运行时直接赋值 mesh.material / mesh.geometry 不会改变场景结构版本）
            for (ro in this._meshes) {
                if (let Some(mesh) <- (ro.mesh as Mesh)) {
                    ro.geometry = mesh.geometry
                    ro.material = mesh.material
                }
            }
        }
        if (visibleOnly) {
            // 可见子集按"当前"可见性重建：可见性可能在运行时被改动
            // （地面反射器渲反射场景前会临时把反射面 hidden，渲完再恢复），
            // 因此不能只在全量重建时算一次。
            this._visibleMeshes.clear()
            for (ro in this._meshes) {
                if (ro.mesh.visible) {
                    this._visibleMeshes.add(ro)
                }
            }
            return this._visibleMeshes
        }
        return this._meshes
    }

    /**
     * @brief[zh-cn] 递归收集场景中的 Mesh（后序：先子节点后自身，与历史实现一致）
     * @param[zh-cn] node 当前节点
     *
     * @brief[en] Recursively collect Meshes in the scene (post-order: children before self, matching the historical implementation)
     * @param[en] node Current node
     */
    private func _collect(node: Object3D): Unit {
        for (child in node.children) {
            if (child.children.size > 0) {
                this._collect(child)
            }
            // kind 字段判断（对照 BgfxShadowPass._collectShadowCasters 的既有约定：
            // 仓颉 `match (child as Mesh)` 对 Mesh 子类不生效，故先看 kind 再解构）
            if (child.kind == "Mesh") {
                if (let Some(mesh) <- (child as Mesh)) {
                        let ro = if (this._poolCursor < this._pool.size) {
                            let pooled = this._pool[this._poolCursor]
                            this._poolCursor += 1
                            pooled.resetFor(mesh, mesh.geometry, mesh.material)
                            pooled
                        } else {
                            let created = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                            this._pool.add(created)
                            this._poolCursor += 1
                            created
                        }
                        this._meshes.add(ro)
                    }
            }
        }
    }
}
