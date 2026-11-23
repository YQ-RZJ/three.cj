# 包 three.renderers.common 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[Animation](./类/Animation.md#class-animation)|渲染通用动画类，管理动画回调与帧更新|
|[Attributes](./类/Attributes.md#class-attributes)|管理顶点属性与后端缓冲区的映射|
|[Background](./类/Background.md#class-background)|场景背景渲染类|
|[BindGroup](./类/BindGroup.md#class-bindgroup)|管线绑定组，包含一组 Binding 及其关联的渲染管线|
|[Binding](./类/Binding.md#class-binding)|单个绑定资源描述，表示 uniform buffer、sampler 等资源绑定|
|[Bindings](./类/Bindings.md#class-bindings)|管线绑定集合管理器|
|[BlendMode](./类/BlendMode.md#class-blendmode)|混合模式描述，定义颜色混合方程和因子|
|[BufferUtils](./类/BufferUtils.md#class-bufferutils)|缓冲区数据类型转换工具类|
|[Buffer](./类/Buffer.md#class-buffer)|GPU 缓冲区管理类|
|[BundleGroup](./类/BundleGroup.md#class-bundlegroup)|渲染包分组，用于将多个渲染对象打包为渲染束|
|[CanvasTarget](./类/CanvasTarget.md#class-canvastarget)|画布渲染目标，描述画布尺寸|
|[ChainMap](./类/ChainMap.md#class-chainmap)|链式键值映射，按优先级在多个 DataMap 中查找键|
|[ClippingContext](./类/ClippingContext.md#class-clippingcontext)|裁剪平面上下文，管理局部裁剪平面集合|
|[ComputeInfo](./类/ComputeInfo.md#class-computeinfo)|计算子统计信息|
|[ComputePipeline](./类/ComputePipeline.md#class-computepipeline)|计算着色器管线|
|[Constants](./类/Constants.md#class-constants)|渲染通用常量定义|
|[CubeRenderTarget](./类/CubeRenderTarget.md#class-cuberendertarget)|立方体渲染目标，用于立方体贴图渲染|
|[DataMap](./类/DataMap.md#class-datamap)|通用键值数据映射基类|
|[Geometries](./类/Geometries.md#class-geometries)|几何体后端数据管理器|
|[GfxBufferFlag](./类/GfxBufferFlag.md#class-gfxbufferflag)|顶点/索引缓冲创建标志|
|[GfxClearFlag](./类/GfxClearFlag.md#class-gfxclearflag)|视图清除标志|
|[GfxResetFlag](./类/GfxResetFlag.md#class-gfxresetflag)|设备重置/呈现参数标志|
|[GfxSamplerFlag](./类/GfxSamplerFlag.md#class-gfxsamplerflag)|纹理绑定期采样器标志|
|[GfxState](./类/GfxState.md#class-gfxstate)|绘制状态位（深度测试/写入掩码/混合/剔除/图元类型/MSAA）|
|[GfxStencilFlag](./类/GfxStencilFlag.md#class-gfxstencilflag)|模板状态位（setStencil 的 fstencil/bstencil 位域组合）|
|[GfxTextureFlag](./类/GfxTextureFlag.md#class-gfxtextureflag)|纹理创建标志（含并入低 32 位的采样器位）|
|[IndirectStorageBufferAttribute](./类/IndirectStorageBufferAttribute.md#class-indirectstoragebufferattribute)|间接存储缓冲区属性标记类|
|[Info](./类/Info.md#class-info)|渲染统计信息|
|[InspectorBase](./类/InspectorBase.md#class-inspectorbase)|调试检查器基类|
|[Lighting](./类/Lighting.md#class-lighting)|光照信息聚合类|
|[MemoryInfo](./类/MemoryInfo.md#class-memoryinfo)|内存子统计信息|
|[Pipeline](./类/Pipeline.md#class-pipeline)|渲染管线基类|
|[Pipelines](./类/Pipelines.md#class-pipelines)|管线集合管理器|
|[PostProcessing](./类/PostProcessing.md#class-postprocessing)|后处理渲染器|
|[ProgrammableStage](./类/ProgrammableStage.md#class-programmablestage)|着色器可编程阶段描述|
|[QuadMesh](./类/QuadMesh.md#class-quadmesh)|全屏四边形网格|
|[ReadbackBuffer](./类/ReadbackBuffer.md#class-readbackbuffer)|GPU 回读缓冲区标记类|
|[RenderBundle](./类/RenderBundle.md#class-renderbundle)|渲染束，包含一组渲染对象的集合|
|[RenderBundles](./类/RenderBundles.md#class-renderbundles)|渲染束集合管理器|
|[RenderContext](./类/RenderContext.md#class-rendercontext)|渲染上下文|
|[RenderContexts](./类/RenderContexts.md#class-rendercontexts)|渲染上下文缓存管理器|
|[RenderInfo](./类/RenderInfo.md#class-renderinfo)|渲染子统计信息|
|[RenderItem](./类/RenderItem.md#class-renderitem)|渲染列表中的单个渲染项|
|[RenderList](./类/RenderList.md#class-renderlist)|渲染列表|
|[RenderLists](./类/RenderLists.md#class-renderlists)|渲染列表缓存管理器|
|[RenderObjectPipeline](./类/RenderObjectPipeline.md#class-renderobjectpipeline)|渲染对象与管线的关联对|
|[RenderObject](./类/RenderObject.md#class-renderobject)|渲染对象|
|[RenderObjects](./类/RenderObjects.md#class-renderobjects)|渲染对象缓存管理器|
|[RenderPipeline](./类/RenderPipeline.md#class-renderpipeline)|TSL 渲染管线|
|[RendererUtils](./类/RendererUtils.md#class-rendererutils)|渲染器工具类|
|[Renderer](./类/Renderer.md#class-renderer)|渲染器抽象基类|
|[SampledTexture](./类/SampledTexture.md#class-sampledtexture)|采样纹理类，关联纹理与采样器参数|
|[Sampler](./类/Sampler.md#class-sampler)|纹理采样器类|
|[SceneCullIndex](./类/SceneCullIndex.md#class-scenecullindex)|场景空间索引|
|[SceneMeshCache](./类/SceneMeshCache.md#class-scenemeshcache)|帧级场景网格缓存|
|[Storage3DTexture](./类/Storage3DTexture.md#class-storage3dtexture)|3D 存储纹理类|
|[StorageArrayTexture](./类/StorageArrayTexture.md#class-storagearraytexture)|存储数组纹理类|
|[StorageBufferAttribute](./类/StorageBufferAttribute.md#class-storagebufferattribute)|存储缓冲属性类|
|[StorageBuffer](./类/StorageBuffer.md#class-storagebuffer)|存储缓冲类|
|[StorageInstancedBufferAttribute](./类/StorageInstancedBufferAttribute.md#class-storageinstancedbufferattribute)|实例化存储缓冲属性类|
|[StorageTexture](./类/StorageTexture.md#class-storagetexture)|存储纹理类|
|[Textures](./类/Textures.md#class-textures)|纹理管理类|
|[TimestampQueryPool](./类/TimestampQueryPool.md#class-timestampquerypool)|时间戳查询池类|
|[UniformBuffer](./类/UniformBuffer.md#class-uniformbuffer)|Uniform 缓冲类|
|[UniformsUtils](./类/UniformsUtils.md#class-uniformsutils)|Uniforms 工具函数|
|[XRManager](./类/XRManager.md#class-xrmanager)|XR 管理器类|
|[XRRenderTarget](./类/XRRenderTarget.md#class-xrrendertarget)|XR 渲染目标类|

### 接口
|  名称   | 描述  |
|  ----  | ----  |
|[IRenderBackend](./接口/IRenderBackend.md#interface-irenderbackend)||
|[IRenderContext](./接口/IRenderContext.md#interface-irendercontext)|渲染上下文接口，提供视图/视口/清除色/帧缓冲等查询方法|
|[IRenderObject](./接口/IRenderObject.md#interface-irenderobject)|渲染对象接口，提供矩阵/几何体/材质/对象 ID 等查询方法|

### 结构体
|  名称   | 描述  |
|  ----  | ----  |
|[GfxAttachmentDesc](./结构体/GfxAttachmentDesc.md#struct-gfxattachmentdesc)|帧缓冲附着描述|
|[GfxAttributeDesc](./结构体/GfxAttributeDesc.md#struct-gfxattributedesc)|顶点布局属性描述|
|[GfxCapsSummary](./结构体/GfxCapsSummary.md#struct-gfxcapssummary)|设备能力摘要|
|[GfxDynamicIndexBufferHandle](./结构体/GfxDynamicIndexBufferHandle.md#struct-gfxdynamicindexbufferhandle)|动态索引缓冲句柄|
|[GfxDynamicVertexBufferHandle](./结构体/GfxDynamicVertexBufferHandle.md#struct-gfxdynamicvertexbufferhandle)|动态顶点缓冲句柄|
|[GfxFrameBufferHandle](./结构体/GfxFrameBufferHandle.md#struct-gfxframebufferhandle)|帧缓冲句柄|
|[GfxIndexBufferHandle](./结构体/GfxIndexBufferHandle.md#struct-gfxindexbufferhandle)|静态索引缓冲句柄|
|[GfxIndirectBufferHandle](./结构体/GfxIndirectBufferHandle.md#struct-gfxindirectbufferhandle)|间接绘制缓冲句柄|
|[GfxOcclusionQueryHandle](./结构体/GfxOcclusionQueryHandle.md#struct-gfxocclusionqueryhandle)|遮挡查询句柄|
|[GfxProgramHandle](./结构体/GfxProgramHandle.md#struct-gfxprogramhandle)|着色器程序句柄（顶点+片段着色器链接产物）|
|[GfxShaderHandle](./结构体/GfxShaderHandle.md#struct-gfxshaderhandle)|着色器句柄|
|[GfxStatsSummary](./结构体/GfxStatsSummary.md#struct-gfxstatssummary)|帧统计摘要|
|[GfxTextureHandle](./结构体/GfxTextureHandle.md#struct-gfxtexturehandle)|纹理句柄|
|[GfxUniformDesc](./结构体/GfxUniformDesc.md#struct-gfxuniformdesc)|uniform 反射信息|
|[GfxUniformHandle](./结构体/GfxUniformHandle.md#struct-gfxuniformhandle)|uniform 句柄|
|[GfxVertexBufferHandle](./结构体/GfxVertexBufferHandle.md#struct-gfxvertexbufferhandle)|静态顶点缓冲句柄|
|[GfxVertexLayoutHandle](./结构体/GfxVertexLayoutHandle.md#struct-gfxvertexlayouthandle)|顶点布局句柄|

### 枚举
|  名称   | 描述  |
|  ----  | ----  |
|[GfxAccess](./枚举/GfxAccess.md#enum-gfxaccess)|计算资源访问权限|
|[GfxAttribType](./枚举/GfxAttribType.md#enum-gfxattribtype)|顶点属性存储类型|
|[GfxAttrib](./枚举/GfxAttrib.md#enum-gfxattrib)|顶点属性语义槽位|
|[GfxBackbufferRatio](./枚举/GfxBackbufferRatio.md#enum-gfxbackbufferratio)|后缓冲比例|
|[GfxRendererType](./枚举/GfxRendererType.md#enum-gfxrenderertype)|渲染后端类型|
|[GfxTextureFormat](./枚举/GfxTextureFormat.md#enum-gfxtextureformat)|纹理像素格式|
|[GfxUniformType](./枚举/GfxUniformType.md#enum-gfxuniformtype)|uniform 数据类型|
|[GfxViewMode](./枚举/GfxViewMode.md#enum-gfxviewmode)|视图渲染排序模式|

