/**
 * @file[zh-cn] 渲染列表
 * @brief[zh-cn] 渲染列表，收集、排序、输出渲染对象
 * @explain[zh-cn] 
 * RenderList 收集渲染项，三级排序后输出：
 * 1. renderOrder 升序
 * 2. material.id 升序
 * 3. 不透明 z 升序 / 透明 z 降序
 * 不透明对象排在前，透明对象排在后。
 * 对照源码: three.js/src/renderers/common/RenderList.js (475 行)
 *
 * @file[en] RenderList
 * @brief[en] Render list, collecting, sorting, and outputting render objects
 * @explain[en] 
 * RenderList collects render items, sorts them with three-level sorting, and outputs:
 * 1. renderOrder ascending
 * 2. material.id ascending
 * 3. opaque z ascending / transparent z descending
 * Opaque objects are placed first, transparent objects after.
 * Corresponding source: three.js/src/renderers/common/RenderList.js (475 lines)
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
     *
     * @brief[en] Unique ID (auto-increment, for stable sorting)
     */
    public let id: Int64
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
     */
    private var opaque: ArrayList<RenderItem> = ArrayList<RenderItem>()
    /**
     * @brief[zh-cn] 透明渲染项列表
     */
    private var transparent: ArrayList<RenderItem> = ArrayList<RenderItem>()
    /**
     * @brief[zh-cn] 合并后的输出列表（sort+finish 写入）
     */
    private var renderItems: ArrayList<RenderItem> = ArrayList<RenderItem>()
    /**
     * @brief[zh-cn] 自增 ID 计数器
     */
    private var _nextId: Int64 = 0

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
        let item = RenderItem(this._nextId, object, geometry, material,
                             groupOrder, renderOrder, z, group)
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
    public func sort(): Unit {
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

        // 透明排序（reversePainterSortStable）
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
    }
}
