/**
 * @file bgfx 公共函数包装
 * @brief bgfx C99 API 的仓颉安全包装函数
 * @explain 本文件为每个 bgfx foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note 每个函数对应一个 C 端 bgfx 函数，功能与 C API 一致。
 *     Cangjie 从外部调用时，应使用这些 `_cj` 后缀的包装函数。
 */
protected package three._vendor.bgfx4cj.bgfx

/**
 * @brief 初始化帧缓冲附件描述符
 * @param `this` 对象实例指针
 * @param handle 资源句柄
 * @param access 访问权限
 * @param layer 图层索引
 * @param numLayers 图层数量
 * @param mip Mip 等级
 * @param flags 附加标志（ATTACHMENT_*；旧版 resolve 语义由 ATTACHMENT_AUTO_GEN_MIPS 等承载）
 */
public func bgfx_attachment_init_cj(`this`: CPointer<Attachment>, handle: TextureHandle, access: UInt32, layer: UInt16, numLayers: UInt16, mip: UInt16, flags!: UInt8 = ATTACHMENT_NONE): Unit {
    unsafe {
        bgfx_attachment_init(`this`, handle, access, layer, numLayers, mip, flags)
    }
}

/**
 * @brief 开始声明顶点布局，指定渲染器类型
 * @param `this` 对象实例指针
 * @param rendererType 渲染器类型
 * @return CPointer 返回值描述
 */
public func bgfx_vertex_layout_begin_cj(`this`: CPointer<VertexLayout>, rendererType: UInt32): CPointer<VertexLayout> {
    return unsafe {
        bgfx_vertex_layout_begin(`this`, rendererType)
    }
}

/**
 * @brief 向顶点布局添加一个属性
 * @param `this` 对象实例指针
 * @param attrib 属性类型
 * @param num 数量
 * @param `type` type
 * @param normalized 是否归一化
 * @param asInt 是否整数处理
 * @return CPointer 返回值描述
 */
public func bgfx_vertex_layout_add_cj(`this`: CPointer<VertexLayout>, attrib: UInt32, num: UInt8, `type`: UInt32, normalized: Bool, asInt: Bool): CPointer<VertexLayout> {
    return unsafe {
        bgfx_vertex_layout_add(`this`, attrib, num, `type`, normalized, asInt)
    }
}

/**
 * @brief 解码顶点布局中指定属性的编码信息
 * @param `this` 对象实例指针
 * @param attrib 属性类型
 * @param num 数量
 * @param `type` type
 * @param normalized 是否归一化
 * @param asInt 是否整数处理
 */
public func bgfx_vertex_layout_decode_cj(`this`: CPointer<VertexLayout>, attrib: UInt32, num: CPointer<UInt8>, `type`: CPointer<UInt32>, normalized: CPointer<Bool>, asInt: CPointer<Bool>): Unit {
    unsafe {
        bgfx_vertex_layout_decode(`this`, attrib, num, `type`, normalized, asInt)
    }
}

/**
 * @brief 检查顶点布局是否包含指定属性
 * @param `this` 对象实例指针
 * @param attrib 属性类型
 * @return Bool 返回值描述
 */
public func bgfx_vertex_layout_has_cj(`this`: CPointer<VertexLayout>, attrib: UInt32): Bool {
    return unsafe {
        bgfx_vertex_layout_has(`this`, attrib)
    }
}

/**
 * @brief 在顶点布局中跳过指定数量的字节
 * @param `this` 对象实例指针
 * @param num 数量
 * @return CPointer 返回值描述
 */
public func bgfx_vertex_layout_skip_cj(`this`: CPointer<VertexLayout>, num: UInt8): CPointer<VertexLayout> {
    return unsafe {
        bgfx_vertex_layout_skip(`this`, num)
    }
}

/**
 * @brief 结束顶点布局声明
 * @param `this` 对象实例指针
 */
public func bgfx_vertex_layout_end_cj(`this`: CPointer<VertexLayout>): Unit {
    unsafe {
        bgfx_vertex_layout_end(`this`)
    }
}

/**
 * @brief 获取顶点布局中指定属性的偏移量
 * @param `this` 对象实例指针
 * @param attrib 属性类型
 * @return UInt16 返回值描述
 */
public func bgfx_vertex_layout_get_offset_cj(`this`: CPointer<VertexLayout>, attrib: UInt32): UInt16 {
    return unsafe {
        bgfx_vertex_layout_get_offset(`this`, attrib)
    }
}

/**
 * @brief 获取顶点布局的步长（单个顶点字节数）
 * @param `this` 对象实例指针
 * @return UInt16 返回值描述
 */
public func bgfx_vertex_layout_get_stride_cj(`this`: CPointer<VertexLayout>): UInt16 {
    return unsafe {
        bgfx_vertex_layout_get_stride(`this`)
    }
}

/**
 * @brief 获取顶点布局处理指定数量顶点所需的大小
 * @param `this` 对象实例指针
 * @param num 数量
 * @return UInt32 返回值描述
 */
public func bgfx_vertex_layout_get_size_cj(`this`: CPointer<VertexLayout>, num: UInt32): UInt32 {
    return unsafe {
        bgfx_vertex_layout_get_size(`this`, num)
    }
}

/**
 * @brief 将浮点顶点属性打包到紧凑格式
 * @param input 输入数据
 * @param inputNormalized 输入是否归一化
 * @param attr 属性类型
 * @param layout 顶点布局
 * @param data 数据指针
 * @param index 索引
 */
public func bgfx_vertex_pack_cj(input: CPointer<Float32>, inputNormalized: Bool, attr: UInt32, layout: CPointer<VertexLayout>, data: CPointer<Unit>, index: UInt32): Unit {
    unsafe {
        bgfx_vertex_pack(input, inputNormalized, attr, layout, data, index)
    }
}

/**
 * @brief 从紧凑格式解包浮点顶点属性
 * @param output 输出数据
 * @param attr 属性类型
 * @param layout 顶点布局
 * @param data 数据指针
 * @param index 索引
 */
public func bgfx_vertex_unpack_cj(output: CPointer<Float32>, attr: UInt32, layout: CPointer<VertexLayout>, data: CPointer<Unit>, index: UInt32): Unit {
    unsafe {
        bgfx_vertex_unpack(output, attr, layout, data, index)
    }
}

/**
 * @brief 在两种顶点布局之间转换顶点数据
 * @param dstLayout 目标布局
 * @param dstData 目标数据
 * @param srcLayout 源布局
 * @param srcData 源数据
 * @param num 数量
 */
public func bgfx_vertex_convert_cj(dstLayout: CPointer<VertexLayout>, dstData: CPointer<Unit>, srcLayout: CPointer<VertexLayout>, srcData: CPointer<Unit>, num: UInt32): Unit {
    unsafe {
        bgfx_vertex_convert(dstLayout, dstData, srcLayout, srcData, num)
    }
}

// 注：bgfx_weld_vertices_cj 已随新版 bgfx 移除 bgfx_weld_vertices 而删除。

/**
 * @brief 拓扑转换（如三角条带转三角列表）
 * @param conversion 转换类型
 * @param dst 目标缓冲
 * @param dstSize 目标缓冲大小
 * @param indices 索引数据
 * @param numIndices 索引数量
 * @param index32 是否32位索引
 * @return UInt32 返回值描述
 */
public func bgfx_topology_convert_cj(conversion: UInt32, dst: CPointer<Unit>, dstSize: UInt32, indices: CPointer<Unit>, numIndices: UInt32, index32: Bool): UInt32 {
    return unsafe {
        bgfx_topology_convert(conversion, dst, dstSize, indices, numIndices, index32)
    }
}

/**
 * @brief 排序三角形列表（用于透明物体排序）
 * @param sort 排序类型
 * @param dst 目标缓冲
 * @param dstSize 目标缓冲大小
 * @param dir 方向向量
 * @param pos 位置
 * @param vertices 顶点数据
 * @param stride 步长（字节）
 * @param indices 索引数据
 * @param numIndices 索引数量
 * @param index32 是否32位索引
 */
public func bgfx_topology_sort_tri_list_cj(sort: UInt32, dst: CPointer<Unit>, dstSize: UInt32, dir: CPointer<Float32>, pos: CPointer<Float32>, vertices: CPointer<Unit>, stride: UInt32, indices: CPointer<Unit>, numIndices: UInt32, index32: Bool): Unit {
    unsafe {
        bgfx_topology_sort_tri_list(sort, dst, dstSize, dir, pos, vertices, stride, indices, numIndices, index32)
    }
}

/**
 * @brief 获取支持的渲染器列表
 * @param max 最大数量
 * @param `enum` enum
 * @return UInt8 返回值描述
 */
public func bgfx_get_supported_renderers_cj(max: UInt8, `enum`: CPointer<UInt32>): UInt8 {
    return unsafe {
        bgfx_get_supported_renderers(max, `enum`)
    }
}

/**
 * @brief 获取渲染器名称字符串
 * @param `type` type
 * @return CString 返回值描述
 */
public func bgfx_get_renderer_name_cj(`type`: UInt32): CString {
    return unsafe {
        bgfx_get_renderer_name(`type`)
    }
}

/**
 * @brief 初始化 bgfx Init 结构体为默认值
 * @param `init` init
 */
public func bgfx_init_ctor_cj(`init`: CPointer<Init>): Unit {
    unsafe {
        bgfx_init_ctor(`init`)
    }
}

/**
 * @brief 初始化 bgfx 渲染器
 * @param `init` init
 * @return Bool 返回值描述
 */
public func bgfx_init_cj(`init`: CPointer<Init>): Bool {
    return unsafe {
        bgfx_init(`init`)
    }
}

/**
 * @brief 关闭 bgfx 渲染器
 */
public func bgfx_shutdown_cj(): Unit {
    unsafe {
        bgfx_shutdown()
    }
}

/**
 * @brief 重置设备与主交换链（分辨率/标志变更时）
 * @explain 新版 bgfx：width/height/格式/后缓冲数等表面属性全部在
 * SwapChain 描述符中，flags 仅承载设备与帧全局设置（RESET_*）。
 * 调用方传入与 init 时同一 swapChain 的更新副本。
 * @param flags 重置标志位（RESET_*）
 * @param swapChain 交换链描述符指针
 */
public func bgfx_reset_cj(flags: UInt32, swapChain: CPointer<SwapChain>): Unit {
    unsafe {
        bgfx_reset(flags, swapChain)
    }
}

/**
 * @brief 提交一帧渲染，返回帧号
 * @param flags 帧标志（FRAME_NONE/FRAME_DEBUG_CAPTURE/FRAME_DISCARD/FRAME_FLUSH）
 * @return 当前编码后的帧号
 */
public func bgfx_frame_cj(flags!: UInt8 = FRAME_NONE): UInt32 {
    return unsafe {
        bgfx_frame(flags)
    }
}

