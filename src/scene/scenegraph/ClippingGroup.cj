/**
 * @file[zh-cn] ClippingGroup
 * @brief[zh-cn] 裁剪组，管理一组用于视锥体裁剪的子对象
 * @explain[zh-cn] 与 Group 类似但语义不同：子对象作为裁剪平面参与渲染，而非普通可见几何。
 * 仅 WebGPURenderer 使用；bgfx4cj 后端下保留接口签名以对齐 JS side，实际裁剪由渲染器内部处理。
 *
 * @file[en] ClippingGroup
 * @brief[en] Clipping group, managing a set of sub-objects for frustum clipping
 * @explain[en] Similar to Group but semantically different: sub-objects participate in rendering as clipping planes, not ordinary visible geometry.
 * Only used by WebGPURenderer; bgfx4cj backend retains interface signature to align with JS side, actual clipping handled by renderer internally.
 */
package three.scene.scenegraph
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 裁剪组，管理一组用于视锥体裁剪的子对象
 * @explain[zh-cn] 子对象作为裁剪平面参与渲染，而非普通可见几何
 *
 * @brief[en] Clipping group, managing a set of sub-objects for frustum clipping
 * @explain[en] Sub-objects participate in rendering as clipping planes, not ordinary visible geometry
 */
public class ClippingGroup <: Object3D {

    /**
     * @brief[zh-cn] 裁剪平面数组，每个子对象视为一个裁剪平面
     *
     * @brief[en] Clipping planes array, each sub-object treated as a clipping plane
     */
    public var clippingPlanes: ArrayList<Plane>

    /**
     * @brief[zh-cn] 是否启用裁剪
     *
     * @brief[en] Whether clipping is enabled
     */
    public var enabled: Bool

    /**
     * @brief[zh-cn] 是否反转裁剪（保留平面外、裁掉平面内）
     *
     * @brief[en] Whether to invert clipping (keep outside planes, clip inside)
     */
    public var clipIntersection: Bool

    /**
     * @brief[zh-cn] 是否在阴影渲染时应用裁剪（仅主渲染裁剪）
     *
     * @brief[en] Whether to apply clipping during shadow rendering (main render clipping only)
     */
    public var clipShadows: Bool

    /**
     * @brief[zh-cn] 构造一个新的裁剪组
     *
     * @brief[en] Construct a new clipping group
     */
    public init() {
        super()
        this.kind = "ClippingGroup"
        this.clippingPlanes = ArrayList<Plane>()
        this.enabled = true
        this.clipIntersection = false
        this.clipShadows = false
    }

    /**
     * @brief[zh-cn] 添加一个子对象（视作裁剪平面）
     * @param[zh-cn] object 子对象
     *
     * @brief[en] Add a sub-object (treated as a clipping plane)
     * @param[en] object Sub-object
     */
    public func addObject(object: Object3D): Unit {
        this.children.add(object)
    }

    /**
     * @brief[zh-cn] 移除一个子对象
     * @param[zh-cn] object 要移除的子对象
     *
     * @brief[en] Remove a sub-object
     * @param[en] object Sub-object to remove
     */
    public func removeObject(object: Object3D): Unit {
        var i = 0
        while (i < this.children.size) {
            if (this.children[i].uuid == object.uuid) {
                this.children.remove(i..i + 1)
                break
            }
            i += 1
        }
    }

    /**
     * @brief[zh-cn] 将给定裁剪组实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given clipping group instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case c: ClippingGroup =>
                this.enabled = c.enabled
                this.clipIntersection = c.clipIntersection
                this.clipShadows = c.clipShadows
                // 浅克隆裁剪平面（Plane 是值类型）
                this.clippingPlanes.clear()
                for (p in c.clippingPlanes) {
                    this.clippingPlanes.add(Plane().copy(p))
                }
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新裁剪组实例
     * @return[zh-cn] 新裁剪组实例
     *
     * @brief[en] Return a new clipping group instance with the same values as this instance
     * @return[en] New clipping group instance
     */
    public override func clone(): Object3D {
        let obj = ClippingGroup()
        return obj.copy(this, true)
    }
}
