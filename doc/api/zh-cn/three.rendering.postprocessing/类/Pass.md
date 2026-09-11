# 类
## class Pass
```cj
public open class Pass
```
后处理 pass 抽象基类

### func dispose\(\)
```cj
public open func dispose(): Unit
```
释放 pass 占用的 GPU 资源

### func init\(\)
```cj
public init()
```


### func onAttach\(EffectComposer\)
```cj
public open func onAttach(composer: EffectComposer): Unit
```
挂载到 composer 时的钩子

参数: 

|名称|类型|描述|
|---|---|---|
|composer|EffectComposer|挂载的 EffectComposer|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public open func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 pass 渲染逻辑

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写入 buffer（FrameBufferHandle）|
|readBuffer|FrameBufferHandle|读取 buffer（上一 pass 结果）|
|deltaTime|Float64|帧间隔（秒）|

### func setQuad\(FullScreenQuad\)
```cj
public func setQuad(quad: FullScreenQuad): Unit
```
注入共享全屏 quad

参数: 

|名称|类型|描述|
|---|---|---|
|quad|FullScreenQuad|composer 持有的共享全屏 quad|

### func setSize\(Int64,Int64\)
```cj
public open func setSize(width: Int64, height: Int64): Unit
```
设置 pass 内部 RT 尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### var clear
```cj
public var clear: Bool = false
```
若为 true，pass 渲染前清 buffer，默认 false

### var enabled
```cj
public var enabled: Bool = true
```
若为 false，composer 跳过本 pass，默认 true

### let isPass
```cj
public let isPass: Bool = true
```
类型标志，用于运行期判断是否为 Pass

### var needsSwap
```cj
public var needsSwap: Bool = true
```
若为 true，pass 渲染后 composer 交换 read/write buffer，默认 true

### var quad
```cj
public var quad: Option < FullScreenQuad >= None
```
共享全屏 quad（由 EffectComposer 持单例，addPass 时经 setQuad 注入）

### var renderToScreen
```cj
public var renderToScreen: Bool = false
```
若为 true，pass 结果直接渲染到屏幕，默认 false

