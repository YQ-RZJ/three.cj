/**
 * @file[zh-cn] BgfxTypes bgfx 句柄类型与枚举重公开
 * @brief[zh-cn] bgfx 句柄类型与枚举重公开 —— 外部使用 Three.cj 无须接触 bgfx4cj
 * @explain[zh-cn] 设计动机：外部（postprocessing/objects/materials 等）的 pass 签名与
 * renderer 高阶 API 需要使用 bgfx 句柄类型（TextureHandle / FrameBufferHandle 等）
 * 与枚举（UniformType / TextureFormat / Attrib / AttribType 等），
 * 原直接 import bgfx4cj.bgfx.* 使用。本文件把这些类型以 type 别名重公开到
 * three.rendering.types，外部只依赖 Three.cj。
 * 分布规则：后端资源标识（WebGLRenderTarget.texture 等）属于
 * renderers 层，故句柄类型放在 renderers 下独立 types 包；枚举与常量同源，
 * 一并重公开。
 * 安全化说明（对照任务 3 调整建议）：
 * - 句柄类型统一以 `Box<bgfx.XxxHandle>` 包装。bgfx 句柄是值语义的 @C struct
 * （仅含 idx: UInt16，无指针、无内存所有权），Box 包装满足"对外不应涉及
 *
 * @file[en] BgfxTypes bgfx handle types and enum re-exports
 * @brief[en] Re-export bgfx handle types and enums so external code only depends on Three.cj
 * @explain[en] Design motivation: external modules (postprocessing/objects/materials etc.) need
 * bgfx handle types (TextureHandle / FrameBufferHandle etc.) and enums
 * (UniformType / TextureFormat / Attrib / AttribType etc.) in pass signatures
 * and renderer high-level APIs. Previously they imported bgfx4cj.bgfx.* directly.
 * This file re-exports these types as type aliases into three.rendering.types,
 * so external code only depends on Three.cj.
 * Distribution rule: backend resource identifiers
 * (e.g. WebGLRenderTarget.texture) belong to the renderers layer, so handle types
 * are placed in a dedicated types package under renderers; enums and constants
 * share the same source and are re-exported together.
 * Safety notes (per task 3 adjustment):
 * - Handle types are uniformly wrapped in `Box<bgfx.XxxHandle>`. bgfx handles are
 * value-semantic @C structs (containing only idx: UInt16, no pointers, no memory
 * ownership). Box wrapping satisfies the "external code should not touch @C structs"
 * requirement, while Box expresses "value exists" and external code need not
 * dereference pointers.
 * - `Memory` (containing raw pointer data: CPointer<UInt8>) is also wrapped in Box;
 * external code only holds Box references, pointer operations are done internally
 * by renderer / utils.BgfxMemory.
 * - External code should not read `handle.value.idx` or hard-code `65535u16` to
 * check validity; use `isValidHandle(handle)` / `INVALID_XXX_HANDLE` constants,
 * or `handleIdx(handle)` (for debug logging only).
 *
 * @C 结构体"要求，同时 Box 表达"存在值"，外部无须自行解包指针。
 * - `Memory`（含裸指针 data: CPointer<UInt8>）同样以 Box 包装重公开；
 * 外部只持有 Box 引用，指针操作由 renderer / utils.BgfxMemory 内部完成。
 * - 外部不应直接读 `handle.value.idx` 或硬编码 `65535u16` 判断有效性；
 * 统一改用 `isValidHandle(handle)` / `INVALID_XXX_HANDLE` 常量，
 * 或 `handleIdx(handle)`（仅用于日志调试输出）。
 *
 *
 *
 * @package three.rendering.types
 */
package three.rendering.types

import bgfx4cj.bgfx as bgfx

// ===== 句柄类型（Box<bgfx.XxxHandle> 包装；idx 0xFFFF = 无效） =====
/**
 * @brief[zh-cn] 帧缓冲句柄
 *
 * @brief[en] Frame buffer handle
 */
public type FrameBufferHandle = Box<bgfx.FrameBufferHandle>
/**
 * @brief[zh-cn] 纹理句柄
 *
 * @brief[en] Texture handle
 */
public type TextureHandle = Box<bgfx.TextureHandle>
/**
 * @brief[zh-cn] 程序句柄（vs+fs 链接后）
 *
 * @brief[en] Program handle (linked vertex + fragment shader)
 */
