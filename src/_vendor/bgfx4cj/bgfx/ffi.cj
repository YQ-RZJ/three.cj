/**
 * @file bgfx CFFI 函数声明
 * @brief bgfx C99 API 的所有 foreign 函数声明
 * @explain 本文件包含所有 bgfx C API 的 foreign 函数声明（BGFX_C_API）。
 *         这些函数是包级私有的，外部调用请使用 `ffi_exports.cj` 中的 `_cj` 包装。
 * @note 仓颉枚举是引用类型，不满足 CType 约束。foreign 函数使用 UInt32
 *       作为 C 枚举的底层表示。调用方通过 `EnumType.value()` 和
 *       `EnumType.fromValue(u32)` 进行转换。
 * @note 被仓颉保留字覆盖的 C 参数名使用反引号转义（如 `type`、`num`）。
 */
protected package three._vendor.bgfx4cj.bgfx

// =============================================================================
// Attachment
// =============================================================================

@FastNative
foreign func bgfx_attachment_init(
    `this`: CPointer<Attachment>,
    handle: TextureHandle,
    access: UInt32,
    layer: UInt16,
    numLayers: UInt16,
    mip: UInt16,
    flags: UInt8
): Unit

// =============================================================================
// Vertex layout
// =============================================================================

@FastNative
foreign func bgfx_vertex_layout_begin(
    `this`: CPointer<VertexLayout>,
    rendererType: UInt32
): CPointer<VertexLayout>

@FastNative
foreign func bgfx_vertex_layout_add(
    `this`: CPointer<VertexLayout>,
    attrib: UInt32,
    num: UInt8,
    `type`: UInt32,
    normalized: Bool,
    asInt: Bool
): CPointer<VertexLayout>

@FastNative
foreign func bgfx_vertex_layout_decode(
    `this`: CPointer<VertexLayout>,
    attrib: UInt32,
    num: CPointer<UInt8>,
    `type`: CPointer<UInt32>,
    normalized: CPointer<Bool>,
    asInt: CPointer<Bool>
): Unit

@FastNative
foreign func bgfx_vertex_layout_has(
    `this`: CPointer<VertexLayout>,
    attrib: UInt32
): Bool

@FastNative
foreign func bgfx_vertex_layout_skip(
    `this`: CPointer<VertexLayout>,
    num: UInt8
): CPointer<VertexLayout>

@FastNative
foreign func bgfx_vertex_layout_end(
    `this`: CPointer<VertexLayout>
): Unit

@FastNative
foreign func bgfx_vertex_layout_get_offset(
    `this`: CPointer<VertexLayout>,
    attrib: UInt32
): UInt16

@FastNative
foreign func bgfx_vertex_layout_get_stride(
    `this`: CPointer<VertexLayout>
): UInt16

@FastNative
foreign func bgfx_vertex_layout_get_size(
    `this`: CPointer<VertexLayout>,
    num: UInt32
): UInt32

// =============================================================================
// Vertex pack/unpack/convert
// =============================================================================

@FastNative
foreign func bgfx_vertex_pack(
    input: CPointer<Float32>,
    inputNormalized: Bool,
    attr: UInt32,
    layout: CPointer<VertexLayout>,
    data: CPointer<Unit>,
    index: UInt32
): Unit

@FastNative
foreign func bgfx_vertex_unpack(
    output: CPointer<Float32>,
    attr: UInt32,
    layout: CPointer<VertexLayout>,
    data: CPointer<Unit>,
    index: UInt32
): Unit

@FastNative
foreign func bgfx_vertex_convert(
    dstLayout: CPointer<VertexLayout>,
    dstData: CPointer<Unit>,
    srcLayout: CPointer<VertexLayout>,
    srcData: CPointer<Unit>,
    num: UInt32
): Unit

// 注：bgfx_weld_vertices 已随新版 bgfx 移除，绑定同步删除（如需顶点焊接由上层实现）。

// =============================================================================
// Topology
// =============================================================================

@FastNative
foreign func bgfx_topology_convert(
    conversion: UInt32,
    dst: CPointer<Unit>,
    dstSize: UInt32,
    indices: CPointer<Unit>,
    numIndices: UInt32,
    index32: Bool
): UInt32

@FastNative
foreign func bgfx_topology_sort_tri_list(
    sort: UInt32,
    dst: CPointer<Unit>,
    dstSize: UInt32,
    dir: CPointer<Float32>,
    pos: CPointer<Float32>,
    vertices: CPointer<Unit>,
    stride: UInt32,
    indices: CPointer<Unit>,
    numIndices: UInt32,
    index32: Bool
): Unit

// =============================================================================
// Renderer info
// =============================================================================

@FastNative
foreign func bgfx_get_supported_renderers(
    max: UInt8,
    `enum`: CPointer<UInt32>
): UInt8

@FastNative
foreign func bgfx_get_renderer_name(
    `type`: UInt32
): CString

// =============================================================================
// Init / shutdown
// =============================================================================

@FastNative
foreign func bgfx_init_ctor(`init`: CPointer<Init>): Unit

foreign func bgfx_init(`init`: CPointer<Init>): Bool

foreign func bgfx_shutdown(): Unit

// =============================================================================
// Reset / frame
// =============================================================================

