# Class
## class Backend
```cj
public open class Backend
```
Render backend abstract base class

### func beginCompute\(ComputePipeline\)
```cj
public open func beginCompute(computeContext: ComputePipeline): Unit
```
Begin compute pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|computeContext|ComputePipeline|Compute pipeline|

### func beginRender\(IRenderContext\)
```cj
public open func beginRender(renderContext: IRenderContext): Unit
```
Begin render pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|IRenderContext|Render context|

### func beginRender\(RenderContext\)
```cj
public open func beginRender(renderContext: RenderContext): Unit
```
beginRender overload, accepts concrete RenderContext class

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext|Render context|

### func bindShadowUniforms\(\)
```cj
public open func bindShadowUniforms(): Unit
```
Bind shadow uniforms to main pass draw, base class throws exception by default

### func blitShadowMap\(UInt16\)
```cj
public open func blitShadowMap(mainViewId: UInt16): Unit
```
Full-screen blit shadow map to screen (for debug mode), base class throws exception by default

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mainViewId|UInt16|Main render view ID (blit output target)|

### func blit\(Texture,Texture,UInt16\)
```cj
public open func blit(textureSrc: Texture, textureDst: Texture, viewId: UInt16): Unit
```
Blit operation, copy from source texture to destination texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureSrc|Texture|Source texturetextureDst Destination textureviewId View ID|
|textureDst|Texture||
|viewId|UInt16||

### func clear\(IRenderContext,Bool,Bool,Bool\)
```cj
public open func clear(renderContext: IRenderContext, color: Bool, depth: Bool, stencil: Bool): Unit
```
Clear buffers

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|IRenderContext|Render contextcolor Whether to clear color bufferdepth Whether to clear depth bufferstencil Whether to clear stencil buffer|
|color|Bool||
|depth|Bool||
|stencil|Bool||

### func clear\(RenderContext,Bool,Bool,Bool\)
```cj
public open func clear(renderContext: RenderContext, color: Bool, depth: Bool, stencil: Bool): Unit
```
clear overload, accepts concrete RenderContext class

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext|Render contextcolor Whether to clear color bufferdepth Whether to clear depth bufferstencil Whether to clear stencil buffer|
|color|Bool||
|depth|Bool||
|stencil|Bool||

### func clear\(\)
```cj
public open func clear(): Unit
```
clear no-argument version (legacy compatibility)

### func compute\(ComputePipeline\)
```cj
public open func compute(computeNode: ComputePipeline): Unit
```
Execute compute dispatch

Parameter: 

|Name|Type|Describe|
|---|---|---|
|computeNode|ComputePipeline|Compute node|

### func copyTo\(Texture,Texture\)
```cj
public open func copyTo(textureSrc: Texture, textureDst: Texture): Unit
```
Copy texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureSrc|Texture|Source texturetextureDst Destination texture|
|textureDst|Texture||

### func createBindings\(Bindings\)
```cj
public open func createBindings(bindings: Bindings): Unit
```
Create bindings

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bindings|Bindings|Bindings object|

### func createPipeline\(IRenderObject\)
```cj
public open func createPipeline(renderObject: IRenderObject): ComputePipeline
```
Create pipeline

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderObject|IRenderObject|Render object|

Return: 

- Compute pipeline instance

### func createProgram\(ProgrammableStage\)
```cj
public open func createProgram(program: ProgrammableStage): Unit
```
Create program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|program|ProgrammableStage|Programmable stage|

### func createSampler\(Sampler\)
```cj
public open func createSampler(sampler: Sampler): Unit
```
Create sampler

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sampler|Sampler|Sampler|

### func createTexture\(Texture\)
```cj
public open func createTexture(texture: Texture): Unit
```
Create texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture|

### func destroyTexture\(Texture\)
```cj
public open func destroyTexture(texture: Texture): Unit
```
Destroy texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture|