public type ProgramHandle = Box<bgfx.ProgramHandle>
/**
 * @brief[zh-cn] uniform 句柄
 *
 * @brief[en] Uniform handle
 */
public type UniformHandle = Box<bgfx.UniformHandle>
/**
 * @brief[zh-cn] 静态顶点缓冲句柄
 *
 * @brief[en] Static vertex buffer handle
 */
public type VertexBufferHandle = Box<bgfx.VertexBufferHandle>
/**
 * @brief[zh-cn] 静态索引缓冲句柄
 *
 * @brief[en] Static index buffer handle
 */
public type IndexBufferHandle = Box<bgfx.IndexBufferHandle>
/**
 * @brief[zh-cn] 顶点布局句柄
 *
 * @brief[en] Vertex layout handle
 */
public type VertexLayoutHandle = Box<bgfx.VertexLayoutHandle>
/**
 * @brief[zh-cn] 动态顶点缓冲句柄
 *
 * @brief[en] Dynamic vertex buffer handle
 */
public type DynamicVertexBufferHandle = Box<bgfx.DynamicVertexBufferHandle>
/**
 * @brief[zh-cn] 动态索引缓冲句柄
 *
 * @brief[en] Dynamic index buffer handle
 */
public type DynamicIndexBufferHandle = Box<bgfx.DynamicIndexBufferHandle>
/**
 * @brief[zh-cn] 着色器句柄
 *
 * @brief[en] Shader handle
 */
public type ShaderHandle = Box<bgfx.ShaderHandle>
/**
 * @brief[zh-cn] 间接绘制缓冲句柄
 *
 * @brief[en] Indirect buffer handle
 */
public type IndirectBufferHandle = Box<bgfx.IndirectBufferHandle>
/**
 * @brief[zh-cn] 遮挡查询句柄
 *
 * @brief[en] Occlusion query handle
 */
public type OcclusionQueryHandle = Box<bgfx.OcclusionQueryHandle>

// ===== 内存块（Box 包装；指针操作由 renderer / BgfxMemory 内部完成） =====
/**
 * @brief[zh-cn] bgfx 内存块（createTexture2D/createVertexBuffer 的 mem 参数占位）
 * @explain[zh-cn] Box 包装后外部只持有引用、不接触内部指针；实际数据读写走 utils.BgfxMemory，
 * 或由 renderer 高阶 API 内部构造空内存。
 *
 * @brief[en] bgfx memory block (placeholder for mem parameter of createTexture2D/createVertexBuffer)
 * @explain[en] After Box wrapping, external code only holds references without touching internal pointers;
 * actual data read/write is done via utils.BgfxMemory, or empty memory is constructed
 * internally by renderer high-level APIs.
 */
public type Memory = Box<bgfx.Memory>

// ===== 非句柄 @C 结构体重公开（统一 Box 包装；指针操作由 renderer / utils 内部完成） =====
/**
 * @brief[zh-cn] 非句柄 @C 结构体重公开设计说明
 * @explain[zh-cn] 以下 @C 结构体与句柄/Memory 同源，均以 `Box<bgfx.X>` 包装重公开，
 * 使外部只依赖 Three.cj 即可完全脱离 bgfx 底层。外部仅持有 Box 引用，
 * 字段读写（含内部 CPointer / VArray）由 renderer / utils 层封装完成。
 *
 * @brief[en] Design note for non-handle @C struct re-exports
 * @explain[en] The following @C structs share the same source as handles/Memory, all re-exported
 * wrapped in `Box<bgfx.X>`, enabling external code to depend only on Three.cj without
 * touching the low-level bgfx layer. External code only holds Box references;
 * field read/write (including internal CPointer / VArray) is encapsulated by
 * the renderer / utils layer.
 */
/**
 * @brief[zh-cn] GPU 信息（PCI 厂商/设备 ID）
 *
 * @brief[en] GPU information (PCI vendor/device ID)
 */
public type CapsGpu = Box<bgfx.CapsGpu>
/**
 * @brief[zh-cn] 渲染器运行时限制（资源上限）
 *
 * @brief[en] Renderer runtime limits (resource caps)
 */
public type CapsLimits = Box<bgfx.CapsLimits>
/**
 * @brief[zh-cn] 渲染器能力信息（rendererType / supported / limits 等）
 *
 * @brief[en] Renderer capabilities info (rendererType / supported / limits etc.)
 */
