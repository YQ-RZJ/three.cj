# Class
## class RenderTransitionPass
```cj
public class RenderTransitionPass <: Pass
```
Scene transition render pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 RenderTransitionPass 占用的所有 GPU 资源。
transition shader program 由 PostProcessingShaders 全局管理，不在此 dispose。
全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。

### func init\(Scene,Camera,Scene,Camera\)
```cj
public init(sceneA: Scene, cameraA: Camera, sceneB: Scene, cameraB: Camera)
```
构造 RenderTransitionPass。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sceneA|Scene|场景 A（过渡起点）|
|cameraA|Camera|场景 A 的相机|
|sceneB|Scene|场景 B（过渡终点）|
|cameraB|Camera|场景 B 的相机|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 RenderTransitionPass。

流程：
1. 渲染场景 A 到 RT_A（view 0 + renderer.render，完整材质）
2. 渲染场景 B 到 RT_B（view 0 + renderer.render）
3. 合成 pass（view+2）：transition shader 混合 tDiffuse1/tDiffuse2
（+ tMixTexture 纹理过渡）→ writeBuffer（或上屏）

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 的输出目标）|
|readBuffer|FrameBufferHandle|读 buffer（本 pass 不用，场景自渲）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸。
RT_A/RT_B 尺寸与渲染目标一致。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|目标宽（像素）|
|height|Int64|目标高（像素）|

### func setTextureThreshold\(Float64\)
```cj
public func setTextureThreshold(value: Float64): Unit
```
设置过渡纹理阈值 [0,1]。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|阈值|

### func setTexture\(TextureHandle\)
```cj
public func setTexture(value: TextureHandle): Unit
```
设置过渡纹理。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|TextureHandle|过渡纹理句柄|

### func setTransition\(Float64\)
```cj
public func setTransition(value: Float64): Unit
```
设置过渡比例 [0,1]。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|过渡比例|

### func useTexture\(Bool\)
```cj
public func useTexture(value: Bool): Unit
```
切换是否使用过渡纹理。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Bool|是否使用过渡纹理|

### let TRANSITION\_VIEW\_ID\_BASE
```cj
public static let TRANSITION_VIEW_ID_BASE: UInt16 = 234u16
```
分配给本 pass 的 bgfx view ID 段。
+0: 场景 A 渲染（view 0 语义 —— 场景渲染复用 renderer.viewId）
+1: 场景 B 渲染
+2: 合成 pass（transition shader 混合 → writeBuffer/屏幕）
取 234 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229 /
RenderPixelatedPass 230~233。

### var cameraA
```cj
public var cameraA: Option < Camera >= None
```
场景 A 的相机。

### var cameraB
```cj
public var cameraB: Option < Camera >= None
```
场景 B 的相机。

### var mixRatio
```cj
public var mixRatio: Float64 = 0.0
```
过渡比例 [0,1]：0=全场景A，1=全场景B。

### var sceneA
```cj
public var sceneA: Option < Scene >= None
```
场景 A（过渡起点）。

### var sceneB
```cj
public var sceneB: Option < Scene >= None
```
场景 B（过渡终点）。

### var tMixTexture
```cj
public var tMixTexture: TextureHandle = INVALID_TEXTURE_HANDLE
```
过渡纹理（bgfx TextureHandle，RGBA8 灰度/噪声图，r 通道做阈值）。

### var threshold
```cj
public var threshold: Float64 = 0.1
```
过渡纹理阈值 [0,1]（0=全效果, 1=无效果）。默认 0.1。

### var useMixTexture
```cj
public var useMixTexture: Bool = true
```
是否使用过渡纹理（true=纹理过渡, false=纯比例混合）。默认 true。
注：字段名用 useMixTexture 避开与 useTexture(value) 方法名冲突。

