# Class
## class ClearMaskPass
```cj
public class ClearMaskPass <: Pass
```
Clear-mask pass

### func init\(\)
```cj
public init()
```
构造 ClearMaskPass。

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行清遮罩。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用）|
|readBuffer|FrameBufferHandle|读 buffer（本 pass 不用）|
|deltaTime|Float64|帧间隔|

