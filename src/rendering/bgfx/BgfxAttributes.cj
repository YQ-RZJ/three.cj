/**
 * @file[zh-cn] bgfx 顶点属性缓冲管理
 * @brief[zh-cn] 替代 WebGLAttributes，使用 bgfx VertexBufferHandle/IndexBufferHandle 管理顶点缓冲
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLAttributes.js。在 WebGL 中通过 gl.createBuffer/gl.bufferData 管理缓冲，在 bgfx 中通过 bgfx_create_vertex_buffer_cj/bgfx_create_index_buffer_cj 管理。
 *
 * @file[en] bgfx Vertex Attribute Buffer Management
 * @brief[en] Replace WebGLAttributes, manage vertex buffers using bgfx VertexBufferHandle/IndexBufferHandle
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLAttributes.js. In WebGL, buffers are managed via gl.createBuffer/gl.bufferData; in bgfx, via bgfx_create_vertex_buffer_cj/bgfx_create_index_buffer_cj.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] 顶点缓冲信息
 * @explain[zh-cn] 对照 WebGLAttributes 中 createBuffer 返回的数据结构，存储 bgfx 顶点缓冲句柄及元数据。
 *
 * @brief[en] Vertex buffer info
 * @explain[en] Mirrors the data structure returned by createBuffer in WebGLAttributes, storing bgfx vertex buffer handle and metadata.
 */
public class VertexBufferInfo {
    /**
     * @brief[zh-cn] bgfx 顶点缓冲句柄
     *
     * @brief[en] bgfx vertex buffer handle
     */
    public var handle: VertexBufferHandle = VertexBufferHandle()
    /**
     * @brief[zh-cn] 数据类型大小（字节）
     *
     * @brief[en] Data type size in bytes
     */
    public var bytesPerElement: Int64 = 0
    /**
     * @brief[zh-cn] 版本号（用于检测更新）
     *
     * @brief[en] Version number (for update detection)
     */
    public var version: Int64 = 0
    /**
     * @brief[zh-cn] 缓冲大小（字节）
     *
     * @brief[en] Buffer size in bytes
     */
    public var size: Int64 = 0
    /**
     * @brief[zh-cn] 是否动态缓冲
     *
     * @brief[en] Whether the buffer is dynamic
     */
    public var dynamic: Bool = false

    public init() {}
}

/**
 * @brief[zh-cn] 索引缓冲信息
 * @explain[zh-cn] 存储 bgfx 索引缓冲句柄及元数据。
 *
 * @brief[en] Index buffer info
 * @explain[en] Stores bgfx index buffer handle and metadata.
 */
public class IndexBufferInfo {
    /**
     * @brief[zh-cn] bgfx 索引缓冲句柄
     *
     * @brief[en] bgfx index buffer handle
     */
    public var handle: IndexBufferHandle = IndexBufferHandle()
    /**
     * @brief[zh-cn] 数据类型大小（字节）
     *
     * @brief[en] Data type size in bytes
     */
    public var bytesPerElement: Int64 = 2
    /**
     * @brief[zh-cn] 版本号
     *
     * @brief[en] Version number
     */
    public var version: Int64 = 0
    /**
     * @brief[zh-cn] 缓冲大小（字节）
     *
     * @brief[en] Buffer size in bytes
     */
    public var size: Int64 = 0

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 顶点属性缓冲管理
 * @explain[zh-cn] 对照 WebGLAttributes，管理顶点缓冲和索引缓冲的创建、更新和销毁。使用 HashMap 替代 WeakMap 存储属性到缓冲的映射。
 *
 * @brief[en] bgfx vertex attribute buffer management
 * @explain[en] Mirrors WebGLAttributes, managing creation, update, and destruction of vertex and index buffers. Uses HashMap instead of WeakMap for attribute-to-buffer mapping.
 */
public class BgfxAttributes {
    /**
     * @brief[zh-cn] 顶点缓冲映射（属性 ID -> 缓冲信息）
     */
    private var vertexBuffers: HashMap<Int64, VertexBufferInfo>
    /**
     * @brief[zh-cn] 索引缓冲映射（属性 ID -> 缓冲信息）
     */
    private var indexBuffers: HashMap<Int64, IndexBufferInfo>
    /**
     * @brief[zh-cn] 渲染统计
     */
    private var info: BgfxInfo
    /**
     * @brief[zh-cn] 顶点布局句柄 → 内存指针注册表（createVertexLayout 时登记，updateVertexBuffer 查表取指针）
     */
    private var layoutPtrs: HashMap<UInt16, AutoFreePtr<VertexLayout>>

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.vertexBuffers = HashMap<Int64, VertexBufferInfo>()
        this.indexBuffers = HashMap<Int64, IndexBufferInfo>()
        this.layoutPtrs = HashMap<UInt16, AutoFreePtr<VertexLayout>>()
        this.info = info
    }

