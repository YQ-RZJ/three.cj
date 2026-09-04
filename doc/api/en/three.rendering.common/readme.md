# Package three.rendering.common 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[Animation](./Class/Animation.md#class-animation)|Rendering common animation class, managing animation callbacks and frame updates|
|[Attributes](./Class/Attributes.md#class-attributes)|Manages the mapping between vertex attributes and backend buffers|
|[Backend](./Class/Backend.md#class-backend)|Render backend abstract base class|
|[Background](./Class/Background.md#class-background)|Scene background rendering class|
|[BindGroup](./Class/BindGroup.md#class-bindgroup)|Pipeline bind group, containing a set of Bindings and their associated render pipeline|
|[Binding](./Class/Binding.md#class-binding)|Single binding resource description, representing uniform buffer, sampler, or other resource bindings|
|[Bindings](./Class/Bindings.md#class-bindings)|Pipeline bindings collection manager|
|[BlendMode](./Class/BlendMode.md#class-blendmode)|Blend mode description, defining color blending equation and factors|
|[BufferUtils](./Class/BufferUtils.md#class-bufferutils)|Buffer data type conversion utility class|
|[Buffer](./Class/Buffer.md#class-buffer)|GPU buffer management class|
|[BundleGroup](./Class/BundleGroup.md#class-bundlegroup)|Render bundle group, used to package multiple render objects into render bundles|
|[CanvasTarget](./Class/CanvasTarget.md#class-canvastarget)|Canvas render target, describing canvas dimensions|
|[ChainMap](./Class/ChainMap.md#class-chainmap)|Chained key-value map, looking up keys across multiple DataMaps by priority|
|[ClippingContext](./Class/ClippingContext.md#class-clippingcontext)|Clipping plane context, managing a collection of local clipping planes|
|[Color4](./Class/Color4.md#class-color4)|RGBA four-channel color representation|
|[ComputeInfo](./Class/ComputeInfo.md#class-computeinfo)|Compute sub-statistics|
|[ComputePipeline](./Class/ComputePipeline.md#class-computepipeline)|Compute shader pipeline|
|[Constants](./Class/Constants.md#class-constants)|Rendering common constants definitions|
|[CubeRenderTarget](./Class/CubeRenderTarget.md#class-cuberendertarget)|Cube render target, used for cube map rendering|
|[DataMap](./Class/DataMap.md#class-datamap)|Generic key-value data mapping base class|
|[Geometries](./Class/Geometries.md#class-geometries)|Geometry backend data manager|
|[IndirectStorageBufferAttribute](./Class/IndirectStorageBufferAttribute.md#class-indirectstoragebufferattribute)|Indirect storage buffer attribute marker class|
|[Info](./Class/Info.md#class-info)|Rendering statistics|
|[InspectorBase](./Class/InspectorBase.md#class-inspectorbase)|Debug inspector base class|
|[Lighting](./Class/Lighting.md#class-lighting)|Lighting information aggregation class|
|[MemoryInfo](./Class/MemoryInfo.md#class-memoryinfo)|Memory sub-statistics|
|[Pipeline](./Class/Pipeline.md#class-pipeline)|Render pipeline base class|
|[Pipelines](./Class/Pipelines.md#class-pipelines)|Pipeline collection manager|
|[PostProcessing](./Class/PostProcessing.md#class-postprocessing)|Post-processing renderer|
|[ProgrammableStage](./Class/ProgrammableStage.md#class-programmablestage)|Shader programmable stage description|
|[QuadMesh](./Class/QuadMesh.md#class-quadmesh)|Fullscreen quad mesh|
|[ReadbackBuffer](./Class/ReadbackBuffer.md#class-readbackbuffer)|GPU readback buffer marker class|
|[RenderBundle](./Class/RenderBundle.md#class-renderbundle)|Render bundle, containing a collection of render objects|
|[RenderBundles](./Class/RenderBundles.md#class-renderbundles)|Render bundles collection manager|
|[RenderContext](./Class/RenderContext.md#class-rendercontext)|Render context|
|[RenderContexts](./Class/RenderContexts.md#class-rendercontexts)|Render context cache manager|
|[RenderInfo](./Class/RenderInfo.md#class-renderinfo)|Render sub-statistics|
|[RenderItem](./Class/RenderItem.md#class-renderitem)|A single render item in the render list|
|[RenderList](./Class/RenderList.md#class-renderlist)|Render list|
|[RenderLists](./Class/RenderLists.md#class-renderlists)|Render list cache manager|
|[RenderObjectPipeline](./Class/RenderObjectPipeline.md#class-renderobjectpipeline)|Association pair between a render object and a pipeline|
|[RenderObject](./Class/RenderObject.md#class-renderobject)|Render object|
|[RenderObjects](./Class/RenderObjects.md#class-renderobjects)|Render object cache manager|
|[RenderPipeline](./Class/RenderPipeline.md#class-renderpipeline)|TSL render pipeline|
|[RendererUtils](./Class/RendererUtils.md#class-rendererutils)|Renderer utility class|
|[Renderer](./Class/Renderer.md#class-renderer)|Abstract base class for the renderer|
|[SampledTexture](./Class/SampledTexture.md#class-sampledtexture)|Sampled texture class, associating a texture with sampler parameters|
|[Sampler](./Class/Sampler.md#class-sampler)|Texture sampler class|
|[Storage3DTexture](./Class/Storage3DTexture.md#class-storage3dtexture)|Storage 3D texture class|
|[StorageArrayTexture](./Class/StorageArrayTexture.md#class-storagearraytexture)|Storage array texture class|
|[StorageBufferAttribute](./Class/StorageBufferAttribute.md#class-storagebufferattribute)|Storage buffer attribute class|
|[StorageBuffer](./Class/StorageBuffer.md#class-storagebuffer)|Storage buffer class|
|[StorageInstancedBufferAttribute](./Class/StorageInstancedBufferAttribute.md#class-storageinstancedbufferattribute)|Storage instanced buffer attribute class|
|[StorageTexture](./Class/StorageTexture.md#class-storagetexture)|Storage texture class|
|[Textures](./Class/Textures.md#class-textures)|Textures management class|
|[TimestampQueryPool](./Class/TimestampQueryPool.md#class-timestampquerypool)|Timestamp query pool class|
|[UniformBuffer](./Class/UniformBuffer.md#class-uniformbuffer)|Uniform buffer class|
|[XRManager](./Class/XRManager.md#class-xrmanager)|XR Manager class|
|[XRRenderTarget](./Class/XRRenderTarget.md#class-xrrendertarget)|XR render target class|

### Interface
|  Name   | Describe  |
|  ----  | ----  |
|[IRenderContext](./Interface/IRenderContext.md#interface-irendercontext)|Render context placeholder interface, providing view/viewport/clear color/framebuffer query methods|
|[IRenderObject](./Interface/IRenderObject.md#interface-irenderobject)|Render object placeholder interface, providing matrix/geometry/material/object ID query methods|

