/**
 * @file[zh-cn] bgfx 顶点属性工具
 * @brief[zh-cn] 对照 WebGLAttributeUtils.js，使用 VertexLayout API 配置顶点属性
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLAttributeUtils.js。提供顶点布局创建、步长计算、属性解码/编码/焊接/拓扑转换等 CPU 侧工具函数。
 *
 * @file[en] bgfx Vertex Attribute Utilities
 * @brief[en] Configure vertex attributes using VertexLayout API, mirroring WebGLAttributeUtils.js
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLAttributeUtils.js. Provides vertex layout creation, stride computation, attribute decode/encode/weld/topology conversion and other CPU-side utility functions.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.PtrArray
import three.rendering.types.VertexLayoutPtr

/**
 * @brief[zh-cn] 顶点属性描述
 * @explain[zh-cn] 存储单个顶点属性的元数据，包括名称、语义、分量数、数据类型、归一化和整数标志。
 *
 * @brief[en] Vertex attribute descriptor
 * @explain[en] Stores metadata for a single vertex attribute, including name, semantics, component count, data type, normalization, and integer flags.
 */
public class BgfxAttributeDesc {
    /**
     * @brief[zh-cn] 属性名称
     *
     * @brief[en] Attribute name
     */
    public var name: String = ""
    /**
     * @brief[zh-cn] 语义（POSITION, NORMAL, TEXCOORD0 等）
     *
     * @brief[en] Attribute semantics (POSITION, NORMAL, TEXCOORD0, etc.)
     */
    public var attrib: UInt32 = 0u32
    /**
     * @brief[zh-cn] 属性分量数（1-4）
     *
     * @brief[en] Number of attribute components (1-4)
     */
    public var num: UInt8 = 4u8
    /**
     * @brief[zh-cn] 属性数据类型
     *
     * @brief[en] Attribute data type
     */
    public var attribType: UInt32 = 0u32
    /**
     * @brief[zh-cn] 是否归一化
     *
     * @brief[en] Whether the attribute is normalized
     */
    public var normalized: Bool = false
    /**
     * @brief[zh-cn] 是否为整数
     *
     * @brief[en] Whether the attribute is integer
     */
    public var asInt: Bool = false

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 顶点属性工具
 * @explain[zh-cn] 对照 WebGLAttributeUtils，使用 bgfx VertexLayout API 配置顶点属性。包含顶点布局创建、步长计算、属性解码/编码/焊接/拓扑转换等 CPU 侧工具函数。
 *
 * @brief[en] bgfx vertex attribute utilities
 * @explain[en] Mirrors WebGLAttributeUtils, using bgfx VertexLayout API to configure vertex attributes. Includes vertex layout creation, stride computation, attribute decode/encode/weld/topology conversion and other CPU-side utility functions.
 */
public class BgfxAttributeUtils {
    public init() {}

    /**
     * @brief[zh-cn] 创建顶点布局
     * @explain[zh-cn] 对照 WebGLAttributeUtils 中的顶点属性配置
     * @param[zh-cn] attributes 属性描述列表
     * @return[zh-cn] 顶点布局句柄
     *
     * @brief[en] Create a vertex layout
     * @explain[en] Mirrors vertex attribute configuration in WebGLAttributeUtils
     * @param[en] attributes Attribute descriptor list
     * @return[en] Vertex layout handle
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
        layoutHolder.dispose()
        return handle
    }

    /**
     * @brief[zh-cn] 计算顶点步长
     * @param[zh-cn] attributes 属性描述列表
     * @return[zh-cn] 顶点步长（字节）
     *
     * @brief[en] Compute vertex stride
     * @param[en] attributes Attribute descriptor list
     * @return[en] Vertex stride in bytes
     */
    public func computeStride(attributes: Array<BgfxAttributeDesc>): UInt16 {
        var stride: UInt16 = 0
        for (attr in attributes) {
            stride += getAttribTypeSize(attr.attribType, attr.num)
        }
        return stride
    }