public type Caps = Box<bgfx.Caps>
/**
 * @brief[zh-cn] bgfx 内部数据（caps 指针与上下文指针）
 *
 * @brief[en] bgfx internal data (caps pointer and context pointer)
 */
public type InternalData = Box<bgfx.InternalData>
/**
 * @brief[zh-cn] 平台数据（原生窗口句柄 nwh 等）
 *
 * @brief[en] Platform data (native window handle nwh etc.)
 */
public type PlatformData = Box<bgfx.PlatformData>
/**
 * @brief[zh-cn] 后缓冲分辨率与重置参数
 *
 * @brief[en] Backbuffer resolution and reset parameters
 */
public type Resolution = Box<bgfx.Resolution>
/**
 * @brief[zh-cn] 可配置运行时限制参数
 *
 * @brief[en] Configurable runtime limit parameters
 */
public type InitLimits = Box<bgfx.InitLimits>
/**
 * @brief[zh-cn] 分配器接口（不透明）
 *
 * @brief[en] Allocator interface (opaque)
 */
public type AllocatorInterface = Box<bgfx.AllocatorInterface>
/**
 * @brief[zh-cn] 回调接口（不透明）
 *
 * @brief[en] Callback interface (opaque)
 */
public type CallbackInterface = Box<bgfx.CallbackInterface>
/**
 * @brief[zh-cn] bgfx 初始化参数
 *
 * @brief[en] bgfx initialization parameters
 */
public type Init = Box<bgfx.Init>
/**
 * @brief[zh-cn] 瞬态索引缓冲
 *
 * @brief[en] Transient index buffer
 */
public type TransientIndexBuffer = Box<bgfx.TransientIndexBuffer>
/**
 * @brief[zh-cn] 瞬态顶点缓冲
 *
 * @brief[en] Transient vertex buffer
 */
public type TransientVertexBuffer = Box<bgfx.TransientVertexBuffer>
/**
 * @brief[zh-cn] 实例数据缓冲
 *
 * @brief[en] Instance data buffer
 */
public type InstanceDataBuffer = Box<bgfx.InstanceDataBuffer>
/**
 * @brief[zh-cn] 纹理信息（format / width / height / numMips 等）
 *
 * @brief[en] Texture info (format / width / height / numMips etc.)
 */
public type TextureInfo = Box<bgfx.TextureInfo>
/**
 * @brief[zh-cn] Uniform 变量信息（name / type / num）
 *
 * @brief[en] Uniform variable info (name / type / num)
 */
public type UniformInfo = Box<bgfx.UniformInfo>
/**
 * @brief[zh-cn] 帧缓冲纹理附加信息
 *
 * @brief[en] Frame buffer texture attachment info
 */
public type Attachment = Box<bgfx.Attachment>
/**
 * @brief[zh-cn] 变换数据（矩阵指针）
 *
 * @brief[en] Transform data (matrix pointer)
 */
public type Transform = Box<bgfx.Transform>
/**
 * @brief[zh-cn] 视图统计信息
 *
 * @brief[en] View statistics
 */
public type ViewStats = Box<bgfx.ViewStats>
/**
 * @brief[zh-cn] 编码器统计信息
 *
 * @brief[en] Encoder statistics
 */
public type EncoderStats = Box<bgfx.EncoderStats>
/**
 * @brief[zh-cn] 渲染器统计信息
 *
 * @brief[en] Renderer statistics
 */
public type Stats = Box<bgfx.Stats>
/**
 * @brief[zh-cn] 顶点布局（hash / stride / offset）
 *
 * @brief[en] Vertex layout (hash / stride / offset)
 */
public type VertexLayout = Box<bgfx.VertexLayout>
/**
 * @brief[zh-cn] 渲染编码器
 *
 * @brief[en] Render encoder
 */
public type Encoder = Box<bgfx.Encoder>

// ===== 无效句柄常量（替代外部硬编码 65535u16） =====
/**
 * @brief[zh-cn] bgfx 句柄无效索引值
 * @explain[zh-cn] 外部判断句柄有效性应使用 `isValidHandle(handle)`，不应直接读 `.value.idx` 或硬编码此值。
 *
 * @brief[en] bgfx handle invalid index value
 * @explain[en] External code should use `isValidHandle(handle)` to check handle validity,
 * not directly read `.value.idx` or hard-code this value.
 */
