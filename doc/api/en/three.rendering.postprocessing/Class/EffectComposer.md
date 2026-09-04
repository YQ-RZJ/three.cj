# Class
## class EffectComposer
```cj
public class EffectComposer
```
Post-processing pass chain scheduler

### func addPass\(Pass\)
```cj
public func addPass(pass: Pass): Unit
```
Adds a pass to the end of the chain

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pass|Pass|The pass to add|

### func allocViewId\(\)
```cj
public func allocViewId(): UInt16
```
Allocates a unique bgfx view id (incrementing from 230)

Return: 

- The newly allocated view id

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases all GPU resources held by EffectComposer (internal dual RTs + all passes)

### func init\(BgfxRenderer\)
```cj
public init(renderer: BgfxRenderer)
```
Constructs EffectComposer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|

### func insertPass\(Pass,Int64\)
```cj
public func insertPass(pass: Pass, index: Int64): Unit
```
Inserts a pass at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pass|Pass|The pass to insert|
|index|Int64|Insertion index|

### func removePass\(Pass\)
```cj
public func removePass(pass: Pass): Unit
```
Removes the given pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pass|Pass|The pass to remove|

### func render\(Float64\)
```cj
public func render(deltaTime!: Float64 = 0.016): Unit
```
执行 pass 链，产出最终帧。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float64|帧间隔（秒），默认 0.016bgfx 差异：bgfx 是显式提交模型（bgfx_frame 双缓冲交换），每帧只需在 pass 链全部 submit 后触发一次上屏（renderToScreen=true 时）。各 pass 内部不再调 bgfx_frame（已收敛到此统一入口），避免重复 frame。注意：若链中含 RenderPass，其 renderer.render(scene,camera) 内部finishRender 会触发一次 bgfx_frame（场景渲染阶段的上屏交换），本处仅负责最后一个上屏 pass 之后的那一次交换，二者帧序不冲突。|

### func setSize\(Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64): Unit
```
Sets the RT size (rebuilding the internal dual RTs)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Width|
|height|Int64|Height|

### func writeBuffer\(\)
```cj
public func writeBuffer(): FrameBufferHandle
```
Fetches the current write buffer (used by capture.cj debug readback)

Return: 

- The FrameBufferHandle of the current write buffer

### var passes
```cj
public var passes: ArrayList < Pass >= ArrayList < Pass >()
```
The pass chain (ordered)

### let quad
```cj
public let quad: FullScreenQuad = FullScreenQuad()
```
共享全屏 quad 单例（所有 pass 共用，addPass 时注入）。

### var renderToScreen
```cj
public var renderToScreen: Bool = true
```
Whether to render the final pass result to the screen, default true

### let renderer
```cj
public let renderer: BgfxRenderer
```
Renderer reference

