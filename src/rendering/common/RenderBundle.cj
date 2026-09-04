/**
 * @file[zh-cn] 渲染束
 * @brief[zh-cn] 渲染束，包含一组渲染对象的集合
 * @explain[zh-cn] 
 * RenderBundle 将多个 RenderObject 组合为一个渲染束，用于批量提交渲染命令，
 * 提高渲染性能。对应 Three.js 中的 BundleGroup 渲染束概念。
 *
 * @file[en] RenderBundle
 * @brief[en] Render bundle, containing a collection of render objects
 * @explain[en] 
 * RenderBundle combines multiple RenderObjects into a render bundle for batch submission of render commands,
 * improving rendering performance. Corresponds to the BundleGroup render bundle concept in Three.js.
 */
package three.rendering.common

import std.collection.*

/**
 * @brief[zh-cn] 渲染束，包含一组渲染对象的集合
 * @explain[zh-cn] 
 * 将多个 RenderObject 组合为一个渲染束，用于批量提交。
 *
 * @brief[en] Render bundle, containing a collection of render objects
 * @explain[en] 
 * Combines multiple RenderObjects into a render bundle for batch submission.
 */
public open class RenderBundle {
    /**
     * @brief[zh-cn] 渲染束标识符
     *
     * @brief[en] Render bundle identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 渲染对象列表
     *
     * @brief[en] List of render objects
     */
    public var objects: ArrayList<RenderObject>

    /**
     * @brief[zh-cn] 构造默认渲染束
     *
     * @brief[en] Constructs a default render bundle
     */
    public init() { this.id = 0; this.objects = ArrayList<RenderObject>() }

    /**
     * @brief[zh-cn] 添加渲染对象到渲染束
     * @param[zh-cn] obj 渲染对象
     *
     * @brief[en] Adds a render object to the render bundle
     * @param[en] obj Render object
     */
    public func add(obj: RenderObject): Unit { this.objects.add(obj) }

    /**
     * @brief[zh-cn] 清空渲染对象列表
     *
     * @brief[en] Clears the render object list
     */
    public func clear(): Unit { this.objects = ArrayList<RenderObject>() }
}