// 新版 bgfx：reset(flags, swapChain*)。width/height/format/后缓冲均在
// SwapChain 描述符中；主窗口传其 init 时 swapChain 的更新副本。
@FastNative
foreign func bgfx_reset(
    flags: UInt32,
    swapChain: CPointer<SwapChain>
): Unit

// 新版 bgfx：frame 以 BGFX_FRAME_* 标志位提交（0=翻转，FRAME_FLIP=不翻转，
// FRAME_CAPTURE=捕获），取代旧 bool capture。
foreign func bgfx_frame(flags: UInt8): UInt32

@FastNative
foreign func bgfx_get_renderer_type(): UInt32

// =============================================================================
// Caps / stats
// =============================================================================

@FastNative
foreign func bgfx_get_caps(): CPointer<Caps>

@FastNative
foreign func bgfx_get_stats(): CPointer<Stats>

// =============================================================================
// Memory
// =============================================================================

@FastNative
foreign func bgfx_alloc(size: UInt32): CPointer<Memory>

@FastNative
foreign func bgfx_copy(data: CPointer<Unit>, size: UInt32): CPointer<Memory>

@FastNative
foreign func bgfx_make_ref(data: CPointer<Unit>, size: UInt32): CPointer<Memory>

@FastNative
foreign func bgfx_make_ref_release(
    data: CPointer<Unit>,
    size: UInt32,
    releaseFn: ReleaseFn,
    userData: CPointer<Unit>
): CPointer<Memory>

// =============================================================================
// Debug
// =============================================================================

// 新版 bgfx：debug 标志 + 调试输出目标 frame buffer（无效句柄=后缓冲）
// + 调试文本缩放。
@FastNative
foreign func bgfx_set_debug(
    debug: UInt32,
    frameBuffer: FrameBufferHandle,
    textScale: UInt8
): Unit

@FastNative
foreign func bgfx_dbg_text_clear(attr: UInt8, small: Bool): Unit

@FastNative
foreign func bgfx_dbg_text_printf(
    x: UInt16,
    y: UInt16,
    attr: UInt8,
    format: CString,
    ...
): Unit

@FastNative
foreign func bgfx_dbg_text_vprintf(
    x: UInt16,
    y: UInt16,
    attr: UInt8,
    format: CString,
    argList: CPointer<Unit>
): Unit

@FastNative
foreign func bgfx_dbg_text_image(
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16,
    data: CPointer<Unit>,
    pitch: UInt16
): Unit

// =============================================================================
// Index buffer
// =============================================================================

@FastNative
foreign func bgfx_create_index_buffer(
    mem: CPointer<Memory>,
    flags: UInt16
): IndexBufferHandle

