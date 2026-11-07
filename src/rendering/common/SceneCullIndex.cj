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
 * @file[zh-cn] 场景空间索引（渲染剔除加速）
 * @brief[zh-cn] 把场景中的可渲染对象组织成 BVH，把"每帧逐对象视锥测试"从
 *             O(N) 降为 O(log N + K)，K 为视锥内候选对象数
 * @explain[zh-cn] 大型场景（十万级对象）里逐对象做 6 平面视锥测试是 CPU 侧主要瓶颈：
 *             引擎原实现每帧对场景树中每个对象做一次相交测试，10 万对象即 10 万次
 *             （约 130ms/帧）。本索引用 BVH 把对象按世界包围球空间组织起来，
 *             查询时先测根节点，完全在视锥外的分支整棵跳过。
 *
 *             与场景树遍历的关系：本索引是**加速层**而非替代。场景树遍历仍负责
 *             层级可见性（父节点 visible=false 时子节点不渲染）与对象类型分派，
 *             但"该对象是否落在视锥内"由 BVH 批量回答，避免对每个对象重复做
 *             6 平面测试。
 *
 *             增量更新：
 *             - 结构变化（对象增删）→ Object3D.structureVersion 变化 → 重建索引
 *             - 对象移动/缩放 → 该对象的世界包围球失效 → 只更新它的 BVH 元素并 refit
 *             静态场景下每帧无需重建、无需重算任何包围球。
 *
 * @file[en] Scene spatial index (rendering culling acceleration)
 * @brief[en] Organizes a scene's renderable objects into a BVH, turning the
 *             per-frame per-object frustum test from O(N) into O(log N + K)
 *             (K = number of candidate objects inside the frustum)
 * @explain[en] In large scenes (100k+ objects) the per-object 6-plane frustum test is
 *             the dominant CPU cost: the engine tests every object every frame, i.e.
 *             100k tests (~130ms/frame) at 100k objects. This index organizes objects
 *             spatially by their world bounding spheres so a query tests the root
 *             first and skips whole branches that lie entirely outside the frustum.
 *
 *             Relation to the scene-graph walk: this index is an *acceleration layer*,
 *             not a replacement. The scene-graph walk still handles hierarchical
 *             visibility (children of an invisible parent are not rendered) and object
 *             type dispatch, but "does this object fall inside the frustum" is answered
 *             in bulk by the BVH, avoiding a repeated 6-plane test per object.
 *
 *             Incremental updates:
 *             - Structure change (object added/removed) → Object3D.structureVersion changes
 *               → rebuild the index
 *             - Object moved/scaled → its world bounding sphere goes stale → update
 *               only its BVH element and refit
 *             In a static scene nothing is rebuilt and no bounding sphere is recomputed.
 */
package three.rendering.common

import std.collection.*
import three.core.dsa.Bvh
import three.core.math.*
import three.scene.objects.*
import three.scene.entity.*
import three.scene.scenegraph.*

/**
 * @brief[zh-cn] 场景空间索引
 * @explain[zh-cn] 维护场景中可剔除对象的扁平列表与对应 BVH，并提供逐帧的
 *               "刷新包围盒 + 视锥查询"能力。
 *
 * @brief[en] Scene spatial index
 * @explain[en] Maintains a flat list of cullable scene objects plus the matching BVH,
 *             and provides per-frame "refresh bounds + frustum query" operations.
 */
public class SceneCullIndex {
    /**
     * @brief[zh-cn] 参与空间索引的对象（与 BVH 元素一一对应）
     *
     * @brief[en] Objects participating in the spatial index (one-to-one with BVH elements)
     */
    private var _objects: ArrayList<Object3D> = ArrayList<Object3D>(256)
    /**
     * @brief[zh-cn] 不参与空间索引的对象（frustumCulled=false，恒可见）
     *
     * @brief[en] Objects excluded from the spatial index (frustumCulled=false, always visible)
     */
    private var _alwaysVisible: ArrayList<Object3D> = ArrayList<Object3D>(32)
    /**
     * @brief[zh-cn] BVH 元素中心 X
     *
     * @brief[en] BVH element center X
     */
    private var _centerX: ArrayList<Float64> = ArrayList<Float64>(256)
    private var _centerY: ArrayList<Float64> = ArrayList<Float64>(256)
    private var _centerZ: ArrayList<Float64> = ArrayList<Float64>(256)
    /**
     * @brief[zh-cn] BVH 元素半尺寸 X
     *
     * @brief[en] BVH element half-extent X
     */
    private var _halfX: ArrayList<Float64> = ArrayList<Float64>(256)
    private var _halfY: ArrayList<Float64> = ArrayList<Float64>(256)
    private var _halfZ: ArrayList<Float64> = ArrayList<Float64>(256)
    /**
     * @brief[zh-cn] 空间层次结构
     *
     * @brief[en] The spatial hierarchy
     */
    private var _bvh: Bvh = Bvh()
    /**
     * @brief[zh-cn] 上次构建时的场景结构版本
     *
     * @brief[en] Scene structure version at the last build
     */
    private var _builtVersion: Int64 = -1
    /**
     * @brief[zh-cn] 查询命中的对象下标（复用，避免每帧分配）
     *
     * @brief[en] Indices hit by the last query (reused to avoid per-frame allocation)
     */
    private var _hits: ArrayList<Int64> = ArrayList<Int64>(256)
    /**
     * @brief[zh-cn] 参与索引的对象数量
     *
     * @brief[en] Number of objects participating in the index
     */
    private var _indexedCount: Int64 = 0

