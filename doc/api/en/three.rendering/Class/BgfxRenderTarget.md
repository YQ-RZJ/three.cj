# Class
## class BgfxRenderTarget
```cj
public class BgfxRenderTarget <: IRenderTarget
```
Standard 2D render target based on bgfx framebuffer

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroys the framebuffer and releases GPU resources

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
Constructs a 2D render target with the specified dimensions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Width in pixelsheight Height in pixels|
|height|Int64||

### func setSize\(Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64): Unit
```
Resizes the render target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|New width in pixelsheight New height in pixels|
|height|Int64||

### var depth
```cj
public var depth: Int64
```
Render target depth (layers, for 3D targets)

### var frameBuffer
```cj
public var frameBuffer: FrameBufferHandle
```
bgfx framebuffer handle

### var height
```cj
public var height: Int64
```
Render target height in pixels

### var kind
```cj
public var kind: String
```
Render target type identifier

### var texture
```cj
public var texture: Texture
```
Associated color texture

### var width
```cj
public var width: Int64
```
Render target width in pixels

