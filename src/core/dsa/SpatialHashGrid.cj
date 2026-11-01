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
 * @file[zh-cn] 空间哈希网格
 * @brief[zh-cn] 均匀网格（空间哈希）宽相位索引，支持球/盒邻域查询
 * @explain[zh-cn] 引擎此前只有 BVH 一种空间索引（面向静态/大范围剔除）。
 *             空间哈希网格补齐了另一类常用需求：**动态对象的邻域查询**
 *             （碰撞宽相位、粒子邻域、集群/群体行为）。它的特点是：
 *             1. 插入/查询均为 O(1) 期望（哈希表），与场景规模无关；
 *             2. 对"对象密度均匀"的场景（粒子、集群 NPC、实例化植被）比 BVH
 *                重建代价低得多——对象移动只需更新它所在的那几个格子；
 *             3. 内存友好：元素数据用 SoA（分列数组）存放，避免每个元素一个对象。
 *
 *             元素按其包围球登记，会登记到所有与其相交的格子中，因此一次
 *             球查询只需遍历查询球覆盖的格子，再对候选元素做精确距离判定。
 *
 * @file[en] Spatial hash grid
 * @brief[en] Uniform grid (spatial hash) broadphase index supporting sphere/box neighborhood queries
 * @explain[en] The engine previously had only one spatial index (BVH, aimed at
 *             static / large-scale culling). The spatial hash grid fills in the other
 *             common need: **neighborhood queries for dynamic objects** (collision
 *             broadphase, particle neighborhoods, flocking). Its properties:
 *             1. Insert/query are O(1) expected (hash map), independent of scene size;
 *             2. For scenes with uniform object density (particles, flocking NPCs,
 *                instanced vegetation) it is far cheaper to maintain than rebuilding
 *                a BVH — a moving object only updates the few cells it touches;
 *             3. Memory friendly: element data uses SoA (split arrays) so there is
 *                no per-element object.
 *
 *             Elements are registered by their bounding sphere into every cell they
 *             overlap, so a sphere query only visits the cells covered by the query
 *             sphere and then performs an exact distance test on the candidates.
 */

package three.core.dsa

import std.collection.*
import std.math.*
import std.overflow.*

/**
 * @brief[zh-cn] 网格坐标键
 * @explain[zh-cn] 三维格坐标打包为一个不可变键对象，实现 Hashable & Equatable。
 *             之所以不用"把三个坐标哈希成一个 Int64"的做法：哈希会碰撞，
 *             碰撞后两个不同格子共用同一条桶链，元素会被重复登记，查询结果
 *             出现重复项。键对象按坐标逐分量比较，保证完全无碰撞。
 *
 * @brief[en] Grid cell key
 * @explain[en] Packs the 3D cell coordinates into an immutable key object implementing
 *             Hashable & Equatable. A "hash the three coordinates into one Int64"
 *             approach is avoided: hashes collide, and colliding cells would share
 *             a bucket, causing elements to be registered twice and query results
 *             to contain duplicates. The key object compares coordinate by
 *             coordinate, so it is collision free.
 */
private class CellKey <: Hashable & Equatable<CellKey> {
    /** 格 X 坐标 */
    let x: Int64
    /** 格 Y 坐标 */
    let y: Int64
    /** 格 Z 坐标 */
    let z: Int64

    init(x: Int64, y: Int64, z: Int64) {
        this.x = x
        this.y = y
        this.z = z
    }

    /**
     * @brief[zh-cn] 计算哈希值
     * @explain[zh-cn] FNV-1a 风格 + 末尾位混淆；使用 wrappingMul 避免整数溢出
     *             （仓颉默认对溢出抛 ArithmeticException）。
     *
     * @brief[en] Computes the hash value
     * @explain[en] FNV-1a style with a final bit-mixing step; uses wrappingMul to avoid
     *               integer overflow (Cangjie throws ArithmeticException by default).
     */
    public func hashCode(): Int64 {
        var h: Int64 = 0x811C9DC5
        h = (h ^ (this.x & 0xFFFFFFFF)).wrappingMul(0x01000193)
        h = (h ^ (this.y & 0xFFFFFFFF)).wrappingMul(0x01000193)
        h = (h ^ (this.z & 0xFFFFFFFF)).wrappingMul(0x01000193)
        h = h ^ (h >> 29)
        h = h.wrappingMul(0x2545F491)
        h = h ^ (h >> 31)
        return h
    }