    /**
     * @brief[zh-cn] 参与空间索引的对象数量
     *
     * @brief[en] Number of objects participating in the spatial index
     */
    public prop indexedCount: Int64 {
        get() { return this._indexedCount }
    }

    /**
     * @brief[zh-cn] 恒可见对象数量
     *
     * @brief[en] Number of always-visible objects
     */
    public prop alwaysVisibleCount: Int64 {
        get() { return this._alwaysVisible.size }
    }

    /**
     * @brief[zh-cn] 检查索引是否需要重建（场景结构有变化）
     *
     * @brief[en] Whether the index needs rebuilding (scene structure changed)
     */
    public func needsRebuild(): Bool {
        return this._builtVersion != Object3D.structureVersion
    }

    /**
     * @brief[zh-cn] 重建索引：遍历场景收集可剔除对象并建立 BVH
     * @explain[zh-cn] 只收录"自身及所有祖先 visible"且 frustumCulled=true 且有世界包围球的
     *               可渲染对象（Mesh/Line/Points/Sprite）。其余对象进入恒可见列表，
     *               每帧照常提交，不做空间剔除。
     * @param[zh-cn] scene 场景根节点
     *
     * @brief[en] Rebuild the index: walk the scene collecting cullable objects and build the BVH
     * @explain[en] Only renderable objects (Mesh/Line/Points/Sprite) that are themselves and
     *               ancestrally visible, have frustumCulled=true, and have a world bounding
     *               sphere are collected. The rest go to the always-visible list and are
     *               submitted every frame without spatial culling.
     * @param[en] scene Scene root
     */
    public func rebuild(scene: Object3D): Unit {
        // 旧索引对象的可见标记重置为可见：重建后未再收录的对象（如祖先转为不可见）
        // 不得残留上一帧的 false，否则会被误剔除。
        for (obj in this._objects) {
            obj.cullVisible = true
        }
        for (obj in this._alwaysVisible) {
            obj.cullVisible = true
        }
        this._objects.clear()
        this._alwaysVisible.clear()
        this._centerX.clear()
        this._centerY.clear()
        this._centerZ.clear()
        this._halfX.clear()
        this._halfY.clear()
        this._halfZ.clear()
        this._collect(scene, true)
        this._indexedCount = this._objects.size
        if (this._indexedCount > 0) {
            this._bvh.build(this._centerX.toArray(), this._centerY.toArray(), this._centerZ.toArray(),
                            this._halfX.toArray(), this._halfY.toArray(), this._halfZ.toArray())
        }
        this._builtVersion = Object3D.structureVersion
    }

    /**
     * @brief[zh-cn] 递归收集可剔除对象
     * @explain[zh-cn] ancestorsVisible 表示所有祖先是否可见；任一祖先不可见则整棵子树跳过。
     *
     * @brief[en] Recursively collect cullable objects
     * @explain[en] ancestorsVisible tracks whether all ancestors are visible; an invisible
     *               ancestor skips the entire subtree.
     */
    private func _collect(node: Object3D, ancestorsVisible: Bool): Unit {
        let visible = ancestorsVisible && node.visible
        if (!visible) {
            return
        }
        if (this._isRenderable(node)) {
            if (!node.frustumCulled) {
                // 恒可见：不参与空间剔除
                this._alwaysVisible.add(node)
            } else {
                if (let Some(ball) <- node.getWorldBoundingSphere()) {
                    this._objects.add(node)
                    this._centerX.add(ball[0])
                    this._centerY.add(ball[1])
                    this._centerZ.add(ball[2])
                    this._halfX.add(ball[3])
                    this._halfY.add(ball[3])
                    this._halfZ.add(ball[3])
                } else {
                    // 无包围球 → 无法空间剔除，按恒可见处理
                    this._alwaysVisible.add(node)
                }
            }
        }
        for (child in node.children) {
            this._collect(child, visible)
        }
    }

