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
 * @file[zh-cn] 渲染列表
 * @brief[zh-cn] 渲染列表，收集、排序、输出渲染对象
 * @explain[zh-cn] 
 * RenderList 收集渲染项，三级排序后输出：
 * 1. renderOrder 升序
 * 2. material.id 升序
 * 3. 不透明 z 升序 / 透明 z 降序
 * 不透明对象排在前，透明对象排在后。
 *
 * @file[en] RenderList
 * @brief[en] Render list, collecting, sorting, and outputting render objects
 * @explain[en] 
 * RenderList collects render items, sorts them with three-level sorting, and outputs:
 * 1. renderOrder ascending
 * 2. material.id ascending
 * 3. opaque z ascending / transparent z descending
 * Opaque objects are placed first, transparent objects after.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*
import std.collection.*
import std.sort.*
import three.profiler.*
import three.profiler.macros.*

/**
 * @brief[zh-cn] 渲染列表中的单个渲染项
 * @explain[zh-cn] 
 *
 * @brief[en] A single render item in the render list
 * @explain[en] 
 */
public class RenderItem {
    /**
     * @brief[zh-cn] 唯一 ID（自增，用于稳定排序）
     * @explain[zh-cn] 可写：RenderList 复用渲染项对象（池化）时按帧重新赋值，
     *               避免大场景每帧为每个可见对象分配一个 RenderItem。
     *
     * @brief[en] Unique ID (auto-increment, for stable sorting)
     * @explain[en] Mutable: RenderList reuses pooled render items and reassigns the
     *               id per frame, avoiding one RenderItem allocation per visible
     *               object per frame in large scenes.
     */
    public var id: Int64
    /**
     * @brief[zh-cn] 渲染对象
     *
     * @brief[en] Render object
     */
    public var `object`: Object3D
    /**
     * @brief[zh-cn] 几何体
     *
     * @brief[en] Geometry
     */
    public var geometry: BufferGeometry
    /**
     * @brief[zh-cn] 材质
     *
     * @brief[en] Material
     */
    public var material: Material
    /**
     * @brief[zh-cn] 组顺序
     *
     * @brief[en] Group order
     */
    public var groupOrder: Int64
    /**
     * @brief[zh-cn] 渲染顺序
     *
     * @brief[en] Render order
     */
    public var renderOrder: Int64
    /**
     * @brief[zh-cn] 深度值（相机空间 z）
     *
     * @brief[en] Depth value (camera space z)
     */
    public var z: Float64
    /**
     * @brief[zh-cn] 组索引
     *
     * @brief[en] Group index
     */
    public var group: Int64

    /**
     * @brief[zh-cn] 本帧是否已被聚合路由取代（自动实例化移除标记）
     * @explain[zh-cn] 供批量移除使用：先置标记，再由 removeOpaqueMarked 单遍压缩，
     * 避免逐项 removeOpaqueItem 的 O(n) 线性扫描（合批 800 成员时退化为 O(n²)）。
     * RenderItem 每帧由 push 重建，标记无需跨帧清理。
     *
     * @brief[en] Whether this item was superseded by aggregate routing this frame (batch-removal flag)
     * @explain[en] Used by batch removal: mark first, then compact in a single pass via removeOpaqueMarked,
     * avoiding the O(n) linear scan of per-item removeOpaqueItem (degrading to O(n^2) when batching 800 members).
     * RenderItem is rebuilt by push every frame, so the flag needs no cross-frame cleanup.
     */
    public var routeSuppressed: Bool = false

    public init(id: Int64, object: Object3D, geometry: BufferGeometry, material: Material,
                groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64) {
        this.id = id
        this.object = object
        this.geometry = geometry
        this.material = material
        this.groupOrder = groupOrder
        this.renderOrder = renderOrder
        this.z = z
        this.group = group
    }

    /**
     * @brief[zh-cn] 复用渲染项：按新帧数据重置各字段（池化路径）
     * @explain[zh-cn] 供 RenderList 的渲染项池调用——大场景每帧为每个可见对象
     *               新建 RenderItem 会产生大量短命对象（800 对象 × 600 帧 = 48 万次
     *               堆分配 + GC 压力），改为复用同一批对象，仅重置字段。
     *
     * @brief[en] Reuses this render item: resets its fields for the new frame (pooling path)
     * @explain[en] Used by RenderList's render-item pool — allocating one RenderItem
     *               per visible object per frame creates hundreds of thousands of
     *               short-lived objects in large scenes; reuse them instead.
     */
    public func reset(id: Int64, object: Object3D, geometry: BufferGeometry, material: Material,
                      groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64): Unit {
        this.id = id
        this.object = object
        this.geometry = geometry
        this.material = material
        this.groupOrder = groupOrder
        this.renderOrder = renderOrder
        this.z = z
        this.group = group
        this.routeSuppressed = false
    }
}

