# Class
## class ClearPass
```cj
public class ClearPass <: Pass
```
Clear pass

### func init\(UInt32,Float64\)
```cj
public init(clearColor!: UInt32 = 0x00000000u32, clearAlpha!: Float64 = 0.0)
```
Constructs ClearPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clearColor|UInt32|Clear color (default transparent black 0x00000000)|
|clearAlpha|Float64|Clear alpha (default 0)|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Performs the clear operation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (unused by this pass)|
|readBuffer|FrameBufferHandle|Read buffer (cleared when renderToScreen=false)|
|deltaTime|Float64|Frame delta time|

### var clearAlpha
```cj
public var clearAlpha: Float64 = 0.0
```
Clear alpha [0,1], default 0

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
Clear color (UInt32, 0xAABBGGRR, aligned with BgfxRenderer.clearColor), default transparent black