@FastNative
foreign func bgfx_set_index_buffer_name(
    handle: IndexBufferHandle,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_destroy_index_buffer(handle: IndexBufferHandle): Unit

// =============================================================================
// Vertex layout (create/destroy)
// =============================================================================

@FastNative
foreign func bgfx_create_vertex_layout(layout: CPointer<VertexLayout>): VertexLayoutHandle

@FastNative
foreign func bgfx_destroy_vertex_layout(layoutHandle: VertexLayoutHandle): Unit

// =============================================================================
// Vertex buffer
// =============================================================================

@FastNative
foreign func bgfx_create_vertex_buffer(
    mem: CPointer<Memory>,
    layout: CPointer<VertexLayout>,
    flags: UInt16
): VertexBufferHandle

@FastNative
foreign func bgfx_set_vertex_buffer_name(
    handle: VertexBufferHandle,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_destroy_vertex_buffer(handle: VertexBufferHandle): Unit

// =============================================================================
// Dynamic index buffer
// =============================================================================

@FastNative
foreign func bgfx_create_dynamic_index_buffer(num: UInt32, flags: UInt16): DynamicIndexBufferHandle

@FastNative
foreign func bgfx_create_dynamic_index_buffer_mem(
    mem: CPointer<Memory>,
    flags: UInt16
): DynamicIndexBufferHandle

@FastNative
foreign func bgfx_update_dynamic_index_buffer(
    handle: DynamicIndexBufferHandle,
    startIndex: UInt32,
    mem: CPointer<Memory>
): Unit

@FastNative
foreign func bgfx_destroy_dynamic_index_buffer(handle: DynamicIndexBufferHandle): Unit

// =============================================================================
// Dynamic vertex buffer
// =============================================================================

@FastNative
foreign func bgfx_create_dynamic_vertex_buffer(
    num: UInt32,
    layout: CPointer<VertexLayout>,
    flags: UInt16
): DynamicVertexBufferHandle

@FastNative
foreign func bgfx_create_dynamic_vertex_buffer_mem(
    mem: CPointer<Memory>,
    layout: CPointer<VertexLayout>,
    flags: UInt16
): DynamicVertexBufferHandle

@FastNative
foreign func bgfx_update_dynamic_vertex_buffer(
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    mem: CPointer<Memory>
): Unit

@FastNative
foreign func bgfx_destroy_dynamic_vertex_buffer(handle: DynamicVertexBufferHandle): Unit

// =============================================================================
// Transient buffers
// =============================================================================

@FastNative
foreign func bgfx_get_avail_transient_index_buffer(num: UInt32, index32: Bool): UInt32

@FastNative
foreign func bgfx_get_avail_transient_vertex_buffer(
    num: UInt32,
    layout: CPointer<VertexLayout>
): UInt32

@FastNative
foreign func bgfx_get_avail_instance_data_buffer(num: UInt32, stride: UInt16): UInt32

@FastNative
foreign func bgfx_alloc_transient_index_buffer(
    tib: CPointer<TransientIndexBuffer>,
    num: UInt32,
    index32: Bool
): Unit

@FastNative
foreign func bgfx_alloc_transient_vertex_buffer(
    tvb: CPointer<TransientVertexBuffer>,
    num: UInt32,
    layout: CPointer<VertexLayout>
): Unit

@FastNative
foreign func bgfx_alloc_transient_buffers(
    tvb: CPointer<TransientVertexBuffer>,
    layout: CPointer<VertexLayout>,
    numVertices: UInt32,
    tib: CPointer<TransientIndexBuffer>,
    numIndices: UInt32,
    index32: Bool
): Bool

@FastNative
foreign func bgfx_alloc_instance_data_buffer(
    idb: CPointer<InstanceDataBuffer>,
    num: UInt32,
    stride: UInt16
): Unit

// =============================================================================
// Indirect buffer
// =============================================================================

@FastNative
foreign func bgfx_create_indirect_buffer(num: UInt32): IndirectBufferHandle

@FastNative
foreign func bgfx_destroy_indirect_buffer(handle: IndirectBufferHandle): Unit

// =============================================================================
// Shader
// =============================================================================

@FastNative
foreign func bgfx_create_shader(mem: CPointer<Memory>): ShaderHandle

@FastNative
foreign func bgfx_get_shader_uniforms(
    handle: ShaderHandle,
    uniforms: CPointer<UniformHandle>,
    max: UInt16
): UInt16

@FastNative
foreign func bgfx_set_shader_name(
    handle: ShaderHandle,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_destroy_shader(handle: ShaderHandle): Unit

// =============================================================================
// Program
// =============================================================================

@FastNative
foreign func bgfx_create_program(
    vsh: ShaderHandle,
    fsh: ShaderHandle,
    destroyShaders: Bool
): ProgramHandle

@FastNative
foreign func bgfx_create_compute_program(
    csh: ShaderHandle,
    destroyShaders: Bool
): ProgramHandle

@FastNative
foreign func bgfx_destroy_program(handle: ProgramHandle): Unit

// =============================================================================
// Texture validation and size
// =============================================================================

@FastNative
foreign func bgfx_is_texture_valid(
    depth: UInt16,
    cubeMap: Bool,
    numLayers: UInt16,
    format: UInt32,
    flags: UInt64
): Bool

@FastNative
foreign func bgfx_is_frame_buffer_valid(
    num: UInt8,
    attachment: CPointer<Attachment>
): Bool

@FastNative
foreign func bgfx_calc_texture_size(
    info: CPointer<TextureInfo>,
    width: UInt16,
    height: UInt16,
    depth: UInt16,
    cubeMap: Bool,
    hasMips: Bool,
    numLayers: UInt16,
    format: UInt32
): Unit

// =============================================================================
// Texture creation
// =============================================================================

@FastNative
foreign func bgfx_create_texture(
    mem: CPointer<Memory>,
    flags: UInt64,
    skip: UInt8,
    info: CPointer<TextureInfo>
): TextureHandle

@FastNative
foreign func bgfx_create_texture_2d(
    width: UInt16,
    height: UInt16,
    hasMips: Bool,
    numLayers: UInt16,
    format: UInt32,
    flags: UInt64,
    mem: CPointer<Memory>,
    external: UInt64
): TextureHandle

@FastNative
foreign func bgfx_create_texture_2d_scaled(
    ratio: UInt32,
    hasMips: Bool,
    numLayers: UInt16,
    format: UInt32,
    flags: UInt64
): TextureHandle

@FastNative
foreign func bgfx_create_texture_3d(
    width: UInt16,
    height: UInt16,
    depth: UInt16,
    hasMips: Bool,
    format: UInt32,
    flags: UInt64,
    mem: CPointer<Memory>,
    external: UInt64
): TextureHandle

@FastNative
foreign func bgfx_create_texture_cube(
    size: UInt16,
    hasMips: Bool,
    numLayers: UInt16,
    format: UInt32,
    flags: UInt64,
    mem: CPointer<Memory>,
    external: UInt64
): TextureHandle

// =============================================================================
// Texture update
// =============================================================================

@FastNative
foreign func bgfx_update_texture_2d(
    handle: TextureHandle,
    layer: UInt16,
    mip: UInt8,
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16,
    mem: CPointer<Memory>,
    pitch: UInt16
): Unit

@FastNative
foreign func bgfx_update_texture_3d(
    handle: TextureHandle,
    mip: UInt8,
    x: UInt16,
    y: UInt16,
    z: UInt16,
    width: UInt16,
    height: UInt16,
    depth: UInt16,
    mem: CPointer<Memory>
): Unit

@FastNative
foreign func bgfx_update_texture_cube(
    handle: TextureHandle,
    layer: UInt16,
    side: UInt8,
    mip: UInt8,
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16,
    mem: CPointer<Memory>,
    pitch: UInt16
): Unit

// =============================================================================
// Texture operations
// =============================================================================

// 新版 bgfx：以 TextureRegion 描述源区域（handle/mip/x/y/z/width/height/depth）。
@FastNative
foreign func bgfx_read_texture(
    src: CPointer<TextureRegion>,
    data: CPointer<Unit>
): UInt32

// 新版 bgfx：读取通用 buffer 区域。
@FastNative
foreign func bgfx_read_buffer(
    src: CPointer<BufferRegion>,
    data: CPointer<Unit>
): UInt32

// 新版 bgfx：清空纹理指定 mip/layer 范围。
@FastNative
foreign func bgfx_clear_texture(
    handle: TextureHandle,
    mip: UInt8,
    numMips: UInt8,
    layer: UInt16,
    numLayers: UInt16
): Unit

// 新版 bgfx：初始化 2D 纹理区域（mip=0、z/depth=0）。
@FastNative
foreign func bgfx_texture_region_init(
    region: CPointer<TextureRegion>,
    handle: TextureHandle,
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16
): Unit

// 新版 bgfx：初始化指向 buffer 的 BufferRegion。
@FastNative
foreign func bgfx_buffer_region_init_buffer(
    region: CPointer<BufferRegion>,
    handle: BufferHandle,
    offset: UInt32,
    size: UInt32
): Unit

// 新版 bgfx：按纹理区域推导初始化 BufferRegion（紧凑行间距）。
@FastNative
foreign func bgfx_buffer_region_init_texture(
    region: CPointer<BufferRegion>,
    texture: CPointer<TextureRegion>
): Unit

@FastNative
foreign func bgfx_set_texture_name(
    handle: TextureHandle,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_get_direct_access_ptr(handle: TextureHandle): CPointer<Unit>

@FastNative
foreign func bgfx_destroy_texture(handle: TextureHandle): Unit

// =============================================================================
// Frame buffer
// =============================================================================

@FastNative
foreign func bgfx_create_frame_buffer(
    width: UInt16,
    height: UInt16,
    format: UInt32,
    textureFlags: UInt64
): FrameBufferHandle

@FastNative
foreign func bgfx_create_frame_buffer_scaled(
    ratio: UInt32,
    format: UInt32,
    textureFlags: UInt64
): FrameBufferHandle

@FastNative
foreign func bgfx_create_frame_buffer_from_handles(
    num: UInt8,
    handles: CPointer<TextureHandle>,
    destroyTexture: Bool
): FrameBufferHandle

@FastNative
foreign func bgfx_create_frame_buffer_from_attachment(
    num: UInt8,
    attachment: CPointer<Attachment>,
    destroyTexture: Bool
): FrameBufferHandle

// 新版 bgfx：原生窗口 frame buffer 由 SwapChain 描述符创建/更新，
// 取代旧 bgfx_create_frame_buffer_from_nwh。
@FastNative
foreign func bgfx_create_frame_buffer_from_swap_chain(
    desc: CPointer<SwapChain>
): FrameBufferHandle

@FastNative
foreign func bgfx_update_swap_chain(
    handle: FrameBufferHandle,
    desc: CPointer<SwapChain>
): Unit

@FastNative
foreign func bgfx_set_frame_buffer_name(
    handle: FrameBufferHandle,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_get_texture(
    handle: FrameBufferHandle,
    attachment: UInt8
): TextureHandle

@FastNative
foreign func bgfx_destroy_frame_buffer(handle: FrameBufferHandle): Unit

// =============================================================================
// Uniform
// =============================================================================

@FastNative
foreign func bgfx_create_uniform(
    name: CString,
    `type`: UInt32,
    num: UInt16
): UniformHandle

// 新版 bgfx：可指定更新频率（UNIFORM_FREQ_*）创建 uniform。
@FastNative
foreign func bgfx_create_uniform_with_freq(
    name: CString,
    freq: UInt32,
    `type`: UInt32,
    num: UInt16
): UniformHandle

@FastNative
foreign func bgfx_get_uniform_info(
    handle: UniformHandle,
    info: CPointer<UniformInfo>
): Unit

@FastNative
foreign func bgfx_destroy_uniform(handle: UniformHandle): Unit

// =============================================================================
// Occlusion query
// =============================================================================

@FastNative
foreign func bgfx_create_occlusion_query(): OcclusionQueryHandle

@FastNative
foreign func bgfx_get_result(
    handle: OcclusionQueryHandle,
    result: CPointer<Int32>
): UInt32

@FastNative
foreign func bgfx_destroy_occlusion_query(handle: OcclusionQueryHandle): Unit

// =============================================================================
// Palette color
// =============================================================================

@FastNative
foreign func bgfx_set_palette_color(index: UInt8, rgba: CPointer<Float32>): Unit

@FastNative
foreign func bgfx_set_palette_color_rgba32f(
    index: UInt8,
    r: Float32,
    g: Float32,
    b: Float32,
    a: Float32
): Unit

@FastNative
foreign func bgfx_set_palette_color_rgba8(index: UInt8, rgba: UInt32): Unit

// =============================================================================
// View
// =============================================================================

@FastNative
foreign func bgfx_set_view_name(
    id: ViewId,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_set_view_rect(
    id: ViewId,
    x: Int16,
    y: Int16,
    width: UInt16,
    height: UInt16,
    minDepth: Float32,
    maxDepth: Float32
): Unit

@FastNative
foreign func bgfx_set_view_rect_ratio(
    id: ViewId,
    x: Int16,
    y: Int16,
    ratio: UInt32
): Unit

@FastNative
foreign func bgfx_set_view_scissor(
    id: ViewId,
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16
): Unit

@FastNative
foreign func bgfx_set_view_clear(
    id: ViewId,
    flags: UInt16,
    rgba: UInt32,
    depth: Float32,
    stencil: UInt8
): Unit

@FastNative
foreign func bgfx_set_view_clear_mrt(
    id: ViewId,
    flags: UInt16,
    depth: Float32,
    stencil: UInt8,
    c0: UInt8,
    c1: UInt8,
    c2: UInt8,
    c3: UInt8,
    c4: UInt8,
    c5: UInt8,
    c6: UInt8,
    c7: UInt8
): Unit

@FastNative
foreign func bgfx_set_view_mode(id: ViewId, mode: UInt32): Unit

// 新版 bgfx：view 级深度偏置。
@FastNative
foreign func bgfx_set_view_depth_bias(
    id: ViewId,
    constant: Int32,
    slopeScale: Float32,
    clamp: Float32
): Unit

// 新版 bgfx：view 级采样 mask。
@FastNative
foreign func bgfx_set_view_sample_mask(
    id: ViewId,
    mask: UInt32
): Unit

// 新版 bgfx：view 级着色率（ShadingRate 的 UInt32 表示）。
@FastNative
foreign func bgfx_set_view_shading_rate(
    id: ViewId,
    shadingRate: UInt32
): Unit

@FastNative
foreign func bgfx_set_view_frame_buffer(id: ViewId, handle: FrameBufferHandle): Unit

@FastNative
foreign func bgfx_set_view_transform(
    id: ViewId,
    view: CPointer<Unit>,
    proj: CPointer<Unit>
): Unit

@FastNative
foreign func bgfx_set_view_order(
    id: ViewId,
    num: UInt16,
    order: CPointer<ViewId>
): Unit

@FastNative
foreign func bgfx_reset_view(id: ViewId): Unit

// =============================================================================
// Encoder
// =============================================================================

foreign func bgfx_encoder_begin(forThread: Bool): CPointer<Encoder>

foreign func bgfx_encoder_end(encoder: CPointer<Encoder>): Unit

@FastNative
foreign func bgfx_encoder_set_marker(
    encoder: CPointer<Encoder>,
    name: CString,
    len: Int32
): Unit

@FastNative
foreign func bgfx_encoder_set_state(
    encoder: CPointer<Encoder>,
    state: UInt64,
    rgba: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_condition(
    encoder: CPointer<Encoder>,
    handle: OcclusionQueryHandle,
    visible: Bool
): Unit

@FastNative
foreign func bgfx_encoder_set_stencil(
    encoder: CPointer<Encoder>,
    fstencil: UInt32,
    bstencil: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_scissor(
    encoder: CPointer<Encoder>,
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16
): UInt16

@FastNative
foreign func bgfx_encoder_set_scissor_cached(
    encoder: CPointer<Encoder>,
    cache: UInt16
): Unit

@FastNative
foreign func bgfx_encoder_set_transform(
    encoder: CPointer<Encoder>,
    mtx: CPointer<Unit>,
    num: UInt16
): UInt32

@FastNative
foreign func bgfx_encoder_set_transform_cached(
    encoder: CPointer<Encoder>,
    cache: UInt32,
    num: UInt16
): Unit

@FastNative
foreign func bgfx_encoder_alloc_transform(
    encoder: CPointer<Encoder>,
    transform: CPointer<Transform>,
    num: UInt16
): UInt32

@FastNative
foreign func bgfx_encoder_set_uniform(
    encoder: CPointer<Encoder>,
    handle: UniformHandle,
    value: CPointer<Unit>,
    num: UInt16
): Unit

// 新版 bgfx：encoder 以引用方式设置 uniform。
@FastNative
foreign func bgfx_encoder_set_uniform_ref(
    encoder: CPointer<Encoder>,
    handle: UniformHandle,
    value: CPointer<Unit>,
    num: UInt16
): Unit

@FastNative
foreign func bgfx_encoder_set_index_buffer(
    encoder: CPointer<Encoder>,
    handle: IndexBufferHandle,
    firstIndex: UInt32,
    numIndices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_dynamic_index_buffer(
    encoder: CPointer<Encoder>,
    handle: DynamicIndexBufferHandle,
    firstIndex: UInt32,
    numIndices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_transient_index_buffer(
    encoder: CPointer<Encoder>,
    tib: CPointer<TransientIndexBuffer>,
    firstIndex: UInt32,
    numIndices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_vertex_buffer(
    encoder: CPointer<Encoder>,
    stream: UInt8,
    handle: VertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_vertex_buffer_with_layout(
    encoder: CPointer<Encoder>,
    stream: UInt8,
    handle: VertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32,
    layoutHandle: VertexLayoutHandle
): Unit

@FastNative
foreign func bgfx_encoder_set_dynamic_vertex_buffer(
    encoder: CPointer<Encoder>,
    stream: UInt8,
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_dynamic_vertex_buffer_with_layout(
    encoder: CPointer<Encoder>,
    stream: UInt8,
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32,
    layoutHandle: VertexLayoutHandle
): Unit

@FastNative
foreign func bgfx_encoder_set_transient_vertex_buffer(
    encoder: CPointer<Encoder>,
    stream: UInt8,
    tvb: CPointer<TransientVertexBuffer>,
    startVertex: UInt32,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_transient_vertex_buffer_with_layout(
    encoder: CPointer<Encoder>,
    stream: UInt8,
    tvb: CPointer<TransientVertexBuffer>,
    startVertex: UInt32,
    numVertices: UInt32,
    layoutHandle: VertexLayoutHandle
): Unit

@FastNative
foreign func bgfx_encoder_set_vertex_count(
    encoder: CPointer<Encoder>,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_instance_data_buffer(
    encoder: CPointer<Encoder>,
    idb: CPointer<InstanceDataBuffer>,
    start: UInt32,
    num: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_instance_data_from_vertex_buffer(
    encoder: CPointer<Encoder>,
    handle: VertexBufferHandle,
    startVertex: UInt32,
    num: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer(
    encoder: CPointer<Encoder>,
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    num: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_instance_count(
    encoder: CPointer<Encoder>,
    numInstances: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_texture(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    sampler: UniformHandle,
    handle: TextureHandle,
    flags: UInt32
): Unit

// 新版 bgfx：绑定纹理的指定 layer/mip 视图。
@FastNative
foreign func bgfx_encoder_set_texture_view(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    sampler: UniformHandle,
    handle: TextureHandle,
    firstLayer: UInt16,
    numLayers: UInt16,
    firstMip: UInt8,
    numMips: UInt8,
    flags: UInt32
): Unit

// 新版 bgfx：以 image 方式绑定纹理（compute 读写）。
@FastNative
foreign func bgfx_encoder_set_image_view(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: TextureHandle,
    firstLayer: UInt16,
    numLayers: UInt16,
    mip: UInt8,
    access: UInt32,
    format: UInt32
): Unit

// 新版 bgfx：设置采样 mask。
@FastNative
foreign func bgfx_encoder_set_sample_mask(
    encoder: CPointer<Encoder>,
    mask: UInt32
): Unit

// 新版 bgfx：设置深度控制，返回 cache id 供 _cached 版本复用。
@FastNative
foreign func bgfx_encoder_set_depth_control(
    encoder: CPointer<Encoder>,
    constant: Int32,
    slopeScale: Float32,
    clamp: Float32,
    depthClamp: Bool
): UInt16

@FastNative
foreign func bgfx_encoder_set_depth_control_cached(
    encoder: CPointer<Encoder>,
    cache: UInt16
): Unit

@FastNative
foreign func bgfx_encoder_touch(
    encoder: CPointer<Encoder>,
    id: ViewId
): Unit

@FastNative
foreign func bgfx_encoder_submit(
    encoder: CPointer<Encoder>,
    id: ViewId,
    program: ProgramHandle,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_encoder_submit_occlusion_query(
    encoder: CPointer<Encoder>,
    id: ViewId,
    program: ProgramHandle,
    occlusionQuery: OcclusionQueryHandle,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_encoder_submit_indirect(
    encoder: CPointer<Encoder>,
    id: ViewId,
    program: ProgramHandle,
    indirectHandle: IndirectBufferHandle,
    start: UInt32,
    num: UInt32,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_encoder_submit_indirect_count(
    encoder: CPointer<Encoder>,
    id: ViewId,
    program: ProgramHandle,
    indirectHandle: IndirectBufferHandle,
    start: UInt32,
    numHandle: IndexBufferHandle,
    numIndex: UInt32,
    numMax: UInt32,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_encoder_set_compute_index_buffer(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: IndexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_compute_vertex_buffer(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: VertexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_compute_dynamic_index_buffer(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: DynamicIndexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_compute_dynamic_vertex_buffer(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: DynamicVertexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_compute_indirect_buffer(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: IndirectBufferHandle,
    access: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_set_image(
    encoder: CPointer<Encoder>,
    stage: UInt8,
    handle: TextureHandle,
    mip: UInt8,
    access: UInt32,
    format: UInt32
): Unit

@FastNative
foreign func bgfx_encoder_dispatch(
    encoder: CPointer<Encoder>,
    id: ViewId,
    program: ProgramHandle,
    numX: UInt32,
    numY: UInt32,
    numZ: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_encoder_dispatch_indirect(
    encoder: CPointer<Encoder>,
    id: ViewId,
    program: ProgramHandle,
    indirectHandle: IndirectBufferHandle,
    start: UInt32,
    num: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_encoder_discard(
    encoder: CPointer<Encoder>,
    flags: UInt8
): Unit

// 新版 bgfx：blit 以 TextureRegion 描述符传源/目的区域。
@FastNative
foreign func bgfx_encoder_blit(
    encoder: CPointer<Encoder>,
    id: ViewId,
    dst: CPointer<TextureRegion>,
    src: CPointer<TextureRegion>
): Unit

@FastNative
foreign func bgfx_encoder_blit_buffer(
    encoder: CPointer<Encoder>,
    id: ViewId,
    dst: CPointer<BufferRegion>,
    src: CPointer<BufferRegion>
): Unit

@FastNative
foreign func bgfx_encoder_blit_to_buffer(
    encoder: CPointer<Encoder>,
    id: ViewId,
    dst: CPointer<BufferRegion>,
    src: CPointer<TextureRegion>
): Unit

@FastNative
foreign func bgfx_encoder_blit_from_buffer(
    encoder: CPointer<Encoder>,
    id: ViewId,
    dst: CPointer<TextureRegion>,
    src: CPointer<BufferRegion>
): Unit

// =============================================================================
// Screen shot
// =============================================================================

@FastNative
foreign func bgfx_request_screen_shot(
    handle: FrameBufferHandle,
    filePath: CString
): Unit

// =============================================================================
// Render frame
// =============================================================================

foreign func bgfx_render_frame(msecs: Int32): UInt32

// =============================================================================
// Platform data
// =============================================================================

// 注：bgfx_set_platform_data 已随新版 bgfx 移除（平台数据并入 bgfx_init_t /
// swap chain 描述），绑定同步删除。

@FastNative
foreign func bgfx_get_internal_data(): CPointer<InternalData>

// 注：bgfx_override_internal_texture_ptr / bgfx_override_internal_texture
// 已随新版 bgfx 移除（C99 头中不再提供），绑定同步删除。

// =============================================================================
// Non-encoder rendering state (immediate mode)
// =============================================================================

@FastNative
foreign func bgfx_set_marker(name: CString, len: Int32): Unit

@FastNative
foreign func bgfx_set_state(state: UInt64, rgba: UInt32): Unit

@FastNative
foreign func bgfx_set_condition(
    handle: OcclusionQueryHandle,
    visible: Bool
): Unit

@FastNative
foreign func bgfx_set_stencil(fstencil: UInt32, bstencil: UInt32): Unit

@FastNative
foreign func bgfx_set_scissor(
    x: UInt16,
    y: UInt16,
    width: UInt16,
    height: UInt16
): UInt16

@FastNative
foreign func bgfx_set_scissor_cached(cache: UInt16): Unit

@FastNative
foreign func bgfx_set_transform(mtx: CPointer<Unit>, num: UInt16): UInt32

@FastNative
foreign func bgfx_set_transform_cached(cache: UInt32, num: UInt16): Unit

@FastNative
foreign func bgfx_alloc_transform(
    transform: CPointer<Transform>,
    num: UInt16
): UInt32

@FastNative
foreign func bgfx_set_uniform(
    handle: UniformHandle,
    value: CPointer<Unit>,
    num: UInt16
): Unit

// 新版 bgfx：以引用方式设置 uniform（value 指向调用方持有的数据）。
@FastNative
foreign func bgfx_set_uniform_ref(
    handle: UniformHandle,
    value: CPointer<Unit>,
    num: UInt16
): Unit

// 新版 bgfx：设置帧级 uniform（整帧常量）。
@FastNative
foreign func bgfx_set_frame_uniform(
    handle: UniformHandle,
    value: CPointer<Unit>,
    num: UInt16
): Unit

// 新版 bgfx：设置 view 级 uniform。
@FastNative
foreign func bgfx_set_view_uniform(
    id: ViewId,
    handle: UniformHandle,
    value: CPointer<Unit>,
    num: UInt16
): Unit

@FastNative
foreign func bgfx_set_index_buffer(
    handle: IndexBufferHandle,
    firstIndex: UInt32,
    numIndices: UInt32
): Unit

@FastNative
foreign func bgfx_set_dynamic_index_buffer(
    handle: DynamicIndexBufferHandle,
    firstIndex: UInt32,
    numIndices: UInt32
): Unit

@FastNative
foreign func bgfx_set_transient_index_buffer(
    tib: CPointer<TransientIndexBuffer>,
    firstIndex: UInt32,
    numIndices: UInt32
): Unit

@FastNative
foreign func bgfx_set_vertex_buffer(
    stream: UInt8,
    handle: VertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_set_vertex_buffer_with_layout(
    stream: UInt8,
    handle: VertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32,
    layoutHandle: VertexLayoutHandle
): Unit

@FastNative
foreign func bgfx_set_dynamic_vertex_buffer(
    stream: UInt8,
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_set_dynamic_vertex_buffer_with_layout(
    stream: UInt8,
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    numVertices: UInt32,
    layoutHandle: VertexLayoutHandle
): Unit

@FastNative
foreign func bgfx_set_transient_vertex_buffer(
    stream: UInt8,
    tvb: CPointer<TransientVertexBuffer>,
    startVertex: UInt32,
    numVertices: UInt32
): Unit

@FastNative
foreign func bgfx_set_transient_vertex_buffer_with_layout(
    stream: UInt8,
    tvb: CPointer<TransientVertexBuffer>,
    startVertex: UInt32,
    numVertices: UInt32,
    layoutHandle: VertexLayoutHandle
): Unit

@FastNative
foreign func bgfx_set_vertex_count(numVertices: UInt32): Unit

@FastNative
foreign func bgfx_set_instance_data_buffer(
    idb: CPointer<InstanceDataBuffer>,
    start: UInt32,
    num: UInt32
): Unit

@FastNative
foreign func bgfx_set_instance_data_from_vertex_buffer(
    handle: VertexBufferHandle,
    startVertex: UInt32,
    num: UInt32
): Unit

@FastNative
foreign func bgfx_set_instance_data_from_dynamic_vertex_buffer(
    handle: DynamicVertexBufferHandle,
    startVertex: UInt32,
    num: UInt32
): Unit

@FastNative
foreign func bgfx_set_instance_count(numInstances: UInt32): Unit

@FastNative
foreign func bgfx_set_texture(
    stage: UInt8,
    sampler: UniformHandle,
    handle: TextureHandle,
    flags: UInt32
): Unit

// 新版 bgfx：绑定纹理的指定 layer/mip 视图。
@FastNative
foreign func bgfx_set_texture_view(
    stage: UInt8,
    sampler: UniformHandle,
    handle: TextureHandle,
    firstLayer: UInt16,
    numLayers: UInt16,
    firstMip: UInt8,
    numMips: UInt8,
    flags: UInt32
): Unit

// 新版 bgfx：以 image 方式绑定纹理（compute 读写）。
@FastNative
foreign func bgfx_set_image_view(
    stage: UInt8,
    handle: TextureHandle,
    firstLayer: UInt16,
    numLayers: UInt16,
    mip: UInt8,
    access: UInt32,
    format: UInt32
): Unit

// 新版 bgfx：设置采样 mask。
@FastNative
foreign func bgfx_set_sample_mask(mask: UInt32): Unit

// 新版 bgfx：设置深度控制，返回 cache id 供 _cached 版本复用。
@FastNative
foreign func bgfx_set_depth_control(
    constant: Int32,
    slopeScale: Float32,
    clamp: Float32,
    depthClamp: Bool
): UInt16

@FastNative
foreign func bgfx_set_depth_control_cached(cache: UInt16): Unit

@FastNative
foreign func bgfx_touch(id: ViewId): Unit

@FastNative
foreign func bgfx_submit(
    id: ViewId,
    program: ProgramHandle,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_submit_occlusion_query(
    id: ViewId,
    program: ProgramHandle,
    occlusionQuery: OcclusionQueryHandle,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_submit_indirect(
    id: ViewId,
    program: ProgramHandle,
    indirectHandle: IndirectBufferHandle,
    start: UInt32,
    num: UInt32,
    depth: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_submit_indirect_count(
    id: ViewId,
    program: ProgramHandle,
    indirectHandle: IndirectBufferHandle,
    start: UInt32,
    numHandle: IndexBufferHandle,
    numIndex: UInt32,
    numMax: UInt32,
    depth: UInt32,
    flags: UInt8
): Unit

// =============================================================================
// Non-encoder compute
// =============================================================================

@FastNative
foreign func bgfx_set_compute_index_buffer(
    stage: UInt8,
    handle: IndexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_set_compute_vertex_buffer(
    stage: UInt8,
    handle: VertexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_set_compute_dynamic_index_buffer(
    stage: UInt8,
    handle: DynamicIndexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_set_compute_dynamic_vertex_buffer(
    stage: UInt8,
    handle: DynamicVertexBufferHandle,
    access: UInt32,
    offset: UInt32,
    size: UInt32
): Unit

@FastNative
foreign func bgfx_set_compute_indirect_buffer(
    stage: UInt8,
    handle: IndirectBufferHandle,
    access: UInt32
): Unit

@FastNative
foreign func bgfx_set_image(
    stage: UInt8,
    handle: TextureHandle,
    mip: UInt8,
    access: UInt32,
    format: UInt32
): Unit

@FastNative
foreign func bgfx_dispatch(
    id: ViewId,
    program: ProgramHandle,
    numX: UInt32,
    numY: UInt32,
    numZ: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_dispatch_indirect(
    id: ViewId,
    program: ProgramHandle,
    indirectHandle: IndirectBufferHandle,
    start: UInt32,
    num: UInt32,
    flags: UInt8
): Unit

@FastNative
foreign func bgfx_discard(flags: UInt8): Unit

// 新版 bgfx：blit 以 TextureRegion 描述符传源/目的区域。
@FastNative
foreign func bgfx_blit(
    id: ViewId,
    dst: CPointer<TextureRegion>,
    src: CPointer<TextureRegion>
): Unit

@FastNative
foreign func bgfx_blit_buffer(
    id: ViewId,
    dst: CPointer<BufferRegion>,
    src: CPointer<BufferRegion>
): Unit

@FastNative
foreign func bgfx_blit_to_buffer(
    id: ViewId,
    dst: CPointer<BufferRegion>,
    src: CPointer<TextureRegion>
): Unit

@FastNative
foreign func bgfx_blit_from_buffer(
    id: ViewId,
    dst: CPointer<TextureRegion>,
    src: CPointer<BufferRegion>
): Unit

// =============================================================================
// Video
// =============================================================================

// 新版 bgfx：校验指定视频编解码参数是否被当前后端支持。
@FastNative
foreign func bgfx_is_video_codec_valid(
    codec: UInt32,
    chroma: UInt8,
    bitDepth: UInt8,
    codedWidth: UInt16,
    codedHeight: UInt16,
    maxDpbSlots: UInt8,
    maxActiveReferences: UInt8
): Bool

// =============================================================================
// Interface
// =============================================================================

@FastNative
foreign func bgfx_get_interface(version: UInt32): CPointer<Unit>
