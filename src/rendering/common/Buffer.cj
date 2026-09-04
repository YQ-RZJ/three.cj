/**
 * @file[zh-cn] 缓冲区
 * @brief[zh-cn] GPU 缓冲区管理类，继承 Binding 提供顶点/索引缓冲区操作
 * @explain[zh-cn] 
 * Buffer 继承自 Binding，用于管理 GPU 侧的顶点缓冲区和索引缓冲区。
 * 提供创建、更新和销毁缓冲区的接口，子类（如 BgfxBackend）实现具体 GPU 操作。
 *
 * @file[en] Buffer
 * @brief[en] GPU buffer management class, extending Binding to provide vertex/index buffer operations
 * @explain[en] 
 * Buffer extends Binding and is used to manage GPU-side vertex buffers and index buffers.
 * Provides interfaces for creating, updating, and destroying buffers; subclasses (e.g., BgfxBackend) implement specific GPU operations.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] GPU 缓冲区管理类
 * @explain[zh-cn] 
 * 继承 Binding，提供顶点缓冲区和索引缓冲区的创建、更新和销毁接口。
 *
 * @brief[en] GPU buffer management class
 * @explain[en] 
 * Extends Binding, providing interfaces for creating, updating, and destroying vertex and index buffers.
 */
public open class Buffer <: Binding {
    /**
     * @brief[zh-cn] 后端引用
     *
     * @brief[en] Reference to the backend
     */
    public var backend: Backend

    /**
     * @brief[zh-cn] 构造缓冲区，关联到指定后端
     * @param[zh-cn] backend 渲染后端实例
     *
     * @brief[en] Constructs a buffer associated with the specified backend
     * @param[en] backend Rendering backend instance
     */
    public init(backend: Backend) {
        super("buffer", 0, "buffer")
        this.backend = backend
    }

    /**
     * @brief[zh-cn] 创建顶点缓冲区
     * @param[zh-cn] data 顶点数据数组
     * size 数据大小
     * @return[zh-cn] 缓冲区句柄
     *
     * @brief[en] Creates a vertex buffer
     * @param[en] data Vertex data array
     * size Data size
     * @return[en] Buffer handle
     */
    public func createVertexBuffer(data: Array<Float32>, size: Int64): Int64 { return 0 }

    /**
     * @brief[zh-cn] 创建索引缓冲区
     * @param[zh-cn] data 索引数据数组
     * size 数据大小
     * @return[zh-cn] 缓冲区句柄
     *
     * @brief[en] Creates an index buffer
     * @param[en] data Index data array
     * size Data size
     * @return[en] Buffer handle
     */
    public func createIndexBuffer(data: Array<UInt32>, size: Int64): Int64 { return 0 }

    /**
     * @brief[zh-cn] 更新缓冲区数据
     * @param[zh-cn] handle 缓冲区句柄
     * data 更新数据
     *
     * @brief[en] Updates buffer data
     * @param[en] handle Buffer handle
     * data Update data
     */
    public func updateBuffer(handle: Int64, data: Array<Float32>): Unit { }

    /**
     * @brief[zh-cn] 销毁缓冲区
     * @param[zh-cn] handle 缓冲区句柄
     *
     * @brief[en] Destroys a buffer
     * @param[en] handle Buffer handle
     */
    public func destroyBuffer(handle: Int64): Unit { }
}