### func destroy\(\)
```cj
public open func destroy(): Unit
```
destroy is an alias of dispose (legacy compatibility)

### func dispose\(\)
```cj
public open func dispose(): Unit
```
Dispose backend and release resources

### func draw\(IRenderObject\)
```cj
public open func draw(renderObject: IRenderObject): Unit
```
Execute draw call

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderObject|IRenderObject|Render object|

### func draw\(BufferGeometry,Material\)
```cj
public open func draw(geometry: BufferGeometry, material: Material): Unit
```
draw legacy compatibility (geometry + material)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Buffer geometrymaterial Material|
|material|Material||

### func finishCompute\(ComputePipeline\)
```cj
public open func finishCompute(computeContext: ComputePipeline): Unit
```
Finish compute pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|computeContext|ComputePipeline|Compute pipeline|

### func finishRender\(IRenderContext\)
```cj
public open func finishRender(renderContext: IRenderContext): Unit
```
Finish render pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|IRenderContext|Render context|

### func finishRender\(RenderContext\)
```cj
public open func finishRender(renderContext: RenderContext): Unit
```
finishRender overload, accepts concrete RenderContext class

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext|Render context|

### func generateMipmaps\(Texture\)
```cj
public open func generateMipmaps(texture: Texture): Unit
```
Generate mipmaps

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture|

### func getMaxAnisotropy\(\)
```cj
public open func getMaxAnisotropy(): Int64
```
Get maximum anisotropy

Return: 

- Maximum anisotropy value

### func getMaxTextureSize\(\)
```cj
public open func getMaxTextureSize(): Int64
```
Get maximum texture size

Return: 

- Maximum texture size

### func hasFeature\(String\)
```cj
public open func hasFeature(name: String): Bool
```
Query whether a specified feature is supported

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Feature name|

Return: 

- Whether supported

### func init\(\)
```cj
public init()
```


### func initialize\(Renderer\)
```cj
public open func initialize(renderer: Renderer): Unit
```
Initialize the render backend

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer instance|

### func prepareShadowMap\(Scene\)
```cj
public open func prepareShadowMap(scene: Scene): Unit
```
Shadow depth pre-pass hook, base class throws exception by default, subclass override implements concrete shadow depth pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Render scene (contains lights and caster geometry)|

### func resolveRenderTarget\(RenderTarget\)
```cj
public open func resolveRenderTarget(renderTarget: RenderTarget): Unit
```
Resolve render target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderTarget|RenderTarget|Render target|

### func setClearColor\(UInt32\)
```cj
public open func setClearColor(color: UInt32): Unit
```
Set clear color

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|UInt32|Clear color (UInt32 RGBA)|

### func setScissor\(Int32,Int32,Int32,Int32\)
```cj
public open func setScissor(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```
Set scissor region

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Int32|Scissor X coordinatey Scissor Y coordinatew Scissor widthh Scissor height|
|y|Int32||
|w|Int32||
|h|Int32||

### func setViewport\(Int32,Int32,Int32,Int32\)
```cj
public open func setViewport(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```
Set viewport

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Int32|Viewport X coordinatey Viewport Y coordinatew Viewport widthh Viewport height|
|y|Int32||
|w|Int32||
|h|Int32||

### func updateTexture\(Texture\)
```cj
public open func updateTexture(texture: Texture): Unit
```
Update texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture|

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
Clear color (UInt32 RGBA)

### var coordinateSystem
```cj
public var coordinateSystem: Int64 = 2000
```
Coordinate system (default 2000 = WebGPUCoordinateSystem)

### var hwnd
```cj
public var hwnd: Option < UIntNative >= None
```
Platform window handle

### var initialized
```cj
public var initialized: Bool = false
```
Whether the backend is initialized

### var kind
```cj
public var kind: String
```
Backend type identifier ("WebGL"/"WebGPU"/"bgfx")

### var renderer
```cj
public var renderer: Option < Renderer >= None
```
Renderer reference