    /**
     * @brief[zh-cn] 创建顶点布局并登记内存指针
     * @explain[zh-cn] 供 updateVertexBuffer 查表取 CPointer<VertexLayout>。对照 BgfxRenderer.createVertexLayout。
     * @param[zh-cn] attributes 属性描述列表（BgfxAttributeDesc）
     * @return[zh-cn] 顶点布局句柄（无效则 idx=0xFFFF）
     *
     * @brief[en] Create vertex layout and register memory pointer
     * @explain[en] For updateVertexBuffer to look up CPointer<VertexLayout>. Mirrors BgfxRenderer.createVertexLayout.
     * @param[en] attributes Attribute descriptor list (BgfxAttributeDesc)
     * @return[en] Vertex layout handle (invalid if idx=0xFFFF)
     */
    public func createVertexLayout(attributes: Array<BgfxAttributeDesc>): VertexLayoutHandle {
        let layoutHolder = AutoFreePtr<VertexLayout>(unsafe { LibC.malloc<VertexLayout>() })
        let layout = layoutHolder.get()
        bgfx_vertex_layout_begin_cj(layout, RendererType.Noop.value())
        for (attr in attributes) {
            bgfx_vertex_layout_add_cj(layout, attr.attrib, attr.num, attr.attribType, attr.normalized, attr.asInt)
        }
        bgfx_vertex_layout_end_cj(layout)
        let handle = bgfx_create_vertex_layout_cj(layout)
        this.layoutPtrs.add(handle.idx, layoutHolder)
        return handle
    }

    /**
     * @brief[zh-cn] 销毁顶点布局并释放登记的内存指针
     * @explain[zh-cn] 对照 BgfxRenderer.destroyVertexLayout
     * @param[zh-cn] layout 待销毁的顶点布局句柄
     *
     * @brief[en] Destroy vertex layout and release registered memory pointer
     * @explain[en] Mirrors BgfxRenderer.destroyVertexLayout
     * @param[en] layout Vertex layout handle to destroy
     */
    public func destroyVertexLayout(layout: VertexLayoutHandle): Unit {
        bgfx_destroy_vertex_layout_cj(layout)
        match (this.layoutPtrs.get(layout.idx)) {
            case Some(holder) => holder.dispose()
            case None => ()
        }
        this.layoutPtrs.remove(layout.idx)
    }

    /**
     * @brief[zh-cn] 获取顶点缓冲信息
     * @explain[zh-cn] 对照 WebGLAttributes.get()
     * @param[zh-cn] attributeId 属性对象 ID
     * @return[zh-cn] 顶点缓冲信息，未找到返回 None
     *
     * @brief[en] Get vertex buffer info
     * @explain[en] Mirrors WebGLAttributes.get()
     * @param[en] attributeId Attribute object ID
     * @return[en] Vertex buffer info, or None if not found
     */
    public func getVertexBuffer(attributeId: Int64): Option<VertexBufferInfo> {
        return vertexBuffers.get(attributeId)
    }

    /**
     * @brief[zh-cn] 获取索引缓冲信息
     * @param[zh-cn] attributeId 属性对象 ID
     * @return[zh-cn] 索引缓冲信息，未找到返回 None
     *
     * @brief[en] Get index buffer info
     * @param[en] attributeId Attribute object ID
     * @return[en] Index buffer info, or None if not found
     */
    public func getIndexBuffer(attributeId: Int64): Option<IndexBufferInfo> {
        return indexBuffers.get(attributeId)
    }

