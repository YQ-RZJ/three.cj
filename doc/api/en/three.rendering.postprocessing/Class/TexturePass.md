# Class
## class TexturePass
```cj
public class TexturePass <: Pass & IReleasable
```
Texture overlay pass

### func init\(TextureHandle,Float64\)
```cj
public init(map: TextureHandle, opacity!: Float64 = 1.0)
```
Constructs TexturePass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|map|TextureHandle|Texture to render (bgfx TextureHandle)|
|opacity|Float64|Opacity (default 1.0)|

### func release\(\)
```cj
public override func release(): Bool
```
Releases the GPU resources held by TexturePass

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the texture pass: renders the map to readBuffer or the screen

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (unused by this pass; result goes to readBuffer or screen)|
|readBuffer|FrameBufferHandle|Read buffer (written here when renderToScreen=false)|
|deltaTime|Float64|Frame delta time|

### var map
```cj
public var map: TextureHandle
```
Texture to render (bgfx TextureHandle)

### var opacity
```cj
public var opacity: Float64 = 1.0
```
Opacity [0,1], default 1.0 (fully opaque)

