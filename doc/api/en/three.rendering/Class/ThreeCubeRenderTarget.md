# Class
## class ThreeCubeRenderTarget
```cj
public class ThreeCubeRenderTarget
```
Cube render target based on bgfx framebuffer

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
Constructs a cube render target with the specified dimensions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Width in pixels (face side length)height Height in pixels (face side length)|
|height|Int64||

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

### var width
```cj
public var width: Int64
```
Render target width in pixels

