# 类
## class EffectComposer
```cj
public class EffectComposer
```
后处理 pass 链调度器

### func addPass\(Pass\)
```cj
public func addPass(pass: Pass): Unit
```
添加 pass 到链尾

参数: 

|名称|类型|描述|
|---|---|---|
|pass|Pass|待添加的 pass|

### func allocViewId\(\)
```cj
public func allocViewId(): UInt16
```
分配一个唯一 bgfx view id（从 230 起递增）

返回: 

- 新分配的 view id

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 EffectComposer 占用的所有 GPU 资源（内部双 RT + 所有 pass）

### func init\(BgfxRenderer\)
```cj
public init(renderer: BgfxRenderer)
```
构造 EffectComposer

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|

### func insertPass\(Pass,Int64\)
```cj
public func insertPass(pass: Pass, index: Int64): Unit
```
在指定位置插入 pass

参数: 

|名称|类型|描述|
|---|---|---|
|pass|Pass|待插入的 pass|
|index|Int64|插入位置|

### func removePass\(Pass\)
```cj
public func removePass(pass: Pass): Unit
```
移除指定 pass

参数: 

|名称|类型|描述|
|---|---|---|
|pass|Pass|待移除的 pass|

### func render\(Float64\)
```cj
public func render(deltaTime!: Float64 = 0.016): Unit
```
执行 pass 链，产出最终帧。

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float64|帧间隔（秒），默认 0.016bgfx 差异：bgfx 是显式提交模型（bgfx_frame 双缓冲交换），每帧只需在 pass 链全部 submit 后触发一次上屏（renderToScreen=true 时）。各 pass 内部不再调 bgfx_frame（已收敛到此统一入口），避免重复 frame。注意：若链中含 RenderPass，其 renderer.render(scene,camera) 内部finishRender 会触发一次 bgfx_frame（场景渲染阶段的上屏交换），本处仅负责最后一个上屏 pass 之后的那一次交换，二者帧序不冲突。|

### func setSize\(Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64): Unit
```
设置 RT 尺寸（重建内部双 RT）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度|
|height|Int64|高度|

### func writeBuffer\(\)
```cj
public func writeBuffer(): FrameBufferHandle
```
取当前写 buffer（capture.cj 调试回读用）

返回: 

- 当前写 buffer 的 FrameBufferHandle

### var passes
```cj
public var passes: ArrayList < Pass >= ArrayList < Pass >()
```
pass 链（有序）

### let quad
```cj
public let quad: FullScreenQuad = FullScreenQuad()
```
共享全屏 quad 单例（所有 pass 共用，addPass 时注入）。

### var renderToScreen
```cj
public var renderToScreen: Bool = true
```
是否把最终 pass 结果渲染到屏幕，默认 true

### let renderer
```cj
public let renderer: BgfxRenderer
```
渲染器引用

