# Class
## class TexturePass
```cj
public class TexturePass <: Pass & IReleasable
```
Texture overlay pass

### func init\(EngineDataTexture,Float64\)
```cj
public init(map: EngineDataTexture, opacity!: Float64 = 1.0)
```
Constructs TexturePass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|map|EngineDataTexture|Texture to render (bgfx GfxTextureHandle)|
|opacity|Float64|Opacity (default 1.0)|

### func release\(\)
```cj
public override func release(): Bool
```
Releases the GPU resources held by TexturePass

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
Executes the texture pass: renders the map to readBuffer or the screen

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|GfxFrameBufferHandle|Write buffer (unused by this pass; result goes to readBuffer or screen)|
|readBuffer|GfxFrameBufferHandle|Read buffer (written here when renderToScreen=false)|
|deltaTime|Float64|Frame delta time|

### var map
```cj
public var map: EngineDataTexture
```
Texture to render (bgfx GfxTextureHandle)

### var opacity
```cj
public var opacity: Float64 = 1.0
```
Opacity [0,1], default 1.0 (fully opaque)

