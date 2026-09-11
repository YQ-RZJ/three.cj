# 类
## class RenderPixelatedPass
```cj
public class RenderPixelatedPass <: Pass
```
像素化渲染 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 RenderPixelatedPass 占用的所有 GPU 资源。
shader program 由 PostProcessingShaders/ShaderLibs 全局管理，不在此 dispose。
全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。

### func init\(Int64,Scene,Camera,Float64,Float64\)
```cj
public init(pixelSize: Int64, scene: Scene, camera: Camera, normalEdgeStrength!: Float64 = 0.3, depthEdgeStrength!: Float64 = 0.4)
```
构造 RenderPixelatedPass。

参数: 

|名称|类型|描述|
|---|---|---|
|pixelSize|Int64|像素尺寸（默认 6）|
|scene|Scene|待渲场景|
|camera|Camera|相机|
|normalEdgeStrength|Float64|法线边缘强度（默认 0.3）|
|depthEdgeStrength|Float64|深度边缘强度（默认 0.4）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 RenderPixelatedPass。

流程：
1. beauty pass（view+0）：场景渲染到低分辨率 beauty RT
2. 深度 pass（view+1）：aodepth 渲 NDC 深度到深度 RT
3. 法线 pass（view+2）：normal 渲 view 法线到法线 RT
4. 合成 pass（view+3）：pixelated 放大采样 + 边缘检测 → writeBuffer（或上屏）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 的输出目标）|
|readBuffer|FrameBufferHandle|读 buffer（本 pass 不用，beauty 自渲）|
|deltaTime|Float64|帧间隔|

### func setPixelSize\(Int64\)
```cj
public func setPixelSize(pixelSize: Int64): Unit
```
设置像素尺寸（动态调整低分辨率）。

参数: 

|名称|类型|描述|
|---|---|---|
|pixelSize|Int64|新的像素尺寸|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸。
按 pixelSize 计算低分辨率尺寸，重建全部低分辨率 RT。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|目标宽（像素）|
|height|Int64|目标高（像素）|

### let PIXELATED\_VIEW\_ID\_BASE
```cj
public static let PIXELATED_VIEW_ID_BASE: UInt16 = 230u16
```
分配给本 pass 的 bgfx view ID 段。
+0: beauty pass（场景渲染到低分辨率 beauty RT）
+1: 深度 pass（aodepth 渲 NDC 深度到深度 RT）
+2: 法线 pass（normal 渲 view 法线到法线 RT）
+3: 合成 pass（pixelated 放大 + 边缘检测 → writeBuffer/屏幕）
取 230 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229。

### var depthEdgeStrength
```cj
public var depthEdgeStrength: Float64
```
深度边缘强度 [0,1]。

### var normalEdgeStrength
```cj
public var normalEdgeStrength: Float64
```
法线边缘强度 [0,1]。

### var pixelSize
```cj
public var pixelSize: Int64
```
像素尺寸（每个输出像素对应的低分辨率像素数，如 6 → 1/6 分辨率）。