/**
 * @brief 获取当前渲染器类型
 * @return UInt32 返回值描述
 */
public func bgfx_get_renderer_type_cj(): UInt32 {
    return unsafe {
        bgfx_get_renderer_type()
    }
}

/**
 * @brief 获取渲染器能力信息
 * @return CPointer 返回值描述
 */
public func bgfx_get_caps_cj(): CPointer<Caps> {
    return unsafe {
        bgfx_get_caps()
    }
}

/**
 * @brief 获取渲染器统计信息
 * @return CPointer 返回值描述
 */
public func bgfx_get_stats_cj(): CPointer<Stats> {
    return unsafe {
        bgfx_get_stats()
    }
}

/**
 * @brief 分配 bgfx 内存块
 * @param size 大小（字节）
 * @return CPointer 返回值描述
 */
public func bgfx_alloc_cj(size: UInt32): CPointer<Memory> {
    return unsafe {
        bgfx_alloc(size)
    }
}

/**
 * @brief 拷贝数据到 bgfx 内存块
 * @param data 数据指针
 * @param size 大小（字节）
 * @return CPointer 返回值描述
 */
public func bgfx_copy_cj(data: CPointer<Unit>, size: UInt32): CPointer<Memory> {
    return unsafe {
        bgfx_copy(data, size)
    }
}

/**
 * @brief 创建引用现有数据的内存块（不拷贝）
 * @param data 数据指针
 * @param size 大小（字节）
 * @return CPointer 返回值描述
 */
public func bgfx_make_ref_cj(data: CPointer<Unit>, size: UInt32): CPointer<Memory> {
    return unsafe {
        bgfx_make_ref(data, size)
    }
}

/**
 * @brief 创建带释放回调的引用内存块
 * @param data 数据指针
 * @param size 大小（字节）
 * @param releaseFn 释放回调函数
 * @param userData 用户数据指针
 * @return CPointer 返回值描述
 */
public func bgfx_make_ref_release_cj(data: CPointer<Unit>, size: UInt32, releaseFn: ReleaseFn, userData: CPointer<Unit>): CPointer<Memory> {
    return unsafe {
        bgfx_make_ref_release(data, size, releaseFn, userData)
    }
}

/**
 * @brief 设置调试标志
 * @explain 新版 bgfx 可指定调试绘制目标 frame buffer（默认无效句柄=后缓冲）
 * 与调试文本缩放。
 * @param debug 调试标志（DEBUG_* 组合）
 * @param frameBuffer 调试输出目标 frame buffer（无效句柄=后缓冲）
 * @param textScale 调试文本缩放（1=原始大小）
 */
public func bgfx_set_debug_cj(
    debug: UInt32,
    frameBuffer!: FrameBufferHandle = FrameBufferHandle(),
    textScale!: UInt8 = 1
): Unit {
    unsafe {
        bgfx_set_debug(debug, frameBuffer, textScale)
    }
}

/**
 * @brief 清除调试文本屏幕
 * @param attr 属性类型
 * @param small 是否小字体
 */
public func bgfx_dbg_text_clear_cj(attr: UInt8, small: Bool): Unit {
    unsafe {
        bgfx_dbg_text_clear(attr, small)
    }
}

/**
 * @brief 在调试文本屏幕上打印格式化字符串
 * @param x X 坐标
 * @param y Y 坐标
 * @param attr 属性类型
 * @param format 格式
 */
public func bgfx_dbg_text_printf_cj(x: UInt16, y: UInt16, attr: UInt8, format: CString): Unit {
    unsafe {
        bgfx_dbg_text_printf(x, y, attr, format)
    }
}

/**
 * @brief 在调试文本屏幕上打印可变参数格式化字符串
 * @param x X 坐标
 * @param y Y 坐标
 * @param attr 属性类型
 * @param format 格式
 * @param argList 可变参数列表指针
 */
public func bgfx_dbg_text_vprintf_cj(x: UInt16, y: UInt16, attr: UInt8, format: CString, argList: CPointer<Unit>): Unit {
    unsafe {
        bgfx_dbg_text_vprintf(x, y, attr, format, argList)
    }
}

/**
 * @brief 在调试文本屏幕上显示图像数据
 * @param x X 坐标
 * @param y Y 坐标
 * @param width 宽度
 * @param height 高度
 * @param data 数据指针
 * @param pitch 行步长
 */
public func bgfx_dbg_text_image_cj(x: UInt16, y: UInt16, width: UInt16, height: UInt16, data: CPointer<Unit>, pitch: UInt16): Unit {
    unsafe {
        bgfx_dbg_text_image(x, y, width, height, data, pitch)
    }
}

/**
 * @brief 创建索引缓冲
 * @param mem 内存块指针
 * @param flags 标志位
 * @return IndexBufferHandle 返回值描述
 */
public func bgfx_create_index_buffer_cj(mem: CPointer<Memory>, flags: UInt16): IndexBufferHandle {
    return unsafe {
        bgfx_create_index_buffer(mem, flags)
    }
}

/**
 * @brief 设置索引缓冲名称（调试用）
 * @param handle 资源句柄
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_index_buffer_name_cj(handle: IndexBufferHandle, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_index_buffer_name(handle, name, len)
    }
}

/**
 * @brief 销毁索引缓冲
 * @param handle 资源句柄
 */
public func bgfx_destroy_index_buffer_cj(handle: IndexBufferHandle): Unit {
    unsafe {
        bgfx_destroy_index_buffer(handle)
    }
}

/**
 * @brief 创建顶点布局句柄
 * @param layout 顶点布局
 * @return VertexLayoutHandle 返回值描述
 */
public func bgfx_create_vertex_layout_cj(layout: CPointer<VertexLayout>): VertexLayoutHandle {
    return unsafe {
        bgfx_create_vertex_layout(layout)
    }
}

/**
 * @brief 销毁顶点布局句柄
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_destroy_vertex_layout_cj(layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_destroy_vertex_layout(layoutHandle)
    }
}

/**
 * @brief 创建顶点缓冲
 * @param mem 内存块指针
 * @param layout 顶点布局
 * @param flags 标志位
 * @return VertexBufferHandle 返回值描述
 */
public func bgfx_create_vertex_buffer_cj(mem: CPointer<Memory>, layout: CPointer<VertexLayout>, flags: UInt16): VertexBufferHandle {
    return unsafe {
        bgfx_create_vertex_buffer(mem, layout, flags)
    }
}

/**
 * @brief 设置顶点缓冲名称（调试用）
 * @param handle 资源句柄
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_vertex_buffer_name_cj(handle: VertexBufferHandle, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_vertex_buffer_name(handle, name, len)
    }
}

/**
 * @brief 销毁顶点缓冲
 * @param handle 资源句柄
 */
public func bgfx_destroy_vertex_buffer_cj(handle: VertexBufferHandle): Unit {
    unsafe {
        bgfx_destroy_vertex_buffer(handle)
    }
}

/**
 * @brief 创建动态索引缓冲（指定数量）
 * @param num 数量
 * @param flags 标志位
 * @return DynamicIndexBufferHandle 返回值描述
 */
public func bgfx_create_dynamic_index_buffer_cj(num: UInt32, flags: UInt16): DynamicIndexBufferHandle {
    return unsafe {
        bgfx_create_dynamic_index_buffer(num, flags)
    }
}

/**
 * @brief 创建动态索引缓冲（从内存数据）
 * @param mem 内存块指针
 * @param flags 标志位
 * @return DynamicIndexBufferHandle 返回值描述
 */
public func bgfx_create_dynamic_index_buffer_mem_cj(mem: CPointer<Memory>, flags: UInt16): DynamicIndexBufferHandle {
    return unsafe {
        bgfx_create_dynamic_index_buffer_mem(mem, flags)
    }
}

/**
 * @brief 更新动态索引缓冲
 * @param handle 资源句柄
 * @param startIndex 起始索引
 * @param mem 内存块指针
 */
public func bgfx_update_dynamic_index_buffer_cj(handle: DynamicIndexBufferHandle, startIndex: UInt32, mem: CPointer<Memory>): Unit {
    unsafe {
        bgfx_update_dynamic_index_buffer(handle, startIndex, mem)
    }
}

/**
 * @brief 销毁动态索引缓冲
 * @param handle 资源句柄
 */
public func bgfx_destroy_dynamic_index_buffer_cj(handle: DynamicIndexBufferHandle): Unit {
    unsafe {
        bgfx_destroy_dynamic_index_buffer(handle)
    }
}

/**
 * @brief 创建动态顶点缓冲（指定数量）
 * @param num 数量
 * @param layout 顶点布局
 * @param flags 标志位
 * @return DynamicVertexBufferHandle 返回值描述
 */
public func bgfx_create_dynamic_vertex_buffer_cj(num: UInt32, layout: CPointer<VertexLayout>, flags: UInt16): DynamicVertexBufferHandle {
    return unsafe {
        bgfx_create_dynamic_vertex_buffer(num, layout, flags)
    }
}

/**
 * @brief 创建动态顶点缓冲（从内存数据）
 * @param mem 内存块指针
 * @param layout 顶点布局
 * @param flags 标志位
 * @return DynamicVertexBufferHandle 返回值描述
 */
public func bgfx_create_dynamic_vertex_buffer_mem_cj(mem: CPointer<Memory>, layout: CPointer<VertexLayout>, flags: UInt16): DynamicVertexBufferHandle {
    return unsafe {
        bgfx_create_dynamic_vertex_buffer_mem(mem, layout, flags)
    }
}

/**
 * @brief 更新动态顶点缓冲
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param mem 内存块指针
 */
public func bgfx_update_dynamic_vertex_buffer_cj(handle: DynamicVertexBufferHandle, startVertex: UInt32, mem: CPointer<Memory>): Unit {
    unsafe {
        bgfx_update_dynamic_vertex_buffer(handle, startVertex, mem)
    }
}

/**
 * @brief 销毁动态顶点缓冲
 * @param handle 资源句柄
 */
public func bgfx_destroy_dynamic_vertex_buffer_cj(handle: DynamicVertexBufferHandle): Unit {
    unsafe {
        bgfx_destroy_dynamic_vertex_buffer(handle)
    }
}

/**
 * @brief 获取可用瞬态索引缓冲数量
 * @param num 数量
 * @param index32 是否32位索引
 * @return UInt32 返回值描述
 */
public func bgfx_get_avail_transient_index_buffer_cj(num: UInt32, index32: Bool): UInt32 {
    return unsafe {
        bgfx_get_avail_transient_index_buffer(num, index32)
    }
}

/**
 * @brief 获取可用瞬态顶点缓冲数量
 * @param num 数量
 * @param layout 顶点布局
 * @return UInt32 返回值描述
 */