    /** 相等比较（逐分量） */
    public operator func ==(other: CellKey): Bool {
        return this.x == other.x && this.y == other.y && this.z == other.z
    }

    /** 不等比较 */
    public operator func !=(other: CellKey): Bool {
        return !(this == other)
    }
}

/**
 * @brief[zh-cn] 空间哈希网格
 * @explain[zh-cn] 均匀网格（空间哈希）宽相位索引。元素按包围球登记到相交的格子，
 *             查询时先按格子粗筛再做精确判定。
 *
 * @brief[en] Spatial hash grid
 * @explain[en] Uniform grid (spatial hash) broadphase index. Elements are registered
 *             by their bounding sphere into every overlapped cell; queries first
 *             filter by cell and then perform an exact test on the candidates.
 */
public class SpatialHashGrid {
    /**
     * @brief[zh-cn] 元素中心 X（SoA）
     *
     * @brief[en] Element center X (SoA)
     */
    private var _elemX: ArrayList<Float64> = ArrayList<Float64>()
    /**
     * @brief[zh-cn] 元素中心 Y（SoA）
     *
     * @brief[en] Element center Y (SoA)
     */
    private var _elemY: ArrayList<Float64> = ArrayList<Float64>()
    /**
     * @brief[zh-cn] 元素中心 Z（SoA）
     *
     * @brief[en] Element center Z (SoA)
     */
    private var _elemZ: ArrayList<Float64> = ArrayList<Float64>()
    /**
     * @brief[zh-cn] 元素半径（SoA）
     *
     * @brief[en] Element radius (SoA)
     */
    private var _elemRadius: ArrayList<Float64> = ArrayList<Float64>()
    /**
     * @brief[zh-cn] 格子哈希表：格子键 -> 该格内的元素下标
     *
     * @brief[en] Cell hash map: cell key -> element indices in that cell
     */
    private var _cells: HashMap<CellKey, ArrayList<Int64>> = HashMap<CellKey, ArrayList<Int64>>()
    /**
     * @brief[zh-cn] 格子边长
     *
     * @brief[en] Cell size
     */
    private var _cellSize: Float64
    /**
     * @brief[zh-cn] 格子边长倒数（避免查询时反复做除法）
     *
     * @brief[en] Reciprocal of the cell size (avoids repeated division in queries)
     */
    private var _invCellSize: Float64
    /**
     * @brief[zh-cn] 元素总数
     *
     * @brief[en] Total number of elements
     */
    private var _elementCount: Int64 = 0
    /**
     * @brief[zh-cn] 元素"最近一次命中"的查询戳（用于去重）
     * @explain[zh-cn] 元素按包围球登记到它覆盖的**所有**格子，因此一次查询遍历
     *             多个格子时，同一元素可能被访问多次（半径 0.5、格子 1.0 的元素
     *             会占 8 个格子）。用"查询戳"标记已处理过的元素，保证结果里
     *             每个元素只出现一次。
     *
     * @brief[en] Per-element "last hit" query stamp (used for deduplication)
     * @explain[en] Elements are registered into **every** cell their bounding sphere
     *               covers, so a query visiting several cells may encounter the same
     *               element repeatedly (an element with radius 0.5 in a grid of size
     *               1.0 occupies 8 cells). A query stamp marks already-processed
     *               elements so each element appears only once in the result.
     */
    private var _elemStamp: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 当前查询戳（每次查询自增）
     *
     * @brief[en] Current query stamp (incremented on every query)
     */
    private var _stamp: Int64 = 0

    /**
     * @brief[zh-cn] 构造空间哈希网格
     * @param[zh-cn] cellSize 格子边长（应接近查询半径的量级；<= 0 时按 1.0 处理）
     *
     * @brief[en] Constructs a spatial hash grid
     * @param[en] cellSize Cell edge length (should be on the order of the query radius; <= 0 is treated as 1.0)
     */
    public init(cellSize: Float64) {
        this._cellSize = if (cellSize > 0.0) { cellSize } else { 1.0 }
        this._invCellSize = 1.0 / this._cellSize
    }

