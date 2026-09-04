/**
 * @file[zh-cn] 几何体管理
 * @brief[zh-cn] 几何体后端数据管理器，管理 BufferGeometry 与后端缓冲区的映射
 * @explain[zh-cn] 
 * Geometries 继承自 DataMap，负责将 BufferGeometry 与后端 GPU 缓冲区关联，
 * 提供 get/update/destroy 生命周期方法。子类（如 BgfxGeometries）实现具体 GPU 端操作。
 *
 * @file[en] Geometries
 * @brief[en] Geometry backend data manager, managing the mapping between BufferGeometry and backend buffers
 * @explain[en] 
 * Geometries extends DataMap and is responsible for associating BufferGeometry with backend GPU buffers,
 * providing get/update/destroy lifecycle methods. Subclasses (e.g., BgfxGeometries) implement specific GPU-side operations.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import std.collection.*

/**
 * @brief[zh-cn] 几何体后端数据管理器
 * @explain[zh-cn] 
 * 继承 DataMap，将 BufferGeometry 与后端 GPU 缓冲区关联，
 * 提供 get/update/destroy 生命周期方法。
 *
 * @brief[en] Geometry backend data manager
 * @explain[en] 
 * Extends DataMap, associating BufferGeometry with backend GPU buffers,
 * providing get/update/destroy lifecycle methods.
 */
public open class Geometries <: DataMap {
    /**
     * @brief[zh-cn] 后端引用
     *
     * @brief[en] Reference to the backend
     */
    public var backend: Backend

    /**
     * @brief[zh-cn] 构造几何体管理器
     * @param[zh-cn] backend 渲染后端实例
     *
     * @brief[en] Constructs a geometries manager
     * @param[en] backend Rendering backend instance
     */
    public init(backend: Backend) {
        super()
        this.backend = backend
    }

    /**
     * @brief[zh-cn] 获取几何体对应的后端句柄
     * @param[zh-cn] geometry 几何体
     * @return[zh-cn] 后端句柄
     *
     * @brief[en] Gets the backend handle for the given geometry
     * @param[en] geometry Geometry
     * @return[en] Backend handle
     */
    public func get(geometry: BufferGeometry): Int64 { return 0 }

    /**
     * @brief[zh-cn] 更新几何体缓冲区数据
     * @param[zh-cn] geometry 几何体
     *
     * @brief[en] Updates the geometry buffer data
     * @param[en] geometry Geometry
     */
    public func update(geometry: BufferGeometry): Unit { }

    /**
     * @brief[zh-cn] 根据渲染对象更新几何体缓冲区
     * @param[zh-cn] renderObject 渲染对象
     *
     * @brief[en] Updates the geometry buffer based on the render object
     * @param[en] renderObject Render object
     */
    public func updateForRender(renderObject: RenderObject): Unit { this.update(renderObject.geometry) }

    /**
     * @brief[zh-cn] 销毁几何体对应的后端资源
     * @param[zh-cn] geometry 几何体
     *
     * @brief[en] Destroys the backend resources for the given geometry
     * @param[en] geometry Geometry
     */
    public func destroy(geometry: BufferGeometry): Unit { }
}
