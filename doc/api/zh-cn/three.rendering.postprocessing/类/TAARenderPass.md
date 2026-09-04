# 类
## class TAARenderPass
```cj
public class TAARenderPass <: SSAARenderPass
```
时间抗锯齿渲染 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 TAARenderPass 占用的所有 GPU 资源（holdRT + copy shader）。

### func init\(Scene,Camera,UInt32,Float64\)
```cj
public init(scene: Scene, camera: Camera, clearColor!: UInt32 = 0x00000000u32, clearAlpha!: Float64 = 0.0)
```
构造 TAARenderPass。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|待渲染场景|
|camera|Camera|待渲染相机|
|clearColor|UInt32|clear 颜色（默认透明黑）|
|clearAlpha|Float64|clear alpha（默认 0）差异：全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 TAA 渲染 pass。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（累加结果输出；renderToScreen=true 时写屏幕）|
|readBuffer|FrameBufferHandle|读 buffer（TAA 不直接用 readBuffer，而是渲染场景到 writeBuffer/sampleRT）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸（重建内部 sampleRT + holdRT）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let TAA\_VIEW\_ACCUM
```cj
public static let TAA_VIEW_ACCUM: UInt16 = 219u16
```
TAA pass 用的 view ID 段约定（避开 SSAO 160/Bloom/shadow 50~127/
ShaderPass 200~209/SavePass 210/TexturePass 211/OutputPass 212/FXAAPass 213/
SMAA 214~216/SSAA 217）。
- TAA_VIEW_ACCUM（219）：copy shader 把 writeBuffer × sampleWeight 加性累加到 sampleRT
- TAA_VIEW_HOLD（220）：最终合成 writeBuffer = sampleRT（覆盖）+ holdRT×残留（加性）

### let TAA\_VIEW\_HOLD
```cj
public static let TAA_VIEW_HOLD: UInt16 = 220u16
```


### var accumulateIndex
```cj
public var accumulateIndex: Int64 = - 1
```
累加索引。-1 表示未开始累加，0..jitterOffsets.length-1 表示当前累加到的样本。
默认 -1。

### var accumulate
```cj
public var accumulate: Bool = false
```
是否累加帧。false 时直接 super.render()（单次场景渲染，无累加）。
默认 false。