/**
 * @brief[zh-cn] 渲染列表
 * @explain[zh-cn] 
 * 收集渲染项，三级排序后输出：
 * 1. renderOrder 升序
 * 2. material.id 升序
 * 3. 不透明 z 升序 / 透明 z 降序
 *
 * @brief[en] Render list
 * @explain[en] 
 * Collects render items, sorts them with three-level sorting, and outputs:
 * 1. renderOrder ascending
 * 2. material.id ascending
 * 3. opaque z ascending / transparent z descending
 */
public open class RenderList {
    /**
     * @brief[zh-cn] 不透明渲染项列表
     * @explain[zh-cn] 预分配容量：收集阶段每帧可能 push 数百个成员再聚合为少数 DrawCall，
     * 避免从默认容量 16 反复扩容重分配（初始值按常见大合批场景估算，溢出仍会自动扩容）。
     *
     * @brief[en] Opaque render item list
     * @explain[en] Pre-allocated capacity: the collection phase may push hundreds of members per frame
     * before aggregation collapses them into a few draw calls, avoiding repeated grow-and-realloc
     * from the default capacity of 16 (initial value sized for common large-batch scenes; overflow still grows).
     */
    private var opaque: ArrayList<RenderItem> = ArrayList<RenderItem>(1024)
    /**
     * @brief[zh-cn] 透明渲染项列表
     *
     * @brief[en] Transparent render item list
     */
    private var transparent: ArrayList<RenderItem> = ArrayList<RenderItem>(64)
    /**
     * @brief[zh-cn] 合并后的输出列表（sort+finish 写入）
     *
     * @brief[en] Merged output list (written by sort+finish)
     */
    private var renderItems: ArrayList<RenderItem> = ArrayList<RenderItem>(1024)
    /**
     * @brief[zh-cn] 自增 ID 计数器
     *
     * @brief[en] Auto-increment ID counter
     */
    private var _nextId: Int64 = 0
    /**
     * @brief[zh-cn] 渲染项对象池（复用 RenderItem，避免每帧每对象一次堆分配）
     * @explain[zh-cn] 池中对象按 push 顺序复用：_itemPoolCursor 之前的已在本帧使用，
     *               超出池容量时新建并追加。clear() 时游标归零，池内对象留待下一帧复用。
     *
     * @brief[en] Render-item pool (reuses RenderItem objects to avoid one allocation
     *            per object per frame)
     * @explain[en] Pooled objects are reused in push order: entries before
     *            _itemPoolCursor are already used this frame; new ones are appended
     *            when the pool grows. clear() rewinds the cursor, keeping the pool for
     *            the next frame.
     */
    private var _itemPool: ArrayList<RenderItem> = ArrayList<RenderItem>(1024)
    /**
     * @brief[zh-cn] 渲染项池游标（下一待复用位置）
     *
     * @brief[en] Render-item pool cursor (next slot to reuse)
     */
    private var _itemPoolCursor: Int64 = 0

    /**
     * @brief[zh-cn] 构造默认渲染列表
     *
     * @brief[en] Constructs a default render list
     */
    public init() {}

    /**
     * @brief[zh-cn] 添加渲染对象
     * @explain[zh-cn] 
     * 根据材质的 transparent 属性分别加入 opaque/transparent 列表。
     * @param[zh-cn] object 渲染对象
     * geometry 几何体
     * material 材质
     * groupOrder 组顺序
     * renderOrder 渲染顺序
     * z 深度值
     * group 组索引
     *
     * @brief[en] Adds a render object
     * @explain[en] 
     * Adds to the opaque/transparent list based on the material's transparent property.
     * @param[en] object Render object
     * geometry Geometry
     * material Material
     * groupOrder Group order
     * renderOrder Render order
     * z Depth value
     * group Group index
     */
    public func push(object: Object3D, geometry: BufferGeometry, material: Material,
                     groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64): Unit {
        this._nextId += 1
        // 池化复用：优先取用池中已存在的渲染项（仅重置字段），池满时再新建。
        let item = if (this._itemPoolCursor < this._itemPool.size) {
            let pooled = this._itemPool[this._itemPoolCursor]
            this._itemPoolCursor += 1
            pooled.reset(this._nextId, object, geometry, material,
                         groupOrder, renderOrder, z, group)
            pooled
        } else {
            let created = RenderItem(this._nextId, object, geometry, material,
                                     groupOrder, renderOrder, z, group)
            this._itemPool.add(created)
            this._itemPoolCursor += 1
            created
        }
        if (material.transparent) {
            this.transparent.add(item)
        } else {
            this.opaque.add(item)
        }
    }

