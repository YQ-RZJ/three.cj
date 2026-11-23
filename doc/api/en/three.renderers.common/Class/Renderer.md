# Class
## class Renderer
```cj
public open class Renderer
```
Abstract base class for the renderer

### func \_collectRenderObjects\(Object3D,RenderList,Camera\)
```cj
public open func _collectRenderObjects(obj: Object3D, renderList: RenderList, camera: Camera): Unit
```
Recursively collect render objects from the scene

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Object3D|Current node being traversedrenderList Render listcamera Camera|
|renderList|RenderList||
|camera|Camera||

### func \_fillRenderContext\(RenderContext\)
```cj
public open func _fillRenderContext(renderContext: RenderContext): Unit
```
Subclass hook for filling subclass-specific RenderContext fields

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext|Render context to be filled|

### func \_render\(Scene,Camera\)
```cj
public open func _render(scene: Scene, camera: Camera): Unit
```
Main renderers dispatch flow, orchestrating the complete renderers pipeline

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scenecamera Camera|
|camera|Camera||

### func getPixelRatio\(\)
```cj
public func getPixelRatio(): Float64
```
Get current pixel ratio

Return: 

- Pixel ratio

### func getRenderViewId\(\)
```cj
public open func getRenderViewId(): UInt16
```
Get the bgfx view id used for current renderers

Return: 

- bgfx view id

### func getSceneMeshes\(Object3D,Bool\)
```cj
public func getSceneMeshes(scene: Object3D, visibleOnly!: Bool = false): ArrayList < RenderObject >
```
Get this frame's list of Mesh render objects (frame-scoped shared cache)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Object3D|Scene root nodevisibleOnly Whether to return only visible objects (passes such as SSR skipinvisible objects to avoid self-reflection)|
|visibleOnly|Bool||

Return: 

- Mesh render object list (internal reference, read-only for callers)

### func getSize\(\)
```cj
public func getSize():(Int64, Int64)
```
Get logical renderers dimensions

Return: 

- (logical width, logical height)

### func gfxBackend\(\)
```cj
public func gfxBackend(): IRenderBackend
```
Returns the render backend (GPU API resource channel, used when constructing
resource objects like EngineRenderTarget/EngineDataTexture)

Return: 

- The render backend instance (the IRenderBackend contract)

### func init\(\)
```cj
public init()
```
Default no-argument constructor (null-backend placeholder, backward compatible)

### func renderPass\(Scene,Camera,Bool,Option<UInt16>,Option<\(Int32,Int32,Int32,Int32\)>,Option<UInt32>\)
```cj
public func renderPass(scene: Scene, camera: Camera, present!: Bool = false, viewId!: Option < UInt16 >= None, viewport!: Option <(Int32, Int32, Int32, Int32) >= None, clearColor!: Option < UInt32 >= None): Unit
```
Render a single pass (called by post-processing offscreen rendering, does not present to screen; supports specifying viewId/viewport/clearColor)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene||
|camera|Camera||
|present|Bool||
|viewId|Option<UInt16>||
|viewport|Option<(Int32,Int32,Int32,Int32)>||
|clearColor|Option<UInt32>||

### func render\(Scene,Camera\)
```cj
public open func render(scene: Scene, camera: Camera): Unit
```
renderers entry point, updates scene transform matrices and executes renderers

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scenecamera Camera|
|camera|Camera||

### func setPixelRatio\(Float64\)
```cj
public func setPixelRatio(value: Float64): Unit
```
Set pixel ratio

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|New pixel ratio (must be > 0)|

### func setSize\(Int64,Int64\)
```cj
public func setSize(w: Int64, h: Int64): Unit
```
Set renderers dimensions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|Int64|Render logical widthh Render logical height|
|h|Int64||

### var alpha
```cj
public var alpha: Bool = true
```
Whether alpha is enabled

### var autoClearColor
```cj
public var autoClearColor: Bool = true
```
Whether to auto-clear the color buffer

### var autoClearDepth
```cj
public var autoClearDepth: Bool = true
```
Whether to auto-clear the depth buffer

### var autoClearStencil
```cj
public var autoClearStencil: Bool = true
```
Whether to auto-clear the stencil buffer

### var autoClear
```cj
public var autoClear: Bool = true
```
Whether to auto-clear the frame buffer

### var background
```cj
public var background: Background = Background()
```
Background renderer

### var depth
```cj
public var depth: Bool = true
```
Whether depth buffer is enabled

### var enableSpatialCulling
```cj
public var enableSpatialCulling: Bool = true
```
Whether spatial culling (BVH acceleration) is enabled

### var frameIndex
```cj
public var frameIndex: Int64 = 0
```
Frame index (incremented on every render())

### var height
```cj
public var height: Int64 = 600
```
Render height (physical pixels / backbuffer height)

### var info
```cj
public var info: Info = Info()
```
renderers statistics info

### var lighting
```cj
public var lighting: Lighting = Lighting()
```
Lighting manager

### var logarithmicDepthBuffer
```cj
public var logarithmicDepthBuffer: Bool = false
```
Whether logarithmic depth buffer is enabled

### var outputColorSpace
```cj
public var outputColorSpace: String = "srgb"
```
Output color space

### var pixelRatio
```cj
public var pixelRatio: Float64 = 1.0
```
Pixel ratio

### var renderBundles
```cj
public var renderBundles: RenderBundles = RenderBundles()
```
Render bundles manager

### var renderContexts
```cj
public var renderContexts: RenderContexts
```
Render contexts cache

### var renderLists
```cj
public var renderLists: RenderLists
```
Render lists cache

### var renderObjects
```cj
public var renderObjects: RenderObjects
```
Render objects cache

### var reversedDepthBuffer
```cj
public var reversedDepthBuffer: Bool = false
```
Whether reversed depth buffer is enabled

### var samples
```cj
public var samples: Int64 = 0
```
Sample count (MSAA)

### var sortObjects
```cj
public var sortObjects: Bool = true
```
Whether to auto-sort render objects

### var stencil
```cj
public var stencil: Bool = false
```
Whether stencil buffer is enabled

### var toneMappingExposure
```cj
public var toneMappingExposure: Float64 = 1.0
```
Tone mapping exposure

### var toneMapping
```cj
public var toneMapping: Int64 = 0
```
Tone mapping mode

### var width
```cj
public var width: Int64 = 800
```
Render width (physical pixels / backbuffer width)