public func bgfx_get_avail_transient_vertex_buffer_cj(num: UInt32, layout: CPointer<VertexLayout>): UInt32 {
    return unsafe {
        bgfx_get_avail_transient_vertex_buffer(num, layout)
    }
}

/**
 * @brief 获取可用实例数据缓冲数量
 * @param num 数量
 * @param stride 步长（字节）
 * @return UInt32 返回值描述
 */
public func bgfx_get_avail_instance_data_buffer_cj(num: UInt32, stride: UInt16): UInt32 {
    return unsafe {
        bgfx_get_avail_instance_data_buffer(num, stride)
    }
}

/**
 * @brief 分配瞬态索引缓冲
 * @param tib 瞬态索引缓冲指针
 * @param num 数量
 * @param index32 是否32位索引
 */
public func bgfx_alloc_transient_index_buffer_cj(tib: CPointer<TransientIndexBuffer>, num: UInt32, index32: Bool): Unit {
    unsafe {
        bgfx_alloc_transient_index_buffer(tib, num, index32)
    }
}

/**
 * @brief 分配瞬态顶点缓冲
 * @param tvb 瞬态顶点缓冲指针
 * @param num 数量
 * @param layout 顶点布局
 */
public func bgfx_alloc_transient_vertex_buffer_cj(tvb: CPointer<TransientVertexBuffer>, num: UInt32, layout: CPointer<VertexLayout>): Unit {
    unsafe {
        bgfx_alloc_transient_vertex_buffer(tvb, num, layout)
    }
}

/**
 * @brief 同时分配瞬态索引和顶点缓冲
 * @param tvb 瞬态顶点缓冲指针
 * @param layout 顶点布局
 * @param numVertices 顶点数量
 * @param tib 瞬态索引缓冲指针
 * @param numIndices 索引数量
 * @param index32 是否32位索引
 * @return Bool 返回值描述
 */
public func bgfx_alloc_transient_buffers_cj(tvb: CPointer<TransientVertexBuffer>, layout: CPointer<VertexLayout>, numVertices: UInt32, tib: CPointer<TransientIndexBuffer>, numIndices: UInt32, index32: Bool): Bool {
    return unsafe {
        bgfx_alloc_transient_buffers(tvb, layout, numVertices, tib, numIndices, index32)
    }
}

/**
 * @brief 分配实例数据缓冲
 * @param idb 实例数据缓冲指针
 * @param num 数量
 * @param stride 步长（字节）
 */
public func bgfx_alloc_instance_data_buffer_cj(idb: CPointer<InstanceDataBuffer>, num: UInt32, stride: UInt16): Unit {
    unsafe {
        bgfx_alloc_instance_data_buffer(idb, num, stride)
    }
}

/**
 * @brief 创建间接绘制缓冲
 * @param num 数量
 * @return IndirectBufferHandle 返回值描述
 */
public func bgfx_create_indirect_buffer_cj(num: UInt32): IndirectBufferHandle {
    return unsafe {
        bgfx_create_indirect_buffer(num)
    }
}

/**
 * @brief 销毁间接绘制缓冲
 * @param handle 资源句柄
 */
public func bgfx_destroy_indirect_buffer_cj(handle: IndirectBufferHandle): Unit {
    unsafe {
        bgfx_destroy_indirect_buffer(handle)
    }
}

/**
 * @brief 创建着色器对象
 * @param mem 内存块指针
 * @return ShaderHandle 返回值描述
 */
public func bgfx_create_shader_cj(mem: CPointer<Memory>): ShaderHandle {
    return unsafe {
        bgfx_create_shader(mem)
    }
}

/**
 * @brief 获取着色器的 uniforms 列表
 * @param handle 资源句柄
 * @param uniforms uniform 数组
 * @param max 最大数量
 * @return UInt16 返回值描述
 */
public func bgfx_get_shader_uniforms_cj(handle: ShaderHandle, uniforms: CPointer<UniformHandle>, max: UInt16): UInt16 {
    return unsafe {
        bgfx_get_shader_uniforms(handle, uniforms, max)
    }
}

/**
 * @brief 设置着色器名称（调试用）
 * @param handle 资源句柄
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_shader_name_cj(handle: ShaderHandle, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_shader_name(handle, name, len)
    }
}

/**
 * @brief 销毁着色器
 * @param handle 资源句柄
 */
public func bgfx_destroy_shader_cj(handle: ShaderHandle): Unit {
    unsafe {
        bgfx_destroy_shader(handle)
    }
}

/**
 * @brief 创建着色器程序（顶点+片段）
 * @param vsh 顶点着色器句柄
 * @param fsh 片段着色器句柄
 * @param destroyShaders 是否销毁着色器
 * @return ProgramHandle 返回值描述
 */
public func bgfx_create_program_cj(vsh: ShaderHandle, fsh: ShaderHandle, destroyShaders: Bool): ProgramHandle {
    return unsafe {
        bgfx_create_program(vsh, fsh, destroyShaders)
    }
}

/**
 * @brief 创建计算着色器程序
 * @param csh 计算着色器句柄
 * @param destroyShaders 是否销毁着色器
 * @return ProgramHandle 返回值描述
 */
public func bgfx_create_compute_program_cj(csh: ShaderHandle, destroyShaders: Bool): ProgramHandle {
    return unsafe {
        bgfx_create_compute_program(csh, destroyShaders)
    }
}

/**
 * @brief 销毁着色器程序
 * @param handle 资源句柄
 */
public func bgfx_destroy_program_cj(handle: ProgramHandle): Unit {
    unsafe {
        bgfx_destroy_program(handle)
    }
}

/**
 * @brief 检查纹理格式是否有效
 * @param depth 深度值
 * @param cubeMap 是否为立方体贴图
 * @param numLayers 图层数量
 * @param format 格式
 * @param flags 标志位
 * @return Bool 返回值描述
 */
public func bgfx_is_texture_valid_cj(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): Bool {
    return unsafe {
        bgfx_is_texture_valid(depth, cubeMap, numLayers, format, flags)
    }
}

/**
 * @brief 检查帧缓冲附件是否有效
 * @param num 数量
 * @param attachment 附件结构体指针
 * @return Bool 返回值描述
 */
public func bgfx_is_frame_buffer_valid_cj(num: UInt8, attachment: CPointer<Attachment>): Bool {
    return unsafe {
        bgfx_is_frame_buffer_valid(num, attachment)
    }
}

/**
 * @brief 计算纹理尺寸信息
 * @param info 信息结构体指针
 * @param width 宽度
 * @param height 高度
 * @param depth 深度值
 * @param cubeMap 是否为立方体贴图
 * @param hasMips 是否有 Mip
 * @param numLayers 图层数量
 * @param format 格式
 */
public func bgfx_calc_texture_size_cj(info: CPointer<TextureInfo>, width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool, numLayers: UInt16, format: UInt32): Unit {
    unsafe {
        bgfx_calc_texture_size(info, width, height, depth, cubeMap, hasMips, numLayers, format)
    }
}

/**
 * @brief 创建纹理
 * @param mem 内存块指针
 * @param flags 标志位
 * @param skip 跳过等级
 * @param info 信息结构体指针
 * @return TextureHandle 返回值描述
 */
public func bgfx_create_texture_cj(mem: CPointer<Memory>, flags: UInt64, skip: UInt8, info: CPointer<TextureInfo>): TextureHandle {
    return unsafe {
        bgfx_create_texture(mem, flags, skip, info)
    }
}

/**
 * @brief 创建 2D 纹理
 * @param width 宽度
 * @param height 高度
 * @param hasMips 是否有 Mip
 * @param numLayers 图层数量
 * @param format 格式
 * @param flags 标志位
 * @param mem 内存块指针
 * @return TextureHandle 返回值描述
 */
public func bgfx_create_texture_2d_cj(width: UInt16, height: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: CPointer<Memory>, external!: UInt64 = 0): TextureHandle {
    return unsafe {
        bgfx_create_texture_2d(width, height, hasMips, numLayers, format, flags, mem, external)
    }
}

/**
 * @brief 创建按比例缩放的 2D 纹理
 * @param ratio 比例
 * @param hasMips 是否有 Mip
 * @param numLayers 图层数量
 * @param format 格式
 * @param flags 标志位
 * @return TextureHandle 返回值描述
 */
public func bgfx_create_texture_2d_scaled_cj(ratio: UInt32, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): TextureHandle {
    return unsafe {
        bgfx_create_texture_2d_scaled(ratio, hasMips, numLayers, format, flags)
    }
}

/**
 * @brief 创建 3D 纹理
 * @param width 宽度
 * @param height 高度
 * @param depth 深度值
 * @param hasMips 是否有 Mip
 * @param format 格式
 * @param flags 标志位
 * @param mem 内存块指针
 * @return TextureHandle 返回值描述
 */
public func bgfx_create_texture_3d_cj(width: UInt16, height: UInt16, depth: UInt16, hasMips: Bool, format: UInt32, flags: UInt64, mem: CPointer<Memory>, external!: UInt64 = 0): TextureHandle {
    return unsafe {
        bgfx_create_texture_3d(width, height, depth, hasMips, format, flags, mem, external)
    }
}

/**
 * @brief 创建立方体贴图纹理
 * @param size 大小（字节）
 * @param hasMips 是否有 Mip
 * @param numLayers 图层数量
 * @param format 格式
 * @param flags 标志位
 * @param mem 内存块指针
 * @return TextureHandle 返回值描述
 */
public func bgfx_create_texture_cube_cj(size: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: CPointer<Memory>, external!: UInt64 = 0): TextureHandle {
    return unsafe {
        bgfx_create_texture_cube(size, hasMips, numLayers, format, flags, mem, external)
    }
}

/**
 * @brief 更新 2D 纹理区域
 * @param handle 资源句柄
 * @param layer 图层索引
 * @param mip Mip 等级
 * @param x X 坐标
 * @param y Y 坐标
 * @param width 宽度
 * @param height 高度
 * @param mem 内存块指针
 * @param pitch 行步长
 */
public func bgfx_update_texture_2d_cj(handle: TextureHandle, layer: UInt16, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: CPointer<Memory>, pitch: UInt16): Unit {
    unsafe {
        bgfx_update_texture_2d(handle, layer, mip, x, y, width, height, mem, pitch)
    }
}

/**
 * @brief 更新 3D 纹理区域
 * @param handle 资源句柄
 * @param mip Mip 等级
 * @param x X 坐标
 * @param y Y 坐标
 * @param z Z 坐标
 * @param width 宽度
 * @param height 高度
 * @param depth 深度值
 * @param mem 内存块指针
 */
public func bgfx_update_texture_3d_cj(handle: TextureHandle, mip: UInt8, x: UInt16, y: UInt16, z: UInt16, width: UInt16, height: UInt16, depth: UInt16, mem: CPointer<Memory>): Unit {
    unsafe {
        bgfx_update_texture_3d(handle, mip, x, y, z, width, height, depth, mem)
    }
}