    /**
     * @brief[zh-cn] 三级排序
     * @explain[zh-cn] 
     * 不透明：groupOrder↑ → renderOrder↑ → z↑ → id↑（painterSortStable）
     * 透明：groupOrder↑ → renderOrder↑ → z↓ → id↑（reversePainterSortStable）
     *
     * @brief[en] Three-level sorting
     * @explain[en] 
     * Opaque: groupOrder↑ → renderOrder↑ → z↑ → id↑ (painterSortStable)
     * Transparent: groupOrder↑ → renderOrder↑ → z↓ → id↑ (reversePainterSortStable)
     */
    @Zone[three.rendering.common.RenderList.sort]
    public func sort(): Unit {
        // 快路径：少于 2 项无需排序，避免每帧无谓的 sort 调用开销
        if (this.opaque.size > 1) {
            // 不透明排序（painterSortStable）
            sort(this.opaque, by: { a, b =>
                if (a.groupOrder != b.groupOrder) {
                    a.groupOrder.compare(b.groupOrder)
                } else if (a.renderOrder != b.renderOrder) {
                    a.renderOrder.compare(b.renderOrder)
                } else if (a.z != b.z) {
                    a.z.compare(b.z)
                } else {
                    a.id.compare(b.id)
                }
            })
        }

        // 透明排序（reversePainterSortStable）
        if (this.transparent.size > 1) {
            sort(this.transparent, by: { a, b =>
                if (a.groupOrder != b.groupOrder) {
                    a.groupOrder.compare(b.groupOrder)
                } else if (a.renderOrder != b.renderOrder) {
                    a.renderOrder.compare(b.renderOrder)
                } else if (a.z != b.z) {
                    b.z.compare(a.z)  // 降序：远处的先画
                } else {
                    a.id.compare(b.id)
                }
            })
        }
    }

    /**
     * @brief[zh-cn] 完成收集，返回排序后的渲染项列表
     * @explain[zh-cn] 
     * 调用 sort() 后合并 opaque + transparent 列表。
     * @return[zh-cn] 排序后的渲染项列表
     *
     * @brief[en] Finishes collection, returns sorted render item list
     * @explain[en] 
     * Calls sort() then merges opaque + transparent lists.
     * @return[en] Sorted render item list
     */
    @Zone[three.rendering.common.RenderList.finish]
    public func finish(): ArrayList<RenderItem> {
        this.sort()
        this.renderItems.clear()
        // 不透明在前，透明在后
        for (item in this.opaque) {
            this.renderItems.add(item)
        }
        for (item in this.transparent) {
            this.renderItems.add(item)
        }
        return this.renderItems
    }

    /**
     * @brief[zh-cn] 清空渲染列表
     *
     * @brief[en] Clears the render list
     */
    public func clear(): Unit {
        this.opaque.clear()
        this.transparent.clear()
        this.renderItems.clear()
        // 渲染项池游标归零：池内对象留待下一帧复用（不释放，避免每帧重新分配）
        this._itemPoolCursor = 0
    }

    /**
     * @brief[zh-cn] 获取不透明渲染项列表（内部引用，供合批路由就地修改）
     * @explain[zh-cn] 返回内部 opaque 列表引用（非拷贝），调用方修改会直接影响本帧渲染列表。自动实例化路由用：移除成员项、push 聚合项。
     *
     * @brief[en] Get the opaque render item list (internal reference, for batching route in-place modification)
     * @explain[en] Returns the internal opaque list reference (not a copy); caller modifications directly affect the current frame's render list. Used by auto-instancing route: remove member items and push aggregate items.
     */
    public func getOpaqueItems(): ArrayList<RenderItem> {
        return this.opaque
    }

    /**
     * @brief[zh-cn] 按引用移除一个不透明渲染项
     * @explain[zh-cn] 自动实例化路由用：成员网格被聚合为 InstancedMesh 后，从本帧不透明列表移除其原渲染项，避免重复绘制。
     *
     * @brief[en] Remove an opaque render item by reference
     * @explain[en] Used by auto-instancing route: after member meshes are aggregated into an InstancedMesh, remove their original render items from this frame's opaque list to avoid duplicate drawing.
     */
    public func removeOpaqueItem(item: RenderItem): Unit {
        for (i in 0..this.opaque.size) {
            if (refEq(this.opaque[i], item)) {
                this.opaque.remove(i..i + 1)
                return
            }
        }
    }

    /**
     * @brief[zh-cn] 批量移除所有带 routeSuppressed 标记的不透明渲染项
     * @explain[zh-cn] 就地压缩：把未标记项前移，保持原有相对顺序（不透明列表尚未排序，
     * 顺序即收集顺序），末尾多余位置截断。单遍 O(n)，替代逐项 removeOpaqueItem 的 O(n²)。
     *
     * @brief[en] Batch-remove all opaque render items flagged with routeSuppressed
     * @explain[en] Compacts in place: moves unflagged items forward preserving their relative order
     * (the opaque list is not yet sorted at this point, so order equals collection order), then truncates the tail.
     * Single-pass O(n), replacing per-item removeOpaqueItem's O(n^2).
     */
    public func removeOpaqueMarked(): Unit {
        let list = this.opaque
        var write = 0
        let n = list.size
        for (read in 0..n) {
            let it = list[read]
            if (!it.routeSuppressed) {
                if (write != read) {
                    list[write] = it
                }
                write += 1
            }
        }
        while (list.size > write) {
            let last = list.size - 1
            list.remove(last..last + 1)
        }
    }
}
