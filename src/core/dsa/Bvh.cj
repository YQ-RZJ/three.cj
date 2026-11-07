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
 * @file[zh-cn] Bvh 包围体层次结构（空间加速结构）
 * @brief[zh-cn] 基于轴对齐包围盒（AABB）的层次空间索引，用于把"逐对象视锥测试"的
 *             O(N) 遍历降为 O(log N + K)（K 为可见对象数）
 * @explain[zh-cn] 大型场景（十万级对象）里逐对象做视锥测试是 CPU 侧主要瓶颈：
 *             引擎原实现每帧对场景树中每个对象做一次 6 平面相交测试，
 *             10 万对象即 10 万次测试（约 130ms/帧）。BVH 把对象按空间位置组织成
 *             树，一次查询先测根节点 AABB，完全在视锥外就跳过整棵子树，
 *             只有可能可见的分支才继续下探。
 *
 *             存储采用扁平 SoA（structure of arrays）：节点包围盒分量放在
 *             Array<Float64> 中，子节点索引放在 Array<Int64> 中，而非每个节点一个
 *             class 对象。原因是遍历时需要密集访问包围盒分量，SoA 布局让
 *             6 个分量连续存放、缓存友好，也避免构建期产生与节点数同量的堆对象。
 *
 *             构建策略为「最长轴中位数分割」：每次对当前范围的质心包围盒取最长轴，
 *             按该轴质心中位数划分。相比表面积启发式（SAH）实现简单、构建
 *             O(n log n)，在轴对齐且分布较均匀的场景中质量接近；SAH 需预扫描
 *             多候选分割面，代价与常数都更高。
 *
 * @file[en] Bvh Bounding Volume Hierarchy (spatial acceleration structure)
 * @brief[en] An axis-aligned bounding box hierarchy that turns the O(N) per-object
 *             frustum test sweep into O(log N + K) (K = number of visible objects)
 * @explain[en] In large scenes (100k+ objects) the per-object frustum test sweep is
 *             the dominant CPU cost: the engine tests every object against 6 planes
 *             every frame, i.e. 100k tests (~130ms/frame) at 100k objects. A BVH
 *             organizes objects spatially into a tree: a query first tests the root
 *             AABB and skips whole subtrees that are entirely outside the frustum,
 *             descending only into branches that may contain visible objects.
 *
 *             Storage is a flat SoA (structure of arrays): node bounds components live
 *             in Array<Float64> and child links in Array<Int64>, rather than one class
 *             object per node. Traversal reads bounds components densely, so SoA keeps
 *             the 6 components contiguous (cache friendly) and avoids allocating one
 *             heap object per node at build time.
 *
 *             The build strategy is "median split along the longest axis": for the
 *             centroid bounds of the current range, split at the median of the
 *             centroids on the longest axis. It is simpler and O(n log n) to build,
 *             with quality close to SAH for axis-aligned, evenly distributed scenes;
 *             SAH needs to prescan many candidate split planes at a higher cost.
 */
package three.core.dsa

import std.collection.*
import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] BVH 节点（扁平存储的单个节点）
 * @explain[zh-cn] 仅在构建/查询的临时计算中使用；持久状态存放在 Bvh 的 SoA 数组里。
 *
 * @brief[en] A BVH node (used only for transient build/query computation)
 * @explain[en] Used only during transient build/query computation; persistent state
 *             lives in the Bvh's SoA arrays.
 */
private class BvhBuildNode {
    /** 节点包围盒最小点 */
    var minX: Float64 = 0.0
    var minY: Float64 = 0.0
    var minZ: Float64 = 0.0
    /** 节点包围盒最大点 */
    var maxX: Float64 = 0.0
    var maxY: Float64 = 0.0
    var maxZ: Float64 = 0.0
    /** 质心包围盒（用于选择分割轴与中位数） */
    var cenMinX: Float64 = 0.0
    var cenMinY: Float64 = 0.0
    var cenMinZ: Float64 = 0.0
    var cenMaxX: Float64 = 0.0
    var cenMaxY: Float64 = 0.0
    var cenMaxZ: Float64 = 0.0
    /** 左子节点索引（-1 表示叶子） */
    var left: Int64 = -1
    /** 右子节点索引（-1 表示叶子） */
    var right: Int64 = -1
    /** 叶子对应的元素起始下标（重建后为重排后的下标） */
    var start: Int64 = 0
    /** 叶子元素个数（内部节点为 0） */
    var count: Int64 = 0
    /** 父节点索引（根为 -1），用于 refit 时向上回溯 */
    var parent: Int64 = -1
}

/**
 * @brief[zh-cn] 视锥平面数据（局部缓存，避免遍历中反复索引 planes 数组）
 * @explain[zh-cn] 仓颉不允许 class 内嵌套 class，故置于文件级。
 *
 * @brief[en] Frustum plane data (local cache to avoid repeated planes array indexing)
 * @explain[en] Cangjie does not allow nested class declarations inside a class, so this lives at file level.
 */
