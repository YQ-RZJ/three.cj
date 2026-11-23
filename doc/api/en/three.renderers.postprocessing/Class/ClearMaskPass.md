# Class
## class ClearMaskPass
```cj
public class ClearMaskPass <: Pass & IReleasable
```
Clear-mask pass

### func init\(\)
```cj
public init()
```
构造 ClearMaskPass。

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
执行清遮罩。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|GfxFrameBufferHandle|写 buffer（本 pass 不用）|
|readBuffer|GfxFrameBufferHandle|读 buffer（本 pass 不用）|
|deltaTime|Float64|帧间隔|