/**
 * @brief 更新立方体贴图纹理区域
 * @param handle 资源句柄
 * @param layer 图层索引
 * @param side 立方体贴图面
 * @param mip Mip 等级
 * @param x X 坐标
 * @param y Y 坐标
 * @param width 宽度
 * @param height 高度
 * @param mem 内存块指针
 * @param pitch 行步长
 */
public func bgfx_update_texture_cube_cj(handle: TextureHandle, layer: UInt16, side: UInt8, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: CPointer<Memory>, pitch: UInt16): Unit {
    unsafe {
        bgfx_update_texture_cube(handle, layer, side, mip, x, y, width, height, mem, pitch)
    }
}

/**
 * @brief 读取纹理区域数据到内存
 * @explain 新版 bgfx：源以 TextureRegion 描述（handle/mip/x/y/z/width/height/depth，
 * 尺寸 0 表示取该 mip 剩余部分）。
 * @param src 源纹理区域描述符指针
 * @param data 数据指针（须为 bgfx_alloc 得到的 Memory）
 * @return 读取的字节数
 */
public func bgfx_read_texture_cj(src: CPointer<TextureRegion>, data: CPointer<Unit>): UInt32 {
    return unsafe {
        bgfx_read_texture(src, data)
    }
}

/**
 * @brief 设置纹理名称（调试用）
 * @param handle 资源句柄
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_texture_name_cj(handle: TextureHandle, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_texture_name(handle, name, len)
    }
}

/**
 * @brief 获取纹理直接访问指针
 * @param handle 资源句柄
 * @return CPointer 返回值描述
 */
public func bgfx_get_direct_access_ptr_cj(handle: TextureHandle): CPointer<Unit> {
    return unsafe {
        bgfx_get_direct_access_ptr(handle)
    }
}

/**
 * @brief 销毁纹理
 * @param handle 资源句柄
 */
public func bgfx_destroy_texture_cj(handle: TextureHandle): Unit {
    unsafe {
        bgfx_destroy_texture(handle)
    }
}

/**
 * @brief 创建帧缓冲
 * @param width 宽度
 * @param height 高度
 * @param format 格式
 * @param textureFlags 纹理标志
 * @return FrameBufferHandle 返回值描述
 */
public func bgfx_create_frame_buffer_cj(width: UInt16, height: UInt16, format: UInt32, textureFlags: UInt64): FrameBufferHandle {
    return unsafe {
        bgfx_create_frame_buffer(width, height, format, textureFlags)
    }
}

/**
 * @brief 创建按比例缩放的帧缓冲
 * @param ratio 比例
 * @param format 格式
 * @param textureFlags 纹理标志
 * @return FrameBufferHandle 返回值描述
 */
public func bgfx_create_frame_buffer_scaled_cj(ratio: UInt32, format: UInt32, textureFlags: UInt64): FrameBufferHandle {
    return unsafe {
        bgfx_create_frame_buffer_scaled(ratio, format, textureFlags)
    }
}

/**
 * @brief 从纹理句柄数组创建帧缓冲
 * @param num 数量
 * @param handles 纹理句柄数组
 * @param destroyTexture 是否销毁纹理
 * @return FrameBufferHandle 返回值描述
 */
public func bgfx_create_frame_buffer_from_handles_cj(num: UInt8, handles: CPointer<TextureHandle>, destroyTexture: Bool): FrameBufferHandle {
    return unsafe {
        bgfx_create_frame_buffer_from_handles(num, handles, destroyTexture)
    }
}

/**
 * @brief 从附件描述创建帧缓冲
 * @param num 数量
 * @param attachment 附件结构体指针
 * @param destroyTexture 是否销毁纹理
 * @return FrameBufferHandle 返回值描述
 */
public func bgfx_create_frame_buffer_from_attachment_cj(num: UInt8, attachment: CPointer<Attachment>, destroyTexture: Bool): FrameBufferHandle {
    return unsafe {
        bgfx_create_frame_buffer_from_attachment(num, attachment, destroyTexture)
    }
}

// 新版 bgfx：原生窗口 frame buffer 改由 SwapChain 描述符创建/更新，
// 取代旧 bgfx_create_frame_buffer_from_nwh。
public func bgfx_create_frame_buffer_from_swap_chain_cj(desc: CPointer<SwapChain>): FrameBufferHandle {
    return unsafe {
        bgfx_create_frame_buffer_from_swap_chain(desc)
    }
}

public func bgfx_update_swap_chain_cj(handle: FrameBufferHandle, desc: CPointer<SwapChain>): Unit {
    unsafe {
        bgfx_update_swap_chain(handle, desc)
    }
}

/**
 * @brief 设置帧缓冲名称（调试用）
 * @param handle 资源句柄
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_frame_buffer_name_cj(handle: FrameBufferHandle, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_frame_buffer_name(handle, name, len)
    }
}

/**
 * @brief 获取帧缓冲的纹理附件
 * @param handle 资源句柄
 * @param attachment 附件结构体指针
 * @return TextureHandle 返回值描述
 */
public func bgfx_get_texture_cj(handle: FrameBufferHandle, attachment: UInt8): TextureHandle {
    return unsafe {
        bgfx_get_texture(handle, attachment)
    }
}

/**
 * @brief 销毁帧缓冲
 * @param handle 资源句柄
 */
public func bgfx_destroy_frame_buffer_cj(handle: FrameBufferHandle): Unit {
    unsafe {
        bgfx_destroy_frame_buffer(handle)
    }
}

/**
 * @brief 创建 uniform 变量
 * @param name 名称字符串
 * @param `type` type
 * @param num 数量
 * @return UniformHandle 返回值描述
 */
public func bgfx_create_uniform_cj(name: CString, `type`: UInt32, num: UInt16): UniformHandle {
    return unsafe {
        bgfx_create_uniform(name, `type`, num)
    }
}

/**
 * @brief 获取 uniform 变量信息
 * @param handle 资源句柄
 * @param info 信息结构体指针
 */
public func bgfx_get_uniform_info_cj(handle: UniformHandle, info: CPointer<UniformInfo>): Unit {
    unsafe {
        bgfx_get_uniform_info(handle, info)
    }
}

/**
 * @brief 销毁 uniform 变量
 * @param handle 资源句柄
 */
public func bgfx_destroy_uniform_cj(handle: UniformHandle): Unit {
    unsafe {
        bgfx_destroy_uniform(handle)
    }
}

/**
 * @brief 创建遮挡查询
 * @return OcclusionQueryHandle 返回值描述
 */
public func bgfx_create_occlusion_query_cj(): OcclusionQueryHandle {
    return unsafe {
        bgfx_create_occlusion_query()
    }
}

/**
 * @brief 获取遮挡查询结果
 * @param handle 资源句柄
 * @param result 结果指针
 * @return UInt32 返回值描述
 */
public func bgfx_get_result_cj(handle: OcclusionQueryHandle, result: CPointer<Int32>): UInt32 {
    return unsafe {
        bgfx_get_result(handle, result)
    }
}

/**
 * @brief 销毁遮挡查询
 * @param handle 资源句柄
 */
public func bgfx_destroy_occlusion_query_cj(handle: OcclusionQueryHandle): Unit {
    unsafe {
        bgfx_destroy_occlusion_query(handle)
    }
}

/**
 * @brief 设置调色板颜色
 * @param index 索引
 * @param rgba RGBA 颜色值
 */
public func bgfx_set_palette_color_cj(index: UInt8, rgba: CPointer<Float32>): Unit {
    unsafe {
        bgfx_set_palette_color(index, rgba)
    }
}

/**
 * @brief 设置调色板颜色（RGBA32F 分量）
 * @param index 索引
 * @param r 红色分量
 * @param g 绿色分量
 * @param b 蓝色分量
 * @param a Alpha 分量
 */