private class FrustumPlanes {
    var nx: Array<Float64> = Array<Float64>(6, { _ => 0.0 })
    var ny: Array<Float64> = Array<Float64>(6, { _ => 0.0 })
    var nz: Array<Float64> = Array<Float64>(6, { _ => 0.0 })
    var d: Array<Float64> = Array<Float64>(6, { _ => 0.0 })
}

/**
 * @brief[zh-cn] 包围体层次结构（BVH）
 * @explain[zh-cn] 对一组带 AABB 的元素建立空间层次索引，支持：
 *             1. 视锥查询：只返回包围盒与视锥相交的叶子元素
 *             2. 射线查询：只返回包围盒与射线相交的叶子元素
 *             3. 增量更新：元素移动后调用 refit 重新计算各级包围盒
 *
 *             典型用法（渲染剔除）：
 *             ```
 *             let bvh = Bvh()
 *             bvh.build(centers, extents)   // centers: 元素中心，extents: 半尺寸
 *             // 每帧：
 *             let hits = ArrayList<Int64>()
 *             bvh.queryFrustum(frustum, hits)
 *             ```
 *
 * @brief[en] Bounding Volume Hierarchy (BVH)
 * @explain[en] A spatial hierarchy over elements with AABBs, supporting:
 *             1. Frustum query: returns only leaf elements whose bounds intersect the frustum
 *             2. Ray query: returns only leaf elements whose bounds intersect the ray
 *             3. Incremental update: call refit after elements move to recompute bounds
 */
public class Bvh {
    /**
     * @brief[zh-cn] 节点包围盒最小 X 分量（SoA）
     *
     * @brief[en] Node bounds min X component (SoA)
     */
    private var _minX: ArrayList<Float64> = ArrayList<Float64>()
    private var _minY: ArrayList<Float64> = ArrayList<Float64>()
    private var _minZ: ArrayList<Float64> = ArrayList<Float64>()
    /**
     * @brief[zh-cn] 节点包围盒最大 X 分量（SoA）
     *
     * @brief[en] Node bounds max X component (SoA)
     */
    private var _maxX: ArrayList<Float64> = ArrayList<Float64>()
    private var _maxY: ArrayList<Float64> = ArrayList<Float64>()
    private var _maxZ: ArrayList<Float64> = ArrayList<Float64>()
    /**
     * @brief[zh-cn] 左子节点索引（-1 表示叶子）
     *
     * @brief[en] Left child index (-1 for a leaf)
     */
    private var _left: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 右子节点索引（-1 表示叶子）
     *
     * @brief[en] Right child index (-1 for a leaf)
     */
    private var _right: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 父节点索引（根为 -1）
     *
     * @brief[en] Parent index (-1 for the root)
     */
    private var _parent: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 叶子元素的起始下标（指向 _indices）
     *
     * @brief[en] Leaf element start index (into _indices)
     */
    private var _start: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 叶子元素个数（内部节点为 0）
     *
     * @brief[en] Leaf element count (0 for internal nodes)
     */
    private var _count: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 元素下标重排表：叶子区间 [_start, _start+_count) 映射到原始元素下标
     *
     * @brief[en] Element index permutation: leaf range [_start, _start+_count) maps to original element indices
     */
    private var _indices: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 元素中心点 X（构建用，之后作为只读数据保留）
     *
     * @brief[en] Element center X (build input, kept read-only afterwards)
     */
    private var _centerX: Array<Float64> = Array<Float64>()
    private var _centerY: Array<Float64> = Array<Float64>()
    private var _centerZ: Array<Float64> = Array<Float64>()
    /**
     * @brief[zh-cn] 元素包围盒半尺寸（构建用，之后作为只读数据保留）
     *
     * @brief[en] Element bounds half-extents (build input, kept read-only afterwards)
     */
    private var _halfX: Array<Float64> = Array<Float64>()
    private var _halfY: Array<Float64> = Array<Float64>()
    private var _halfZ: Array<Float64> = Array<Float64>()
    /**
     * @brief[zh-cn] 节点总数
     *
     * @brief[en] Total node count
     */
    private var _nodeCount: Int64 = 0
    /**
     * @brief[zh-cn] 元素总数
     *
     * @brief[en] Total element count
     */
    private var _elementCount: Int64 = 0
    /**
     * @brief[zh-cn] 遍历用栈（复用，避免查询时分配）
     *
     * @brief[en] Traversal stack (reused to avoid per-query allocation)
     */
    private var _stack: ArrayList<Int64> = ArrayList<Int64>(64)
    /**
     * @brief[zh-cn] 构建期临时节点池
     *
     * @brief[en] Transient build-time node pool
     */
    private var _buildNodes: ArrayList<BvhBuildNode> = ArrayList<BvhBuildNode>(64)
    /**
     * @brief[zh-cn] 构建期临时元素下标数组
     *
     * @brief[en] Transient build-time element index array
     */
    private var _buildIndices: ArrayList<Int64> = ArrayList<Int64>(64)
    /**
     * @brief[zh-cn] 视锥平面缓存（跨查询复用，避免每次查询重建）
     *
     * @brief[en] Frustum plane cache (reused across queries)
     */
    private var _planeCache: FrustumPlanes = FrustumPlanes()