public let BGFX_INVALID_HANDLE_IDX: UInt16 = 0xFFFFu16

/**
 * @brief[zh-cn] 无效帧缓冲句柄（idx=0xFFFF），用于字段初始值与销毁后复位
 *
 * @brief[en] Invalid frame buffer handle (idx=0xFFFF), used for field initialization and post-destroy reset
 */
public let INVALID_FRAME_BUFFER_HANDLE: FrameBufferHandle = Box(bgfx.FrameBufferHandle())
/**
 * @brief[zh-cn] 无效纹理句柄
 *
 * @brief[en] Invalid texture handle
 */
public let INVALID_TEXTURE_HANDLE: TextureHandle = Box(bgfx.TextureHandle())
/**
 * @brief[zh-cn] 无效程序句柄
 *
 * @brief[en] Invalid program handle
 */
public let INVALID_PROGRAM_HANDLE: ProgramHandle = Box(bgfx.ProgramHandle())
/**
 * @brief[zh-cn] 无效 uniform 句柄
 *
 * @brief[en] Invalid uniform handle
 */
public let INVALID_UNIFORM_HANDLE: UniformHandle = Box(bgfx.UniformHandle())
/**
 * @brief[zh-cn] 无效静态顶点缓冲句柄
 *
 * @brief[en] Invalid static vertex buffer handle
 */
public let INVALID_VERTEX_BUFFER_HANDLE: VertexBufferHandle = Box(bgfx.VertexBufferHandle())
/**
 * @brief[zh-cn] 无效静态索引缓冲句柄
 *
 * @brief[en] Invalid static index buffer handle
 */
public let INVALID_INDEX_BUFFER_HANDLE: IndexBufferHandle = Box(bgfx.IndexBufferHandle())
/**
 * @brief[zh-cn] 无效顶点布局句柄
 *
 * @brief[en] Invalid vertex layout handle
 */
public let INVALID_VERTEX_LAYOUT_HANDLE: VertexLayoutHandle = Box(bgfx.VertexLayoutHandle())
/**
 * @brief[zh-cn] 无效动态顶点缓冲句柄
 *
 * @brief[en] Invalid dynamic vertex buffer handle
 */
public let INVALID_DYNAMIC_VERTEX_BUFFER_HANDLE: DynamicVertexBufferHandle = Box(bgfx.DynamicVertexBufferHandle())
/**
 * @brief[zh-cn] 无效动态索引缓冲句柄
 *
 * @brief[en] Invalid dynamic index buffer handle
 */
public let INVALID_DYNAMIC_INDEX_BUFFER_HANDLE: DynamicIndexBufferHandle = Box(bgfx.DynamicIndexBufferHandle())
/**
 * @brief[zh-cn] 无效着色器句柄
 *
 * @brief[en] Invalid shader handle
 */
public let INVALID_SHADER_HANDLE: ShaderHandle = Box(bgfx.ShaderHandle())
/**
 * @brief[zh-cn] 无效间接绘制缓冲句柄
 *
 * @brief[en] Invalid indirect buffer handle
 */
public let INVALID_INDIRECT_BUFFER_HANDLE: IndirectBufferHandle = Box(bgfx.IndirectBufferHandle())
/**
 * @brief[zh-cn] 无效遮挡查询句柄
 *
 * @brief[en] Invalid occlusion query handle
 */
public let INVALID_OCCLUSION_QUERY_HANDLE: OcclusionQueryHandle = Box(bgfx.OcclusionQueryHandle())

// ===== 句柄有效性 / 索引高阶 API（替代外部 .idx / 65535u16 访问） =====

/**
 * @brief[zh-cn] 取帧缓冲句柄内部 idx（仅用于日志调试输出；有效性判断请用 isValidHandle）
 *
 * @brief[en] Get frame buffer handle internal idx (for debug logging only; use isValidHandle for validity check)
 */
