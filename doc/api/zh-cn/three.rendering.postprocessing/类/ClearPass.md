# 类
## class ClearPass
```cj
public class ClearPass <: Pass
```
清屏 pass

### func init\(UInt32,Float64\)
```cj
public init(clearColor!: UInt32 = 0x00000000u32, clearAlpha!: Float64 = 0.0)
```
构造 ClearPass

参数: 

|名称|类型|描述|
|---|---|---|
|clearColor|UInt32|clear 颜色（默认透明黑 0x00000000）|
|clearAlpha|Float64|clear alpha（默认 0）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行清屏

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用）|
|readBuffer|FrameBufferHandle|读 buffer（renderToScreen=false 时清这个）|
|deltaTime|Float64|帧间隔|

### var clearAlpha
```cj
public var clearAlpha: Float64 = 0.0
```
Clear alpha [0,1]，默认 0

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
Clear 颜色（UInt32，0xAABBGGRR，对齐 ThreeRenderer.clearColor），默认透明黑

