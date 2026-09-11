# 类
## class SSRPass
```cj
public class SSRPass <: Pass
```


### func blur2Texture\(\)
```cj
public func blur2Texture(): TextureHandle
```
模糊 2 RT color 纹理（capture.cj 调试回读用）

### func depthTexture\(\)
```cj
public func depthTexture(): TextureHandle
```
深度 RT color 纹理（capture.cj 调试回读用）

### func dispose\(\)
```cj
public override func dispose(): Unit
```
销毁全部 GPU 资源（composer.dispose 或 renderer.shutdown 调用）

### func init\(Scene,Camera\)
```cj
public init(scene: Scene, camera: Camera)
```
构造：`new SSRPass({ scene, camera, width, height })`。
默认 output=Default（0）；needsSwap=true（Pass 基类默认）。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene||
|camera|Camera||

### func normalTexture\(\)
```cj
public func normalTexture(): TextureHandle
```
法线 RT color 纹理（capture.cj 调试回读用）

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Pass.render 入口：执行 SSR 链并输出反射应用到场景。

流程：
1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SSR 计算（view+2）→
4. 模糊 1（view+3）→ 5. 模糊 2（view+4）→ 6. 输出（view+5）

各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer||
|writeBuffer|FrameBufferHandle||
|readBuffer|FrameBufferHandle||
|deltaTime|Float64||

### func rtHeight\(\)
```cj
public func rtHeight(): Int64
```
当前 RT 高（capture.cj 调试回读用）

### func rtWidth\(\)
```cj
public func rtWidth(): Int64
```
当前 RT 宽（capture.cj 调试回读用）

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### func ssrTexture\(\)
```cj
public func ssrTexture(): TextureHandle
```
SSR 反射结果 RT color 纹理（capture.cj 调试回读用）

### let OUTPUT\_BEAUTY
```cj
public static let OUTPUT_BEAUTY: Int64 = 3
```
仅 SSR 结果

### let OUTPUT\_DEFAULT
```cj
public static let OUTPUT_DEFAULT: Int64 = 0
```
输出模式。
注：数值跳过 2/6（保留位），Metalness=7 暂未实现。

### let OUTPUT\_DEPTH
```cj
public static let OUTPUT_DEPTH: Int64 = 4
```
仅场景色

### let OUTPUT\_HITNORMALS
```cj
public static let OUTPUT_HITNORMALS: Int64 = 6
```
法线可视化

### let OUTPUT\_NORMAL
```cj
public static let OUTPUT_NORMAL: Int64 = 5
```
深度可视化

### let OUTPUT\_SSR
```cj
public static let OUTPUT_SSR: Int64 = 1
```
场景色 + SSR 混合

### let SSR\_VIEW\_ID\_BASE
```cj
public static let SSR_VIEW_ID_BASE: UInt16 = 176u16
```
SSR pass 用的 view ID 段约定：
SSAO 160~164，GTAO 165~169，SAO 170~175，SSR 176~181，composer 分配 230+
SSR 需要 6 个 view：normal(0) depth(1) ssr(2) blur1(3) blur2(4) output(5)

### var blur
```cj
public var blur: Bool = true
```
是否启用模糊（默认 true）

### var debug
```cj
public var debug: Bool = false
```
诊断可视化开关：true 时 SSR_FS 按射线拒绝原因着色（定位伪影用，默认 false）

### var distanceAttenuation
```cj
public var distanceAttenuation: Bool = true
```
是否启用距离衰减（DISTANCE_ATTENUATION define）

### var fresnel
```cj
public var fresnel: Bool = true
```
是否启用菲涅耳效应（FRESNEL define）

### var groundReflector
```cj
public var groundReflector: Option < GroundReflector >= None
```
地面反射器（平面反射组件，可选）。
范式：selects=[球/立方体/...]+groundReflector → SSR 只处理金属物体表面，
地面用 GroundReflector 平面反射（镜像相机渲场景到反射 RT，
ReflectorShader 经 textureMatrix 投影到地面）。
协作方式（包依赖约束：objects 不能依赖 renderers）：
- GroundReflector.computeVirtualCamera(camera) 做镜像相机数学（纯计算）
- 本 pass 在 render 链开头调用该数学 + 渲场景到反射 RT（view 0 语义 +
renderer.render(scene, virtualCamera)，参照 RenderPass 范式）
- 防自反射：渲反射场景前临时隐藏反射面（visible=false），渲完恢复；
且 _collectMeshes 跳过反射面自身（不参与 normal/depth/metalness/SSR）。

### var infiniteThick
```cj
public var infiniteThick: Bool = false
```
是否使用无限厚度（INFINITE_THICK define）

### var maxDistance
```cj
public var maxDistance: Float64 = 180.0
```
最大反射距离（默认 180）

### var opacity
```cj
public var opacity: Float64 = 0.5
```
反射不透明度（默认 0.5）

### var output
```cj
public var output: Int64 = 0
```
输出模式（默认 Default=0，场景+SSR 混合）

### var selective
```cj
public var selective: Bool = false
```
selective 模式开关。
为 true 时启用 metalness pass + SSR_FS SELECTIVE define：
- _selects 中的 mesh 渲染为 metalness=1（白色）写入 metalness RT
- 其他 mesh 渲染为 metalness=0（黑色）
- SSR_FS 顶层采样 metalness RT，metalness==0 的像素直接 return 跳过 SSR
范式：selects=[球/立方体/...]+groundReflector → SSR 只处理金属物体表面。

### var selects
```cj
public var selects: Option < ArrayList < Object3D >>= None
```
selective 模式下视为金属的 mesh 列表。
列表中的 mesh 在 metalness pass 中渲为白（metalness=1），其他 mesh 渲为黑。
selective=false 时本字段被忽略。

### var thickness
```cj
public var thickness: Float64 = 0.018
```
厚度阈值（默认 0.018）

