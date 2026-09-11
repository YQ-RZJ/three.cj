# 类
## class ClearMaskPass
```cj
public class ClearMaskPass <: Pass
```
清遮罩 pass

### func init\(\)
```cj
public init()
```
构造 ClearMaskPass。

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行清遮罩。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用）|
|readBuffer|FrameBufferHandle|读 buffer（本 pass 不用）|
|deltaTime|Float64|帧间隔|