    /**
     * @brief[zh-cn] 判断对象是否为可渲染类型
     *
     * @brief[en] Whether the object is a renderable type
     */
    private func _isRenderable(node: Object3D): Bool {
        if (let Some(_) <- (node as Mesh)) { return true }
        if (let Some(_) <- (node as Line)) { return true }
        if (let Some(_) <- (node as Points)) { return true }
        if (let Some(_) <- (node as Sprite)) { return true }
        return false
    }

    /**
     * @brief[zh-cn] 刷新包围盒并做视锥查询，结果写入各对象的 cullVisible 标记
     * @explain[zh-cn] 先把已失效（移动/缩放过）的对象包围球写回 BVH，再 refit
     *               一次，最后做视锥查询。静态场景下没有任何包围盒需要重算。
     *               查询前先把所有索引对象标记为不可见，命中者再置回可见；
     *               恒可见对象（frustumCulled=false / 无包围球）无条件置为可见。
     * @param[zh-cn] frustum 视锥
     *
     * @brief[en] Refresh bounds and run a frustum query, writing the result into each
     *            object's cullVisible flag
     * @explain[en] Writes back the bounds of stale (moved/scaled) objects into the BVH,
     *               refits once, then runs the frustum query. In a static scene no
     *               bounds need recomputing. All indexed objects are first marked
     *               invisible, hits are marked visible again, and always-visible objects
     *               (frustumCulled=false / no bounding sphere) are marked visible
     *               unconditionally.
     * @param[en] frustum Frustum
     */
    public func query(frustum: Frustum): Unit {
        // 恒可见对象：无条件可见
        for (obj in this._alwaysVisible) {
            obj.cullVisible = true
        }
        if (this._indexedCount == 0) {
            return
        }
        this._refreshBounds()
        // 先全部置为不可见，命中者再置回可见
        for (obj in this._objects) {
            obj.cullVisible = false
        }
        this._hits.clear()
        this._bvh.queryFrustum(frustum, this._hits)
        for (i in this._hits) {
            this._objects[i].cullVisible = true
        }
    }

    /**
     * @brief[zh-cn] 刷新包围盒并做多眼视锥查询（任一眼可见即不剔除）
     * @explain[zh-cn] 对每只眼的视锥各做一次 BVH 查询，命中结果取并集，
     *               与 FrustumArray.intersectsObject 的"任一眼可见"语义一致。
     * @param[zh-cn] frustumArray 多眼视锥
     *
     * @brief[en] Refresh bounds and run a multi-eye frustum query (visible in any eye)
     * @explain[en] Runs one BVH query per eye and unions the hits, matching the
     *               "visible in any eye" semantics of FrustumArray.intersectsObject.
     * @param[en] frustumArray Multi-eye frustum
     */
    public func queryArrayFrustum(frustumArray: FrustumArray): Unit {
        for (obj in this._alwaysVisible) {
            obj.cullVisible = true
        }
        if (this._indexedCount == 0) {
            return
        }
        this._refreshBounds()
        for (obj in this._objects) {
            obj.cullVisible = false
        }
        for (eye in 0..frustumArray.frustums.size) {
            this._hits.clear()
            this._bvh.queryFrustum(frustumArray.get(eye), this._hits)
            for (i in this._hits) {
                this._objects[i].cullVisible = true
            }
        }
    }

    /**
     * @brief[zh-cn] 把失效对象的世界包围球写回 BVH 元素
     *
     * @brief[en] Write stale objects' world bounding spheres back into the BVH elements
     */
    private func _refreshBounds(): Unit {
        var dirty = false
        let n = this._objects.size
        for (i in 0..n) {
            let obj = this._objects[i]
            if (!obj.worldBoundingSphereDirty) {
                continue
            }
            if (let Some(ball) <- obj.getWorldBoundingSphere()) {
                this._centerX[i] = ball[0]
                this._centerY[i] = ball[1]
                this._centerZ[i] = ball[2]
                this._halfX[i] = ball[3]
                this._halfY[i] = ball[3]
                this._halfZ[i] = ball[3]
                dirty = true
            }
        }
        if (dirty) {
            this._bvh.updateBounds(this._centerX.toArray(), this._centerY.toArray(), this._centerZ.toArray(),
                                    this._halfX.toArray(), this._halfY.toArray(), this._halfZ.toArray())
        }
    }
}