public func bgfx_set_palette_color_rgba32f_cj(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit {
    unsafe {
        bgfx_set_palette_color_rgba32f(index, r, g, b, a)
    }
}

/**
 * @brief 设置调色板颜色（RGBA8 打包）
 * @param index 索引
 * @param rgba RGBA 颜色值
 */
public func bgfx_set_palette_color_rgba8_cj(index: UInt8, rgba: UInt32): Unit {
    unsafe {
        bgfx_set_palette_color_rgba8(index, rgba)
    }
}

/**
 * @brief 设置视图名称
 * @param id 视图 ID
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_view_name_cj(id: ViewId, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_view_name(id, name, len)
    }
}

/**
 * @brief 设置视图矩形与深度范围
 * @explain 新版 bgfx 原点偏移支持负值（Int16），并可设置该视口的
 * min/max 深度。本包装保持 UInt16 入参（调用方坐标恒非负），内部转 Int16。
 */
public func bgfx_set_view_rect_cj(id: ViewId, x: UInt16, y: UInt16, width: UInt16, height: UInt16, minDepth!: Float32 = 0.0f32, maxDepth!: Float32 = 1.0f32): Unit {
    unsafe {
        bgfx_set_view_rect(id, Int16(x), Int16(y), width, height, minDepth, maxDepth)
    }
}

/**
 * @brief 按后缓冲比例设置视图矩形
 * @explain 同 set_view_rect，原点偏移为 Int16；尺寸由后缓冲比例推导。
 */
public func bgfx_set_view_rect_ratio_cj(id: ViewId, x: UInt16, y: UInt16, ratio: UInt32): Unit {
    unsafe {
        bgfx_set_view_rect_ratio(id, Int16(x), Int16(y), ratio)
    }
}

/**
 * @brief 设置视图裁剪矩形
 * @param id 视图 ID
 * @param x X 坐标
 * @param y Y 坐标
 * @param width 宽度
 * @param height 高度
 */
public func bgfx_set_view_scissor_cj(id: ViewId, x: UInt16, y: UInt16, width: UInt16, height: UInt16): Unit {
    unsafe {
        bgfx_set_view_scissor(id, x, y, width, height)
    }
}

/**
 * @brief 设置视图清除参数
 * @param id 视图 ID
 * @param flags 标志位
 * @param rgba RGBA 颜色值
 * @param depth 深度值
 * @param stencil 模板值
 */
public func bgfx_set_view_clear_cj(id: ViewId, flags: UInt16, rgba: UInt32, depth: Float32, stencil: UInt8): Unit {
    unsafe {
        bgfx_set_view_clear(id, flags, rgba, depth, stencil)
    }
}

/**
 * @brief 设置 MRT 视图清除参数
 * @param id 视图 ID
 * @param flags 标志位
 * @param depth 深度值
 * @param stencil 模板值
 * @param c0 颜色缓冲 0
 * @param c1 颜色缓冲 1
 * @param c2 颜色缓冲 2
 * @param c3 颜色缓冲 3
 * @param c4 颜色缓冲 4
 * @param c5 颜色缓冲 5
 * @param c6 颜色缓冲 6
 * @param c7 颜色缓冲 7
 */
public func bgfx_set_view_clear_mrt_cj(id: ViewId, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8, c2: UInt8, c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit {
    unsafe {
        bgfx_set_view_clear_mrt(id, flags, depth, stencil, c0, c1, c2, c3, c4, c5, c6, c7)
    }
}

/**
 * @brief 设置视图渲染模式
 * @param id 视图 ID
 * @param mode 渲染模式
 */
public func bgfx_set_view_mode_cj(id: ViewId, mode: UInt32): Unit {
    unsafe {
        bgfx_set_view_mode(id, mode)
    }
}

/**
 * @brief 设置视图的帧缓冲
 * @param id 视图 ID
 * @param handle 资源句柄
 */
public func bgfx_set_view_frame_buffer_cj(id: ViewId, handle: FrameBufferHandle): Unit {
    unsafe {
        bgfx_set_view_frame_buffer(id, handle)
    }
}

/**
 * @brief 设置视图的变换矩阵（视图+投影）
 * @param id 视图 ID
 * @param view 视图矩阵指针
 * @param proj 投影矩阵指针
 */
public func bgfx_set_view_transform_cj(id: ViewId, view: CPointer<Unit>, proj: CPointer<Unit>): Unit {
    unsafe {
        bgfx_set_view_transform(id, view, proj)
    }
}

/**
 * @brief 设置视图的绘制顺序
 * @param id 视图 ID
 * @param num 数量
 * @param order 视图顺序数组
 */
public func bgfx_set_view_order_cj(id: ViewId, num: UInt16, order: CPointer<ViewId>): Unit {
    unsafe {
        bgfx_set_view_order(id, num, order)
    }
}

/**
 * @brief 重置视图状态
 * @param id 视图 ID
 */
public func bgfx_reset_view_cj(id: ViewId): Unit {
    unsafe {
        bgfx_reset_view(id)
    }
}

/**
 * @brief 开始编码器（多线程渲染）
 * @param forThread 是否为多线程
 * @return CPointer 返回值描述
 */
public func bgfx_encoder_begin_cj(forThread: Bool): CPointer<Encoder> {
    return unsafe {
        bgfx_encoder_begin(forThread)
    }
}

/**
 * @brief 结束编码器
 * @param encoder 编码器指针
 */
public func bgfx_encoder_end_cj(encoder: CPointer<Encoder>): Unit {
    unsafe {
        bgfx_encoder_end(encoder)
    }
}

/**
 * @brief 设置编码器标记
 * @param encoder 编码器指针
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_encoder_set_marker_cj(encoder: CPointer<Encoder>, name: CString, len: Int32): Unit {
    unsafe {
        bgfx_encoder_set_marker(encoder, name, len)
    }
}

/**
 * @brief 设置编码器渲染状态
 * @param encoder 编码器指针
 * @param state 渲染状态
 * @param rgba RGBA 颜色值
 */
public func bgfx_encoder_set_state_cj(encoder: CPointer<Encoder>, state: UInt64, rgba: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_state(encoder, state, rgba)
    }
}

/**
 * @brief 设置编码器遮挡查询条件
 * @param encoder 编码器指针
 * @param handle 资源句柄
 * @param visible 是否可见
 */
public func bgfx_encoder_set_condition_cj(encoder: CPointer<Encoder>, handle: OcclusionQueryHandle, visible: Bool): Unit {
    unsafe {
        bgfx_encoder_set_condition(encoder, handle, visible)
    }
}

/**
 * @brief 设置编码器模板缓冲
 * @param encoder 编码器指针
 * @param fstencil 正面模板
 * @param bstencil 背面模板
 */
public func bgfx_encoder_set_stencil_cj(encoder: CPointer<Encoder>, fstencil: UInt32, bstencil: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_stencil(encoder, fstencil, bstencil)
    }
}

/**
 * @brief 设置编码器裁剪矩形
 * @param encoder 编码器指针
 * @param x X 坐标
 * @param y Y 坐标
 * @param width 宽度
 * @param height 高度
 * @return UInt16 返回值描述
 */
public func bgfx_encoder_set_scissor_cj(encoder: CPointer<Encoder>, x: UInt16, y: UInt16, width: UInt16, height: UInt16): UInt16 {
    return unsafe {
        bgfx_encoder_set_scissor(encoder, x, y, width, height)
    }
}

/**
 * @brief 设置编码器缓存裁剪矩形
 * @param encoder 编码器指针
 * @param cache 缓存索引
 */
public func bgfx_encoder_set_scissor_cached_cj(encoder: CPointer<Encoder>, cache: UInt16): Unit {
    unsafe {
        bgfx_encoder_set_scissor_cached(encoder, cache)
    }
}

/**
 * @brief 设置编码器模型变换矩阵
 * @param encoder 编码器指针
 * @param mtx 变换矩阵指针
 * @param num 数量
 * @return UInt32 返回值描述
 */
public func bgfx_encoder_set_transform_cj(encoder: CPointer<Encoder>, mtx: CPointer<Unit>, num: UInt16): UInt32 {
    return unsafe {
        bgfx_encoder_set_transform(encoder, mtx, num)
    }
}

/**
 * @brief 设置编码器缓存变换矩阵
 * @param encoder 编码器指针
 * @param cache 缓存索引
 * @param num 数量
 */
public func bgfx_encoder_set_transform_cached_cj(encoder: CPointer<Encoder>, cache: UInt32, num: UInt16): Unit {
    unsafe {
        bgfx_encoder_set_transform_cached(encoder, cache, num)
    }
}

/**
 * @brief 分配编码器变换矩阵
 * @param encoder 编码器指针
 * @param transform 变换数据指针
 * @param num 数量
 * @return UInt32 返回值描述
 */
public func bgfx_encoder_alloc_transform_cj(encoder: CPointer<Encoder>, transform: CPointer<Transform>, num: UInt16): UInt32 {
    return unsafe {
        bgfx_encoder_alloc_transform(encoder, transform, num)
    }
}

/**
 * @brief 设置编码器 uniform 变量
 * @param encoder 编码器指针
 * @param handle 资源句柄
 * @param value 值
 * @param num 数量
 */
public func bgfx_encoder_set_uniform_cj(encoder: CPointer<Encoder>, handle: UniformHandle, value: CPointer<Unit>, num: UInt16): Unit {
    unsafe {
        bgfx_encoder_set_uniform(encoder, handle, value, num)
    }
}

/**
 * @brief 设置编码器索引缓冲
 * @param encoder 编码器指针
 * @param handle 资源句柄
 * @param firstIndex 起始索引
 * @param numIndices 索引数量
 */
public func bgfx_encoder_set_index_buffer_cj(encoder: CPointer<Encoder>, handle: IndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_index_buffer(encoder, handle, firstIndex, numIndices)
    }
}

/**
 * @brief 设置编码器动态索引缓冲
 * @param encoder 编码器指针
 * @param handle 资源句柄
 * @param firstIndex 起始索引
 * @param numIndices 索引数量
 */
public func bgfx_encoder_set_dynamic_index_buffer_cj(encoder: CPointer<Encoder>, handle: DynamicIndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_dynamic_index_buffer(encoder, handle, firstIndex, numIndices)
    }
}

/**
 * @brief 设置编码器瞬态索引缓冲
 * @param encoder 编码器指针
 * @param tib 瞬态索引缓冲指针
 * @param firstIndex 起始索引
 * @param numIndices 索引数量
 */
public func bgfx_encoder_set_transient_index_buffer_cj(encoder: CPointer<Encoder>, tib: CPointer<TransientIndexBuffer>, firstIndex: UInt32, numIndices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_transient_index_buffer(encoder, tib, firstIndex, numIndices)
    }
}

/**
 * @brief 设置编码器顶点缓冲
 * @param encoder 编码器指针
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 */
public func bgfx_encoder_set_vertex_buffer_cj(encoder: CPointer<Encoder>, stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_vertex_buffer(encoder, stream, handle, startVertex, numVertices)
    }
}

/**
 * @brief 设置编码器顶点缓冲（带布局）
 * @param encoder 编码器指针
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_encoder_set_vertex_buffer_with_layout_cj(encoder: CPointer<Encoder>, stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_encoder_set_vertex_buffer_with_layout(encoder, stream, handle, startVertex, numVertices, layoutHandle)
    }
}

/**
 * @brief 设置编码器动态顶点缓冲
 * @param encoder 编码器指针
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 */
public func bgfx_encoder_set_dynamic_vertex_buffer_cj(encoder: CPointer<Encoder>, stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_dynamic_vertex_buffer(encoder, stream, handle, startVertex, numVertices)
    }
}

/**
 * @brief 设置编码器动态顶点缓冲（带布局）
 * @param encoder 编码器指针
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_encoder_set_dynamic_vertex_buffer_with_layout_cj(encoder: CPointer<Encoder>, stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_encoder_set_dynamic_vertex_buffer_with_layout(encoder, stream, handle, startVertex, numVertices, layoutHandle)
    }
}

/**
 * @brief 设置编码器瞬态顶点缓冲
 * @param encoder 编码器指针
 * @param stream 顶点流索引
 * @param tvb 瞬态顶点缓冲指针
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 */
public func bgfx_encoder_set_transient_vertex_buffer_cj(encoder: CPointer<Encoder>, stream: UInt8, tvb: CPointer<TransientVertexBuffer>, startVertex: UInt32, numVertices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_transient_vertex_buffer(encoder, stream, tvb, startVertex, numVertices)
    }
}

/**
 * @brief 设置编码器瞬态顶点缓冲（带布局）
 * @param encoder 编码器指针
 * @param stream 顶点流索引
 * @param tvb 瞬态顶点缓冲指针
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_encoder_set_transient_vertex_buffer_with_layout_cj(encoder: CPointer<Encoder>, stream: UInt8, tvb: CPointer<TransientVertexBuffer>, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_encoder_set_transient_vertex_buffer_with_layout(encoder, stream, tvb, startVertex, numVertices, layoutHandle)
    }
}

/**
 * @brief 设置编码器顶点数量
 * @param encoder 编码器指针
 * @param numVertices 顶点数量
 */
public func bgfx_encoder_set_vertex_count_cj(encoder: CPointer<Encoder>, numVertices: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_vertex_count(encoder, numVertices)
    }
}

/**
 * @brief 设置编码器实例数据缓冲
 * @param encoder 编码器指针
 * @param idb 实例数据缓冲指针
 * @param start 起始偏移
 * @param num 数量
 */
public func bgfx_encoder_set_instance_data_buffer_cj(encoder: CPointer<Encoder>, idb: CPointer<InstanceDataBuffer>, start: UInt32, num: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_instance_data_buffer(encoder, idb, start, num)
    }
}

