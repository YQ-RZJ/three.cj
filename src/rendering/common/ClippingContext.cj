/**
 * @file[zh-cn] 裁剪上下文
 * @brief[zh-cn] 裁剪平面上下文，管理局部裁剪平面集合
 * @explain[zh-cn] 
 * ClippingContext 管理场景中的裁剪平面，用于在着色器中执行用户定义的裁剪操作。
 * 当 localClippingEnabled 为 true 时，planes 中的平面会被传递到着色器进行裁剪。
 *
 * @file[en] ClippingContext
 * @brief[en] Clipping plane context, managing a collection of local clipping planes
 * @explain[en] 
 * ClippingContext manages clipping planes in the scene, used to perform user-defined clipping operations in shaders.
 * When localClippingEnabled is true, the planes are passed to the shader for clipping.
 */
package three.rendering.common

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 裁剪平面上下文，管理局部裁剪平面集合
 * @explain[zh-cn] 
 * 管理场景中的裁剪平面，用于着色器中执行用户定义的裁剪操作。
 *
 * @brief[en] Clipping plane context, managing a collection of local clipping planes
 * @explain[en] 
 * Manages clipping planes in the scene for user-defined clipping operations in shaders.
 */
public open class ClippingContext {
    /**
     * @brief[zh-cn] 是否启用局部裁剪
     *
     * @brief[en] Whether local clipping is enabled
     */
    public var localClippingEnabled: Bool

    /**
     * @brief[zh-cn] 裁剪平面列表
     *
     * @brief[en] List of clipping planes
     */
    public var planes: ArrayList<Plane>

    /**
     * @brief[zh-cn] 构造默认裁剪上下文
     *
     * @brief[en] Constructs a default clipping context
     */
    public init() { this.localClippingEnabled = false; this.planes = ArrayList<Plane>() }

    /**
     * @brief[zh-cn] 添加裁剪平面
     * @param[zh-cn] plane 裁剪平面
     *
     * @brief[en] Adds a clipping plane
     * @param[en] plane Clipping plane
     */
    public func addPlane(plane: Plane): Unit { this.planes.add(plane) }

    /**
     * @brief[zh-cn] 计算平面交集（占位方法）
     *
     * @brief[en] Computes plane intersections (placeholder method)
     */
    public func intersectPlanes(): Unit { }
}
