# 类
## class SSAARenderPass
```cj
public open class SSAARenderPass <: Pass
```
超采样抗锯齿渲染 pass

### func dispose\(\)
```cj
public open override func dispose(): Unit
```
释放 SSAARenderPass 占用的所有 GPU 资源（sampleRT + copy shader）。

### func init\(Scene,Camera,UInt32,Float64\)
```cj
public init(scene: Scene, camera: Camera, clearColor!: UInt32 = 0x00000000u32, clearAlpha!: Float64 = 0.0)
```
构造 SSAARenderPass。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|待渲染场景|
|camera|Camera|待渲染相机|
|clearColor|UInt32|clear 颜色（默认透明黑）|
|clearAlpha|Float64|clear alpha（默认 0）差异：全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public open override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 SSAA 渲染 pass（单帧多 jitter 样本累加）。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（累加结果输出；renderToScreen=true 时写屏幕）|
|readBuffer|FrameBufferHandle|读 buffer（SSAA 不用 readBuffer，而是渲染场景到 sampleRT）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public open override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸（重建内部 sampleRT）。

调用约定：caller（EffectComposer.setSize/addPass）已把本方法包进 renderer.execBgfx，
故本方法直接调 bgfx API，不再嵌套 renderer.execBgfx（避免死锁）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let SSAA\_VIEW\_ACCUM
```cj
public static let SSAA_VIEW_ACCUM: UInt16 = 217u16
```
累加 pass 用的 view ID（避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209/
SavePass 210/TexturePass 211/OutputPass 212/FXAAPass 213/SMAA 214~216）。

### let camera
```cj
public let camera: Camera
```
待渲染相机。

### var clearAlpha
```cj
public var clearAlpha: Float64 = 0.0
```
clear alpha [0,1]。
默认 0。

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
clear 颜色（UInt32，0xRRGGBB）。
默认透明黑。

### var sampleLevel
```cj
public var sampleLevel: Int64 = 4
```
采样级别。指定为 n，其中样本数为 2^n，故 sampleLevel=4 为 2^4=16 样本。
默认 4。

### let scene
```cj
public let scene: Scene
```
待渲染场景。

### var unbiased
```cj
public var unbiased: Bool = true
```
是否 unbiased。true 时 sampleWeight 按 uniformCenteredDistribution 微调，
避免累加舍入误差（RGBA8 下最明显）。
默认 true。

