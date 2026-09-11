# 类
## class BokehPass
```cj
public class BokehPass <: Pass
```
景深（DOF）后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 BokehPass 占用的所有 GPU 资源。
bokeh/bokeh_depth shader program 由 PostProcessingShaders 全局管理，不在此 dispose。
全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。

### func init\(Scene,Camera,Float64,Float64,Float64\)
```cj
public init(scene: Scene, camera: Camera, focus!: Float64 = 1.0, aperture!: Float64 = 0.025, maxblur!: Float64 = 1.0)
```
构造 BokehPass。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|待渲场景（深度 pass 用）|
|camera|Camera|相机（view transform / near / far / aspect）|
|focus|Float64|焦点距离（默认 1.0）|
|aperture|Float64|光圈（默认 0.025）|
|maxblur|Float64|最大模糊量（默认 1.0）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 BokehPass。

流程：
1. 深度 pass（view+0）：场景几何 → bokeh_depth → 深度 RT（clear 白=far，packDepthToRGBA）
2. bokeh 合成 pass（view+1）：全屏四边形 41 抽头 lens blur，tColor=readBuffer.color0,
tDepth=深度 RT → writeBuffer（或 renderToScreen 时上屏）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 的输出目标）|
|readBuffer|FrameBufferHandle|读 buffer（上一 pass 结果，绑到 tColor）|
|deltaTime|Float64|帧间隔（秒）|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸。
深度 RT 尺寸与渲染目标一致（setSize 时同步），
且 aspect 同步更新（aspect = width / height）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|目标宽（像素）|
|height|Int64|目标高（像素）|

### let BOKEH\_VIEW\_ID\_BASE
```cj
public static let BOKEH_VIEW_ID_BASE: UInt16 = 228u16
```
分配给本 pass 的 bgfx view ID 段。
+0: 深度 pass（场景几何 → bokeh_depth → 深度 RT）
+1: bokeh 合成 pass（41 抽头 lens blur → writeBuffer/屏幕）
取 228 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
DotScreenPass 226 / HalftonePass 227。

### var aperture
```cj
public var aperture: Float64
```
光圈（越大景深越浅）

### var debugMode
```cj
public var debugMode: Int64 = 0
```
调试输出模式（测试项目按键切换，中间步骤独立呈现）：
0 = 完整 bokeh 流程（41 抽头 lens blur，默认）
1 = 深度图可视化（tDepth 解包 → 灰度伪彩显示）
2 = 原图直出（tColor 透传，跳过模糊）
非 0 时 bokeh shader 跳过 41 抽头，直接输出对应中间结果。
注：此为测试辅助扩展，不改变默认 0 的语义。

### var focus
```cj
public var focus: Float64
```
焦点距离（世界单位，沿相机朝向）

### var maxblur
```cj
public var maxblur: Float64
```
最大模糊量（控制散景半径上限）