    /**
     * @brief[zh-cn] 构造空的 BVH
     *
     * @brief[en] Constructs an empty BVH
     */
    public init() {}

    /**
     * @brief[zh-cn] 节点总数
     *
     * @brief[en] Total node count
     */
    public prop nodeCount: Int64 {
        get() { return this._nodeCount }
    }

    /**
     * @brief[zh-cn] 元素总数
     *
     * @brief[en] Total element count
     */
    public prop elementCount: Int64 {
        get() { return this._elementCount }
    }

    /**
     * @brief[zh-cn] 是否为空（无元素）
     *
     * @brief[en] Whether the BVH is empty (no elements)
     */
    public func isEmpty(): Bool {
        return this._elementCount == 0
    }

    /**
     * @brief[zh-cn] 用元素中心与半尺寸构建 BVH
     * @explain[zh-cn] 元素包围盒由中心与半尺寸确定：min = center - half，max = center + half。
     *               构建采用最长轴中位数分割，复杂度 O(n log n)。
     *               元素少于 2 个时建为单节点叶子。
     * @param[zh-cn] centerX 元素中心 X 分量
     * @param[zh-cn] centerY 元素中心 Y 分量
     * @param[zh-cn] centerZ 元素中心 Z 分量
     * @param[zh-cn] halfX 元素包围盒半尺寸 X 分量
     * @param[zh-cn] halfY 元素包围盒半尺寸 Y 分量
     * @param[zh-cn] halfZ 元素包围盒半尺寸 Z 分量
     *
     * @param[en] centerX Element center X components
     * @param[en] centerY Element center Y components
     * @param[en] centerZ Element center Z components
     * @param[en] halfX Element bounds half-extent X components
     * @param[en] halfY Element bounds half-extent Y components
     * @param[en] halfZ Element bounds half-extent Z components
     */
    public func build(centerX: Array<Float64>, centerY: Array<Float64>, centerZ: Array<Float64>,
                      halfX: Array<Float64>, halfY: Array<Float64>, halfZ: Array<Float64>): Unit {
        let n = centerX.size
        this._elementCount = n
        this._centerX = centerX
        this._centerY = centerY
        this._centerZ = centerZ
        this._halfX = halfX
        this._halfY = halfY
        this._halfZ = halfZ
        this._nodeCount = 0
        if (n == 0) {
            return
        }

        // 构建期临时数据
        this._buildNodes.clear()
        this._buildIndices.clear()
        // 展平数组每次构建重置（build 可被多次调用）
        this._minX.clear()
        this._minY.clear()
        this._minZ.clear()
        this._maxX.clear()
        this._maxY.clear()
        this._maxZ.clear()
        this._left.clear()
        this._right.clear()
        this._parent.clear()
        this._start.clear()
        this._count.clear()
        this._indices.clear()
        for (i in 0..n) {
            this._buildIndices.add(i)
        }
        // 预估节点数：二叉树叶子数约为 n/2，总节点约 2n
        this._buildNodes.reserve(n * 2)

        let root = this._createBuildNode()
        this._buildNodes[root].start = 0
        this._buildNodes[root].count = n
        this._computeBuildBounds(root, 0, n)
        this._splitBuild(root)

        // 展平到 SoA 数组
        this._flatten(root, -1)
    }

