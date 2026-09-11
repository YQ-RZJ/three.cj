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
Main rendering dispatch flow, orchestrating the complete rendering pipeline

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
Get the bgfx view id used for current rendering

Return: 

- bgfx view id

### func getSize\(\)
```cj
public func getSize():(Int64, Int64)
```
Get logical rendering dimensions

Return: 

- (logical width, logical height)

### func init\(Backend,Bool,Bool,Bool,Bool,Int64,Bool,Bool\)
```cj
public init(backend: Backend, alpha!: Bool = true, depth!: Bool = true, stencil!: Bool = false, antialias!: Bool = false, samples!: Int64 = 0, logarithmicDepthBuffer!: Bool = false, reversedDepthBuffer!: Bool = false)
```
Constructor with specified backend and rendering options

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|Backend|Rendering backend instancealpha Whether to enable alpha, default truedepth Whether to enable depth buffer, default truestencil Whether to enable stencil buffer, default falseantialias Whether to enable antialiasing, default falsesamples Sample count, 0 for auto, default 0logarithmicDepthBuffer Whether to enable logarithmic depth buffer, default falsereversedDepthBuffer Whether to enable reversed depth buffer, default false|
|alpha|Bool||
|depth|Bool||
|stencil|Bool||
|antialias|Bool||
|samples|Int64||
|logarithmicDepthBuffer|Bool||
|reversedDepthBuffer|Bool||

### func init\(\)
```cj
public init()
```
Default no-argument constructor for backward compatibility

### func render\(Scene,Camera\)
```cj
public open func render(scene: Scene, camera: Camera): Unit
```
Rendering entry point, updates scene transform matrices and executes rendering

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
Set rendering dimensions

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

### var backend
```cj
public var backend: Backend
```
Rendering backend

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

### var height
```cj
public var height: Int64 = 600
```
Render height (physical pixels / backbuffer height)

### var info
```cj
public var info: Info = Info()
```
Rendering statistics info

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