    /**
     * @brief[zh-cn] 获取属性类型大小（字节）
     * @param[zh-cn] attribType 属性数据类型
     * num 分量数
     * @return[zh-cn] 类型大小（字节）
     *
     * @brief[en] Get attribute type size in bytes
     * @param[en] attribType Attribute data type
     * num Number of components
     * @return[en] Type size in bytes
     */
    private func getAttribTypeSize(attribType: UInt32, num: UInt8): UInt16 {
        let typeSize: UInt16 = match (attribType) {
            case 0u32 => 1u16   // Uint8
            case 1u32 => 4u16   // Uint10 (packed)
            case 2u32 => 2u16   // Int16
            case 3u32 => 2u16   // Half
            case 4u32 => 4u16   // Float
            case _ => 4u16
        }
        return UInt16(num) * typeSize
    }

    // ========================================================================
    // ===== 顶点布局查询 / 顶点数据工具（纯 CPU 工具，线程安全，直接调用） =====
    // ========================================================================

    /**
     * @brief[zh-cn] 解码顶点布局的属性信息
     * @explain[zh-cn] 对照 JS: WebGLAttributes 的 attribute 元数据
     * @param[zh-cn] layout 顶点布局指针（VertexLayoutPtr 包装）
     * attrib 属性语义（Attrib.value()）
     * num 输出分量数（PtrArray 输出）
     * type 输出数据类型（PtrArray 输出）
     * normalized 输出是否归一化（PtrArray 输出）
     * asInt 输出是否整数（PtrArray 输出）
     *
     * @brief[en] Decode attribute info from a vertex layout
     * @explain[en] Mirrors JS: WebGLAttributes attribute metadata
     * @param[en] layout Vertex layout pointer (VertexLayoutPtr wrapper)
     * attrib Attribute semantics (Attrib.value())
     * num Output component count (PtrArray output)
     * type Output data type (PtrArray output)
     * normalized Output whether normalized (PtrArray output)
     * asInt Output whether integer (PtrArray output)
     */
    public func vertexLayoutDecode(
        layout: VertexLayoutPtr, attrib: UInt32,
        num: PtrArray<UInt8>, `type`: PtrArray<UInt32>,
        normalized: PtrArray<Bool>, asInt: PtrArray<Bool>
    ): Unit {
        bgfx_vertex_layout_decode_cj(layout.value, attrib, num.data(), `type`.data(), normalized.data(), asInt.data())
    }

    /**
     * @brief[zh-cn] 查询布局是否包含某属性
     * @param[zh-cn] layout 顶点布局指针
     * attrib 属性语义
     * @return[zh-cn] 是否包含该属性
     *
     * @brief[en] Check if layout contains an attribute
     * @param[en] layout Vertex layout pointer
     * attrib Attribute semantics
     * @return[en] Whether the attribute exists in the layout
     */
    public func vertexLayoutHas(layout: VertexLayoutPtr, attrib: UInt32): Bool {
        return bgfx_vertex_layout_has_cj(layout.value, attrib)
    }

    /**
     * @brief[zh-cn] 跳过 num 个属性分量（布局构建游标推进）
     * @param[zh-cn] layout 顶点布局指针
     * num 跳过的分量数
     * @return[zh-cn] 更新后的顶点布局指针
     *
     * @brief[en] Skip num attribute components (advance layout build cursor)
     * @param[en] layout Vertex layout pointer
     * num Number of components to skip
     * @return[en] Updated vertex layout pointer
     */
    public func vertexLayoutSkip(layout: VertexLayoutPtr, num: UInt8): VertexLayoutPtr {
        return Box(bgfx_vertex_layout_skip_cj(layout.value, num))
    }

    /**
     * @brief[zh-cn] 获取属性偏移（字节）
     * @param[zh-cn] layout 顶点布局指针
     * attrib 属性语义
     * @return[zh-cn] 属性偏移（字节）
     *
     * @brief[en] Get attribute offset in bytes
     * @param[en] layout Vertex layout pointer
     * attrib Attribute semantics
     * @return[en] Attribute offset in bytes
     */
    public func vertexLayoutGetOffset(layout: VertexLayoutPtr, attrib: UInt32): UInt16 {
        return bgfx_vertex_layout_get_offset_cj(layout.value, attrib)
    }