    /**
     * @brief[zh-cn] 元素移动后重算各级包围盒（自底向上）
     * @explain[zh-cn] 元素自身包围盒由中心/半尺寸决定；本方法先用当前数据重算叶子
     *               的包围盒，再沿父链向上合并，得到与重建等价的包围盒层次。
     *               代价 O(n)，远低于重新构建的 O(n log n)。
     *
     * @brief[en] Recompute bounds after elements moved (bottom-up)
     * @explain[en] Recomputes leaf bounds from the current centers/half-extents, then
     *               merges upward along parent links, producing bounds equivalent to a
     *               rebuild. Costs O(n), far less than the O(n log n) rebuild.
     */
    public func refit(): Unit {
        if (this._elementCount == 0 || this._nodeCount == 0) {
            return
        }
        // 展平为深度优先顺序，父节点下标恒小于子节点下标，
        // 因此逆序遍历即"子节点先于父节点"：叶子重算包围盒、内部节点合并子节点，
        // 一次逆序循环即可完成自底向上的 refit。
        var i = this._nodeCount - 1
        while (i >= 0) {
            let l = this._left[i]
            if (l < 0) {
                this._refitLeaf(i)
            } else {
                let r = this._right[i]
                var minX = this._minX[l]
                var minY = this._minY[l]
                var minZ = this._minZ[l]
                var maxX = this._maxX[l]
                var maxY = this._maxY[l]
                var maxZ = this._maxZ[l]
                if (this._minX[r] < minX) { minX = this._minX[r] }
                if (this._minY[r] < minY) { minY = this._minY[r] }
                if (this._minZ[r] < minZ) { minZ = this._minZ[r] }
                if (this._maxX[r] > maxX) { maxX = this._maxX[r] }
                if (this._maxY[r] > maxY) { maxY = this._maxY[r] }
                if (this._maxZ[r] > maxZ) { maxZ = this._maxZ[r] }
                this._minX[i] = minX
                this._minY[i] = minY
                this._minZ[i] = minZ
                this._maxX[i] = maxX
                this._maxY[i] = maxY
                this._maxZ[i] = maxZ
            }
            i -= 1
        }
    }

    /**
     * @brief[zh-cn] 元素中心更新后调用 refit 的便捷入口
     * @param[zh-cn] centerX 新的中心 X 分量
     * @param[zh-cn] centerY 新的中心 Y 分量
     * @param[zh-cn] centerZ 新的中心 Z 分量
     *
     * @brief[en] Convenience entry: update element centers then refit
     * @param[en] centerX New center X components
     * @param[en] centerY New center Y components
     * @param[en] centerZ New center Z components
     */
    public func updateCenters(centerX: Array<Float64>, centerY: Array<Float64>, centerZ: Array<Float64>): Unit {
        this._centerX = centerX
        this._centerY = centerY
        this._centerZ = centerZ
        this.refit()
    }

    /**
     * @brief[zh-cn] 整体替换元素包围盒数据（中心 + 半尺寸）并 refit
     * @explain[zh-cn] 用于引擎侧批量更新：调用方每帧重新计算全部元素的包围盒后，
     *               用新数组整体替换（避免逐元素 API 的调用开销），再 refit 一次。
     * @param[zh-cn] centerX 新的中心 X 分量
     * @param[zh-cn] centerY 新的中心 Y 分量
     * @param[zh-cn] centerZ 新的中心 Z 分量
     * @param[zh-cn] halfX 新的半尺寸 X 分量
     * @param[zh-cn] halfY 新的半尺寸 Y 分量
     * @param[zh-cn] halfZ 新的半尺寸 Z 分量
     *
     * @brief[en] Replace all element bounds (center + half extents) wholesale and refit
     * @explain[en] Used by the engine for batch updates: after recomputing every element's
     *               bounds, the caller replaces the arrays wholesale (cheaper than a
     *               per-element API) and refits once.
     * @param[en] centerX New center X components
     * @param[en] centerY New center Y components
     * @param[en] centerZ New center Z components
     * @param[en] halfX New half-extent X components
     * @param[en] halfY New half-extent Y components
     * @param[en] halfZ New half-extent Z components
     */
    public func updateBounds(centerX: Array<Float64>, centerY: Array<Float64>, centerZ: Array<Float64>,
                             halfX: Array<Float64>, halfY: Array<Float64>, halfZ: Array<Float64>): Unit {
        this._centerX = centerX
        this._centerY = centerY
        this._centerZ = centerZ
        this._halfX = halfX
        this._halfY = halfY
        this._halfZ = halfZ
        this.refit()
    }

    /**
     * @brief[zh-cn] 读取元素的包围盒（中心 + 半尺寸）
     * @explain[zh-cn] 供引擎侧在更新前取回旧值做差分（只更新变化的元素）。
     * @param[zh-cn] element 元素下标
     * @param[zh-cn] outCenter 输出中心（写入 cx, cy, cz）
     * @param[zh-cn] outHalf 输出半尺寸（写入 hx, hy, hz）
     *
     * @brief[en] Read an element's bounds (center + half extents)
     * @explain[en] Lets the engine read the old values to diff against, so only changed
     *               elements need updating.
     * @param[en] element Element index
     * @param[en] outCenter Output center (cx, cy, cz written)
     * @param[en] outHalf Output half extents (hx, hy, hz written)
     */
    public func getElementBounds(element: Int64, outCenter: Array<Float64>, outHalf: Array<Float64>): Unit {
        outCenter[0] = this._centerX[element]
        outCenter[1] = this._centerY[element]
        outCenter[2] = this._centerZ[element]
        outHalf[0] = this._halfX[element]
        outHalf[1] = this._halfY[element]
        outHalf[2] = this._halfZ[element]
    }