    /**
     * @brief[zh-cn] 移除顶点缓冲
     * @explain[zh-cn] 对照 WebGLAttributes.remove()
     * @param[zh-cn] attributeId 属性对象 ID
     *
     * @brief[en] Remove vertex buffer
     * @explain[en] Mirrors WebGLAttributes.remove()
     * @param[en] attributeId Attribute object ID
     */
    public func removeVertexBuffer(attributeId: Int64): Unit {
        match (vertexBuffers.get(attributeId)) {
            case Some(data) =>
                if (data.handle.idx != 0xFFFFu16) {
                    bgfx_destroy_vertex_buffer_cj(data.handle)
                }
                vertexBuffers.remove(attributeId)
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 移除索引缓冲
     * @param[zh-cn] attributeId 属性对象 ID
     *
     * @brief[en] Remove index buffer
     * @param[en] attributeId Attribute object ID
     */
    public func removeIndexBuffer(attributeId: Int64): Unit {
        match (indexBuffers.get(attributeId)) {
            case Some(data) =>
                if (data.handle.idx != 0xFFFFu16) {
                    bgfx_destroy_index_buffer_cj(data.handle)
                }
                indexBuffers.remove(attributeId)
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 更新或创建顶点缓冲
     * @explain[zh-cn] 对照 WebGLAttributes.update()
     * @param[zh-cn] attributeId 属性对象 ID
     * mem 顶点数据内存（BgfxMemory，内部取指针）
     * layout 顶点布局句柄（经 createVertexLayout 创建，内部查表取指针）
     * size 数据大小（字节）
     * bytesPerElement 每元素字节数
     * version 版本号
     * dynamic 是否动态缓冲
     *
     * @brief[en] Update or create vertex buffer
     * @explain[en] Mirrors WebGLAttributes.update()
     * @param[en] attributeId Attribute object ID
     * mem Vertex data memory (BgfxMemory, takes pointer internally)
     * layout Vertex layout handle (created via createVertexLayout, internally looks up pointer)
     * size Data size in bytes
     * bytesPerElement Bytes per element
     * version Version number
     * dynamic Whether the buffer is dynamic
     */
    public func updateVertexBuffer(attributeId: Int64, mem: BgfxMemory, layout: VertexLayoutHandle,
        size: Int64, bytesPerElement: Int64, version: Int64, dynamic: Bool): Unit {
        let layoutPtr = match (this.layoutPtrs.get(layout.idx)) {
            case Some(holder) => holder.get()
            case None => CPointer<VertexLayout>()
        }
        match (vertexBuffers.get(attributeId)) {
            case Some(cached) =>
                if (cached.version < version) {
                    // 版本更新，需要重建缓冲
                    if (cached.handle.idx != 0xFFFFu16) {
                        bgfx_destroy_vertex_buffer_cj(cached.handle)
                    }
                    let flags: UInt16 = 0u16  // bgfx 缓冲标志（动态缓冲使用 DynamicVertexBufferHandle）
                    let handle = bgfx_create_vertex_buffer_cj(mem.get(), layoutPtr, flags)
                    cached.handle = handle
                    cached.size = size
                    cached.version = version
                    cached.bytesPerElement = bytesPerElement
                    cached.dynamic = dynamic
                }
            case None =>
                let flags: UInt16 = 0u16  // bgfx 缓冲标志
                let handle = bgfx_create_vertex_buffer_cj(mem.get(), layoutPtr, flags)
                let info = VertexBufferInfo()
                info.handle = handle
                info.bytesPerElement = bytesPerElement
                info.version = version
                info.size = size
                info.dynamic = dynamic
                vertexBuffers.add(attributeId, info)
        }
    }

    /**
     * @brief[zh-cn] 更新或创建索引缓冲
     * @param[zh-cn] attributeId 属性对象 ID
     * mem 索引数据内存
     * size 数据大小（字节）
     * bytesPerElement 每元素字节数
     * version 版本号
     *
     * @brief[en] Update or create index buffer
     * @param[en] attributeId Attribute object ID
     * mem Index data memory
     * size Data size in bytes
     * bytesPerElement Bytes per element
     * version Version number
     */
    public func updateIndexBuffer(attributeId: Int64, mem: BgfxMemory,
        size: Int64, bytesPerElement: Int64, version: Int64): Unit {
        match (indexBuffers.get(attributeId)) {
            case Some(cached) =>
                if (cached.version < version) {
                    if (cached.handle.idx != 0xFFFFu16) {
                        bgfx_destroy_index_buffer_cj(cached.handle)
                    }
                    let handle = bgfx_create_index_buffer_cj(mem.get(), 0u16)
                    cached.handle = handle
                    cached.size = size
                    cached.version = version
                    cached.bytesPerElement = bytesPerElement
                }
            case None =>
                let handle = bgfx_create_index_buffer_cj(mem.get(), 0u16)
                let info = IndexBufferInfo()
                info.handle = handle
                info.bytesPerElement = bytesPerElement
                info.version = version
                info.size = size
                indexBuffers.add(attributeId, info)
        }
    }

    /**
     * @brief[zh-cn] 释放所有缓冲
     *
     * @brief[en] Dispose all buffers
     */
    public func dispose(): Unit {
        for ((_, data) in vertexBuffers) {
            if (data.handle.idx != 0xFFFFu16) {
                bgfx_destroy_vertex_buffer_cj(data.handle)
            }
        }
        for ((_, data) in indexBuffers) {
            if (data.handle.idx != 0xFFFFu16) {
                bgfx_destroy_index_buffer_cj(data.handle)
            }
        }
        vertexBuffers = HashMap<Int64, VertexBufferInfo>()
        indexBuffers = HashMap<Int64, IndexBufferInfo>()
    }
}
