# Class
## class RenderPass
```cj
public class RenderPass <: Pass
```
Scene rendering pass

### func init\(Scene,Camera\)
```cj
public init(scene: Scene, camera: Camera)
```
Constructs RenderPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scene|
|camera|Camera|Camera|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Renders the scene into the readBuffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (unused by this pass)|
|readBuffer|FrameBufferHandle|Read buffer (render target of this pass)|
|deltaTime|Float64|Frame delta time|

### let camera
```cj
public let camera: Camera
```
Camera to render with

### var clearAlpha
```cj
public var clearAlpha: Option < Float64 >= None
```
Clear alpha (optional)

### var clearColor
```cj
public var clearColor: Option < UInt32 >= None
```
Clear color (optional)

### var clearDepth
```cj
public var clearDepth: Bool = false
```
Whether to clear the depth buffer

### var overrideMaterial
```cj
public var overrideMaterial: Option < Material >= Option < Material >.None
```
Override material (optional)

### let scene
```cj
public let scene: Scene
```
Scene to render