public func handleIdx(handle: FrameBufferHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断帧缓冲句柄是否有效（idx != 0xFFFF）
 *
 * @brief[en] Check if frame buffer handle is valid (idx != 0xFFFF)
 */
public func isValidHandle(handle: FrameBufferHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取纹理句柄 idx（日志用）
 *
 * @brief[en] Get texture handle idx (for logging)
 */
public func handleIdx(handle: TextureHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断纹理句柄是否有效
 *
 * @brief[en] Check if texture handle is valid
 */
public func isValidHandle(handle: TextureHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取程序句柄 idx（日志用）
 *
 * @brief[en] Get program handle idx (for logging)
 */
public func handleIdx(handle: ProgramHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断程序句柄是否有效
 *
 * @brief[en] Check if program handle is valid
 */
public func isValidHandle(handle: ProgramHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取 uniform 句柄 idx（日志用）
 *
 * @brief[en] Get uniform handle idx (for logging)
 */
public func handleIdx(handle: UniformHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断 uniform 句柄是否有效
 *
 * @brief[en] Check if uniform handle is valid
 */
public func isValidHandle(handle: UniformHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取静态顶点缓冲句柄 idx（日志用）
 *
 * @brief[en] Get static vertex buffer handle idx (for logging)
 */
public func handleIdx(handle: VertexBufferHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断静态顶点缓冲句柄是否有效
 *
 * @brief[en] Check if static vertex buffer handle is valid
 */
public func isValidHandle(handle: VertexBufferHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取静态索引缓冲句柄 idx（日志用）
 *
 * @brief[en] Get static index buffer handle idx (for logging)
 */
public func handleIdx(handle: IndexBufferHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断静态索引缓冲句柄是否有效
 *
 * @brief[en] Check if static index buffer handle is valid
 */
public func isValidHandle(handle: IndexBufferHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取顶点布局句柄 idx（日志用）
 *
 * @brief[en] Get vertex layout handle idx (for logging)
 */
public func handleIdx(handle: VertexLayoutHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断顶点布局句柄是否有效
 *
 * @brief[en] Check if vertex layout handle is valid
 */
public func isValidHandle(handle: VertexLayoutHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取动态顶点缓冲句柄 idx（日志用）
 *
 * @brief[en] Get dynamic vertex buffer handle idx (for logging)
 */
public func handleIdx(handle: DynamicVertexBufferHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断动态顶点缓冲句柄是否有效
 *
 * @brief[en] Check if dynamic vertex buffer handle is valid
 */
public func isValidHandle(handle: DynamicVertexBufferHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取动态索引缓冲句柄 idx（日志用）
 *
 * @brief[en] Get dynamic index buffer handle idx (for logging)
 */
public func handleIdx(handle: DynamicIndexBufferHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断动态索引缓冲句柄是否有效
 *
 * @brief[en] Check if dynamic index buffer handle is valid
 */
public func isValidHandle(handle: DynamicIndexBufferHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取着色器句柄 idx（日志用）
 *
 * @brief[en] Get shader handle idx (for logging)
 */
public func handleIdx(handle: ShaderHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断着色器句柄是否有效
 *
 * @brief[en] Check if shader handle is valid
 */
public func isValidHandle(handle: ShaderHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取间接绘制缓冲句柄 idx（日志用）
 *
 * @brief[en] Get indirect buffer handle idx (for logging)
 */
public func handleIdx(handle: IndirectBufferHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断间接绘制缓冲句柄是否有效
 *
 * @brief[en] Check if indirect buffer handle is valid
 */
public func isValidHandle(handle: IndirectBufferHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

/**
 * @brief[zh-cn] 取遮挡查询句柄 idx（日志用）
 *
 * @brief[en] Get occlusion query handle idx (for logging)
 */
public func handleIdx(handle: OcclusionQueryHandle): UInt16 {
    return handle.value.idx
}

/**
 * @brief[zh-cn] 判断遮挡查询句柄是否有效
 *
 * @brief[en] Check if occlusion query handle is valid
 */
public func isValidHandle(handle: OcclusionQueryHandle): Bool {
    return handle.value.idx != BGFX_INVALID_HANDLE_IDX
}

// ===== 枚举重公开（enum 本身非 @C struct，type 别名直接重公开） =====
/**
 * @brief[zh-cn] 渲染器类型（Direct3D11 / Vulkan / OpenGLES / Metal / Noop ...）
 *
 * @brief[en] Renderer type (Direct3D11 / Vulkan / OpenGLES / Metal / Noop ...)
 */
public type RendererType = bgfx.RendererType
/**
 * @brief[zh-cn] 纹理格式（RGBA8 / RGBA16F / D24 / D24S8 ...）
 *
 * @brief[en] Texture format (RGBA8 / RGBA16F / D24 / D24S8 ...)
 */
public type TextureFormat = bgfx.TextureFormat
/**
 * @brief[zh-cn] uniform 类型（Sampler / Vec4 / Mat4 / Int1 ...）
 *
 * @brief[en] Uniform type (Sampler / Vec4 / Mat4 / Int1 ...)
 */
public type UniformType = bgfx.UniformType
/**
 * @brief[zh-cn] 顶点属性语义（Position / Normal / TexCoord0 / Color0 ...）
 *
 * @brief[en] Vertex attribute semantic (Position / Normal / TexCoord0 / Color0 ...)
 */
public type Attrib = bgfx.Attrib
/**
 * @brief[zh-cn] 顶点属性数据类型（Float / Half / Int16 / Uint8 ...）
 *
 * @brief[en] Vertex attribute data type (Float / Half / Int16 / Uint8 ...)
 */
public type AttribType = bgfx.AttribType
/**
 * @brief[zh-cn] 后端能力枚举（GPU 型号名）
 *
 * @brief[en] Backend capability enum (GPU model name)
 */
public type Topology = bgfx.Topology
/**
 * @brief[zh-cn] 视图模式（默认 / 顺序 / 深度升序 / 深度降序）
 *
 * @brief[en] View mode (Default / Sequential / Depth Ascending / Depth Descending)
 */
public type ViewMode = bgfx.ViewMode
/**
 * @brief[zh-cn] 后读缓冲比例（Full / Half / Quarter ...）
 *
 * @brief[en] Backbuffer ratio (Full / Half / Quarter ...)
 */
public type BackbufferRatio = bgfx.BackbufferRatio
/**
 * @brief[zh-cn] 资源访问类型（Read / Write / ReadWrite）
 *
 * @brief[en] Resource access type (Read / Write / ReadWrite)
 */
public type Access = bgfx.Access
/**
 * @brief[zh-cn] 渲染帧类型（Render / Submit）
 *
 * @brief[en] Render frame type (Render / Submit)
 */
public type RenderFrame = bgfx.RenderFrame
/**
 * @brief[zh-cn] 致命错误类型（用于回调）
 *
 * @brief[en] Fatal error type (for callbacks)
 */
public type Fatal = bgfx.Fatal
/**
 * @brief[zh-cn] 遮挡查询结果（Invisible / Visible / NoResult）
 *
 * @brief[en] Occlusion query result (Invisible / Visible / NoResult)
 */
public type OcclusionQueryResult = bgfx.OcclusionQueryResult
/**
 * @brief[zh-cn] 拓扑转换类型（TriListFlipWinding / TriStripToTriList ...）
 *
 * @brief[en] Topology convert type (TriListFlipWinding / TriStripToTriList ...)
 */
public type TopologyConvert = bgfx.TopologyConvert
/**
 * @brief[zh-cn] 拓扑排序类型（DirectionFrontToBackMin / DistanceBackToFrontAvg ...）
 *
 * @brief[en] Topology sort type (DirectionFrontToBackMin / DistanceBackToFrontAvg ...)
 */
public type TopologySort = bgfx.TopologySort
/**
 * @brief[zh-cn] 原生窗口句柄类型（Default / Wayland）
 *
 * @brief[en] Native window handle type (Default / Wayland)
 */
public type NativeWindowHandleType = bgfx.NativeWindowHandleType

// ===== 指针包装类型（Box<CPointer<bgfx.X>> 表达"指向 X 的指针"，外部只持有引用） =====
/**
 * @brief[zh-cn] 指针包装类型设计说明
 * @explain[zh-cn] 部分 bgfx API 需要传入/返回指向 @C 结构体的指针（如
 * CPointer<VertexLayout> / CPointer<Caps>）。为满足"公开接口不出现裸指针"，
 * 统一以 `Box<CPointer<bgfx.X>>` 包装：外部只持有 Box 引用，指针本身由
 * renderer / utils 内部构造、解包与释放，外部无须接触 CPointer。
 * 配套使用：`Box(CPointer<bgfx.X>())` 构造空指针 / `ptr.value` 解包。
 *
 * @brief[en] Design note for pointer wrapper types
 * @explain[en] Some bgfx APIs require passing/returning pointers to @C structs (e.g.
 * CPointer<VertexLayout> / CPointer<Caps>). To satisfy the "no raw pointers in
 * public interfaces" requirement, they are uniformly wrapped in `Box<CPointer<bgfx.X>>`:
 * external code only holds Box references, while the pointer itself is constructed,
 * unwrapped and freed internally by renderer / utils. External code never touches CPointer.
 * Usage: `Box(CPointer<bgfx.X>())` constructs a null pointer / `ptr.value` unwraps.
 */
/**
 * @brief[zh-cn] void* 指针包装（用于 getInterface / getDirectAccessPtr 等无类型指针）
 *
 * @brief[en] void* pointer wrapper (for getInterface / getDirectAccessPtr etc.)
 */
public type UnitPtr = Box<CPointer<Unit>>
/**
 * @brief[zh-cn] 渲染器能力指针（getCaps 返回）
 *
 * @brief[en] Renderer capabilities pointer (returned by getCaps)
 */
public type CapsPtr = Box<CPointer<bgfx.Caps>>
/**
 * @brief[zh-cn] 渲染器统计指针（getStats 返回）
 *
 * @brief[en] Renderer statistics pointer (returned by getStats)
 */
public type StatsPtr = Box<CPointer<bgfx.Stats>>
/**
 * @brief[zh-cn] bgfx 内部数据指针（getInternalData 返回）
 *
 * @brief[en] bgfx internal data pointer (returned by getInternalData)
 */
public type InternalDataPtr = Box<CPointer<bgfx.InternalData>>
/**
 * @brief[zh-cn] 平台数据指针（setPlatformData 传入）
 *
 * @brief[en] Platform data pointer (passed to setPlatformData)
 */
public type PlatformDataPtr = Box<CPointer<bgfx.PlatformData>>
/**
 * @brief[zh-cn] 纹理信息指针（createTexture / calcTextureSize 传入）
 *
 * @brief[en] Texture info pointer (passed to createTexture / calcTextureSize)
 */
public type TextureInfoPtr = Box<CPointer<bgfx.TextureInfo>>
/**
 * @brief[zh-cn] Uniform 信息指针（getUniformInfo 传入）
 *
 * @brief[en] Uniform info pointer (passed to getUniformInfo)
 */
public type UniformInfoPtr = Box<CPointer<bgfx.UniformInfo>>
/**
 * @brief[zh-cn] 帧缓冲附加信息指针（isFrameBufferValid 传入）
 *
 * @brief[en] Frame buffer attachment info pointer (passed to isFrameBufferValid)
 */
public type AttachmentPtr = Box<CPointer<bgfx.Attachment>>
/**
 * @brief[zh-cn] 变换数据指针（allocTransform / encoderAllocTransform）
 *
 * @brief[en] Transform data pointer (for allocTransform / encoderAllocTransform)
 */
public type TransformPtr = Box<CPointer<bgfx.Transform>>
/**
 * @brief[zh-cn] 顶点布局指针（createDynamicVertexBuffer 等传入）
 *
 * @brief[en] Vertex layout pointer (passed to createDynamicVertexBuffer etc.)
 */
public type VertexLayoutPtr = Box<CPointer<bgfx.VertexLayout>>
/**
 * @brief[zh-cn] 瞬态索引缓冲指针（setTransientIndexBuffer 传入）
 *
 * @brief[en] Transient index buffer pointer (passed to setTransientIndexBuffer)
 */
public type TransientIndexBufferPtr = Box<CPointer<bgfx.TransientIndexBuffer>>
/**
 * @brief[zh-cn] 瞬态顶点缓冲指针（setTransientVertexBuffer 传入）
 *
 * @brief[en] Transient vertex buffer pointer (passed to setTransientVertexBuffer)
 */
public type TransientVertexBufferPtr = Box<CPointer<bgfx.TransientVertexBuffer>>
/**
 * @brief[zh-cn] 实例数据缓冲指针（setInstanceDataBuffer 传入）
 *
 * @brief[en] Instance data buffer pointer (passed to setInstanceDataBuffer)
 */
public type InstanceDataBufferPtr = Box<CPointer<bgfx.InstanceDataBuffer>>
/**
 * @brief[zh-cn] 渲染编码器指针（encoder* 系列传入/返回）
 *
 * @brief[en] Render encoder pointer (passed/returned by encoder* series)
 */
public type EncoderPtr = Box<CPointer<bgfx.Encoder>>