    /**
     * @brief[zh-cn] 视锥查询：收集包围盒与视锥相交的叶子元素下标
     * @explain[zh-cn] 遍历时若节点包围盒完全在视锥外，则整棵子树跳过；
     *               叶子节点再对其元素包围盒做一次精确相交测试。
     * @param[zh-cn] frustum 视锥
     * @param[zh-cn] out 输出数组（追加命中下标）
     *
     * @brief[en] Frustum query: collect leaf element indices whose bounds intersect the frustum
     * @explain[en] During traversal, a node whose bounds lie entirely outside the frustum
     *               causes its whole subtree to be skipped; leaf nodes then run an exact
     *               bounds intersection test per element.
     * @param[en] frustum Frustum
     * @param[en] out Output array (hit indices are appended)
     */
    public func queryFrustum(frustum: Frustum, out: ArrayList<Int64>): Unit {
        if (this._nodeCount == 0) {
            return
        }
        // 把视锥平面数据取到局部变量，避免遍历中反复走 planes[i] 的属性访问
        let pn = this._extractPlanes(frustum)
        this._stack.clear()
        this._stack.add(0)
        while (!this._stack.isEmpty()) {
            let idx = this._stack.remove(at: this._stack.size - 1)
            if (!this._nodeIntersectsFrustum(idx, pn)) {
                continue
            }
            if (this._left[idx] >= 0) {
                this._stack.add(this._left[idx])
                this._stack.add(this._right[idx])
            } else {
                let s = this._start[idx]
                let c = this._count[idx]
                for (k in 0..c) {
                    let e = this._indices[s + k]
                    if (this._elementIntersectsFrustum(e, pn)) {
                        out.add(e)
                    }
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 射线查询：收集包围盒与射线相交的叶子元素下标
     * @param[zh-cn] origin 射线起点
     * @param[zh-cn] direction 射线方向（不必归一化）
     * @param[zh-cn] maxDistance 最远距离
     * @param[zh-cn] out 输出数组（追加命中下标）
     *
     * @brief[en] Ray query: collect leaf element indices whose bounds intersect the ray
     * @param[en] origin Ray origin
     * @param[en] direction Ray direction (need not be normalized)
     * @param[en] maxDistance Maximum distance
     * @param[en] out Output array (hit indices are appended)
     */
    public func queryRay(origin: Vector3, direction: Vector3, maxDistance: Float64, out: ArrayList<Int64>): Unit {
        if (this._nodeCount == 0) {
            return
        }
        let ox = origin.x
        let oy = origin.y
        let oz = origin.z
        let dx = direction.x
        let dy = direction.y
        let dz = direction.z
        this._stack.clear()
        this._stack.add(0)
        while (!this._stack.isEmpty()) {
            let idx = this._stack.remove(at: this._stack.size - 1)
            if (!this._nodeIntersectsRay(idx, ox, oy, oz, dx, dy, dz, maxDistance)) {
                continue
            }
            if (this._left[idx] >= 0) {
                this._stack.add(this._left[idx])
                this._stack.add(this._right[idx])
            } else {
                let s = this._start[idx]
                let c = this._count[idx]
                for (k in 0..c) {
                    let e = this._indices[s + k]
                    if (this._elementIntersectsRay(e, ox, oy, oz, dx, dy, dz, maxDistance)) {
                        out.add(e)
                    }
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 取根节点包围盒（最小点写入 outMin，最大点写入 outMax）
     * @param[zh-cn] outMin 输出最小点
     * @param[zh-cn] outMax 输出最大点
     * @return[zh-cn] 是否存在根节点
     *
     * @brief[en] Get the root node bounds (min into outMin, max into outMax)
     * @param[en] outMin Output min corner
     * @param[en] outMax Output max corner
     * @brief[en] Whether a root node exists
     */
    public func getRootBounds(outMin: Vector3, outMax: Vector3): Bool {
        if (this._nodeCount == 0) {
            return false
        }
        outMin.set(this._minX[0], this._minY[0], this._minZ[0])
        outMax.set(this._maxX[0], this._maxY[0], this._maxZ[0])
        return true
    }

    // ===== 内部实现 =====

    private func _extractPlanes(frustum: Frustum): FrustumPlanes {
        let p = this._planeCache
        for (i in 0..6) {
            let plane = frustum.planes[i]
            p.nx[i] = plane.normal.x
            p.ny[i] = plane.normal.y
            p.nz[i] = plane.normal.z
            p.d[i] = plane.constant
        }
        return p
    }

    private func _createBuildNode(): Int64 {
        let n = BvhBuildNode()
        this._buildNodes.add(n)
        return this._buildNodes.size - 1
    }

    /**
     * @brief[zh-cn] 计算构建节点的包围盒与质心包围盒
     *
     * @brief[en] Compute a build node's bounds and centroid bounds
     */
    private func _computeBuildBounds(nodeIdx: Int64, start: Int64, count: Int64): Unit {
        let node = this._buildNodes[nodeIdx]
        var minX = Float64.Inf
        var minY = Float64.Inf
        var minZ = Float64.Inf
        var maxX = -Float64.Inf
        var maxY = -Float64.Inf
        var maxZ = -Float64.Inf
        var cenMinX = Float64.Inf
        var cenMinY = Float64.Inf
        var cenMinZ = Float64.Inf
        var cenMaxX = -Float64.Inf
        var cenMaxY = -Float64.Inf
        var cenMaxZ = -Float64.Inf
        for (i in start..(start + count)) {
            let e = this._buildIndices[i]
            let cx = this._centerX[e]
            let cy = this._centerY[e]
            let cz = this._centerZ[e]
            let hx = this._halfX[e]
            let hy = this._halfY[e]
            let hz = this._halfZ[e]
            if (cx - hx < minX) { minX = cx - hx }
            if (cy - hy < minY) { minY = cy - hy }
            if (cz - hz < minZ) { minZ = cz - hz }
            if (cx + hx > maxX) { maxX = cx + hx }
            if (cy + hy > maxY) { maxY = cy + hy }
            if (cz + hz > maxZ) { maxZ = cz + hz }
            if (cx < cenMinX) { cenMinX = cx }
            if (cy < cenMinY) { cenMinY = cy }
            if (cz < cenMinZ) { cenMinZ = cz }
            if (cx > cenMaxX) { cenMaxX = cx }
            if (cy > cenMaxY) { cenMaxY = cy }
            if (cz > cenMaxZ) { cenMaxZ = cz }
        }
        node.minX = minX
        node.minY = minY
        node.minZ = minZ
        node.maxX = maxX
        node.maxY = maxY
        node.maxZ = maxZ
        node.cenMinX = cenMinX
        node.cenMinY = cenMinY
        node.cenMinZ = cenMinZ
        node.cenMaxX = cenMaxX
        node.cenMaxY = cenMaxY
        node.cenMaxZ = cenMaxZ
    }

    /**
     * @brief[zh-cn] 分割构建节点（最长轴中位数分割）
     * @explain[zh-cn] 叶子（count <= 1）不再分割；否则按质心包围盒最长轴取中位数划分。
     *               划分用快排式 partition（Hoare 分区），O(count) 完成。
     *
     * @brief[en] Split a build node (median split along the longest axis)
     */
    private func _splitBuild(nodeIdx: Int64): Unit {
        let node = this._buildNodes[nodeIdx]
        let count = node.count
        if (count <= 1) {
            return
        }
        let start = node.start
        // 选择最长轴
        let ex = node.cenMaxX - node.cenMinX
        let ey = node.cenMaxY - node.cenMinY
        let ez = node.cenMaxZ - node.cenMinZ
        var axis = 0
        if (ey > ex && ey >= ez) {
            axis = 1
        } else if (ez > ex && ez > ey) {
            axis = 2
        }
        // 中位数分割
        let mid = this._partitionByAxis(start, start + count, axis)
        let leftCount = mid - start
        if (leftCount == 0 || leftCount == count) {
            // 无法有效划分（所有元素同轴同值）：退化为按数量均分，避免死循环
            let half = count / 2
            let mid2 = start + half
            this._makeInternal(nodeIdx, start, half, mid2, count - half)
            return
        }
        this._makeInternal(nodeIdx, start, leftCount, mid, count - leftCount)
    }

    /**
     * @brief[zh-cn] 创建子节点并递归分割
     *
     * @brief[en] Create child nodes and recurse
     */
    private func _makeInternal(nodeIdx: Int64, start: Int64, leftCount: Int64,
                               rightStart: Int64, rightCount: Int64): Unit {
        let leftIdx = this._createBuildNode()
        let rightIdx = this._createBuildNode()
        let node = this._buildNodes[nodeIdx]
        node.left = leftIdx
        node.right = rightIdx
        this._buildNodes[leftIdx].parent = nodeIdx
        this._buildNodes[rightIdx].parent = nodeIdx
        this._buildNodes[leftIdx].start = start
        this._buildNodes[leftIdx].count = leftCount
        this._buildNodes[rightIdx].start = rightStart
        this._buildNodes[rightIdx].count = rightCount
        this._computeBuildBounds(leftIdx, start, leftCount)
        this._computeBuildBounds(rightIdx, rightStart, rightCount)
        this._splitBuild(leftIdx)
        this._splitBuild(rightIdx)
    }

    /**
     * @brief[zh-cn] 按指定轴对质心中位数做分区（Hoare 双指针）
     * @return[zh-cn] 分区后左半段的结束下标
     *
     * @brief[en] Partition by median centroid along the given axis (Hoare scheme)
     * @return[en] End index of the left half after partitioning
     */
    private func _partitionByAxis(lo: Int64, hi: Int64, axis: Int64): Int64 {
        // 取中位数位置的质心值作为枢轴
        let midIdx = (lo + hi) / 2
        let pivotElem = this._buildIndices[midIdx]
        var pivot: Float64 = 0.0
        if (axis == 0) {
            pivot = this._centerX[pivotElem]
        } else if (axis == 1) {
            pivot = this._centerY[pivotElem]
        } else {
            pivot = this._centerZ[pivotElem]
        }
        var i = lo
        var j = hi - 1
        while (i <= j) {
            while (i <= j && this._axisValue(this._buildIndices[i], axis) < pivot) {
                i += 1
            }
            while (i <= j && this._axisValue(this._buildIndices[j], axis) >= pivot) {
                j -= 1
            }
            if (i < j) {
                let tmp = this._buildIndices[i]
                this._buildIndices[i] = this._buildIndices[j]
                this._buildIndices[j] = tmp
                i += 1
                j -= 1
            }
        }
        return i
    }

    private func _axisValue(elem: Int64, axis: Int64): Float64 {
        if (axis == 0) {
            return this._centerX[elem]
        } else if (axis == 1) {
            return this._centerY[elem]
        } else {
            return this._centerZ[elem]
        }
    }

    /**
     * @brief[zh-cn] 把构建树展平到 SoA 数组（深度优先，产出连续数组）
     *
     * @brief[en] Flatten the build tree into the SoA arrays (depth-first, contiguous output)
     */
    private func _flatten(nodeIdx: Int64, parentIdx: Int64): Int64 {
        let node = this._buildNodes[nodeIdx]
        let outIdx = this._nodeCount
        this._nodeCount += 1
        // 预留位置
        this._minX.add(node.minX)
        this._minY.add(node.minY)
        this._minZ.add(node.minZ)
        this._maxX.add(node.maxX)
        this._maxY.add(node.maxY)
        this._maxZ.add(node.maxZ)
        this._left.add(-1)
        this._right.add(-1)
        this._parent.add(parentIdx)
        this._start.add(0)
        this._count.add(node.count)
        if (node.left >= 0) {
            let l = this._flatten(node.left, outIdx)
            let r = this._flatten(node.right, outIdx)
            this._left[outIdx] = l
            this._right[outIdx] = r
        } else {
            // 叶子：把元素下标写入 _indices 的对应区段。
            // 注意 _start 必须是 _indices 空间里的起始位置，而非构建期 buildIndices 的偏移
            // （分区会重排 buildIndices，两者不一致）。
            let idxStart = this._indices.size
            this._start[outIdx] = idxStart
            for (k in 0..node.count) {
                this._indices.add(this._buildIndices[node.start + k])
            }
        }
        return outIdx
    }

    /**
     * @brief[zh-cn] 重算单个叶子节点的包围盒
     *
     * @brief[en] Recompute a leaf node's bounds
     */
    private func _refitLeaf(idx: Int64): Unit {
        let s = this._start[idx]
        let c = this._count[idx]
        var minX = Float64.Inf
        var minY = Float64.Inf
        var minZ = Float64.Inf
        var maxX = -Float64.Inf
        var maxY = -Float64.Inf
        var maxZ = -Float64.Inf
        for (k in 0..c) {
            let e = this._indices[s + k]
            let cx = this._centerX[e]
            let cy = this._centerY[e]
            let cz = this._centerZ[e]
            let hx = this._halfX[e]
            let hy = this._halfY[e]
            let hz = this._halfZ[e]
            if (cx - hx < minX) { minX = cx - hx }
            if (cy - hy < minY) { minY = cy - hy }
            if (cz - hz < minZ) { minZ = cz - hz }
            if (cx + hx > maxX) { maxX = cx + hx }
            if (cy + hy > maxY) { maxY = cy + hy }
            if (cz + hz > maxZ) { maxZ = cz + hz }
        }
        this._minX[idx] = minX
        this._minY[idx] = minY
        this._minZ[idx] = minZ
        this._maxX[idx] = maxX
        this._maxY[idx] = maxY
        this._maxZ[idx] = maxZ
    }

    /**
     * @brief[zh-cn] 节点包围盒是否与视锥相交（AABB vs 6 平面）
     *
     * @brief[en] Whether a node's AABB intersects the frustum (AABB vs 6 planes)
     */
    private func _nodeIntersectsFrustum(idx: Int64, p: FrustumPlanes): Bool {
        let minX = this._minX[idx]
        let minY = this._minY[idx]
        let minZ = this._minZ[idx]
        let maxX = this._maxX[idx]
        let maxY = this._maxY[idx]
        let maxZ = this._maxZ[idx]
        for (i in 0..6) {
            let nx = p.nx[i]
            let ny = p.ny[i]
            let nz = p.nz[i]
            // 取包围盒在法线方向上的"最负点"（p-vertex）：让 n·p 尽可能小。
            // n.x > 0 时取 maxX，n.x < 0 时取 minX（与 Frustum.intersectsBox 一致）。
            let px = if (nx > 0.0) { maxX } else { minX }
            let py = if (ny > 0.0) { maxY } else { minY }
            let pz = if (nz > 0.0) { maxZ } else { minZ }
            if (nx * px + ny * py + nz * pz + p.d[i] < 0.0) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 元素包围盒是否与视锥相交
     *
     * @brief[en] Whether an element's bounds intersect the frustum
     */
    private func _elementIntersectsFrustum(e: Int64, p: FrustumPlanes): Bool {
        let cx = this._centerX[e]
        let cy = this._centerY[e]
        let cz = this._centerZ[e]
        let hx = this._halfX[e]
        let hy = this._halfY[e]
        let hz = this._halfZ[e]
        let minX = cx - hx
        let minY = cy - hy
        let minZ = cz - hz
        let maxX = cx + hx
        let maxY = cy + hy
        let maxZ = cz + hz
        for (i in 0..6) {
            let nx = p.nx[i]
            let ny = p.ny[i]
            let nz = p.nz[i]
            // p-vertex：n.x > 0 取 maxX，n.x < 0 取 minX
            let px = if (nx > 0.0) { maxX } else { minX }
            let py = if (ny > 0.0) { maxY } else { minY }
            let pz = if (nz > 0.0) { maxZ } else { minZ }
            if (nx * px + ny * py + nz * pz + p.d[i] < 0.0) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 节点包围盒是否与射线相交（slab 法）
     *
     * @brief[en] Whether a node's AABB intersects the ray (slab method)
     */
    private func _nodeIntersectsRay(idx: Int64, ox: Float64, oy: Float64, oz: Float64,
                                    dx: Float64, dy: Float64, dz: Float64, maxDistance: Float64): Bool {
        return this._aabbIntersectsRay(this._minX[idx], this._minY[idx], this._minZ[idx],
                                       this._maxX[idx], this._maxY[idx], this._maxZ[idx],
                                       ox, oy, oz, dx, dy, dz, maxDistance)
    }

    /**
     * @brief[zh-cn] 元素包围盒是否与射线相交
     *
     * @brief[en] Whether an element's bounds intersect the ray
     */
    private func _elementIntersectsRay(e: Int64, ox: Float64, oy: Float64, oz: Float64,
                                       dx: Float64, dy: Float64, dz: Float64, maxDistance: Float64): Bool {
        let cx = this._centerX[e]
        let cy = this._centerY[e]
        let cz = this._centerZ[e]
        let hx = this._halfX[e]
        let hy = this._halfY[e]
        let hz = this._halfZ[e]
        return this._aabbIntersectsRay(cx - hx, cy - hy, cz - hz, cx + hx, cy + hy, cz + hz,
                                       ox, oy, oz, dx, dy, dz, maxDistance)
    }

    /**
     * @brief[zh-cn] AABB 与射线相交测试（slab 法，逐轴求参数区间）
     *
     * @brief[en] AABB-ray intersection (slab method, per-axis parameter intervals)
     */
    private func _aabbIntersectsRay(minX: Float64, minY: Float64, minZ: Float64,
                                    maxX: Float64, maxY: Float64, maxZ: Float64,
                                    ox: Float64, oy: Float64, oz: Float64,
                                    dx: Float64, dy: Float64, dz: Float64,
                                    maxDistance: Float64): Bool {
        var tMin = 0.0
        var tMax = maxDistance
        // X 轴
        if (abs(dx) < 1e-12) {
            if (ox < minX || ox > maxX) { return false }
        } else {
            var t1 = (minX - ox) / dx
            var t2 = (maxX - ox) / dx
            if (t1 > t2) { let t = t1; t1 = t2; t2 = t }
            if (t1 > tMin) { tMin = t1 }
            if (t2 < tMax) { tMax = t2 }
            if (tMin > tMax) { return false }
        }
        // Y 轴
        if (abs(dy) < 1e-12) {
            if (oy < minY || oy > maxY) { return false }
        } else {
            var t1 = (minY - oy) / dy
            var t2 = (maxY - oy) / dy
            if (t1 > t2) { let t = t1; t1 = t2; t2 = t }
            if (t1 > tMin) { tMin = t1 }
            if (t2 < tMax) { tMax = t2 }
            if (tMin > tMax) { return false }
        }
        // Z 轴
        if (abs(dz) < 1e-12) {
            if (oz < minZ || oz > maxZ) { return false }
        } else {
            var t1 = (minZ - oz) / dz
            var t2 = (maxZ - oz) / dz
            if (t1 > t2) { let t = t1; t1 = t2; t2 = t }
            if (t1 > tMin) { tMin = t1 }
            if (t2 < tMax) { tMax = t2 }
            if (tMin > tMax) { return false }
        }
        return true
    }
}