    /**
     * @brief[zh-cn] 获取布局步长（字节）
     * @param[zh-cn] layout 顶点布局指针
     * @return[zh-cn] 布局步长（字节）
     *
     * @brief[en] Get layout stride in bytes
     * @param[en] layout Vertex layout pointer
     * @return[en] Layout stride in bytes
     */
    public func vertexLayoutGetStride(layout: VertexLayoutPtr): UInt16 {
        return bgfx_vertex_layout_get_stride_cj(layout.value)
    }

    /**
     * @brief[zh-cn] 获取属性分量大小（字节）
     * @param[zh-cn] layout 顶点布局指针
     * num 分量数
     * @return[zh-cn] 属性分量大小（字节）
     *
     * @brief[en] Get attribute component size in bytes
     * @param[en] layout Vertex layout pointer
     * num Number of components
     * @return[en] Attribute component size in bytes
     */
    public func vertexLayoutGetSize(layout: VertexLayoutPtr, num: UInt32): UInt32 {
        return bgfx_vertex_layout_get_size_cj(layout.value, num)
    }

    /**
     * @brief[zh-cn] 打包顶点数据到缓冲
     * @explain[zh-cn] 对照 JS: BufferGeometryUtils 的顶点数据布局
     * @param[zh-cn] input 输入浮点数据
     * inputNormalized 输入是否归一化
     * attr 属性语义
     * layout 顶点布局指针
     * data 目标数据缓冲
     * index 顶点索引
     *
     * @brief[en] Pack vertex data into buffer
     * @explain[en] Mirrors JS: BufferGeometryUtils vertex data layout
     * @param[en] input Input float data
     * inputNormalized Whether input is normalized
     * attr Attribute semantics
     * layout Vertex layout pointer
     * data Destination data buffer
     * index Vertex index
     */
    public func vertexPack(input: PtrArray<Float32>, inputNormalized: Bool, attr: UInt32, layout: VertexLayoutPtr, data: PtrArray<UInt8>, index: UInt32): Unit {
        bgfx_vertex_pack_cj(input.data(), inputNormalized, attr, layout.value, unsafe { CPointer<Unit>(data.data()) }, index)
    }

    /**
     * @brief[zh-cn] 从缓冲解包顶点数据
     * @param[zh-cn] output 输出浮点数据
     * attr 属性语义
     * layout 顶点布局指针
     * data 源数据缓冲
     * index 顶点索引
     *
     * @brief[en] Unpack vertex data from buffer
     * @param[en] output Output float data
     * attr Attribute semantics
     * layout Vertex layout pointer
     * data Source data buffer
     * index Vertex index
     */
    public func vertexUnpack(output: PtrArray<Float32>, attr: UInt32, layout: VertexLayoutPtr, data: PtrArray<UInt8>, index: UInt32): Unit {
        bgfx_vertex_unpack_cj(output.data(), attr, layout.value, unsafe { CPointer<Unit>(data.data()) }, index)
    }

    /**
     * @brief[zh-cn] 顶点数据格式转换（layout A → layout B）
     * @explain[zh-cn] 对照 JS: BufferGeometryUtils 的 attribute 重新布局
     * @param[zh-cn] dstLayout 目标顶点布局指针
     * dstData 目标数据缓冲
     * srcLayout 源顶点布局指针
     * srcData 源数据缓冲
     * num 顶点数
     *
     * @brief[en] Convert vertex data format (layout A → layout B)
     * @explain[en] Mirrors JS: BufferGeometryUtils attribute re-layout
     * @param[en] dstLayout Destination vertex layout pointer
     * dstData Destination data buffer
     * srcLayout Source vertex layout pointer
     * srcData Source data buffer
     * num Number of vertices
     */
    public func vertexConvert(dstLayout: VertexLayoutPtr, dstData: PtrArray<UInt8>, srcLayout: VertexLayoutPtr, srcData: PtrArray<UInt8>, num: UInt32): Unit {
        bgfx_vertex_convert_cj(dstLayout.value, unsafe { CPointer<Unit>(dstData.data()) }, srcLayout.value, unsafe { CPointer<Unit>(srcData.data()) }, num)
    }

