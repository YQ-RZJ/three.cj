# 类
## class GlitchPass
```cj
public class GlitchPass <: Pass
```
数字故障后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 glitch pass 占用的所有 GPU 资源。
释放位移贴图纹理；glitch shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。

### func init\(Int64\)
```cj
public init(dt_size!: Int64 = 64)
```
构造 GlitchPass。

参数: 

|名称|类型|描述|
|---|---|---|
|dt_size|Int64||

### func onAttach\(EffectComposer\)
```cj
public override func onAttach(composer: EffectComposer): Unit
```
挂载到 composer 时的钩子。
在此创建位移贴图（bgfx 调用须在渲染线程，onAttach 由 addPass 触发）。

参数: 

|名称|类型|描述|
|---|---|---|
|composer|EffectComposer|挂载的 EffectComposer|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 glitch pass。

流程：
1. seed = random()（每帧新种子）
2. byp = 0（默认应用 glitch）
3. 触发器机制：
- 触发帧（_curF % _randX == 0）或 goWild：
amount = random/30, angle = randFloat(-π, π),
seed_x = randFloat(-1,1), seed_y = randFloat(-1,1),
distortion_x = randFloat(0,1), distortion_y = randFloat(0,1)
_curF = 0, _generateTrigger()
- 触发后 1/5 周期（_curF % _randX < _randX/5）：
amount = random/90（弱 glitch），刷新扭曲参数
- 其余帧 + goWild=false：byp = 1（透传）
4. 绑定 tDiffuse = readBuffer.color0（stage 0）
5. 绑定 tDisp = _heightMap（stage 1）
6. 设置 9 个 uniforms（byp/amount/angle/seed/seed_x/seed_y/distortion_x/distortion_y/col_s）
7. 全屏 quad submit（覆盖写 state）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 的输出目标）|
|readBuffer|FrameBufferHandle|读 buffer（上一 pass 结果，绑到 tDiffuse）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸。
GlitchPass 无内部 RT，尺寸仅用于视口记录。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let GLITCH\_VIEW\_ID\_BASE
```cj
public static let GLITCH_VIEW_ID_BASE: UInt16 = 225u16
```
分配给本 pass 的 bgfx view ID 段。
+0: glitch pass（扭曲 + RGB shift + snow）
取 225 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
TAA 219~220 / Afterimage 221~223 / FilmPass 224。

### let dtSize
```cj
public let dtSize: Int64
```
位移贴图尺寸（像素，正方形）

### var goWild
```cj
public var goWild: Bool = false
```
是否显著增强 glitch 效果

