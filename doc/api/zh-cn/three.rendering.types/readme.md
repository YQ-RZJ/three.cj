# 包 three.rendering.types 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[Handle](./类/Handle.md#class-handle)|bgfx 类型工厂 —— 统一的 Box 包装类型构建入口|

### 类型别名
|  名称   | 描述  |
|  ----  | ----  |
|[Access](./类型别名.md#type-access)|资源访问类型（Read / Write / ReadWrite）|
|[AllocatorInterface](./类型别名.md#type-allocatorinterface)|分配器接口（不透明）|
|[AttachmentPtr](./类型别名.md#type-attachmentptr)|帧缓冲附加信息指针（isFrameBufferValid 传入）|
|[Attachment](./类型别名.md#type-attachment)|帧缓冲纹理附加信息|
|[AttribType](./类型别名.md#type-attribtype)|顶点属性数据类型（Float / Half / Int16 / Uint8 ...）|
|[Attrib](./类型别名.md#type-attrib)|顶点属性语义（Position / Normal / TexCoord0 / Color0 ...）|
|[BackbufferRatio](./类型别名.md#type-backbufferratio)|后读缓冲比例（Full / Half / Quarter ...）|
|[CallbackInterface](./类型别名.md#type-callbackinterface)|回调接口（不透明）|
|[CapsGpu](./类型别名.md#type-capsgpu)|GPU 信息（PCI 厂商/设备 ID）|
|[CapsLimits](./类型别名.md#type-capslimits)|渲染器运行时限制（资源上限）|
|[CapsPtr](./类型别名.md#type-capsptr)|渲染器能力指针（getCaps 返回）|
|[Caps](./类型别名.md#type-caps)|渲染器能力信息（rendererType / supported / limits 等）|
|[DynamicIndexBufferHandle](./类型别名.md#type-dynamicindexbufferhandle)|动态索引缓冲句柄|
|[DynamicVertexBufferHandle](./类型别名.md#type-dynamicvertexbufferhandle)|动态顶点缓冲句柄|
|[EncoderPtr](./类型别名.md#type-encoderptr)|渲染编码器指针（encoder* 系列传入/返回）|
|[EncoderStats](./类型别名.md#type-encoderstats)|编码器统计信息|
|[Encoder](./类型别名.md#type-encoder)|渲染编码器|
|[Fatal](./类型别名.md#type-fatal)|致命错误类型（用于回调）|
|[FrameBufferHandle](./类型别名.md#type-framebufferhandle)|帧缓冲句柄|
|[IndexBufferHandle](./类型别名.md#type-indexbufferhandle)|静态索引缓冲句柄|
|[IndirectBufferHandle](./类型别名.md#type-indirectbufferhandle)|间接绘制缓冲句柄|
|[InitLimits](./类型别名.md#type-initlimits)|可配置运行时限制参数|
|[Init](./类型别名.md#type-init)|bgfx 初始化参数|
|[InstanceDataBufferPtr](./类型别名.md#type-instancedatabufferptr)|实例数据缓冲指针（setInstanceDataBuffer 传入）|
|[InstanceDataBuffer](./类型别名.md#type-instancedatabuffer)|实例数据缓冲|
|[InternalDataPtr](./类型别名.md#type-internaldataptr)|bgfx 内部数据指针（getInternalData 返回）|
|[InternalData](./类型别名.md#type-internaldata)|bgfx 内部数据（caps 指针与上下文指针）|
|[Memory](./类型别名.md#type-memory)|bgfx 内存块（createTexture2D/createVertexBuffer 的 mem 参数占位）|
|[NativeWindowHandleType](./类型别名.md#type-nativewindowhandletype)|原生窗口句柄类型（Default / Wayland）|
|[OcclusionQueryHandle](./类型别名.md#type-occlusionqueryhandle)|遮挡查询句柄|
|[OcclusionQueryResult](./类型别名.md#type-occlusionqueryresult)|遮挡查询结果（Invisible / Visible / NoResult）|
|[PlatformDataPtr](./类型别名.md#type-platformdataptr)|平台数据指针（setPlatformData 传入）|
|[PlatformData](./类型别名.md#type-platformdata)|平台数据（原生窗口句柄 nwh 等）|
|[ProgramHandle](./类型别名.md#type-programhandle)|程序句柄（vs+fs 链接后）|
|[RenderFrame](./类型别名.md#type-renderframe)|渲染帧类型（Render / Submit）|
|[RendererType](./类型别名.md#type-renderertype)|渲染器类型（Direct3D11 / Vulkan / OpenGLES / Metal / Noop ...）|
|[ShaderHandle](./类型别名.md#type-shaderhandle)|着色器句柄|
|[StatsPtr](./类型别名.md#type-statsptr)|渲染器统计指针（getStats 返回）|
|[Stats](./类型别名.md#type-stats)|渲染器统计信息|
|[SwapChain](./类型别名.md#type-swapchain)|交换链描述（原生窗口 backbuffer，新版 bgfx 取代 Resolution）|
|[TextureFormat](./类型别名.md#type-textureformat)|纹理格式（RGBA8 / RGBA16F / D24 / D24S8 ...）|
|[TextureHandle](./类型别名.md#type-texturehandle)|纹理句柄|
|[TextureInfoPtr](./类型别名.md#type-textureinfoptr)|纹理信息指针（createTexture / calcTextureSize 传入）|
|[TextureInfo](./类型别名.md#type-textureinfo)|纹理信息（format / width / height / numMips 等）|
|[TextureRegion](./类型别名.md#type-textureregion)|纹理区域描述符（新版 bgfx read/blit 区域模型）|
|[TopologyConvert](./类型别名.md#type-topologyconvert)|拓扑转换类型（TriListFlipWinding / TriStripToTriList ...）|
|[TopologySort](./类型别名.md#type-topologysort)|拓扑排序类型（DirectionFrontToBackMin / DistanceBackToFrontAvg ...）|
|[Topology](./类型别名.md#type-topology)|后端能力枚举（GPU 型号名）|
|[TransformPtr](./类型别名.md#type-transformptr)|变换数据指针（allocTransform / encoderAllocTransform）|
|[Transform](./类型别名.md#type-transform)|变换数据（矩阵指针）|
|[TransientIndexBufferPtr](./类型别名.md#type-transientindexbufferptr)|瞬态索引缓冲指针（setTransientIndexBuffer 传入）|
|[TransientIndexBuffer](./类型别名.md#type-transientindexbuffer)|瞬态索引缓冲|
|[TransientVertexBufferPtr](./类型别名.md#type-transientvertexbufferptr)|瞬态顶点缓冲指针（setTransientVertexBuffer 传入）|
|[TransientVertexBuffer](./类型别名.md#type-transientvertexbuffer)|瞬态顶点缓冲|
|[UniformHandle](./类型别名.md#type-uniformhandle)|uniform 句柄|
|[UniformInfoPtr](./类型别名.md#type-uniforminfoptr)|Uniform 信息指针（getUniformInfo 传入）|
|[UniformInfo](./类型别名.md#type-uniforminfo)|Uniform 变量信息（name / type / num）|
|[UniformType](./类型别名.md#type-uniformtype)|uniform 类型（Sampler / Vec4 / Mat4 / Int1 ...）|
|[UnitPtr](./类型别名.md#type-unitptr)|void* 指针包装（用于 getInterface / getDirectAccessPtr 等无类型指针）|
|[VertexBufferHandle](./类型别名.md#type-vertexbufferhandle)|静态顶点缓冲句柄|
|[VertexLayoutHandle](./类型别名.md#type-vertexlayouthandle)|顶点布局句柄|
|[VertexLayoutPtr](./类型别名.md#type-vertexlayoutptr)|顶点布局指针（createDynamicVertexBuffer 等传入）|
|[VertexLayout](./类型别名.md#type-vertexlayout)|顶点布局（hash / stride / offset）|
|[ViewMode](./类型别名.md#type-viewmode)|视图模式（默认 / 顺序 / 深度升序 / 深度降序）|
|[ViewStats](./类型别名.md#type-viewstats)|视图统计信息|

### 变量与常量
|  名称   | 描述  |
|  ----  | ----  |
|[BGFX_API_VERSION](./变量与常量.md#let-bgfx_api_version)|bgfx API 版本号|
|[BGFX_INVALID_HANDLE_IDX](./变量与常量.md#let-bgfx_invalid_handle_idx)|bgfx 句柄无效索引值|
|[BUFFER_ALLOW_RESIZE](./变量与常量.md#let-buffer_allow_resize)|允许动态缓冲 resize|
|[BUFFER_COMPUTE_READ](./变量与常量.md#let-buffer_compute_read)|计算缓冲可读|
|[BUFFER_COMPUTE_READ_WRITE](./变量与常量.md#let-buffer_compute_read_write)|计算缓冲可读写|
|[BUFFER_COMPUTE_WRITE](./变量与常量.md#let-buffer_compute_write)|计算缓冲可写|
|[BUFFER_DRAW_INDIRECT](./变量与常量.md#let-buffer_draw_indirect)|间接绘制缓冲|
|[BUFFER_INDEX32](./变量与常量.md#let-buffer_index32)|32bit 索引缓冲|
|[BUFFER_NONE](./变量与常量.md#let-buffer_none)|无特殊标志|
|[CAPS_BLEND_INDEPENDENT](./变量与常量.md#let-caps_blend_independent)|独立混合支持|
|[CAPS_COMPUTE](./变量与常量.md#let-caps_compute)|计算着色器支持|
|[CAPS_CONSERVATIVE_RASTER](./变量与常量.md#let-caps_conservative_raster)|保守光栅化支持|
|[CAPS_DRAW_INDIRECT](./变量与常量.md#let-caps_draw_indirect)|间接绘制支持|
|[CAPS_DRAW_INDIRECT_COUNT](./变量与常量.md#let-caps_draw_indirect_count)|带计数的间接绘制支持|
|[CAPS_FORMAT_TEXTURE_2D](./变量与常量.md#let-caps_format_texture_2d)|2D 纹理支持|
|[CAPS_FORMAT_TEXTURE_2D_EMULATED](./变量与常量.md#let-caps_format_texture_2d_emulated)|2D emulated texture support|
|[CAPS_FORMAT_TEXTURE_2D_SRGB](./变量与常量.md#let-caps_format_texture_2d_srgb)|2D sRGB 纹理支持|
|[CAPS_FORMAT_TEXTURE_3D](./变量与常量.md#let-caps_format_texture_3d)|3D 纹理支持|
|[CAPS_FORMAT_TEXTURE_3D_EMULATED](./变量与常量.md#let-caps_format_texture_3d_emulated)|3D emulated texture support|
|[CAPS_FORMAT_TEXTURE_3D_SRGB](./变量与常量.md#let-caps_format_texture_3d_srgb)|3D sRGB 纹理支持|
|[CAPS_FORMAT_TEXTURE_CUBE](./变量与常量.md#let-caps_format_texture_cube)|立方体纹理支持|
|[CAPS_FORMAT_TEXTURE_CUBE_EMULATED](./变量与常量.md#let-caps_format_texture_cube_emulated)|Cube emulated texture support|
|[CAPS_FORMAT_TEXTURE_CUBE_SRGB](./变量与常量.md#let-caps_format_texture_cube_srgb)|立方体 sRGB 纹理支持|
|[CAPS_FORMAT_TEXTURE_FRAMEBUFFER](./变量与常量.md#let-caps_format_texture_framebuffer)|帧缓冲支持|
|[CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA](./变量与常量.md#let-caps_format_texture_framebuffer_msaa)|MSAA 帧缓冲支持|
|[CAPS_FORMAT_TEXTURE_IMAGE_READ](./变量与常量.md#let-caps_format_texture_image_read)|Image read support|
|[CAPS_FORMAT_TEXTURE_IMAGE_WRITE](./变量与常量.md#let-caps_format_texture_image_write)|Image write support|
|[CAPS_FORMAT_TEXTURE_MIP_AUTOGEN](./变量与常量.md#let-caps_format_texture_mip_autogen)|Auto mipmap generation support|
|[CAPS_FORMAT_TEXTURE_MSAA](./变量与常量.md#let-caps_format_texture_msaa)|MSAA 纹理支持|
|[CAPS_FORMAT_TEXTURE_NONE](./变量与常量.md#let-caps_format_texture_none)|格式无能力|
|[CAPS_FORMAT_TEXTURE_VERTEX](./变量与常量.md#let-caps_format_texture_vertex)|顶点缓冲纹理支持|
|[CAPS_FRAGMENT_ORDERING](./变量与常量.md#let-caps_fragment_ordering)|片元排序支持|
|[CAPS_GRAPHICS_DEBUGGER](./变量与常量.md#let-caps_graphics_debugger)|Graphics debugger support|
|[CAPS_HDR10](./变量与常量.md#let-caps_hdr10)|HDR10 支持|
|[CAPS_IMAGE_RW](./变量与常量.md#let-caps_image_rw)|图像读写支持|
|[CAPS_INDEX32](./变量与常量.md#let-caps_index32)|32bit 索引支持|
|[CAPS_PRIMITIVE_ID](./变量与常量.md#let-caps_primitive_id)|图元 ID 支持|
|[CAPS_RENDERER_MULTITHREADED](./变量与常量.md#let-caps_renderer_multithreaded)|多线程渲染器支持|
|[CAPS_SWAP_CHAIN](./变量与常量.md#let-caps_swap_chain)|交换链支持|
|[CAPS_TEXTURE_CUBE_ARRAY](./变量与常量.md#let-caps_texture_cube_array)|Cube texture array support|
|[CAPS_TEXTURE_DIRECT_ACCESS](./变量与常量.md#let-caps_texture_direct_access)|Texture direct access support|
|[CAPS_TRANSPARENT_BACKBUFFER](./变量与常量.md#let-caps_transparent_backbuffer)|Transparent backbuffer support|
|[CAPS_VERTEX_ATTRIB_UINT10](./变量与常量.md#let-caps_vertex_attrib_uint10)|顶点属性 UInt10 支持|
|[CAPS_VIEWPORT_LAYER_ARRAY](./变量与常量.md#let-caps_viewport_layer_array)|Viewport layer array support|
|[CLEAR_COLOR](./变量与常量.md#let-clear_color)|Clear color|
|[CLEAR_DEPTH](./变量与常量.md#let-clear_depth)|Clear depth|
|[CLEAR_DISCARD_COLOR_0](./变量与常量.md#let-clear_discard_color_0)|丢弃颜色附件 0|
|[CLEAR_DISCARD_COLOR_1](./变量与常量.md#let-clear_discard_color_1)|丢弃颜色附件 1|
|[CLEAR_DISCARD_COLOR_2](./变量与常量.md#let-clear_discard_color_2)|丢弃颜色附件 2|
|[CLEAR_DISCARD_COLOR_3](./变量与常量.md#let-clear_discard_color_3)|丢弃颜色附件 3|
|[CLEAR_DISCARD_COLOR_4](./变量与常量.md#let-clear_discard_color_4)|丢弃颜色附件 4|
|[CLEAR_DISCARD_COLOR_5](./变量与常量.md#let-clear_discard_color_5)|丢弃颜色附件 5|
|[CLEAR_DISCARD_COLOR_6](./变量与常量.md#let-clear_discard_color_6)|丢弃颜色附件 6|
|[CLEAR_DISCARD_COLOR_7](./变量与常量.md#let-clear_discard_color_7)|丢弃颜色附件 7|
|[CLEAR_DISCARD_COLOR_MASK](./变量与常量.md#let-clear_discard_color_mask)|丢弃颜色附件mask|
|[CLEAR_DISCARD_DEPTH](./变量与常量.md#let-clear_discard_depth)|丢弃深度|
|[CLEAR_DISCARD_MASK](./变量与常量.md#let-clear_discard_mask)|丢弃mask|
|[CLEAR_DISCARD_STENCIL](./变量与常量.md#let-clear_discard_stencil)|丢弃模板|
|[CLEAR_NONE](./变量与常量.md#let-clear_none)|无清除|
|[CLEAR_STENCIL](./变量与常量.md#let-clear_stencil)|Clear stencil|
|[DEBUG_IFH](./变量与常量.md#let-debug_ifh)|IFH（无句柄）调试|
|[DEBUG_NONE](./变量与常量.md#let-debug_none)|无调试|
|[DEBUG_PROFILER](./变量与常量.md#let-debug_profiler)|性能分析调试|
|[DEBUG_STATS](./变量与常量.md#let-debug_stats)|统计调试|
|[DEBUG_TEXT](./变量与常量.md#let-debug_text)|文本调试|
|[DEBUG_WIREFRAME](./变量与常量.md#let-debug_wireframe)|线框调试|
|[DISCARD_ALL](./变量与常量.md#let-discard_all)|丢弃全部|
|[DISCARD_BINDINGS](./变量与常量.md#let-discard_bindings)|丢弃绑定|
|[DISCARD_INDEX_BUFFER](./变量与常量.md#let-discard_index_buffer)|丢弃索引缓冲|
|[DISCARD_INSTANCE_DATA](./变量与常量.md#let-discard_instance_data)|丢弃实例数据|
|[DISCARD_NONE](./变量与常量.md#let-discard_none)|无丢弃|
|[DISCARD_STATE](./变量与常量.md#let-discard_state)|丢弃状态|
|[DISCARD_TRANSFORM](./变量与常量.md#let-discard_transform)|丢弃变换|
|[DISCARD_VERTEX_STREAMS](./变量与常量.md#let-discard_vertex_streams)|丢弃顶点流|
|[INVALID_DYNAMIC_INDEX_BUFFER_HANDLE](./变量与常量.md#let-invalid_dynamic_index_buffer_handle)|无效动态索引缓冲句柄|
|[INVALID_DYNAMIC_VERTEX_BUFFER_HANDLE](./变量与常量.md#let-invalid_dynamic_vertex_buffer_handle)|无效动态顶点缓冲句柄|
|[INVALID_FRAME_BUFFER_HANDLE](./变量与常量.md#let-invalid_frame_buffer_handle)|无效帧缓冲句柄（idx=0xFFFF），用于字段初始值与销毁后复位|
|[INVALID_INDEX_BUFFER_HANDLE](./变量与常量.md#let-invalid_index_buffer_handle)|无效静态索引缓冲句柄|
|[INVALID_INDIRECT_BUFFER_HANDLE](./变量与常量.md#let-invalid_indirect_buffer_handle)|无效间接绘制缓冲句柄|
|[INVALID_OCCLUSION_QUERY_HANDLE](./变量与常量.md#let-invalid_occlusion_query_handle)|无效遮挡查询句柄|
|[INVALID_PROGRAM_HANDLE](./变量与常量.md#let-invalid_program_handle)|无效程序句柄|
|[INVALID_SHADER_HANDLE](./变量与常量.md#let-invalid_shader_handle)|无效着色器句柄|
|[INVALID_TEXTURE_HANDLE](./变量与常量.md#let-invalid_texture_handle)|无效纹理句柄|
|[INVALID_UNIFORM_HANDLE](./变量与常量.md#let-invalid_uniform_handle)|无效 uniform 句柄|
|[INVALID_VERTEX_BUFFER_HANDLE](./变量与常量.md#let-invalid_vertex_buffer_handle)|无效静态顶点缓冲句柄|
|[INVALID_VERTEX_LAYOUT_HANDLE](./变量与常量.md#let-invalid_vertex_layout_handle)|无效顶点布局句柄|
|[PCI_ID_AMD](./变量与常量.md#let-pci_id_amd)|AMD|
|[PCI_ID_APPLE](./变量与常量.md#let-pci_id_apple)|Apple|
|[PCI_ID_INTEL](./变量与常量.md#let-pci_id_intel)|Intel|
|[PCI_ID_MICROSOFT](./变量与常量.md#let-pci_id_microsoft)|Microsoft|
|[PCI_ID_NONE](./变量与常量.md#let-pci_id_none)|无厂商|
|[PCI_ID_NVIDIA](./变量与常量.md#let-pci_id_nvidia)|NVIDIA|
|[PCI_ID_SOFTWARE_RASTERIZER](./变量与常量.md#let-pci_id_software_rasterizer)|软件光栅化|
|[RESET_CAPTURE](./变量与常量.md#let-reset_capture)|捕获|
|[RESET_DEPTH_CLAMP](./变量与常量.md#let-reset_depth_clamp)|深度clamp|
|[RESET_FLIP_AFTER_RENDER](./变量与常量.md#let-reset_flip_after_render)|渲染后翻转|
|[RESET_FLUSH_AFTER_RENDER](./变量与常量.md#let-reset_flush_after_render)|渲染后刷新|
|[RESET_FULLSCREEN](./变量与常量.md#let-reset_fullscreen)|全屏|
|[RESET_FULLSCREEN_MASK](./变量与常量.md#let-reset_fullscreen_mask)|全屏 bit mask|
|[RESET_FULLSCREEN_SHIFT](./变量与常量.md#let-reset_fullscreen_shift)|全屏 bit offset|
|[RESET_HDR10](./变量与常量.md#let-reset_hdr10)|HDR10|
|[RESET_HIDPI](./变量与常量.md#let-reset_hidpi)|HiDPI|
|[RESET_MAXANISOTROPY](./变量与常量.md#let-reset_maxanisotropy)|最大各向异性|
|[RESET_MSAA_MASK](./变量与常量.md#let-reset_msaa_mask)|MSAA  bit mask|
|[RESET_MSAA_SHIFT](./变量与常量.md#let-reset_msaa_shift)|MSAA  bit offset|
|[RESET_MSAA_X16](./变量与常量.md#let-reset_msaa_x16)|MSAA ×16|
|[RESET_MSAA_X2](./变量与常量.md#let-reset_msaa_x2)|MSAA ×2|
|[RESET_MSAA_X4](./变量与常量.md#let-reset_msaa_x4)|MSAA ×4|
|[RESET_MSAA_X8](./变量与常量.md#let-reset_msaa_x8)|MSAA ×8|
|[RESET_NONE](./变量与常量.md#let-reset_none)|无重置|
|[RESET_RESERVED_MASK](./变量与常量.md#let-reset_reserved_mask)|保留 bit mask|
|[RESET_RESERVED_SHIFT](./变量与常量.md#let-reset_reserved_shift)|保留 bit offset|
|[RESET_SRGB_BACKBUFFER](./变量与常量.md#let-reset_srgb_backbuffer)|sRGB back缓冲|
|[RESET_SUSPEND](./变量与常量.md#let-reset_suspend)|Suspended|
|[RESET_TRANSPARENT_BACKBUFFER](./变量与常量.md#let-reset_transparent_backbuffer)|透明back缓冲|
|[RESET_VSYNC](./变量与常量.md#let-reset_vsync)|VSync|
|[RESOLVE_AUTO_GEN_MIPS](./变量与常量.md#let-resolve_auto_gen_mips)|自动生成 mipmap|
|[RESOLVE_NONE](./变量与常量.md#let-resolve_none)|无解析|
|[SAMPLER_BITS_MASK](./变量与常量.md#let-sampler_bits_mask)|采样器 bit maskfull set|
|[SAMPLER_BORDER_COLOR_MASK](./变量与常量.md#let-sampler_border_color_mask)|边界颜色 bit mask|
|[SAMPLER_BORDER_COLOR_SHIFT](./变量与常量.md#let-sampler_border_color_shift)|边界颜色 bit offset|
|[SAMPLER_COMPARE_ALWAYS](./变量与常量.md#let-sampler_compare_always)|深度比较：始终|
|[SAMPLER_COMPARE_EQUAL](./变量与常量.md#let-sampler_compare_equal)|深度比较：等于|
|[SAMPLER_COMPARE_GEQUAL](./变量与常量.md#let-sampler_compare_gequal)|深度比较：大于等于|
|[SAMPLER_COMPARE_GREATER](./变量与常量.md#let-sampler_compare_greater)|深度比较：大于|
|[SAMPLER_COMPARE_LEQUAL](./变量与常量.md#let-sampler_compare_lequal)|深度比较：小于等于|
|[SAMPLER_COMPARE_LESS](./变量与常量.md#let-sampler_compare_less)|深度比较：小于|
|[SAMPLER_COMPARE_MASK](./变量与常量.md#let-sampler_compare_mask)|深度比较 bit mask|
|[SAMPLER_COMPARE_NEVER](./变量与常量.md#let-sampler_compare_never)|深度比较：从不|
|[SAMPLER_COMPARE_NOTEQUAL](./变量与常量.md#let-sampler_compare_notequal)|深度比较：不等于|
|[SAMPLER_COMPARE_SHIFT](./变量与常量.md#let-sampler_compare_shift)|深度比较 bit offset|
|[SAMPLER_MAG_ANISOTROPIC](./变量与常量.md#let-sampler_mag_anisotropic)|放大过滤：各向异性|
|[SAMPLER_MAG_MASK](./变量与常量.md#let-sampler_mag_mask)|放大过滤 bit mask|
|[SAMPLER_MAG_POINT](./变量与常量.md#let-sampler_mag_point)|放大过滤：点采样|
|[SAMPLER_MAG_SHIFT](./变量与常量.md#let-sampler_mag_shift)|放大过滤 bit offset|
|[SAMPLER_MIN_ANISOTROPIC](./变量与常量.md#let-sampler_min_anisotropic)|缩小过滤：各向异性|
|[SAMPLER_MIN_MASK](./变量与常量.md#let-sampler_min_mask)|缩小过滤 bit mask|
|[SAMPLER_MIN_POINT](./变量与常量.md#let-sampler_min_point)|缩小过滤：点采样|
|[SAMPLER_MIN_SHIFT](./变量与常量.md#let-sampler_min_shift)|缩小过滤 bit offset|
|[SAMPLER_MIP_MASK](./变量与常量.md#let-sampler_mip_mask)|mip 过滤 bit mask|
|[SAMPLER_MIP_POINT](./变量与常量.md#let-sampler_mip_point)|mip 过滤：点采样|
|[SAMPLER_MIP_SHIFT](./变量与常量.md#let-sampler_mip_shift)|mip 过滤 bit offset|
|[SAMPLER_NONE](./变量与常量.md#let-sampler_none)|无采样器标志|
|[SAMPLER_POINT](./变量与常量.md#let-sampler_point)|点采样combination（min/mag/mip 均点采样）|
|[SAMPLER_RESERVED_MASK](./变量与常量.md#let-sampler_reserved_mask)|保留 bit mask|
|[SAMPLER_RESERVED_SHIFT](./变量与常量.md#let-sampler_reserved_shift)|保留 bit offset|
|[SAMPLER_SAMPLE_STENCIL](./变量与常量.md#let-sampler_sample_stencil)|采样模板|
|[SAMPLER_UVW_BORDER](./变量与常量.md#let-sampler_uvw_border)|UVW 边界combination|
|[SAMPLER_UVW_CLAMP](./变量与常量.md#let-sampler_uvw_clamp)|UVW clamp位combination|
|[SAMPLER_UVW_MIRROR](./变量与常量.md#let-sampler_uvw_mirror)|UVW 镜像combination|
|[SAMPLER_U_BORDER](./变量与常量.md#let-sampler_u_border)|U 方向边界|
|[SAMPLER_U_CLAMP](./变量与常量.md#let-sampler_u_clamp)|U 方向clamp位|
|[SAMPLER_U_MASK](./变量与常量.md#let-sampler_u_mask)|U 方向 bit mask|
|[SAMPLER_U_MIRROR](./变量与常量.md#let-sampler_u_mirror)|U 方向镜像|
|[SAMPLER_U_SHIFT](./变量与常量.md#let-sampler_u_shift)|U 方向 bit offset|
|[SAMPLER_V_BORDER](./变量与常量.md#let-sampler_v_border)|V 方向边界|
|[SAMPLER_V_CLAMP](./变量与常量.md#let-sampler_v_clamp)|V 方向clamp位|
|[SAMPLER_V_MASK](./变量与常量.md#let-sampler_v_mask)|V 方向 bit mask|
|[SAMPLER_V_MIRROR](./变量与常量.md#let-sampler_v_mirror)|V 方向镜像|
|[SAMPLER_V_SHIFT](./变量与常量.md#let-sampler_v_shift)|V 方向 bit offset|
|[SAMPLER_W_BORDER](./变量与常量.md#let-sampler_w_border)|W 方向边界|
|[SAMPLER_W_CLAMP](./变量与常量.md#let-sampler_w_clamp)|W 方向clamp位|
|[SAMPLER_W_MASK](./变量与常量.md#let-sampler_w_mask)|W 方向 bit mask|
|[SAMPLER_W_MIRROR](./变量与常量.md#let-sampler_w_mirror)|W 方向镜像|
|[SAMPLER_W_SHIFT](./变量与常量.md#let-sampler_w_shift)|W 方向 bit offset|
|[STATE_ALPHA_REF_MASK](./变量与常量.md#let-state_alpha_ref_mask)|alpha 参考值 bit mask|
|[STATE_ALPHA_REF_SHIFT](./变量与常量.md#let-state_alpha_ref_shift)|alpha 参考值 bit offset|
|[STATE_BLEND_ALPHA_TO_COVERAGE](./变量与常量.md#let-state_blend_alpha_to_coverage)|alpha 到覆盖|
|[STATE_BLEND_DST_ALPHA](./变量与常量.md#let-state_blend_dst_alpha)|混合因子：目标 alpha|
|[STATE_BLEND_DST_COLOR](./变量与常量.md#let-state_blend_dst_color)|混合因子：目标颜色|
|[STATE_BLEND_EQUATION_ADD](./变量与常量.md#let-state_blend_equation_add)|混合方程：加法|
|[STATE_BLEND_EQUATION_MASK](./变量与常量.md#let-state_blend_equation_mask)|混合方程 bit mask|
|[STATE_BLEND_EQUATION_MAX](./变量与常量.md#let-state_blend_equation_max)|混合方程：取最大值|
|[STATE_BLEND_EQUATION_MIN](./变量与常量.md#let-state_blend_equation_min)|混合方程：取最小值|
|[STATE_BLEND_EQUATION_REVSUB](./变量与常量.md#let-state_blend_equation_revsub)|混合方程：反向减法|
|[STATE_BLEND_EQUATION_SHIFT](./变量与常量.md#let-state_blend_equation_shift)|混合方程 bit offset|
|[STATE_BLEND_EQUATION_SUB](./变量与常量.md#let-state_blend_equation_sub)|混合方程：减法|
|[STATE_BLEND_FACTOR](./变量与常量.md#let-state_blend_factor)|混合因子：常数|
|[STATE_BLEND_INDEPENDENT](./变量与常量.md#let-state_blend_independent)|独立混合|
|[STATE_BLEND_INV_DST_ALPHA](./变量与常量.md#let-state_blend_inv_dst_alpha)|混合因子：目标 alpha inverted|
|[STATE_BLEND_INV_DST_COLOR](./变量与常量.md#let-state_blend_inv_dst_color)|混合因子：目标颜色inverted|
|[STATE_BLEND_INV_FACTOR](./变量与常量.md#let-state_blend_inv_factor)|混合因子：常数inverted|
|[STATE_BLEND_INV_SRC_ALPHA](./变量与常量.md#let-state_blend_inv_src_alpha)|混合因子：源 alpha inverted|
|[STATE_BLEND_INV_SRC_COLOR](./变量与常量.md#let-state_blend_inv_src_color)|混合因子：源颜色inverted|
|[STATE_BLEND_MASK](./变量与常量.md#let-state_blend_mask)|混合因子 bit mask|
|[STATE_BLEND_ONE](./变量与常量.md#let-state_blend_one)|混合因子：一|
|[STATE_BLEND_SHIFT](./变量与常量.md#let-state_blend_shift)|混合因子 bit offset|
|[STATE_BLEND_SRC_ALPHA](./变量与常量.md#let-state_blend_src_alpha)|混合因子：源 alpha|
|[STATE_BLEND_SRC_ALPHA_SAT](./变量与常量.md#let-state_blend_src_alpha_sat)|混合因子：源 alpha 饱和|
|[STATE_BLEND_SRC_COLOR](./变量与常量.md#let-state_blend_src_color)|混合因子：源颜色|
|[STATE_BLEND_ZERO](./变量与常量.md#let-state_blend_zero)|混合因子：零|
|[STATE_CONSERVATIVE_RASTER](./变量与常量.md#let-state_conservative_raster)|保守光栅化|
|[STATE_CULL_CCW](./变量与常量.md#let-state_cull_ccw)|face剔除：逆时针|
|[STATE_CULL_CW](./变量与常量.md#let-state_cull_cw)|face剔除：顺时针|
|[STATE_CULL_MASK](./变量与常量.md#let-state_cull_mask)|face剔除 bit mask|
|[STATE_CULL_SHIFT](./变量与常量.md#let-state_cull_shift)|face剔除 bit offset|
|[STATE_DEFAULT](./变量与常量.md#let-state_default)|默认状态（深度测试 + write RGB + write Z + CCW face剔除）|
|[STATE_DEPTH_TEST_ALWAYS](./变量与常量.md#let-state_depth_test_always)|深度测试：始终|
|[STATE_DEPTH_TEST_EQUAL](./变量与常量.md#let-state_depth_test_equal)|深度测试：等于|
|[STATE_DEPTH_TEST_GEQUAL](./变量与常量.md#let-state_depth_test_gequal)|深度测试：大于等于|
|[STATE_DEPTH_TEST_GREATER](./变量与常量.md#let-state_depth_test_greater)|深度测试：大于|
|[STATE_DEPTH_TEST_LEQUAL](./变量与常量.md#let-state_depth_test_lequal)|深度测试：小于等于|
|[STATE_DEPTH_TEST_LESS](./变量与常量.md#let-state_depth_test_less)|深度测试：小于|
|[STATE_DEPTH_TEST_MASK](./变量与常量.md#let-state_depth_test_mask)|深度测试 bit mask|
|[STATE_DEPTH_TEST_NEVER](./变量与常量.md#let-state_depth_test_never)|深度测试：从不|
|[STATE_DEPTH_TEST_NOTEQUAL](./变量与常量.md#let-state_depth_test_notequal)|深度测试：不等于|
|[STATE_DEPTH_TEST_SHIFT](./变量与常量.md#let-state_depth_test_shift)|深度测试 bit offset|
|[STATE_FRONT_CCW](./变量与常量.md#let-state_front_ccw)|逆时针正face|
|[STATE_LINEAA](./变量与常量.md#let-state_lineaa)|线段抗锯齿|
|[STATE_MASK](./变量与常量.md#let-state_mask)|状态maskfull set|
|[STATE_MSAA](./变量与常量.md#let-state_msaa)|MSAA|
|[STATE_NONE](./变量与常量.md#let-state_none)|无状态|
|[STATE_POINT_SIZE_MASK](./变量与常量.md#let-state_point_size_mask)|点大小 bit mask|
|[STATE_POINT_SIZE_SHIFT](./变量与常量.md#let-state_point_size_shift)|点大小 bit offset|
|[STATE_PT_LINESTRIP](./变量与常量.md#let-state_pt_linestrip)|图元类型：线段条带|
|[STATE_PT_LINES](./变量与常量.md#let-state_pt_lines)|图元类型：线段列表|
|[STATE_PT_MASK](./变量与常量.md#let-state_pt_mask)|图元类型 bit mask|
|[STATE_PT_POINTS](./变量与常量.md#let-state_pt_points)|图元类型：点列表|
|[STATE_PT_SHIFT](./变量与常量.md#let-state_pt_shift)|图元类型 bit offset|
|[STATE_PT_TRISTRIP](./变量与常量.md#let-state_pt_tristrip)|图元类型：三角形条带|
|[STATE_RESERVED_MASK](./变量与常量.md#let-state_reserved_mask)|保留 bit mask|
|[STATE_RESERVED_SHIFT](./变量与常量.md#let-state_reserved_shift)|保留 bit offset|
|[STATE_WRITE_A](./变量与常量.md#let-state_write_a)|写入 A 通道|
|[STATE_WRITE_B](./变量与常量.md#let-state_write_b)|写入 B 通道|
|[STATE_WRITE_G](./变量与常量.md#let-state_write_g)|写入 G 通道|
|[STATE_WRITE_MASK](./变量与常量.md#let-state_write_mask)|写入maskfull set|
|[STATE_WRITE_RGB](./变量与常量.md#let-state_write_rgb)|写入 RGB 通道|
|[STATE_WRITE_R](./变量与常量.md#let-state_write_r)|写入 R 通道|
|[STATE_WRITE_Z](./变量与常量.md#let-state_write_z)|写入 Z（深度）通道|
|[STENCIL_FUNC_REF_MASK](./变量与常量.md#let-stencil_func_ref_mask)|模板函数参考值 bit mask|
|[STENCIL_FUNC_REF_SHIFT](./变量与常量.md#let-stencil_func_ref_shift)|模板函数参考值 bit offset|
|[STENCIL_FUNC_RMASK_MASK](./变量与常量.md#let-stencil_func_rmask_mask)|模板函数mask bit mask|
|[STENCIL_FUNC_RMASK_SHIFT](./变量与常量.md#let-stencil_func_rmask_shift)|模板函数mask bit offset|
|[STENCIL_MASK](./变量与常量.md#let-stencil_mask)|模板maskfull set|
|[STENCIL_NONE](./变量与常量.md#let-stencil_none)|无模板|
|[STENCIL_OP_FAIL_S_DECRSAT](./变量与常量.md#let-stencil_op_fail_s_decrsat)|模板操作：失败递减饱和|
|[STENCIL_OP_FAIL_S_DECR](./变量与常量.md#let-stencil_op_fail_s_decr)|模板操作：失败递减|
|[STENCIL_OP_FAIL_S_INCRSAT](./变量与常量.md#let-stencil_op_fail_s_incrsat)|模板操作：失败递增饱和|
|[STENCIL_OP_FAIL_S_INCR](./变量与常量.md#let-stencil_op_fail_s_incr)|模板操作：失败递增|
|[STENCIL_OP_FAIL_S_INVERT](./变量与常量.md#let-stencil_op_fail_s_invert)|模板操作：失败inverted|
|[STENCIL_OP_FAIL_S_KEEP](./变量与常量.md#let-stencil_op_fail_s_keep)|模板操作：失败保持|
|[STENCIL_OP_FAIL_S_MASK](./变量与常量.md#let-stencil_op_fail_s_mask)|模板操作 bit mask|
|[STENCIL_OP_FAIL_S_REPLACE](./变量与常量.md#let-stencil_op_fail_s_replace)|模板操作：失败替换|
|[STENCIL_OP_FAIL_S_SHIFT](./变量与常量.md#let-stencil_op_fail_s_shift)|模板操作 bit offset|
|[STENCIL_OP_FAIL_S_ZERO](./变量与常量.md#let-stencil_op_fail_s_zero)|模板操作：失败零|
|[STENCIL_OP_FAIL_Z_DECRSAT](./变量与常量.md#let-stencil_op_fail_z_decrsat)|模板操作：深度失败递减饱和|
|[STENCIL_OP_FAIL_Z_DECR](./变量与常量.md#let-stencil_op_fail_z_decr)|模板操作：深度失败递减|
|[STENCIL_OP_FAIL_Z_INCRSAT](./变量与常量.md#let-stencil_op_fail_z_incrsat)|模板操作：深度失败递增饱和|
|[STENCIL_OP_FAIL_Z_INCR](./变量与常量.md#let-stencil_op_fail_z_incr)|模板操作：深度失败递增|
|[STENCIL_OP_FAIL_Z_INVERT](./变量与常量.md#let-stencil_op_fail_z_invert)|模板操作：深度失败inverted|
|[STENCIL_OP_FAIL_Z_KEEP](./变量与常量.md#let-stencil_op_fail_z_keep)|模板操作：深度失败保持|
|[STENCIL_OP_FAIL_Z_MASK](./变量与常量.md#let-stencil_op_fail_z_mask)|模板操作 bit mask|
|[STENCIL_OP_FAIL_Z_REPLACE](./变量与常量.md#let-stencil_op_fail_z_replace)|模板操作：深度失败替换|
|[STENCIL_OP_FAIL_Z_SHIFT](./变量与常量.md#let-stencil_op_fail_z_shift)|模板操作 bit offset|
|[STENCIL_OP_FAIL_Z_ZERO](./变量与常量.md#let-stencil_op_fail_z_zero)|模板操作：深度失败零|
|[STENCIL_OP_PASS_Z_DECRSAT](./变量与常量.md#let-stencil_op_pass_z_decrsat)|模板操作：深度通过递减饱和|
|[STENCIL_OP_PASS_Z_DECR](./变量与常量.md#let-stencil_op_pass_z_decr)|模板操作：深度通过递减|
|[STENCIL_OP_PASS_Z_INCRSAT](./变量与常量.md#let-stencil_op_pass_z_incrsat)|模板操作：深度通过递增饱和|
|[STENCIL_OP_PASS_Z_INCR](./变量与常量.md#let-stencil_op_pass_z_incr)|模板操作：深度通过递增|
|[STENCIL_OP_PASS_Z_INVERT](./变量与常量.md#let-stencil_op_pass_z_invert)|模板操作：深度通过inverted|
|[STENCIL_OP_PASS_Z_KEEP](./变量与常量.md#let-stencil_op_pass_z_keep)|模板操作：深度通过保持|
|[STENCIL_OP_PASS_Z_MASK](./变量与常量.md#let-stencil_op_pass_z_mask)|模板操作 bit mask|
|[STENCIL_OP_PASS_Z_REPLACE](./变量与常量.md#let-stencil_op_pass_z_replace)|模板操作：深度通过替换|
|[STENCIL_OP_PASS_Z_SHIFT](./变量与常量.md#let-stencil_op_pass_z_shift)|模板操作 bit offset|
|[STENCIL_OP_PASS_Z_ZERO](./变量与常量.md#let-stencil_op_pass_z_zero)|模板操作：深度通过零|
|[STENCIL_TEST_ALWAYS](./变量与常量.md#let-stencil_test_always)|模板测试：始终|
|[STENCIL_TEST_EQUAL](./变量与常量.md#let-stencil_test_equal)|模板测试：等于|
|[STENCIL_TEST_GEQUAL](./变量与常量.md#let-stencil_test_gequal)|模板测试：大于等于|
|[STENCIL_TEST_GREATER](./变量与常量.md#let-stencil_test_greater)|模板测试：大于|
|[STENCIL_TEST_LEQUAL](./变量与常量.md#let-stencil_test_lequal)|模板测试：小于等于|
|[STENCIL_TEST_LESS](./变量与常量.md#let-stencil_test_less)|模板测试：小于|
|[STENCIL_TEST_MASK](./变量与常量.md#let-stencil_test_mask)|模板测试 bit mask|
|[STENCIL_TEST_NEVER](./变量与常量.md#let-stencil_test_never)|模板测试：从不|
|[STENCIL_TEST_NOTEQUAL](./变量与常量.md#let-stencil_test_notequal)|模板测试：不等于|
|[STENCIL_TEST_SHIFT](./变量与常量.md#let-stencil_test_shift)|模板测试 bit offset|
|[TEXTURE_BLIT_DST](./变量与常量.md#let-texture_blit_dst)|纹理 blit 目标|
|[TEXTURE_COMPUTE_WRITE](./变量与常量.md#let-texture_compute_write)|计算写纹理|
|[TEXTURE_MSAA_SAMPLE](./变量与常量.md#let-texture_msaa_sample)|MSAA 采样纹理|
|[TEXTURE_NONE](./变量与常量.md#let-texture_none)|无Texture flag|
|[TEXTURE_READ_BACK](./变量与常量.md#let-texture_read_back)|纹理回读|
|[TEXTURE_RT](./变量与常量.md#let-texture_rt)|渲染目标纹理|
|[TEXTURE_RT_MASK](./变量与常量.md#let-texture_rt_mask)|RT  bit mask|
|[TEXTURE_RT_MSAA_MASK](./变量与常量.md#let-texture_rt_msaa_mask)|RT MSAA  bit mask|
|[TEXTURE_RT_MSAA_SHIFT](./变量与常量.md#let-texture_rt_msaa_shift)|RT MSAA  bit offset|
|[TEXTURE_RT_MSAA_X16](./变量与常量.md#let-texture_rt_msaa_x16)|RT MSAA ×16|
|[TEXTURE_RT_MSAA_X2](./变量与常量.md#let-texture_rt_msaa_x2)|RT MSAA ×2|
|[TEXTURE_RT_MSAA_X4](./变量与常量.md#let-texture_rt_msaa_x4)|RT MSAA ×4|
|[TEXTURE_RT_MSAA_X8](./变量与常量.md#let-texture_rt_msaa_x8)|RT MSAA ×8|
|[TEXTURE_RT_SHIFT](./变量与常量.md#let-texture_rt_shift)|RT  bit offset|
|[TEXTURE_RT_WRITE_ONLY](./变量与常量.md#let-texture_rt_write_only)|RT 只写|
|[TEXTURE_SRGB](./变量与常量.md#let-texture_srgb)|sRGB 纹理|