    /**
     * @brief[zh-cn] 构造默认格子边长（1.0）的空间哈希网格
     *
     * @brief[en] Constructs a spatial hash grid with the default cell size (1.0)
     */
    public init() {
        this._cellSize = 1.0
        this._invCellSize = 1.0
    }

    /**
     * @brief[zh-cn] 格子边长
     *
     * @brief[en] Cell edge length
     */
    public prop cellSize: Float64 {
        get() { this._cellSize }
    }

    /**
     * @brief[zh-cn] 元素总数
     *
     * @brief[en] Total number of elements
     */
    public prop elementCount: Int64 {
        get() { this._elementCount }
    }

    /**
     * @brief[zh-cn] 非空格子数
     *
     * @brief[en] Number of non-empty cells
     */
    public prop cellCount: Int64 {
        get() { this._cells.size }
    }

    /**
     * @brief[zh-cn] 登记一个元素（按包围球覆盖到的所有格子登记）
     * @explain[zh-cn] 本结构是纯 append 型：元素按 insert 调用顺序占据内部
     *               SoA 槽位 0,1,2...，因此 index 必须等于当前元素总数
     *               （即调用方按 0 起始连续编号）。格子表登记的下标与 SoA
     *               槽位必须一致，故内部统一以槽位号为准。
     * @param[zh-cn] index 元素下标（必须为 0 起始的连续编号，与调用顺序一致）
     * x 中心 X
     * y 中心 Y
     * z 中心 Z
     * radius 包围球半径
     *
     * @brief[en] Registers an element (into every cell overlapped by its bounding sphere)
     * @explain[en] This structure is append-only: elements occupy internal SoA slots
     *               0,1,2... in insert call order, so index must equal the current
     *               element count (caller numbers elements consecutively from 0).
     *               Cell registrations must match the SoA slot, so the slot index
     *               is used internally.
     * @param[en] index Element index (must be consecutive, 0-based, matching call order)
     * x Center X
     * y Center Y
     * z Center Z
     * radius Bounding sphere radius
     */
    public func insert(index: Int64, x: Float64, y: Float64, z: Float64, radius: Float64): Unit {
        let slot = this._elementCount
        this._elemX.add(x)
        this._elemY.add(y)
        this._elemZ.add(z)
        this._elemRadius.add(radius)
        this._elemStamp.add(0)
        this._elementCount += 1

        // 元素可能跨多个格子：逐格登记
        let minIx = this._cellIndexX(x - radius)
        let maxIx = this._cellIndexX(x + radius)
        let minIy = this._cellIndexY(y - radius)
        let maxIy = this._cellIndexY(y + radius)
        let minIz = this._cellIndexZ(z - radius)
        let maxIz = this._cellIndexZ(z + radius)
        for (ix in minIx..maxIx + 1) {
            for (iy in minIy..maxIy + 1) {
                for (iz in minIz..maxIz + 1) {
                    let key = CellKey(ix, iy, iz)
                    if (let Some(list) <- this._cells.get(key)) {
                        list.add(slot)
                    } else {
                        let list = ArrayList<Int64>(4)
                        list.add(slot)
                        this._cells.add(key, list)
                    }
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 球邻域查询
     * @explain[zh-cn] 先按查询球覆盖的格子粗筛，再对候选元素做精确的球-球相交判定。
     * @param[zh-cn] cx 查询球中心 X
     * cy 查询球中心 Y
     * cz 查询球中心 Z
     * radius 查询球半径
     * out 命中元素下标（调用方提供以复用缓冲）
     *
     * @brief[en] Sphere neighborhood query
     * @explain[en] First filters by the cells covered by the query sphere, then performs
     *               an exact sphere-sphere overlap test on the candidates.
     * @param[en] cx Query sphere center X
     * cy Query sphere center Y
     * cz Query sphere center Z
     * radius Query sphere radius
     * out Hit element indices (the caller supplies the buffer so it can be reused)
     */
    public func querySphere(cx: Float64, cy: Float64, cz: Float64, radius: Float64,
                            out: ArrayList<Int64>): Unit {
        // 查询戳自增：本次查询内每个元素只处理一次（元素可能登记在多个格子）
        this._stamp += 1
        let stamp = this._stamp
        let minIx = this._cellIndexX(cx - radius)
        let maxIx = this._cellIndexX(cx + radius)
        let minIy = this._cellIndexY(cy - radius)
        let maxIy = this._cellIndexY(cy + radius)
        let minIz = this._cellIndexZ(cz - radius)
        let maxIz = this._cellIndexZ(cz + radius)
        for (ix in minIx..maxIx + 1) {
            for (iy in minIy..maxIy + 1) {
                for (iz in minIz..maxIz + 1) {
                    let key = CellKey(ix, iy, iz)
                    if (let Some(list) <- this._cells.get(key)) {
                        for (idx in list) {
                            if (this._elemStamp[idx] == stamp) { continue }
                            this._elemStamp[idx] = stamp
                            let dx = this._elemX[idx] - cx
                            let dy = this._elemY[idx] - cy
                            let dz = this._elemZ[idx] - cz
                            let r = this._elemRadius[idx]
                            let sum = r + radius
                            if (dx * dx + dy * dy + dz * dz <= sum * sum) {
                                out.add(idx)
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 轴对齐盒邻域查询
     * @explain[zh-cn] 先按查询盒覆盖的格子粗筛，再对候选元素做精确的球-盒判定。
     * @param[zh-cn] minX 查询盒最小 X
     * minY 查询盒最小 Y
     * minZ 查询盒最小 Z
     * maxX 查询盒最大 X
     * maxY 查询盒最大 Y
     * maxZ 查询盒最大 Z
     * out 命中元素下标
     *
     * @brief[en] Axis-aligned box neighborhood query
     * @explain[en] First filters by the cells covered by the query box, then performs
     *               an exact sphere-box overlap test on the candidates.
     * @param[en] minX Query box min X
     * minY Query box min Y
     * minZ Query box min Z
     * maxX Query box max X
     * maxY Query box max Y
     * maxZ Query box max Z
     * out Hit element indices
     */
    public func queryAabb(minX: Float64, minY: Float64, minZ: Float64,
                           maxX: Float64, maxY: Float64, maxZ: Float64,
                           out: ArrayList<Int64>): Unit {
        // 查询戳自增：本次查询内每个元素只处理一次（元素可能登记在多个格子）
        this._stamp += 1
        let stamp = this._stamp
        let minIx = this._cellIndexX(minX)
        let maxIx = this._cellIndexX(maxX)
        let minIy = this._cellIndexY(minY)
        let maxIy = this._cellIndexY(maxY)
        let minIz = this._cellIndexZ(minZ)
        let maxIz = this._cellIndexZ(maxZ)
        for (ix in minIx..maxIx + 1) {
            for (iy in minIy..maxIy + 1) {
                for (iz in minIz..maxIz + 1) {
                    let key = CellKey(ix, iy, iz)
                    if (let Some(list) <- this._cells.get(key)) {
                        for (idx in list) {
                            if (this._elemStamp[idx] == stamp) { continue }
                            this._elemStamp[idx] = stamp
                            // 球与 AABB 相交：球心到盒的最近点距离 <= 半径
                            let ex = this._elemX[idx]
                            let ey = this._elemY[idx]
                            let ez = this._elemZ[idx]
                            let cx = if (ex < minX) { minX } else if (ex > maxX) { maxX } else { ex }
                            let cy = if (ey < minY) { minY } else if (ey > maxY) { maxY } else { ey }
                            let cz = if (ez < minZ) { minZ } else if (ez > maxZ) { maxZ } else { ez }
                            let dx = ex - cx
                            let dy = ey - cy
                            let dz = ez - cz
                            let r = this._elemRadius[idx]
                            if (dx * dx + dy * dy + dz * dz <= r * r) {
                                out.add(idx)
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 清空网格
     *
     * @brief[en] Clears the grid
     */
    public func clear(): Unit {
        this._elemX.clear()
        this._elemY.clear()
        this._elemZ.clear()
        this._elemRadius.clear()
        this._elemStamp.clear()
        this._cells.clear()
        this._elementCount = 0
    }

    /** 计算 X 方向的格坐标 */
    private func _cellIndexX(x: Float64): Int64 {
        return Int64(floor(x * this._invCellSize))
    }

    /** 计算 Y 方向的格坐标 */
    private func _cellIndexY(y: Float64): Int64 {
        return Int64(floor(y * this._invCellSize))
    }

    /** 计算 Z 方向的格坐标 */
    private func _cellIndexZ(z: Float64): Int64 {
        return Int64(floor(z * this._invCellSize))
    }
}
