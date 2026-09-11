# Class
## class ThreeArrayRenderTarget
```cj
public class ThreeArrayRenderTarget
```
Array render target based on bgfx framebuffer

### func init\(Int64,Int64,Int64\)
```cj
public init(width: Int64, height: Int64, depth: Int64)
```
Constructs an array render target with the specified dimensions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Width in pixelsheight Height in pixelsdepth Number of layers|
|height|Int64||
|depth|Int64||

### var depth
```cj
public var depth: Int64
```
Render target depth (number of layers)

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

