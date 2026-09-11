# 类
## class SavePass
```cj
public class SavePass <: Pass
```
保存 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 SavePass 占用的 GPU 资源（内部 RT）

### func init\(\)
```cj
public init()
```
构造 SavePass

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行保存 pass：拷 readBuffer 到 renderTarget

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用，结果存 renderTarget）|
|readBuffer|FrameBufferHandle|读 buffer（拷贝源）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置内部 RT 尺寸（销毁重建）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### var renderTarget
```cj
public var renderTarget: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
```
内部 render target（color RT，RGBA16F，无 depth）