/**
 * @brief 设置编码器实例数据（从顶点缓冲）
 * @param encoder 编码器指针
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param num 数量
 */
public func bgfx_encoder_set_instance_data_from_vertex_buffer_cj(encoder: CPointer<Encoder>, handle: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_instance_data_from_vertex_buffer(encoder, handle, startVertex, num)
    }
}

/**
 * @brief 设置编码器实例数据（从动态顶点缓冲）
 * @param encoder 编码器指针
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param num 数量
 */
public func bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer_cj(encoder: CPointer<Encoder>, handle: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer(encoder, handle, startVertex, num)
    }
}

/**
 * @brief 设置编码器实例数量
 * @param encoder 编码器指针
 * @param numInstances 实例数量
 */
public func bgfx_encoder_set_instance_count_cj(encoder: CPointer<Encoder>, numInstances: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_instance_count(encoder, numInstances)
    }
}

/**
 * @brief 设置编码器纹理绑定
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param sampler 采样器 uniform 句柄
 * @param handle 资源句柄
 * @param flags 标志位
 */
public func bgfx_encoder_set_texture_cj(encoder: CPointer<Encoder>, stage: UInt8, sampler: UniformHandle, handle: TextureHandle, flags: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_texture(encoder, stage, sampler, handle, flags)
    }
}

/**
 * @brief 标记编码器视图为活跃
 * @param encoder 编码器指针
 * @param id 视图 ID
 */
public func bgfx_encoder_touch_cj(encoder: CPointer<Encoder>, id: ViewId): Unit {
    unsafe {
        bgfx_encoder_touch(encoder, id)
    }
}

/**
 * @brief 提交编码器绘制调用
 * @param encoder 编码器指针
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_encoder_submit_cj(encoder: CPointer<Encoder>, id: ViewId, program: ProgramHandle, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_submit(encoder, id, program, depth, flags)
    }
}

/**
 * @brief 提交编码器遮挡查询
 * @param encoder 编码器指针
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param occlusionQuery 遮挡查询句柄
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_encoder_submit_occlusion_query_cj(encoder: CPointer<Encoder>, id: ViewId, program: ProgramHandle, occlusionQuery: OcclusionQueryHandle, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_submit_occlusion_query(encoder, id, program, occlusionQuery, depth, flags)
    }
}

/**
 * @brief 提交编码器间接绘制
 * @param encoder 编码器指针
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param indirectHandle 间接绘制句柄
 * @param start 起始偏移
 * @param num 数量
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_encoder_submit_indirect_cj(encoder: CPointer<Encoder>, id: ViewId, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_submit_indirect(encoder, id, program, indirectHandle, start, num, depth, flags)
    }
}

/**
 * @brief 提交编码器计数间接绘制
 * @param encoder 编码器指针
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param indirectHandle 间接绘制句柄
 * @param start 起始偏移
 * @param numHandle 索引缓冲句柄
 * @param numIndex 索引数量
 * @param numMax 最大数量
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_encoder_submit_indirect_count_cj(encoder: CPointer<Encoder>, id: ViewId, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_submit_indirect_count(encoder, id, program, indirectHandle, start, numHandle, numIndex, numMax, depth, flags)
    }
}

/**
 * @brief 设置编码器计算索引缓冲
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_encoder_set_compute_index_buffer_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: IndexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_encoder_set_compute_index_buffer(encoder, stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置编码器计算顶点缓冲
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_encoder_set_compute_vertex_buffer_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: VertexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_encoder_set_compute_vertex_buffer(encoder, stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置编码器计算动态索引缓冲
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_encoder_set_compute_dynamic_index_buffer_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: DynamicIndexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_encoder_set_compute_dynamic_index_buffer(encoder, stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置编码器计算动态顶点缓冲
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_encoder_set_compute_dynamic_vertex_buffer_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: DynamicVertexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_encoder_set_compute_dynamic_vertex_buffer(encoder, stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置编码器计算间接缓冲
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_encoder_set_compute_indirect_buffer_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: IndirectBufferHandle, access: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_compute_indirect_buffer(encoder, stage, handle, access)
    }
}

/**
 * @brief 设置编码器计算图像
 * @param encoder 编码器指针
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param mip Mip 等级
 * @param access 访问权限
 * @param format 格式
 */
public func bgfx_encoder_set_image_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_image(encoder, stage, handle, mip, access, format)
    }
}

/**
 * @brief 提交编码器计算调度
 * @param encoder 编码器指针
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param numX X 方向线程数
 * @param numY Y 方向线程数
 * @param numZ Z 方向线程数
 * @param flags 标志位
 */
public func bgfx_encoder_dispatch_cj(encoder: CPointer<Encoder>, id: ViewId, program: ProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_dispatch(encoder, id, program, numX, numY, numZ, flags)
    }
}

/**
 * @brief 提交编码器间接计算调度
 * @param encoder 编码器指针
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param indirectHandle 间接绘制句柄
 * @param start 起始偏移
 * @param num 数量
 * @param flags 标志位
 */
public func bgfx_encoder_dispatch_indirect_cj(encoder: CPointer<Encoder>, id: ViewId, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_dispatch_indirect(encoder, id, program, indirectHandle, start, num, flags)
    }
}

/**
 * @brief 丢弃编码器状态
 * @param encoder 编码器指针
 * @param flags 标志位
 */
public func bgfx_encoder_discard_cj(encoder: CPointer<Encoder>, flags: UInt8): Unit {
    unsafe {
        bgfx_encoder_discard(encoder, flags)
    }
}

/**
 * @brief 执行编码器 Blit 操作（region 指针透传）
 * @explain 新版 bgfx 以 TextureRegion 描述符传源/目的区域。
 */
public func bgfx_encoder_blit_region_cj(encoder: CPointer<Encoder>, id: ViewId, dst: CPointer<TextureRegion>, src: CPointer<TextureRegion>): Unit {
    unsafe {
        bgfx_encoder_blit(encoder, id, dst, src)
    }
}

/**
 * @brief 执行编码器 Blit 操作（旧参数形态兼容包装）
 * @explain 内部按各参数构造 TextureRegion 描述符后调用新版 blit。
 */
public func bgfx_encoder_blit_cj(encoder: CPointer<Encoder>, id: ViewId, dst: TextureHandle, dstMip: UInt8, dstX: UInt16, dstY: UInt16, dstZ: UInt16, src: TextureHandle, srcMip: UInt8, srcX: UInt16, srcY: UInt16, srcZ: UInt16, width: UInt16, height: UInt16, depth: UInt16): Unit {
    var dstRegion = TextureRegion()
    dstRegion.handle = dst
    dstRegion.mip = dstMip
    dstRegion.x = dstX
    dstRegion.y = dstY
    dstRegion.z = dstZ
    dstRegion.width = width
    dstRegion.height = height
    dstRegion.depth = depth
    var srcRegion = TextureRegion()
    srcRegion.handle = src
    srcRegion.mip = srcMip
    srcRegion.x = srcX
    srcRegion.y = srcY
    srcRegion.z = srcZ
    srcRegion.width = width
    srcRegion.height = height
    srcRegion.depth = depth
    unsafe {
        bgfx_encoder_blit(encoder, id, inout dstRegion, inout srcRegion)
    }
}

/**
 * @brief 请求屏幕截图
 * @param handle 资源句柄
 * @param filePath 文件路径
 */
public func bgfx_request_screen_shot_cj(handle: FrameBufferHandle, filePath: CString): Unit {
    unsafe {
        bgfx_request_screen_shot(handle, filePath)
    }
}

/**
 * @brief 渲染一帧（外部循环模式）
 * @param msecs 等待毫秒数
 * @return UInt32 返回值描述
 */
public func bgfx_render_frame_cj(msecs: Int32): UInt32 {
    return unsafe {
        bgfx_render_frame(msecs)
    }
}

// 注：bgfx_set_platform_data_cj 已随新版 bgfx 移除 bgfx_set_platform_data 而删除
//（平台数据改为经 bgfx_init_t / swap chain 描述在 init 时传入）。

/**
 * @brief 获取内部数据
 * @return CPointer 返回值描述
 */
public func bgfx_get_internal_data_cj(): CPointer<InternalData> {
    return unsafe {
        bgfx_get_internal_data()
    }
}

// 注：bgfx_override_internal_texture_ptr_cj / bgfx_override_internal_texture_cj
// 已随新版 bgfx 移除 overrideInternalTexturePtr/overrideInternalTexture 而删除。

/**
 * @brief 设置渲染标记
 * @param name 名称字符串
 * @param len 字符串长度
 */
public func bgfx_set_marker_cj(name: CString, len: Int32): Unit {
    unsafe {
        bgfx_set_marker(name, len)
    }
}

/**
 * @brief 设置渲染状态
 * @param state 渲染状态
 * @param rgba RGBA 颜色值
 */
public func bgfx_set_state_cj(state: UInt64, rgba: UInt32): Unit {
    unsafe {
        bgfx_set_state(state, rgba)
    }
}

/**
 * @brief 设置遮挡查询条件
 * @param handle 资源句柄
 * @param visible 是否可见
 */
public func bgfx_set_condition_cj(handle: OcclusionQueryHandle, visible: Bool): Unit {
    unsafe {
        bgfx_set_condition(handle, visible)
    }
}

/**
 * @brief 设置模板缓冲
 * @param fstencil 正面模板
 * @param bstencil 背面模板
 */
public func bgfx_set_stencil_cj(fstencil: UInt32, bstencil: UInt32): Unit {
    unsafe {
        bgfx_set_stencil(fstencil, bstencil)
    }
}

/**
 * @brief 设置裁剪矩形
 * @param x X 坐标
 * @param y Y 坐标
 * @param width 宽度
 * @param height 高度
 * @return UInt16 返回值描述
 */
public func bgfx_set_scissor_cj(x: UInt16, y: UInt16, width: UInt16, height: UInt16): UInt16 {
    return unsafe {
        bgfx_set_scissor(x, y, width, height)
    }
}

/**
 * @brief 设置缓存裁剪矩形
 * @param cache 缓存索引
 */
public func bgfx_set_scissor_cached_cj(cache: UInt16): Unit {
    unsafe {
        bgfx_set_scissor_cached(cache)
    }
}

/**
 * @brief 设置模型变换矩阵
 * @param mtx 变换矩阵指针
 * @param num 数量
 * @return UInt32 返回值描述
 */
public func bgfx_set_transform_cj(mtx: CPointer<Unit>, num: UInt16): UInt32 {
    return unsafe {
        bgfx_set_transform(mtx, num)
    }
}

/**
 * @brief 设置缓存模型变换矩阵
 * @param cache 缓存索引
 * @param num 数量
 */
public func bgfx_set_transform_cached_cj(cache: UInt32, num: UInt16): Unit {
    unsafe {
        bgfx_set_transform_cached(cache, num)
    }
}