    /**
     * @brief[zh-cn] 顶点焊接（按 epsilon 去重，返回焊接后顶点数）
     * @explain[zh-cn] 对照 JS: BufferGeometryUtils.mergeVertices
     * @param[zh-cn] output 输出焊接后数据
     * layout 顶点布局指针
     * data 源数据缓冲
     * num 顶点数
     * index32 是否使用 32 位索引
     * epsilon 焊接阈值
     * @return[zh-cn] 焊接后顶点数
     *
     * @brief[en] Weld vertices (deduplicate by epsilon, return welded vertex count)
     * @explain[en] Mirrors JS: BufferGeometryUtils.mergeVertices
     * @param[en] output Output welded data
     * layout Vertex layout pointer
     * data Source data buffer
     * num Number of vertices
     * index32 Whether to use 32-bit indices
     * epsilon Weld epsilon threshold
     * @return[en] Welded vertex count
     */
    public func weldVertices(output: PtrArray<UInt8>, layout: VertexLayoutPtr, data: PtrArray<UInt8>, num: UInt32, index32: Bool, epsilon: Float32): UInt32 {
        return bgfx_weld_vertices_cj(unsafe { CPointer<Unit>(output.data()) }, layout.value, unsafe { CPointer<Unit>(data.data()) }, num, index32, epsilon)
    }

    /**
     * @brief[zh-cn] 拓扑转换（返回转换后索引数）
     * @explain[zh-cn] 对照 JS: BufferGeometryUtils 的拓扑转换工具
     * @param[zh-cn] conversion 转换类型
     * dst 目标索引缓冲
     * dstSize 目标缓冲大小
     * indices 源索引数据
     * numIndices 索引数
     * index32 是否使用 32 位索引
     * @return[zh-cn] 转换后索引数
     *
     * @brief[en] Topology conversion (returns converted index count)
     * @explain[en] Mirrors JS: BufferGeometryUtils topology conversion utility
     * @param[en] conversion Conversion type
     * dst Destination index buffer
     * dstSize Destination buffer size
     * indices Source index data
     * numIndices Number of indices
     * index32 Whether to use 32-bit indices
     * @return[en] Converted index count
     */
    public func topologyConvert(conversion: UInt32, dst: PtrArray<UInt8>, dstSize: UInt32, indices: PtrArray<UInt8>, numIndices: UInt32, index32: Bool): UInt32 {
        return bgfx_topology_convert_cj(conversion, unsafe { CPointer<Unit>(dst.data()) }, dstSize, unsafe { CPointer<Unit>(indices.data()) }, numIndices, index32)
    }

    /**
     * @brief[zh-cn] 三角形列表排序（透明物体排序）
     * @explain[zh-cn] 对照 JS: PainterSort 透明排序
     * @param[zh-cn] sort 排序类型
     * dst 目标索引缓冲
     * dstSize 目标缓冲大小
     * dir 排序方向
     * pos 排序位置
     * vertices 顶点数据
     * stride 顶点步长
     * indices 索引数据
     * numIndices 索引数
     * index32 是否使用 32 位索引
     *
     * @brief[en] Sort triangle list (transparent object sorting)
     * @explain[en] Mirrors JS: PainterSort transparent sorting
     * @param[en] sort Sort type
     * dst Destination index buffer
     * dstSize Destination buffer size
     * dir Sort direction
     * pos Sort position
     * vertices Vertex data
     * stride Vertex stride
     * indices Index data
     * numIndices Number of indices
     * index32 Whether to use 32-bit indices
     */
    public func topologySortTriList(
        sort: UInt32, dst: PtrArray<UInt8>, dstSize: UInt32, dir: PtrArray<Float32>, pos: PtrArray<Float32>,
        vertices: PtrArray<UInt8>, stride: UInt32, indices: PtrArray<UInt8>, numIndices: UInt32, index32: Bool
    ): Unit {
        bgfx_topology_sort_tri_list_cj(sort, unsafe { CPointer<Unit>(dst.data()) }, dstSize, dir.data(), pos.data(), unsafe { CPointer<Unit>(vertices.data()) }, stride, unsafe { CPointer<Unit>(indices.data()) }, numIndices, index32)
    }
}
