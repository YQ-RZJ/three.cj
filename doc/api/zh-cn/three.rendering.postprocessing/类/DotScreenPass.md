# 类
## class DotScreenPass
```cj
public class DotScreenPass <: Pass
```
点阵屏后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 dot screen pass 占用的所有 GPU 资源

### func init\(Vector2,Float64,Float64\)
```cj
public init(center!: Vector2 = Vector2(0.5, 0.5), angle!: Float64 = 1.57, scale!: Float64 = 1.0)
```
构造 DotScreenPass

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|点阵中心（默认 (0.5, 0.5)）|
|angle|Float64|点阵旋转角度（默认 1.57 ≈ π/2）|
|scale|Float64|点阵密度（默认 1.0）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 dot screen pass

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
设置 pass 尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let DOTSCREEN\_VIEW\_ID\_BASE
```cj
public static let DOTSCREEN_VIEW_ID_BASE: UInt16 = 226u16
```
分配给本 pass 的 bgfx view ID 段。
+0: dot_screen pass（点阵网点处理）
取 226 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225。

### var angle
```cj
public var angle: Float64
```
点阵旋转角度（弧度），默认 1.57 ≈ π/2

### var center
```cj
public var center: Vector2
```
点阵中心（UV 空间，0~1），默认 (0.5, 0.5)

### var scale
```cj
public var scale: Float64
```
点阵密度系数（值越大点越小），默认 1.0