/**
 * @brief 分配变换矩阵
 * @param transform 变换数据指针
 * @param num 数量
 * @return UInt32 返回值描述
 */
public func bgfx_alloc_transform_cj(transform: CPointer<Transform>, num: UInt16): UInt32 {
    return unsafe {
        bgfx_alloc_transform(transform, num)
    }
}

/**
 * @brief 设置 uniform 变量
 * @param handle 资源句柄
 * @param value 值
 * @param num 数量
 */
public func bgfx_set_uniform_cj(handle: UniformHandle, value: CPointer<Unit>, num: UInt16): Unit {
    unsafe {
        bgfx_set_uniform(handle, value, num)
    }
}

/**
 * @brief 设置索引缓冲
 * @param handle 资源句柄
 * @param firstIndex 起始索引
 * @param numIndices 索引数量
 */
public func bgfx_set_index_buffer_cj(handle: IndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit {
    unsafe {
        bgfx_set_index_buffer(handle, firstIndex, numIndices)
    }
}

/**
 * @brief 设置动态索引缓冲
 * @param handle 资源句柄
 * @param firstIndex 起始索引
 * @param numIndices 索引数量
 */
public func bgfx_set_dynamic_index_buffer_cj(handle: DynamicIndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit {
    unsafe {
        bgfx_set_dynamic_index_buffer(handle, firstIndex, numIndices)
    }
}

/**
 * @brief 设置瞬态索引缓冲
 * @param tib 瞬态索引缓冲指针
 * @param firstIndex 起始索引
 * @param numIndices 索引数量
 */
public func bgfx_set_transient_index_buffer_cj(tib: CPointer<TransientIndexBuffer>, firstIndex: UInt32, numIndices: UInt32): Unit {
    unsafe {
        bgfx_set_transient_index_buffer(tib, firstIndex, numIndices)
    }
}

/**
 * @brief 设置顶点缓冲
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 */
public func bgfx_set_vertex_buffer_cj(stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit {
    unsafe {
        bgfx_set_vertex_buffer(stream, handle, startVertex, numVertices)
    }
}

/**
 * @brief 设置顶点缓冲（带布局）
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_set_vertex_buffer_with_layout_cj(stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_set_vertex_buffer_with_layout(stream, handle, startVertex, numVertices, layoutHandle)
    }
}

/**
 * @brief 设置动态顶点缓冲
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 */
public func bgfx_set_dynamic_vertex_buffer_cj(stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit {
    unsafe {
        bgfx_set_dynamic_vertex_buffer(stream, handle, startVertex, numVertices)
    }
}

/**
 * @brief 设置动态顶点缓冲（带布局）
 * @param stream 顶点流索引
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_set_dynamic_vertex_buffer_with_layout_cj(stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_set_dynamic_vertex_buffer_with_layout(stream, handle, startVertex, numVertices, layoutHandle)
    }
}

/**
 * @brief 设置瞬态顶点缓冲
 * @param stream 顶点流索引
 * @param tvb 瞬态顶点缓冲指针
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 */
public func bgfx_set_transient_vertex_buffer_cj(stream: UInt8, tvb: CPointer<TransientVertexBuffer>, startVertex: UInt32, numVertices: UInt32): Unit {
    unsafe {
        bgfx_set_transient_vertex_buffer(stream, tvb, startVertex, numVertices)
    }
}

/**
 * @brief 设置瞬态顶点缓冲（带布局）
 * @param stream 顶点流索引
 * @param tvb 瞬态顶点缓冲指针
 * @param startVertex 起始顶点
 * @param numVertices 顶点数量
 * @param layoutHandle 顶点布局句柄
 */
public func bgfx_set_transient_vertex_buffer_with_layout_cj(stream: UInt8, tvb: CPointer<TransientVertexBuffer>, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit {
    unsafe {
        bgfx_set_transient_vertex_buffer_with_layout(stream, tvb, startVertex, numVertices, layoutHandle)
    }
}

/**
 * @brief 设置顶点数量
 * @param numVertices 顶点数量
 */
public func bgfx_set_vertex_count_cj(numVertices: UInt32): Unit {
    unsafe {
        bgfx_set_vertex_count(numVertices)
    }
}

/**
 * @brief 设置实例数据缓冲
 * @param idb 实例数据缓冲指针
 * @param start 起始偏移
 * @param num 数量
 */
public func bgfx_set_instance_data_buffer_cj(idb: CPointer<InstanceDataBuffer>, start: UInt32, num: UInt32): Unit {
    unsafe {
        bgfx_set_instance_data_buffer(idb, start, num)
    }
}

/**
 * @brief 设置实例数据（从顶点缓冲）
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param num 数量
 */
public func bgfx_set_instance_data_from_vertex_buffer_cj(handle: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
    unsafe {
        bgfx_set_instance_data_from_vertex_buffer(handle, startVertex, num)
    }
}

/**
 * @brief 设置实例数据（从动态顶点缓冲）
 * @param handle 资源句柄
 * @param startVertex 起始顶点
 * @param num 数量
 */
public func bgfx_set_instance_data_from_dynamic_vertex_buffer_cj(handle: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
    unsafe {
        bgfx_set_instance_data_from_dynamic_vertex_buffer(handle, startVertex, num)
    }
}

/**
 * @brief 设置实例数量
 * @param numInstances 实例数量
 */
public func bgfx_set_instance_count_cj(numInstances: UInt32): Unit {
    unsafe {
        bgfx_set_instance_count(numInstances)
    }
}

/**
 * @brief 设置纹理绑定
 * @param stage 纹理阶段
 * @param sampler 采样器 uniform 句柄
 * @param handle 资源句柄
 * @param flags 标志位
 */
public func bgfx_set_texture_cj(stage: UInt8, sampler: UniformHandle, handle: TextureHandle, flags: UInt32): Unit {
    unsafe {
        bgfx_set_texture(stage, sampler, handle, flags)
    }
}

/**
 * @brief 标记视图为活跃
 * @param id 视图 ID
 */
public func bgfx_touch_cj(id: ViewId): Unit {
    unsafe {
        bgfx_touch(id)
    }
}

/**
 * @brief 提交绘制调用
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_submit_cj(id: ViewId, program: ProgramHandle, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_submit(id, program, depth, flags)
    }
}

/**
 * @brief 提交遮挡查询
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param occlusionQuery 遮挡查询句柄
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_submit_occlusion_query_cj(id: ViewId, program: ProgramHandle, occlusionQuery: OcclusionQueryHandle, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_submit_occlusion_query(id, program, occlusionQuery, depth, flags)
    }
}

/**
 * @brief 提交间接绘制
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param indirectHandle 间接绘制句柄
 * @param start 起始偏移
 * @param num 数量
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_submit_indirect_cj(id: ViewId, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_submit_indirect(id, program, indirectHandle, start, num, depth, flags)
    }
}

/**
 * @brief 提交计数间接绘制
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param indirectHandle 间接绘制句柄
 * @param start 起始偏移
 * @param numHandle 索引缓冲句柄
 * @param numIndex 索引数量
 * @param numMax 最大数量
 * @param depth 深度值
 * @param flags 标志位
 */
public func bgfx_submit_indirect_count_cj(id: ViewId, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32, depth: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_submit_indirect_count(id, program, indirectHandle, start, numHandle, numIndex, numMax, depth, flags)
    }
}

/**
 * @brief 设置计算索引缓冲
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_set_compute_index_buffer_cj(stage: UInt8, handle: IndexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_set_compute_index_buffer(stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置计算顶点缓冲
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_set_compute_vertex_buffer_cj(stage: UInt8, handle: VertexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_set_compute_vertex_buffer(stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置计算动态索引缓冲
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_set_compute_dynamic_index_buffer_cj(stage: UInt8, handle: DynamicIndexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_set_compute_dynamic_index_buffer(stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置计算动态顶点缓冲
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_set_compute_dynamic_vertex_buffer_cj(stage: UInt8, handle: DynamicVertexBufferHandle, access: UInt32, offset!: UInt32 = 0, size!: UInt32 = 0xFFFFFFFFu32): Unit {
    unsafe {
        bgfx_set_compute_dynamic_vertex_buffer(stage, handle, access, offset, size)
    }
}

/**
 * @brief 设置计算间接缓冲
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param access 访问权限
 */
public func bgfx_set_compute_indirect_buffer_cj(stage: UInt8, handle: IndirectBufferHandle, access: UInt32): Unit {
    unsafe {
        bgfx_set_compute_indirect_buffer(stage, handle, access)
    }
}

/**
 * @brief 设置计算图像
 * @param stage 纹理阶段
 * @param handle 资源句柄
 * @param mip Mip 等级
 * @param access 访问权限
 * @param format 格式
 */
public func bgfx_set_image_cj(stage: UInt8, handle: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit {
    unsafe {
        bgfx_set_image(stage, handle, mip, access, format)
    }
}

/**
 * @brief 提交计算调度
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param numX X 方向线程数
 * @param numY Y 方向线程数
 * @param numZ Z 方向线程数
 * @param flags 标志位
 */
public func bgfx_dispatch_cj(id: ViewId, program: ProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_dispatch(id, program, numX, numY, numZ, flags)
    }
}

/**
 * @brief 提交间接计算调度
 * @param id 视图 ID
 * @param program 着色器程序句柄
 * @param indirectHandle 间接绘制句柄
 * @param start 起始偏移
 * @param num 数量
 * @param flags 标志位
 */
public func bgfx_dispatch_indirect_cj(id: ViewId, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, flags: UInt8): Unit {
    unsafe {
        bgfx_dispatch_indirect(id, program, indirectHandle, start, num, flags)
    }
}

/**
 * @brief 丢弃状态
 * @param flags 标志位
 */
public func bgfx_discard_cj(flags: UInt8): Unit {
    unsafe {
        bgfx_discard(flags)
    }
}

/**
 * @brief 执行 Blit 操作（region 指针透传）
 * @explain 新版 bgfx 以 TextureRegion 描述符传源/目的区域。
 */
public func bgfx_blit_region_cj(id: ViewId, dst: CPointer<TextureRegion>, src: CPointer<TextureRegion>): Unit {
    unsafe {
        bgfx_blit(id, dst, src)
    }
}

/**
 * @brief 执行 Blit 操作（旧参数形态兼容包装）
 * @explain 内部按各参数构造 TextureRegion 描述符后调用新版 blit。
 */
public func bgfx_blit_cj(id: ViewId, dst: TextureHandle, dstMip: UInt8, dstX: UInt16, dstY: UInt16, dstZ: UInt16, src: TextureHandle, srcMip: UInt8, srcX: UInt16, srcY: UInt16, srcZ: UInt16, width: UInt16, height: UInt16, depth: UInt16): Unit {
    var dstRegion = TextureRegion()
    dstRegion.handle = dst
    dstRegion.mip = dstMip
    dstRegion.x = dstX
    dstRegion.y = dstY
    dstRegion.z = dstZ
    dstRegion.width = width
    dstRegion.height = height
    dstRegion.depth = depth
    var srcRegion = TextureRegion()
    srcRegion.handle = src
    srcRegion.mip = srcMip
    srcRegion.x = srcX
    srcRegion.y = srcY
    srcRegion.z = srcZ
    srcRegion.width = width
    srcRegion.height = height
    srcRegion.depth = depth
    unsafe {
        bgfx_blit(id, inout dstRegion, inout srcRegion)
    }
}

/**
 * @brief 获取接口
 * @param version 版本
 * @return CPointer 返回值描述
 */
public func bgfx_get_interface_cj(version: UInt32): CPointer<Unit> {
    return unsafe {
        bgfx_get_interface(version)
    }
}

// =============================================================================
// 新版 bgfx 新增 API 导出（与 c99/bgfx.h 一一对应）
// =============================================================================

/**
 * @brief 初始化 2D 纹理区域（mip=0、z/depth=0）
 */
public func bgfx_texture_region_init_cj(region: CPointer<TextureRegion>, handle: TextureHandle, x: UInt16, y: UInt16, width: UInt16, height: UInt16): Unit {
    unsafe {
        bgfx_texture_region_init(region, handle, x, y, width, height)
    }
}

/**
 * @brief 初始化指向 buffer 的缓冲区域
 */
public func bgfx_buffer_region_init_buffer_cj(region: CPointer<BufferRegion>, handle: BufferHandle, offset: UInt32, size: UInt32): Unit {
    unsafe {
        bgfx_buffer_region_init_buffer(region, handle, offset, size)
    }
}

/**
 * @brief 按纹理区域推导初始化缓冲区域
 */
public func bgfx_buffer_region_init_texture_cj(region: CPointer<BufferRegion>, texture: CPointer<TextureRegion>): Unit {
    unsafe {
        bgfx_buffer_region_init_texture(region, texture)
    }
}

/**
 * @brief 清空纹理指定 mip/layer 范围
 */
public func bgfx_clear_texture_cj(handle: TextureHandle, mip: UInt8, numMips: UInt8, layer: UInt16, numLayers: UInt16): Unit {
    unsafe {
        bgfx_clear_texture(handle, mip, numMips, layer, numLayers)
    }
}

/**
 * @brief 读取缓冲区域数据
 */
public func bgfx_read_buffer_cj(src: CPointer<BufferRegion>, data: CPointer<Unit>): UInt32 {
    return unsafe {
        bgfx_read_buffer(src, data)
    }
}

/**
 * @brief buffer 间 blit
 */
public func bgfx_blit_buffer_cj(id: ViewId, dst: CPointer<BufferRegion>, src: CPointer<BufferRegion>): Unit {
    unsafe {
        bgfx_blit_buffer(id, dst, src)
    }
}

/**
 * @brief 纹理 blit 到 buffer
 */
public func bgfx_blit_to_buffer_cj(id: ViewId, dst: CPointer<BufferRegion>, src: CPointer<TextureRegion>): Unit {
    unsafe {
        bgfx_blit_to_buffer(id, dst, src)
    }
}

/**
 * @brief 从 buffer blit 到纹理
 */
public func bgfx_blit_from_buffer_cj(id: ViewId, dst: CPointer<TextureRegion>, src: CPointer<BufferRegion>): Unit {
    unsafe {
        bgfx_blit_from_buffer(id, dst, src)
    }
}

/**
 * @brief encoder：buffer 间 blit
 */
public func bgfx_encoder_blit_buffer_cj(encoder: CPointer<Encoder>, id: ViewId, dst: CPointer<BufferRegion>, src: CPointer<BufferRegion>): Unit {
    unsafe {
        bgfx_encoder_blit_buffer(encoder, id, dst, src)
    }
}

/**
 * @brief encoder：纹理 blit 到 buffer
 */
public func bgfx_encoder_blit_to_buffer_cj(encoder: CPointer<Encoder>, id: ViewId, dst: CPointer<BufferRegion>, src: CPointer<TextureRegion>): Unit {
    unsafe {
        bgfx_encoder_blit_to_buffer(encoder, id, dst, src)
    }
}

/**
 * @brief encoder：从 buffer blit 到纹理
 */
public func bgfx_encoder_blit_from_buffer_cj(encoder: CPointer<Encoder>, id: ViewId, dst: CPointer<TextureRegion>, src: CPointer<BufferRegion>): Unit {
    unsafe {
        bgfx_encoder_blit_from_buffer(encoder, id, dst, src)
    }
}

/**
 * @brief 按更新频率创建 uniform
 */
public func bgfx_create_uniform_with_freq_cj(name: CString, freq: UInt32, `type`: UInt32, num: UInt16): UniformHandle {
    return unsafe {
        bgfx_create_uniform_with_freq(name, freq, `type`, num)
    }
}

/**
 * @brief 以引用方式设置 uniform
 */
public func bgfx_set_uniform_ref_cj(handle: UniformHandle, value: CPointer<Unit>, num: UInt16): Unit {
    unsafe {
        bgfx_set_uniform_ref(handle, value, num)
    }
}

/**
 * @brief encoder：以引用方式设置 uniform
 */
public func bgfx_encoder_set_uniform_ref_cj(encoder: CPointer<Encoder>, handle: UniformHandle, value: CPointer<Unit>, num: UInt16): Unit {
    unsafe {
        bgfx_encoder_set_uniform_ref(encoder, handle, value, num)
    }
}

/**
 * @brief 设置帧级 uniform
 */
public func bgfx_set_frame_uniform_cj(handle: UniformHandle, value: CPointer<Unit>, num: UInt16): Unit {
    unsafe {
        bgfx_set_frame_uniform(handle, value, num)
    }
}

/**
 * @brief 设置 view 级 uniform
 */
public func bgfx_set_view_uniform_cj(id: ViewId, handle: UniformHandle, value: CPointer<Unit>, num: UInt16): Unit {
    unsafe {
        bgfx_set_view_uniform(id, handle, value, num)
    }
}

/**
 * @brief 绑定纹理的指定 layer/mip 视图
 */
public func bgfx_set_texture_view_cj(stage: UInt8, sampler: UniformHandle, handle: TextureHandle, firstLayer: UInt16, numLayers: UInt16, firstMip: UInt8, numMips: UInt8, flags: UInt32): Unit {
    unsafe {
        bgfx_set_texture_view(stage, sampler, handle, firstLayer, numLayers, firstMip, numMips, flags)
    }
}

/**
 * @brief encoder：绑定纹理的指定 layer/mip 视图
 */
public func bgfx_encoder_set_texture_view_cj(encoder: CPointer<Encoder>, stage: UInt8, sampler: UniformHandle, handle: TextureHandle, firstLayer: UInt16, numLayers: UInt16, firstMip: UInt8, numMips: UInt8, flags: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_texture_view(encoder, stage, sampler, handle, firstLayer, numLayers, firstMip, numMips, flags)
    }
}

/**
 * @brief 以 image 方式绑定纹理（compute 读写）
 */
public func bgfx_set_image_view_cj(stage: UInt8, handle: TextureHandle, firstLayer: UInt16, numLayers: UInt16, mip: UInt8, access: UInt32, format: UInt32): Unit {
    unsafe {
        bgfx_set_image_view(stage, handle, firstLayer, numLayers, mip, access, format)
    }
}

/**
 * @brief encoder：以 image 方式绑定纹理
 */
public func bgfx_encoder_set_image_view_cj(encoder: CPointer<Encoder>, stage: UInt8, handle: TextureHandle, firstLayer: UInt16, numLayers: UInt16, mip: UInt8, access: UInt32, format: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_image_view(encoder, stage, handle, firstLayer, numLayers, mip, access, format)
    }
}

/**
 * @brief 设置采样 mask
 */
public func bgfx_set_sample_mask_cj(mask: UInt32): Unit {
    unsafe {
        bgfx_set_sample_mask(mask)
    }
}

/**
 * @brief encoder：设置采样 mask
 */
public func bgfx_encoder_set_sample_mask_cj(encoder: CPointer<Encoder>, mask: UInt32): Unit {
    unsafe {
        bgfx_encoder_set_sample_mask(encoder, mask)
    }
}

/**
 * @brief 设置深度控制，返回 cache id
 */
public func bgfx_set_depth_control_cj2(constant: Int32, slopeScale: Float32, clamp: Float32, depthClamp: Bool): UInt16 {
    return unsafe {
        bgfx_set_depth_control(constant, slopeScale, clamp, depthClamp)
    }
}

/**
 * @brief 复用缓存的深度控制
 */
public func bgfx_set_depth_control_cached_cj(cache: UInt16): Unit {
    unsafe {
        bgfx_set_depth_control_cached(cache)
    }
}

/**
 * @brief encoder：设置深度控制，返回 cache id
 */
public func bgfx_encoder_set_depth_control_cj2(encoder: CPointer<Encoder>, constant: Int32, slopeScale: Float32, clamp: Float32, depthClamp: Bool): UInt16 {
    return unsafe {
        bgfx_encoder_set_depth_control(encoder, constant, slopeScale, clamp, depthClamp)
    }
}

/**
 * @brief encoder：复用缓存的深度控制
 */
public func bgfx_encoder_set_depth_control_cached_cj(encoder: CPointer<Encoder>, cache: UInt16): Unit {
    unsafe {
        bgfx_encoder_set_depth_control_cached(encoder, cache)
    }
}

/**
 * @brief 设置 view 级深度偏置
 */
public func bgfx_set_view_depth_bias_cj(id: ViewId, constant: Int32, slopeScale: Float32, clamp: Float32): Unit {
    unsafe {
        bgfx_set_view_depth_bias(id, constant, slopeScale, clamp)
    }
}

/**
 * @brief 设置 view 级采样 mask
 */
public func bgfx_set_view_sample_mask_cj(id: ViewId, mask: UInt32): Unit {
    unsafe {
        bgfx_set_view_sample_mask(id, mask)
    }
}

/**
 * @brief 设置 view 级着色率
 */
public func bgfx_set_view_shading_rate_cj(id: ViewId, shadingRate: UInt32): Unit {
    unsafe {
        bgfx_set_view_shading_rate(id, shadingRate)
    }
}

/**
 * @brief 校验视频编解码参数是否被当前后端支持
 */
public func bgfx_is_video_codec_valid_cj(codec: UInt32, chroma: UInt8, bitDepth: UInt8, codedWidth: UInt16, codedHeight: UInt16, maxDpbSlots: UInt8, maxActiveReferences: UInt8): Bool {
    return unsafe {
        bgfx_is_video_codec_valid(codec, chroma, bitDepth, codedWidth, codedHeight, maxDpbSlots, maxActiveReferences)
    }
}

