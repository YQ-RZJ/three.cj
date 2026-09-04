# Package three.rendering.types 

## API List

### Function
|  Name   | Describe  |
|  ----  | ----  |
|[handleIdx(FrameBufferHandle)](./Function.md#func-handleidxframebufferhandle)|Get frame buffer handle internal idx (for debug logging only; use isValidHandle for validity check)|
|[handleIdx(TextureHandle)](./Function.md#func-handleidxtexturehandle)|Get texture handle idx (for logging)|
|[handleIdx(ProgramHandle)](./Function.md#func-handleidxprogramhandle)|Get program handle idx (for logging)|
|[handleIdx(UniformHandle)](./Function.md#func-handleidxuniformhandle)|Get uniform handle idx (for logging)|
|[handleIdx(VertexBufferHandle)](./Function.md#func-handleidxvertexbufferhandle)|Get static vertex buffer handle idx (for logging)|
|[handleIdx(IndexBufferHandle)](./Function.md#func-handleidxindexbufferhandle)|Get static index buffer handle idx (for logging)|
|[handleIdx(VertexLayoutHandle)](./Function.md#func-handleidxvertexlayouthandle)|Get vertex layout handle idx (for logging)|
|[handleIdx(DynamicVertexBufferHandle)](./Function.md#func-handleidxdynamicvertexbufferhandle)|Get dynamic vertex buffer handle idx (for logging)|
|[handleIdx(DynamicIndexBufferHandle)](./Function.md#func-handleidxdynamicindexbufferhandle)|Get dynamic index buffer handle idx (for logging)|
|[handleIdx(ShaderHandle)](./Function.md#func-handleidxshaderhandle)|Get shader handle idx (for logging)|
|[handleIdx(IndirectBufferHandle)](./Function.md#func-handleidxindirectbufferhandle)|Get indirect buffer handle idx (for logging)|
|[handleIdx(OcclusionQueryHandle)](./Function.md#func-handleidxocclusionqueryhandle)|Get occlusion query handle idx (for logging)|
|[isValidHandle(FrameBufferHandle)](./Function.md#func-isvalidhandleframebufferhandle)|Check if frame buffer handle is valid (idx != 0xFFFF)|
|[isValidHandle(TextureHandle)](./Function.md#func-isvalidhandletexturehandle)|Check if texture handle is valid|
|[isValidHandle(ProgramHandle)](./Function.md#func-isvalidhandleprogramhandle)|Check if program handle is valid|
|[isValidHandle(UniformHandle)](./Function.md#func-isvalidhandleuniformhandle)|Check if uniform handle is valid|
|[isValidHandle(VertexBufferHandle)](./Function.md#func-isvalidhandlevertexbufferhandle)|Check if static vertex buffer handle is valid|
|[isValidHandle(IndexBufferHandle)](./Function.md#func-isvalidhandleindexbufferhandle)|Check if static index buffer handle is valid|
|[isValidHandle(VertexLayoutHandle)](./Function.md#func-isvalidhandlevertexlayouthandle)|Check if vertex layout handle is valid|
|[isValidHandle(DynamicVertexBufferHandle)](./Function.md#func-isvalidhandledynamicvertexbufferhandle)|Check if dynamic vertex buffer handle is valid|
|[isValidHandle(DynamicIndexBufferHandle)](./Function.md#func-isvalidhandledynamicindexbufferhandle)|Check if dynamic index buffer handle is valid|
|[isValidHandle(ShaderHandle)](./Function.md#func-isvalidhandleshaderhandle)|Check if shader handle is valid|
|[isValidHandle(IndirectBufferHandle)](./Function.md#func-isvalidhandleindirectbufferhandle)|Check if indirect buffer handle is valid|
|[isValidHandle(OcclusionQueryHandle)](./Function.md#func-isvalidhandleocclusionqueryhandle)|Check if occlusion query handle is valid|

### Type Alias
|  Name   | Describe  |
|  ----  | ----  |
|[Access](./Type%20Alias.md#type-access)|Resource access type (Read / Write / ReadWrite)|
|[AllocatorInterface](./Type%20Alias.md#type-allocatorinterface)|Allocator interface (opaque)|
|[AttachmentPtr](./Type%20Alias.md#type-attachmentptr)|Frame buffer attachment info pointer (passed to isFrameBufferValid)|
|[Attachment](./Type%20Alias.md#type-attachment)|Frame buffer texture attachment info|
|[AttribType](./Type%20Alias.md#type-attribtype)|Vertex attribute data type (Float / Half / Int16 / Uint8 ...)|
|[Attrib](./Type%20Alias.md#type-attrib)|Vertex attribute semantic (Position / Normal / TexCoord0 / Color0 ...)|
|[BackbufferRatio](./Type%20Alias.md#type-backbufferratio)|Backbuffer ratio (Full / Half / Quarter ...)|
|[CallbackInterface](./Type%20Alias.md#type-callbackinterface)|Callback interface (opaque)|
|[CapsGpu](./Type%20Alias.md#type-capsgpu)|GPU information (PCI vendor/device ID)|
|[CapsLimits](./Type%20Alias.md#type-capslimits)|Renderer runtime limits (resource caps)|
|[CapsPtr](./Type%20Alias.md#type-capsptr)|Renderer capabilities pointer (returned by getCaps)|
|[Caps](./Type%20Alias.md#type-caps)|Renderer capabilities info (rendererType / supported / limits etc.)|
|[DynamicIndexBufferHandle](./Type%20Alias.md#type-dynamicindexbufferhandle)|Dynamic index buffer handle|
|[DynamicVertexBufferHandle](./Type%20Alias.md#type-dynamicvertexbufferhandle)|Dynamic vertex buffer handle|
|[EncoderPtr](./Type%20Alias.md#type-encoderptr)|Render encoder pointer (passed/returned by encoder* series)|
|[EncoderStats](./Type%20Alias.md#type-encoderstats)|Encoder statistics|
|[Encoder](./Type%20Alias.md#type-encoder)|Render encoder|
|[Fatal](./Type%20Alias.md#type-fatal)|Fatal error type (for callbacks)|
|[FrameBufferHandle](./Type%20Alias.md#type-framebufferhandle)|Frame buffer handle|
|[IndexBufferHandle](./Type%20Alias.md#type-indexbufferhandle)|Static index buffer handle|
|[IndirectBufferHandle](./Type%20Alias.md#type-indirectbufferhandle)|Indirect buffer handle|
|[InitLimits](./Type%20Alias.md#type-initlimits)|Configurable runtime limit parameters|
|[Init](./Type%20Alias.md#type-init)|bgfx initialization parameters|
|[InstanceDataBufferPtr](./Type%20Alias.md#type-instancedatabufferptr)|Instance data buffer pointer (passed to setInstanceDataBuffer)|
|[InstanceDataBuffer](./Type%20Alias.md#type-instancedatabuffer)|Instance data buffer|
|[InternalDataPtr](./Type%20Alias.md#type-internaldataptr)|bgfx internal data pointer (returned by getInternalData)|
|[InternalData](./Type%20Alias.md#type-internaldata)|bgfx internal data (caps pointer and context pointer)|
|[Memory](./Type%20Alias.md#type-memory)|bgfx memory block (placeholder for mem parameter of createTexture2D/createVertexBuffer)|
|[NativeWindowHandleType](./Type%20Alias.md#type-nativewindowhandletype)|Native window handle type (Default / Wayland)|
|[OcclusionQueryHandle](./Type%20Alias.md#type-occlusionqueryhandle)|Occlusion query handle|
|[OcclusionQueryResult](./Type%20Alias.md#type-occlusionqueryresult)|Occlusion query result (Invisible / Visible / NoResult)|
|[PlatformDataPtr](./Type%20Alias.md#type-platformdataptr)|Platform data pointer (passed to setPlatformData)|
|[PlatformData](./Type%20Alias.md#type-platformdata)|Platform data (native window handle nwh etc.)|
|[ProgramHandle](./Type%20Alias.md#type-programhandle)|Program handle (linked vertex + fragment shader)|
|[RenderFrame](./Type%20Alias.md#type-renderframe)|Render frame type (Render / Submit)|
|[RendererType](./Type%20Alias.md#type-renderertype)|Renderer type (Direct3D11 / Vulkan / OpenGLES / Metal / Noop ...)|
|[Resolution](./Type%20Alias.md#type-resolution)|Backbuffer resolution and reset parameters|
|[ShaderHandle](./Type%20Alias.md#type-shaderhandle)|Shader handle|
|[StatsPtr](./Type%20Alias.md#type-statsptr)|Renderer statistics pointer (returned by getStats)|
|[Stats](./Type%20Alias.md#type-stats)|Renderer statistics|
|[TextureFormat](./Type%20Alias.md#type-textureformat)|Texture format (RGBA8 / RGBA16F / D24 / D24S8 ...)|
|[TextureHandle](./Type%20Alias.md#type-texturehandle)|Texture handle|
|[TextureInfoPtr](./Type%20Alias.md#type-textureinfoptr)|Texture info pointer (passed to createTexture / calcTextureSize)|
|[TextureInfo](./Type%20Alias.md#type-textureinfo)|Texture info (format / width / height / numMips etc.)|
|[TopologyConvert](./Type%20Alias.md#type-topologyconvert)|Topology convert type (TriListFlipWinding / TriStripToTriList ...)|
|[TopologySort](./Type%20Alias.md#type-topologysort)|Topology sort type (DirectionFrontToBackMin / DistanceBackToFrontAvg ...)|
|[Topology](./Type%20Alias.md#type-topology)|Backend capability enum (GPU model name)|
|[TransformPtr](./Type%20Alias.md#type-transformptr)|Transform data pointer (for allocTransform / encoderAllocTransform)|
|[Transform](./Type%20Alias.md#type-transform)|Transform data (matrix pointer)|
|[TransientIndexBufferPtr](./Type%20Alias.md#type-transientindexbufferptr)|Transient index buffer pointer (passed to setTransientIndexBuffer)|
|[TransientIndexBuffer](./Type%20Alias.md#type-transientindexbuffer)|Transient index buffer|
|[TransientVertexBufferPtr](./Type%20Alias.md#type-transientvertexbufferptr)|Transient vertex buffer pointer (passed to setTransientVertexBuffer)|
|[TransientVertexBuffer](./Type%20Alias.md#type-transientvertexbuffer)|Transient vertex buffer|
|[UniformHandle](./Type%20Alias.md#type-uniformhandle)|Uniform handle|
|[UniformInfoPtr](./Type%20Alias.md#type-uniforminfoptr)|Uniform info pointer (passed to getUniformInfo)|
|[UniformInfo](./Type%20Alias.md#type-uniforminfo)|Uniform variable info (name / type / num)|
|[UniformType](./Type%20Alias.md#type-uniformtype)|Uniform type (Sampler / Vec4 / Mat4 / Int1 ...)|
|[UnitPtr](./Type%20Alias.md#type-unitptr)|void* pointer wrapper (for getInterface / getDirectAccessPtr etc.)|
|[VertexBufferHandle](./Type%20Alias.md#type-vertexbufferhandle)|Static vertex buffer handle|
|[VertexLayoutHandle](./Type%20Alias.md#type-vertexlayouthandle)|Vertex layout handle|
|[VertexLayoutPtr](./Type%20Alias.md#type-vertexlayoutptr)|Vertex layout pointer (passed to createDynamicVertexBuffer etc.)|
|[VertexLayout](./Type%20Alias.md#type-vertexlayout)|Vertex layout (hash / stride / offset)|
|[ViewMode](./Type%20Alias.md#type-viewmode)|View mode (Default / Sequential / Depth Ascending / Depth Descending)|
|[ViewStats](./Type%20Alias.md#type-viewstats)|View statistics|

### Variables & constants
|  Name   | Describe  |
|  ----  | ----  |
|[BGFX_API_VERSION](./Variables%20&%20constants.md#let-bgfx_api_version)|bgfx API version number|
|[BGFX_INVALID_HANDLE_IDX](./Variables%20&%20constants.md#let-bgfx_invalid_handle_idx)|bgfx handle invalid index value|
|[BUFFER_ALLOW_RESIZE](./Variables%20&%20constants.md#let-buffer_allow_resize)|Allow dynamic buffer resize|
|[BUFFER_COMPUTE_FORMAT_16X1](./Variables%20&%20constants.md#let-buffer_compute_format_16x1)|Compute buffer format: 16bit × 1|
|[BUFFER_COMPUTE_FORMAT_16X2](./Variables%20&%20constants.md#let-buffer_compute_format_16x2)|Compute buffer format: 16bit × 2|
|[BUFFER_COMPUTE_FORMAT_16X4](./Variables%20&%20constants.md#let-buffer_compute_format_16x4)|Compute buffer format: 16bit × 4|
|[BUFFER_COMPUTE_FORMAT_32X1](./Variables%20&%20constants.md#let-buffer_compute_format_32x1)|Compute buffer format: 32bit × 1|
|[BUFFER_COMPUTE_FORMAT_32X2](./Variables%20&%20constants.md#let-buffer_compute_format_32x2)|Compute buffer format: 32bit × 2|
|[BUFFER_COMPUTE_FORMAT_32X4](./Variables%20&%20constants.md#let-buffer_compute_format_32x4)|Compute buffer format: 32bit × 4|
|[BUFFER_COMPUTE_FORMAT_8X1](./Variables%20&%20constants.md#let-buffer_compute_format_8x1)|Compute buffer format: 8bit × 1|
|[BUFFER_COMPUTE_FORMAT_8X2](./Variables%20&%20constants.md#let-buffer_compute_format_8x2)|Compute buffer format: 8bit × 2|
|[BUFFER_COMPUTE_FORMAT_8X4](./Variables%20&%20constants.md#let-buffer_compute_format_8x4)|Compute buffer format: 8bit × 4|
|[BUFFER_COMPUTE_FORMAT_MASK](./Variables%20&%20constants.md#let-buffer_compute_format_mask)|Compute buffer format bit mask|
|[BUFFER_COMPUTE_FORMAT_SHIFT](./Variables%20&%20constants.md#let-buffer_compute_format_shift)|Compute buffer format bit offset|
|[BUFFER_COMPUTE_READ](./Variables%20&%20constants.md#let-buffer_compute_read)|Compute buffer readable|
|[BUFFER_COMPUTE_READ_WRITE](./Variables%20&%20constants.md#let-buffer_compute_read_write)|Compute buffer read-write|
|[BUFFER_COMPUTE_TYPE_FLOAT](./Variables%20&%20constants.md#let-buffer_compute_type_float)|Compute buffer type: Float|
|[BUFFER_COMPUTE_TYPE_INT](./Variables%20&%20constants.md#let-buffer_compute_type_int)|Compute buffer type: Int|
|[BUFFER_COMPUTE_TYPE_MASK](./Variables%20&%20constants.md#let-buffer_compute_type_mask)|Compute buffer type bit mask|
|[BUFFER_COMPUTE_TYPE_SHIFT](./Variables%20&%20constants.md#let-buffer_compute_type_shift)|Compute buffer type bit offset|
|[BUFFER_COMPUTE_TYPE_UINT](./Variables%20&%20constants.md#let-buffer_compute_type_uint)|Compute buffer type: UInt|
|[BUFFER_COMPUTE_WRITE](./Variables%20&%20constants.md#let-buffer_compute_write)|Compute buffer writable|
|[BUFFER_DRAW_INDIRECT](./Variables%20&%20constants.md#let-buffer_draw_indirect)|Draw indirectbuffer|
|[BUFFER_INDEX32](./Variables%20&%20constants.md#let-buffer_index32)|32bit indexbuffer|
|[BUFFER_NONE](./Variables%20&%20constants.md#let-buffer_none)|No special flags|
|[CAPS_ALPHA_TO_COVERAGE](./Variables%20&%20constants.md#let-caps_alpha_to_coverage)|Alpha to coverage support|
|[CAPS_BLEND_INDEPENDENT](./Variables%20&%20constants.md#let-caps_blend_independent)|Independentblendsupport|
|[CAPS_COMPUTE](./Variables%20&%20constants.md#let-caps_compute)|Computeshadersupport|
|[CAPS_CONSERVATIVE_RASTER](./Variables%20&%20constants.md#let-caps_conservative_raster)|Conservative rasterization support|
|[CAPS_DRAW_INDIRECT](./Variables%20&%20constants.md#let-caps_draw_indirect)|Draw indirectsupport|
|[CAPS_DRAW_INDIRECT_COUNT](./Variables%20&%20constants.md#let-caps_draw_indirect_count)|With countdraw indirectsupport|
|[CAPS_FORMAT_TEXTURE_2D](./Variables%20&%20constants.md#let-caps_format_texture_2d)|2D texturesupport|
|[CAPS_FORMAT_TEXTURE_2D_EMULATED](./Variables%20&%20constants.md#let-caps_format_texture_2d_emulated)|2D emulated texture support|
|[CAPS_FORMAT_TEXTURE_2D_SRGB](./Variables%20&%20constants.md#let-caps_format_texture_2d_srgb)|2D sRGB texturesupport|
|[CAPS_FORMAT_TEXTURE_3D](./Variables%20&%20constants.md#let-caps_format_texture_3d)|3D texturesupport|
|[CAPS_FORMAT_TEXTURE_3D_EMULATED](./Variables%20&%20constants.md#let-caps_format_texture_3d_emulated)|3D emulated texture support|
|[CAPS_FORMAT_TEXTURE_3D_SRGB](./Variables%20&%20constants.md#let-caps_format_texture_3d_srgb)|3D sRGB texturesupport|
|[CAPS_FORMAT_TEXTURE_CUBE](./Variables%20&%20constants.md#let-caps_format_texture_cube)|cubetexturesupport|
|[CAPS_FORMAT_TEXTURE_CUBE_EMULATED](./Variables%20&%20constants.md#let-caps_format_texture_cube_emulated)|Cube emulated texture support|
|[CAPS_FORMAT_TEXTURE_CUBE_SRGB](./Variables%20&%20constants.md#let-caps_format_texture_cube_srgb)|cube sRGB texturesupport|
|[CAPS_FORMAT_TEXTURE_FRAMEBUFFER](./Variables%20&%20constants.md#let-caps_format_texture_framebuffer)|Framebuffersupport|
|[CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA](./Variables%20&%20constants.md#let-caps_format_texture_framebuffer_msaa)|MSAA framebuffersupport|
|[CAPS_FORMAT_TEXTURE_IMAGE_READ](./Variables%20&%20constants.md#let-caps_format_texture_image_read)|Image read support|
|[CAPS_FORMAT_TEXTURE_IMAGE_WRITE](./Variables%20&%20constants.md#let-caps_format_texture_image_write)|Image write support|
|[CAPS_FORMAT_TEXTURE_MIP_AUTOGEN](./Variables%20&%20constants.md#let-caps_format_texture_mip_autogen)|Auto mipmap generation support|
|[CAPS_FORMAT_TEXTURE_MSAA](./Variables%20&%20constants.md#let-caps_format_texture_msaa)|MSAA texturesupport|
|[CAPS_FORMAT_TEXTURE_NONE](./Variables%20&%20constants.md#let-caps_format_texture_none)|Format not supported|
|[CAPS_FORMAT_TEXTURE_VERTEX](./Variables%20&%20constants.md#let-caps_format_texture_vertex)|Vertexbuffertexturesupport|
|[CAPS_FRAGMENT_DEPTH](./Variables%20&%20constants.md#let-caps_fragment_depth)|Fragmentdepthsupport|
|[CAPS_FRAGMENT_ORDERING](./Variables%20&%20constants.md#let-caps_fragment_ordering)|Fragment orderingsupport|
|[CAPS_GRAPHICS_DEBUGGER](./Variables%20&%20constants.md#let-caps_graphics_debugger)|Graphics debugger support|
|[CAPS_HDR10](./Variables%20&%20constants.md#let-caps_hdr10)|HDR10 support|
|[CAPS_HIDPI](./Variables%20&%20constants.md#let-caps_hidpi)|HiDPI support|
|[CAPS_IMAGE_RW](./Variables%20&%20constants.md#let-caps_image_rw)|Image read-writesupport|
|[CAPS_INDEX32](./Variables%20&%20constants.md#let-caps_index32)|32-bit indexsupport|
|[CAPS_INSTANCING](./Variables%20&%20constants.md#let-caps_instancing)|Instancingsupport|
|[CAPS_OCCLUSION_QUERY](./Variables%20&%20constants.md#let-caps_occlusion_query)|Occlusion querysupport|
|[CAPS_PRIMITIVE_ID](./Variables%20&%20constants.md#let-caps_primitive_id)|Primitive ID support|
|[CAPS_RENDERER_MULTITHREADED](./Variables%20&%20constants.md#let-caps_renderer_multithreaded)|Multi-threaded renderer support|
|[CAPS_SWAP_CHAIN](./Variables%20&%20constants.md#let-caps_swap_chain)|Swap chain support|
|[CAPS_TEXTURE_2D_ARRAY](./Variables%20&%20constants.md#let-caps_texture_2d_array)|2D texture array support|
|[CAPS_TEXTURE_3D](./Variables%20&%20constants.md#let-caps_texture_3d)|3D texturesupport|
|[CAPS_TEXTURE_BLIT](./Variables%20&%20constants.md#let-caps_texture_blit)|Texture blit support|
|[CAPS_TEXTURE_COMPARE_ALL](./Variables%20&%20constants.md#let-caps_texture_compare_all)|Texture depth comparison support (all)|
|[CAPS_TEXTURE_COMPARE_LEQUAL](./Variables%20&%20constants.md#let-caps_texture_compare_lequal)|Texture depth comparison support (LEQUAL)|
|[CAPS_TEXTURE_COMPARE_RESERVED](./Variables%20&%20constants.md#let-caps_texture_compare_reserved)|Texture depth comparison reserved bit|
|[CAPS_TEXTURE_CUBE_ARRAY](./Variables%20&%20constants.md#let-caps_texture_cube_array)|Cube texture array support|
|[CAPS_TEXTURE_DIRECT_ACCESS](./Variables%20&%20constants.md#let-caps_texture_direct_access)|Texture direct access support|
|[CAPS_TEXTURE_READ_BACK](./Variables%20&%20constants.md#let-caps_texture_read_back)|Texture readback support|
|[CAPS_TRANSPARENT_BACKBUFFER](./Variables%20&%20constants.md#let-caps_transparent_backbuffer)|Transparent backbuffer support|
|[CAPS_VERTEX_ATTRIB_HALF](./Variables%20&%20constants.md#let-caps_vertex_attrib_half)|Vertex attribute Half-float support|
|[CAPS_VERTEX_ATTRIB_UINT10](./Variables%20&%20constants.md#let-caps_vertex_attrib_uint10)|Vertex attribute UInt10 support|
|[CAPS_VERTEX_ID](./Variables%20&%20constants.md#let-caps_vertex_id)|Vertex ID support|
|[CAPS_VIEWPORT_LAYER_ARRAY](./Variables%20&%20constants.md#let-caps_viewport_layer_array)|Viewport layer array support|
|[CLEAR_COLOR](./Variables%20&%20constants.md#let-clear_color)|Clear color|
|[CLEAR_DEPTH](./Variables%20&%20constants.md#let-clear_depth)|Clear depth|
|[CLEAR_DISCARD_COLOR_0](./Variables%20&%20constants.md#let-clear_discard_color_0)|Discardcolorattachment 0|
|[CLEAR_DISCARD_COLOR_1](./Variables%20&%20constants.md#let-clear_discard_color_1)|Discardcolorattachment 1|
|[CLEAR_DISCARD_COLOR_2](./Variables%20&%20constants.md#let-clear_discard_color_2)|Discardcolorattachment 2|
|[CLEAR_DISCARD_COLOR_3](./Variables%20&%20constants.md#let-clear_discard_color_3)|Discardcolorattachment 3|
|[CLEAR_DISCARD_COLOR_4](./Variables%20&%20constants.md#let-clear_discard_color_4)|Discardcolorattachment 4|
|[CLEAR_DISCARD_COLOR_5](./Variables%20&%20constants.md#let-clear_discard_color_5)|Discardcolorattachment 5|
|[CLEAR_DISCARD_COLOR_6](./Variables%20&%20constants.md#let-clear_discard_color_6)|Discardcolorattachment 6|
|[CLEAR_DISCARD_COLOR_7](./Variables%20&%20constants.md#let-clear_discard_color_7)|Discardcolorattachment 7|
|[CLEAR_DISCARD_COLOR_MASK](./Variables%20&%20constants.md#let-clear_discard_color_mask)|Discardcolorattachmentmask|
|[CLEAR_DISCARD_DEPTH](./Variables%20&%20constants.md#let-clear_discard_depth)|Discarddepth|
|[CLEAR_DISCARD_MASK](./Variables%20&%20constants.md#let-clear_discard_mask)|Discardmask|
|[CLEAR_DISCARD_STENCIL](./Variables%20&%20constants.md#let-clear_discard_stencil)|Discardstencil|
|[CLEAR_NONE](./Variables%20&%20constants.md#let-clear_none)|No clear|
|[CLEAR_STENCIL](./Variables%20&%20constants.md#let-clear_stencil)|Clear stencil|
|[DEBUG_IFH](./Variables%20&%20constants.md#let-debug_ifh)|IFH（nohandle）debug|
|[DEBUG_NONE](./Variables%20&%20constants.md#let-debug_none)|nodebug|
|[DEBUG_PROFILER](./Variables%20&%20constants.md#let-debug_profiler)|profilingdebug|
|[DEBUG_STATS](./Variables%20&%20constants.md#let-debug_stats)|Statisticsdebug|
|[DEBUG_TEXT](./Variables%20&%20constants.md#let-debug_text)|textdebug|
|[DEBUG_WIREFRAME](./Variables%20&%20constants.md#let-debug_wireframe)|wireframedebug|
|[DISCARD_ALL](./Variables%20&%20constants.md#let-discard_all)|Discard all|
|[DISCARD_BINDINGS](./Variables%20&%20constants.md#let-discard_bindings)|Discardbinding|
|[DISCARD_INDEX_BUFFER](./Variables%20&%20constants.md#let-discard_index_buffer)|Discardindexbuffer|
|[DISCARD_INSTANCE_DATA](./Variables%20&%20constants.md#let-discard_instance_data)|Discardinstancedata|
|[DISCARD_NONE](./Variables%20&%20constants.md#let-discard_none)|NoDiscard|
|[DISCARD_STATE](./Variables%20&%20constants.md#let-discard_state)|Discardstate|
|[DISCARD_TRANSFORM](./Variables%20&%20constants.md#let-discard_transform)|Discardtransform|
|[DISCARD_VERTEX_STREAMS](./Variables%20&%20constants.md#let-discard_vertex_streams)|Discardvertexstream|
|[INVALID_DYNAMIC_INDEX_BUFFER_HANDLE](./Variables%20&%20constants.md#let-invalid_dynamic_index_buffer_handle)|Invalid dynamic index buffer handle|
|[INVALID_DYNAMIC_VERTEX_BUFFER_HANDLE](./Variables%20&%20constants.md#let-invalid_dynamic_vertex_buffer_handle)|Invalid dynamic vertex buffer handle|
|[INVALID_FRAME_BUFFER_HANDLE](./Variables%20&%20constants.md#let-invalid_frame_buffer_handle)|Invalid frame buffer handle (idx=0xFFFF), used for field initialization and post-destroy reset|
|[INVALID_INDEX_BUFFER_HANDLE](./Variables%20&%20constants.md#let-invalid_index_buffer_handle)|Invalid static index buffer handle|
|[INVALID_INDIRECT_BUFFER_HANDLE](./Variables%20&%20constants.md#let-invalid_indirect_buffer_handle)|Invalid indirect buffer handle|
|[INVALID_OCCLUSION_QUERY_HANDLE](./Variables%20&%20constants.md#let-invalid_occlusion_query_handle)|Invalid occlusion query handle|
|[INVALID_PROGRAM_HANDLE](./Variables%20&%20constants.md#let-invalid_program_handle)|Invalid program handle|
|[INVALID_SHADER_HANDLE](./Variables%20&%20constants.md#let-invalid_shader_handle)|Invalid shader handle|
|[INVALID_TEXTURE_HANDLE](./Variables%20&%20constants.md#let-invalid_texture_handle)|Invalid texture handle|
|[INVALID_UNIFORM_HANDLE](./Variables%20&%20constants.md#let-invalid_uniform_handle)|Invalid uniform handle|
|[INVALID_VERTEX_BUFFER_HANDLE](./Variables%20&%20constants.md#let-invalid_vertex_buffer_handle)|Invalid static vertex buffer handle|
|[INVALID_VERTEX_LAYOUT_HANDLE](./Variables%20&%20constants.md#let-invalid_vertex_layout_handle)|Invalid vertex layout handle|
|[PCI_ID_AMD](./Variables%20&%20constants.md#let-pci_id_amd)|AMD|
|[PCI_ID_APPLE](./Variables%20&%20constants.md#let-pci_id_apple)|Apple|
|[PCI_ID_INTEL](./Variables%20&%20constants.md#let-pci_id_intel)|Intel|
|[PCI_ID_MICROSOFT](./Variables%20&%20constants.md#let-pci_id_microsoft)|Microsoft|
|[PCI_ID_NONE](./Variables%20&%20constants.md#let-pci_id_none)|No vendor|
|[PCI_ID_NVIDIA](./Variables%20&%20constants.md#let-pci_id_nvidia)|NVIDIA|
|[PCI_ID_SOFTWARE_RASTERIZER](./Variables%20&%20constants.md#let-pci_id_software_rasterizer)|Software rasterization|
|[RESET_CAPTURE](./Variables%20&%20constants.md#let-reset_capture)|Capture|
|[RESET_DEPTH_CLAMP](./Variables%20&%20constants.md#let-reset_depth_clamp)|Depth clamp|
|[RESET_FLIP_AFTER_RENDER](./Variables%20&%20constants.md#let-reset_flip_after_render)|Post-render flip|
|[RESET_FLUSH_AFTER_RENDER](./Variables%20&%20constants.md#let-reset_flush_after_render)|Post-render flush|
|[RESET_FULLSCREEN](./Variables%20&%20constants.md#let-reset_fullscreen)|fullscreen|
|[RESET_FULLSCREEN_MASK](./Variables%20&%20constants.md#let-reset_fullscreen_mask)|Fullscreen bit mask|
|[RESET_FULLSCREEN_SHIFT](./Variables%20&%20constants.md#let-reset_fullscreen_shift)|Fullscreen bit offset|
|[RESET_HDR10](./Variables%20&%20constants.md#let-reset_hdr10)|HDR10|
|[RESET_HIDPI](./Variables%20&%20constants.md#let-reset_hidpi)|HiDPI|
|[RESET_MAXANISOTROPY](./Variables%20&%20constants.md#let-reset_maxanisotropy)|Maxanisotropic|
|[RESET_MSAA_MASK](./Variables%20&%20constants.md#let-reset_msaa_mask)|MSAA bit mask|
|[RESET_MSAA_SHIFT](./Variables%20&%20constants.md#let-reset_msaa_shift)|MSAA bit offset|
|[RESET_MSAA_X16](./Variables%20&%20constants.md#let-reset_msaa_x16)|MSAA ×16|
|[RESET_MSAA_X2](./Variables%20&%20constants.md#let-reset_msaa_x2)|MSAA ×2|
|[RESET_MSAA_X4](./Variables%20&%20constants.md#let-reset_msaa_x4)|MSAA ×4|
|[RESET_MSAA_X8](./Variables%20&%20constants.md#let-reset_msaa_x8)|MSAA ×8|
|[RESET_NONE](./Variables%20&%20constants.md#let-reset_none)|No reset|
|[RESET_RESERVED_MASK](./Variables%20&%20constants.md#let-reset_reserved_mask)|preservebit mask|
|[RESET_RESERVED_SHIFT](./Variables%20&%20constants.md#let-reset_reserved_shift)|preservebit offset|
|[RESET_SRGB_BACKBUFFER](./Variables%20&%20constants.md#let-reset_srgb_backbuffer)|sRGB backbuffer|
|[RESET_SUSPEND](./Variables%20&%20constants.md#let-reset_suspend)|Suspended|
|[RESET_TRANSPARENT_BACKBUFFER](./Variables%20&%20constants.md#let-reset_transparent_backbuffer)|Transparent backbuffer|
|[RESET_VSYNC](./Variables%20&%20constants.md#let-reset_vsync)|VSync|
|[RESOLVE_AUTO_GEN_MIPS](./Variables%20&%20constants.md#let-resolve_auto_gen_mips)|autogeneration mipmap|
|[RESOLVE_NONE](./Variables%20&%20constants.md#let-resolve_none)|No resolve|
|[SAMPLER_BITS_MASK](./Variables%20&%20constants.md#let-sampler_bits_mask)|Sampler bit mask full set|
|[SAMPLER_BORDER_COLOR_MASK](./Variables%20&%20constants.md#let-sampler_border_color_mask)|Bordercolorbit mask|
|[SAMPLER_BORDER_COLOR_SHIFT](./Variables%20&%20constants.md#let-sampler_border_color_shift)|Bordercolorbit offset|
|[SAMPLER_COMPARE_ALWAYS](./Variables%20&%20constants.md#let-sampler_compare_always)|Depthcompare: always|
|[SAMPLER_COMPARE_EQUAL](./Variables%20&%20constants.md#let-sampler_compare_equal)|Depthcompare: equal|
|[SAMPLER_COMPARE_GEQUAL](./Variables%20&%20constants.md#let-sampler_compare_gequal)|Depthcompare: greater or equal|
|[SAMPLER_COMPARE_GREATER](./Variables%20&%20constants.md#let-sampler_compare_greater)|Depthcompare: greater|
|[SAMPLER_COMPARE_LEQUAL](./Variables%20&%20constants.md#let-sampler_compare_lequal)|Depthcompare: less or equal|
|[SAMPLER_COMPARE_LESS](./Variables%20&%20constants.md#let-sampler_compare_less)|Depthcompare: less|
|[SAMPLER_COMPARE_MASK](./Variables%20&%20constants.md#let-sampler_compare_mask)|depthcomparebit mask|
|[SAMPLER_COMPARE_NEVER](./Variables%20&%20constants.md#let-sampler_compare_never)|Depth compare: never|
|[SAMPLER_COMPARE_NOTEQUAL](./Variables%20&%20constants.md#let-sampler_compare_notequal)|Depthcompare: no equal|
|[SAMPLER_COMPARE_SHIFT](./Variables%20&%20constants.md#let-sampler_compare_shift)|depthcomparebit offset|
|[SAMPLER_MAG_ANISOTROPIC](./Variables%20&%20constants.md#let-sampler_mag_anisotropic)|Mag filtering: anisotropic|
|[SAMPLER_MAG_MASK](./Variables%20&%20constants.md#let-sampler_mag_mask)|Mag filtering bit mask|
|[SAMPLER_MAG_POINT](./Variables%20&%20constants.md#let-sampler_mag_point)|Mag filtering: point sampling|
|[SAMPLER_MAG_SHIFT](./Variables%20&%20constants.md#let-sampler_mag_shift)|Mag filtering bit offset|
|[SAMPLER_MIN_ANISOTROPIC](./Variables%20&%20constants.md#let-sampler_min_anisotropic)|Min filtering: anisotropic|
|[SAMPLER_MIN_MASK](./Variables%20&%20constants.md#let-sampler_min_mask)|Min filtering bit mask|
|[SAMPLER_MIN_POINT](./Variables%20&%20constants.md#let-sampler_min_point)|Min filtering: point sampling|
|[SAMPLER_MIN_SHIFT](./Variables%20&%20constants.md#let-sampler_min_shift)|Min filtering bit offset|
|[SAMPLER_MIP_MASK](./Variables%20&%20constants.md#let-sampler_mip_mask)|Mip filteringbit mask|
|[SAMPLER_MIP_POINT](./Variables%20&%20constants.md#let-sampler_mip_point)|Mip filtering: pointsampling|
|[SAMPLER_MIP_SHIFT](./Variables%20&%20constants.md#let-sampler_mip_shift)|Mip filteringbit offset|
|[SAMPLER_NONE](./Variables%20&%20constants.md#let-sampler_none)|nosamplerflag|
|[SAMPLER_POINT](./Variables%20&%20constants.md#let-sampler_point)|Point sampling combination (min/mag/mip all point sampling)|
|[SAMPLER_RESERVED_MASK](./Variables%20&%20constants.md#let-sampler_reserved_mask)|preservebit mask|
|[SAMPLER_RESERVED_SHIFT](./Variables%20&%20constants.md#let-sampler_reserved_shift)|preservebit offset|
|[SAMPLER_SAMPLE_STENCIL](./Variables%20&%20constants.md#let-sampler_sample_stencil)|Samplingstencil|
|[SAMPLER_UVW_BORDER](./Variables%20&%20constants.md#let-sampler_uvw_border)|UVW bordercombination|
|[SAMPLER_UVW_CLAMP](./Variables%20&%20constants.md#let-sampler_uvw_clamp)|UVW clamp combination|
|[SAMPLER_UVW_MIRROR](./Variables%20&%20constants.md#let-sampler_uvw_mirror)|UVW mirrorcombination|
|[SAMPLER_U_BORDER](./Variables%20&%20constants.md#let-sampler_u_border)|U direction border|
|[SAMPLER_U_CLAMP](./Variables%20&%20constants.md#let-sampler_u_clamp)|U direction clamp bit|
|[SAMPLER_U_MASK](./Variables%20&%20constants.md#let-sampler_u_mask)|U direction bit mask|
|[SAMPLER_U_MIRROR](./Variables%20&%20constants.md#let-sampler_u_mirror)|U direction mirror|
|[SAMPLER_U_SHIFT](./Variables%20&%20constants.md#let-sampler_u_shift)|U direction bit offset|
|[SAMPLER_V_BORDER](./Variables%20&%20constants.md#let-sampler_v_border)|V direction border|
|[SAMPLER_V_CLAMP](./Variables%20&%20constants.md#let-sampler_v_clamp)|V direction clamp bit|
|[SAMPLER_V_MASK](./Variables%20&%20constants.md#let-sampler_v_mask)|V direction bit mask|
|[SAMPLER_V_MIRROR](./Variables%20&%20constants.md#let-sampler_v_mirror)|V direction mirror|
|[SAMPLER_V_SHIFT](./Variables%20&%20constants.md#let-sampler_v_shift)|V direction bit offset|
|[SAMPLER_W_BORDER](./Variables%20&%20constants.md#let-sampler_w_border)|W direction border|
|[SAMPLER_W_CLAMP](./Variables%20&%20constants.md#let-sampler_w_clamp)|W direction clamp bit|
|[SAMPLER_W_MASK](./Variables%20&%20constants.md#let-sampler_w_mask)|W direction bit mask|
|[SAMPLER_W_MIRROR](./Variables%20&%20constants.md#let-sampler_w_mirror)|W direction mirror|
|[SAMPLER_W_SHIFT](./Variables%20&%20constants.md#let-sampler_w_shift)|W direction bit offset|
|[STATE_ALPHA_REF_MASK](./Variables%20&%20constants.md#let-state_alpha_ref_mask)|Alpha reference value bit mask|
|[STATE_ALPHA_REF_SHIFT](./Variables%20&%20constants.md#let-state_alpha_ref_shift)|Alpha reference value bit offset|
|[STATE_BLEND_ALPHA_TO_COVERAGE](./Variables%20&%20constants.md#let-state_blend_alpha_to_coverage)|Alpha to coverage|
|[STATE_BLEND_DST_ALPHA](./Variables%20&%20constants.md#let-state_blend_dst_alpha)|Blendfactor: destination alpha|
|[STATE_BLEND_DST_COLOR](./Variables%20&%20constants.md#let-state_blend_dst_color)|Blendfactor: destinationcolor|
|[STATE_BLEND_EQUATION_ADD](./Variables%20&%20constants.md#let-state_blend_equation_add)|Blend equation: additive|
|[STATE_BLEND_EQUATION_MASK](./Variables%20&%20constants.md#let-state_blend_equation_mask)|Blend equation bit mask|
|[STATE_BLEND_EQUATION_MAX](./Variables%20&%20constants.md#let-state_blend_equation_max)|Blend equation: max|
|[STATE_BLEND_EQUATION_MIN](./Variables%20&%20constants.md#let-state_blend_equation_min)|Blend equation: min|
|[STATE_BLEND_EQUATION_REVSUB](./Variables%20&%20constants.md#let-state_blend_equation_revsub)|Blend equation: reverse subtractive|
|[STATE_BLEND_EQUATION_SHIFT](./Variables%20&%20constants.md#let-state_blend_equation_shift)|Blend equation bit offset|
|[STATE_BLEND_EQUATION_SUB](./Variables%20&%20constants.md#let-state_blend_equation_sub)|Blend equation: subtractive|
|[STATE_BLEND_FACTOR](./Variables%20&%20constants.md#let-state_blend_factor)|Blend factor: constant|
|[STATE_BLEND_INDEPENDENT](./Variables%20&%20constants.md#let-state_blend_independent)|independentblend|
|[STATE_BLEND_INV_DST_ALPHA](./Variables%20&%20constants.md#let-state_blend_inv_dst_alpha)|Blendfactor: destination alpha inverted|
|[STATE_BLEND_INV_DST_COLOR](./Variables%20&%20constants.md#let-state_blend_inv_dst_color)|Blendfactor: destination color inverted|
|[STATE_BLEND_INV_FACTOR](./Variables%20&%20constants.md#let-state_blend_inv_factor)|Blend factor: constant inverted|
|[STATE_BLEND_INV_SRC_ALPHA](./Variables%20&%20constants.md#let-state_blend_inv_src_alpha)|Blendfactor: source alpha inverted|
|[STATE_BLEND_INV_SRC_COLOR](./Variables%20&%20constants.md#let-state_blend_inv_src_color)|Blend factor: source color inverted|
|[STATE_BLEND_MASK](./Variables%20&%20constants.md#let-state_blend_mask)|Blendfactorbit mask|
|[STATE_BLEND_ONE](./Variables%20&%20constants.md#let-state_blend_one)|Blendfactor: one|
|[STATE_BLEND_SHIFT](./Variables%20&%20constants.md#let-state_blend_shift)|Blendfactorbit offset|
|[STATE_BLEND_SRC_ALPHA](./Variables%20&%20constants.md#let-state_blend_src_alpha)|Blendfactor: source alpha|
|[STATE_BLEND_SRC_ALPHA_SAT](./Variables%20&%20constants.md#let-state_blend_src_alpha_sat)|Blendfactor: source alpha saturate|
|[STATE_BLEND_SRC_COLOR](./Variables%20&%20constants.md#let-state_blend_src_color)|Blendfactor: sourcecolor|
|[STATE_BLEND_ZERO](./Variables%20&%20constants.md#let-state_blend_zero)|Blendfactor: zero|
|[STATE_CONSERVATIVE_RASTER](./Variables%20&%20constants.md#let-state_conservative_raster)|Conservative rasterization|
|[STATE_CULL_CCW](./Variables%20&%20constants.md#let-state_cull_ccw)|Face cull: counter-clockwise|
|[STATE_CULL_CW](./Variables%20&%20constants.md#let-state_cull_cw)|Face cull: clockwise|
|[STATE_CULL_MASK](./Variables%20&%20constants.md#let-state_cull_mask)|facecullbit mask|
|[STATE_CULL_SHIFT](./Variables%20&%20constants.md#let-state_cull_shift)|facecullbit offset|
|[STATE_DEFAULT](./Variables%20&%20constants.md#let-state_default)|Default state（depthtest + write RGB + write Z + CCW facecull）|
|[STATE_DEPTH_TEST_ALWAYS](./Variables%20&%20constants.md#let-state_depth_test_always)|Depthtest: always|
|[STATE_DEPTH_TEST_EQUAL](./Variables%20&%20constants.md#let-state_depth_test_equal)|Depthtest: equal|
|[STATE_DEPTH_TEST_GEQUAL](./Variables%20&%20constants.md#let-state_depth_test_gequal)|Depthtest: greater or equal|
|[STATE_DEPTH_TEST_GREATER](./Variables%20&%20constants.md#let-state_depth_test_greater)|Depthtest: greater|
|[STATE_DEPTH_TEST_LEQUAL](./Variables%20&%20constants.md#let-state_depth_test_lequal)|Depthtest: less or equal|
|[STATE_DEPTH_TEST_LESS](./Variables%20&%20constants.md#let-state_depth_test_less)|Depthtest: less|
|[STATE_DEPTH_TEST_MASK](./Variables%20&%20constants.md#let-state_depth_test_mask)|Depthtestbit mask|
|[STATE_DEPTH_TEST_NEVER](./Variables%20&%20constants.md#let-state_depth_test_never)|Depth test: never|
|[STATE_DEPTH_TEST_NOTEQUAL](./Variables%20&%20constants.md#let-state_depth_test_notequal)|Depthtest: no equal|
|[STATE_DEPTH_TEST_SHIFT](./Variables%20&%20constants.md#let-state_depth_test_shift)|Depthtestbit offset|
|[STATE_FRONT_CCW](./Variables%20&%20constants.md#let-state_front_ccw)|Counter-clockwise front face|
|[STATE_LINEAA](./Variables%20&%20constants.md#let-state_lineaa)|Line AA (anti-aliasing)|
|[STATE_MASK](./Variables%20&%20constants.md#let-state_mask)|statemaskfull set|
|[STATE_MSAA](./Variables%20&%20constants.md#let-state_msaa)|MSAA|
|[STATE_NONE](./Variables%20&%20constants.md#let-state_none)|Nostate|
|[STATE_POINT_SIZE_MASK](./Variables%20&%20constants.md#let-state_point_size_mask)|Point size bit mask|
|[STATE_POINT_SIZE_SHIFT](./Variables%20&%20constants.md#let-state_point_size_shift)|Point size bit offset|
|[STATE_PT_LINESTRIP](./Variables%20&%20constants.md#let-state_pt_linestrip)|Primitive type: line strip|
|[STATE_PT_LINES](./Variables%20&%20constants.md#let-state_pt_lines)|Primitive type: line list|
|[STATE_PT_MASK](./Variables%20&%20constants.md#let-state_pt_mask)|Primitivetypebit mask|
|[STATE_PT_POINTS](./Variables%20&%20constants.md#let-state_pt_points)|Primitivetype: pointlist|
|[STATE_PT_SHIFT](./Variables%20&%20constants.md#let-state_pt_shift)|Primitivetypebit offset|
|[STATE_PT_TRISTRIP](./Variables%20&%20constants.md#let-state_pt_tristrip)|Primitive type: triangle strip|
|[STATE_RESERVED_MASK](./Variables%20&%20constants.md#let-state_reserved_mask)|preservebit mask|
|[STATE_RESERVED_SHIFT](./Variables%20&%20constants.md#let-state_reserved_shift)|preservebit offset|
|[STATE_WRITE_A](./Variables%20&%20constants.md#let-state_write_a)|Write A channel|
|[STATE_WRITE_B](./Variables%20&%20constants.md#let-state_write_b)|Write B channel|
|[STATE_WRITE_G](./Variables%20&%20constants.md#let-state_write_g)|Write G channel|
|[STATE_WRITE_MASK](./Variables%20&%20constants.md#let-state_write_mask)|Write mask full set|
|[STATE_WRITE_RGB](./Variables%20&%20constants.md#let-state_write_rgb)|Write RGB channel|
|[STATE_WRITE_R](./Variables%20&%20constants.md#let-state_write_r)|Write R channel|
|[STATE_WRITE_Z](./Variables%20&%20constants.md#let-state_write_z)|Write Z（depth）channel|
|[STENCIL_DEFAULT](./Variables%20&%20constants.md#let-stencil_default)|defaultstencil|
|[STENCIL_FUNC_REF_MASK](./Variables%20&%20constants.md#let-stencil_func_ref_mask)|Stencil function reference value bit mask|
|[STENCIL_FUNC_REF_SHIFT](./Variables%20&%20constants.md#let-stencil_func_ref_shift)|Stencil function reference value bit offset|
|[STENCIL_FUNC_RMASK_MASK](./Variables%20&%20constants.md#let-stencil_func_rmask_mask)|stencilfunctionmaskbit mask|
|[STENCIL_FUNC_RMASK_SHIFT](./Variables%20&%20constants.md#let-stencil_func_rmask_shift)|stencilfunctionmaskbit offset|
|[STENCIL_MASK](./Variables%20&%20constants.md#let-stencil_mask)|Stencilmaskfull set|
|[STENCIL_NONE](./Variables%20&%20constants.md#let-stencil_none)|nostencil|
|[STENCIL_OP_FAIL_S_DECRSAT](./Variables%20&%20constants.md#let-stencil_op_fail_s_decrsat)|Stencil operation: fail decrementsaturate|
|[STENCIL_OP_FAIL_S_DECR](./Variables%20&%20constants.md#let-stencil_op_fail_s_decr)|Stencil operation: fail decrement|
|[STENCIL_OP_FAIL_S_INCRSAT](./Variables%20&%20constants.md#let-stencil_op_fail_s_incrsat)|Stencil operation: fail incrementsaturate|
|[STENCIL_OP_FAIL_S_INCR](./Variables%20&%20constants.md#let-stencil_op_fail_s_incr)|Stencil operation: fail increment|
|[STENCIL_OP_FAIL_S_INVERT](./Variables%20&%20constants.md#let-stencil_op_fail_s_invert)|Stenciloperation: failinverted|
|[STENCIL_OP_FAIL_S_KEEP](./Variables%20&%20constants.md#let-stencil_op_fail_s_keep)|Stenciloperation: failkeep|
|[STENCIL_OP_FAIL_S_MASK](./Variables%20&%20constants.md#let-stencil_op_fail_s_mask)|Stenciloperationbit mask|
|[STENCIL_OP_FAIL_S_REPLACE](./Variables%20&%20constants.md#let-stencil_op_fail_s_replace)|Stenciloperation: failreplace|
|[STENCIL_OP_FAIL_S_SHIFT](./Variables%20&%20constants.md#let-stencil_op_fail_s_shift)|Stenciloperationbit offset|
|[STENCIL_OP_FAIL_S_ZERO](./Variables%20&%20constants.md#let-stencil_op_fail_s_zero)|Stenciloperation: failzero|
|[STENCIL_OP_FAIL_Z_DECRSAT](./Variables%20&%20constants.md#let-stencil_op_fail_z_decrsat)|Stencil operation: depth-fail decrementsaturate|
|[STENCIL_OP_FAIL_Z_DECR](./Variables%20&%20constants.md#let-stencil_op_fail_z_decr)|Stencil operation: depth-fail decrement|
|[STENCIL_OP_FAIL_Z_INCRSAT](./Variables%20&%20constants.md#let-stencil_op_fail_z_incrsat)|Stencil operation: depth-fail incrementsaturate|
|[STENCIL_OP_FAIL_Z_INCR](./Variables%20&%20constants.md#let-stencil_op_fail_z_incr)|Stencil operation: depth-fail increment|
|[STENCIL_OP_FAIL_Z_INVERT](./Variables%20&%20constants.md#let-stencil_op_fail_z_invert)|Stenciloperation: depthfailinverted|
|[STENCIL_OP_FAIL_Z_KEEP](./Variables%20&%20constants.md#let-stencil_op_fail_z_keep)|Stenciloperation: depthfailkeep|
|[STENCIL_OP_FAIL_Z_MASK](./Variables%20&%20constants.md#let-stencil_op_fail_z_mask)|Stenciloperationbit mask|
|[STENCIL_OP_FAIL_Z_REPLACE](./Variables%20&%20constants.md#let-stencil_op_fail_z_replace)|Stenciloperation: depthfailreplace|
|[STENCIL_OP_FAIL_Z_SHIFT](./Variables%20&%20constants.md#let-stencil_op_fail_z_shift)|Stenciloperationbit offset|
|[STENCIL_OP_FAIL_Z_ZERO](./Variables%20&%20constants.md#let-stencil_op_fail_z_zero)|Stenciloperation: depthfailzero|
|[STENCIL_OP_PASS_Z_DECRSAT](./Variables%20&%20constants.md#let-stencil_op_pass_z_decrsat)|Stencil operation: depth-pass decrementsaturate|
|[STENCIL_OP_PASS_Z_DECR](./Variables%20&%20constants.md#let-stencil_op_pass_z_decr)|Stencil operation: depth-pass decrement|
|[STENCIL_OP_PASS_Z_INCRSAT](./Variables%20&%20constants.md#let-stencil_op_pass_z_incrsat)|Stencil operation: depth-pass incrementsaturate|
|[STENCIL_OP_PASS_Z_INCR](./Variables%20&%20constants.md#let-stencil_op_pass_z_incr)|Stencil operation: depth-pass increment|
|[STENCIL_OP_PASS_Z_INVERT](./Variables%20&%20constants.md#let-stencil_op_pass_z_invert)|Stenciloperation: depthpassinverted|
|[STENCIL_OP_PASS_Z_KEEP](./Variables%20&%20constants.md#let-stencil_op_pass_z_keep)|Stenciloperation: depthpasskeep|
|[STENCIL_OP_PASS_Z_MASK](./Variables%20&%20constants.md#let-stencil_op_pass_z_mask)|Stenciloperationbit mask|
|[STENCIL_OP_PASS_Z_REPLACE](./Variables%20&%20constants.md#let-stencil_op_pass_z_replace)|Stenciloperation: depthpassreplace|
|[STENCIL_OP_PASS_Z_SHIFT](./Variables%20&%20constants.md#let-stencil_op_pass_z_shift)|Stenciloperationbit offset|
|[STENCIL_OP_PASS_Z_ZERO](./Variables%20&%20constants.md#let-stencil_op_pass_z_zero)|Stenciloperation: depthpasszero|
|[STENCIL_TEST_ALWAYS](./Variables%20&%20constants.md#let-stencil_test_always)|Stenciltest: always|
|[STENCIL_TEST_EQUAL](./Variables%20&%20constants.md#let-stencil_test_equal)|Stenciltest: equal|
|[STENCIL_TEST_GEQUAL](./Variables%20&%20constants.md#let-stencil_test_gequal)|Stenciltest: greater or equal|
|[STENCIL_TEST_GREATER](./Variables%20&%20constants.md#let-stencil_test_greater)|Stenciltest: greater|
|[STENCIL_TEST_LEQUAL](./Variables%20&%20constants.md#let-stencil_test_lequal)|Stenciltest: less or equal|
|[STENCIL_TEST_LESS](./Variables%20&%20constants.md#let-stencil_test_less)|Stenciltest: less|
|[STENCIL_TEST_MASK](./Variables%20&%20constants.md#let-stencil_test_mask)|Stenciltestbit mask|
|[STENCIL_TEST_NEVER](./Variables%20&%20constants.md#let-stencil_test_never)|Stenciltest: never|
|[STENCIL_TEST_NOTEQUAL](./Variables%20&%20constants.md#let-stencil_test_notequal)|Stenciltest: no equal|
|[STENCIL_TEST_SHIFT](./Variables%20&%20constants.md#let-stencil_test_shift)|Stenciltestbit offset|
|[TEXTURE_BLIT_DST](./Variables%20&%20constants.md#let-texture_blit_dst)|Texture blit destination|
|[TEXTURE_COMPUTE_WRITE](./Variables%20&%20constants.md#let-texture_compute_write)|Compute write texture|
|[TEXTURE_MSAA_SAMPLE](./Variables%20&%20constants.md#let-texture_msaa_sample)|MSAA samplingtexture|
|[TEXTURE_NONE](./Variables%20&%20constants.md#let-texture_none)|notextureflag|
|[TEXTURE_READ_BACK](./Variables%20&%20constants.md#let-texture_read_back)|Texture readback|
|[TEXTURE_RT](./Variables%20&%20constants.md#let-texture_rt)|Renderdestinationtexture|
|[TEXTURE_RT_MASK](./Variables%20&%20constants.md#let-texture_rt_mask)|RT bit mask|
|[TEXTURE_RT_MSAA_MASK](./Variables%20&%20constants.md#let-texture_rt_msaa_mask)|RT MSAA bit mask|
|[TEXTURE_RT_MSAA_SHIFT](./Variables%20&%20constants.md#let-texture_rt_msaa_shift)|RT MSAA bit offset|
|[TEXTURE_RT_MSAA_X16](./Variables%20&%20constants.md#let-texture_rt_msaa_x16)|RT MSAA ×16|
|[TEXTURE_RT_MSAA_X2](./Variables%20&%20constants.md#let-texture_rt_msaa_x2)|RT MSAA ×2|
|[TEXTURE_RT_MSAA_X4](./Variables%20&%20constants.md#let-texture_rt_msaa_x4)|RT MSAA ×4|
|[TEXTURE_RT_MSAA_X8](./Variables%20&%20constants.md#let-texture_rt_msaa_x8)|RT MSAA ×8|
|[TEXTURE_RT_SHIFT](./Variables%20&%20constants.md#let-texture_rt_shift)|RT bit offset|
|[TEXTURE_RT_WRITE_ONLY](./Variables%20&%20constants.md#let-texture_rt_write_only)|RT write-only|
|[TEXTURE_SRGB](./Variables%20&%20constants.md#let-texture_srgb)|sRGB texture|

