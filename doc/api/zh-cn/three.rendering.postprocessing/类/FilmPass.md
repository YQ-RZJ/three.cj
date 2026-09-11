# 类
## class FilmPass
```cj
public class FilmPass <: Pass
```
胶片颗粒后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 film pass 占用的所有 GPU 资源

### func init\(Float64,Bool\)
```cj
public init(intensity!: Float64 = 0.5, grayscale!: Bool = false)
```
构造 FilmPass

参数: 

|名称|类型|描述|
|---|---|---|
|intensity|Float64|颗粒强度（默认 0.5）|
|grayscale|Bool|是否灰度（默认 false）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 film pass

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

### let FILM\_VIEW\_ID\_BASE
```cj
public static let FILM_VIEW_ID_BASE: UInt16 = 224u16
```
分配给本 pass 的 bgfx view ID 段。
+0: film pass（颗粒处理 + 可选灰度）
取 224 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
TAA 219~220 / Afterimage 221~223。

### var grayscale
```cj
public var grayscale: Bool
```
是否启用灰度转换，默认 false

### var intensity
```cj
public var intensity: Float64
```
颗粒强度（0~1）：0 = 无效果，1 = 全强度，默认 0.5

### var time
```cj
public var time: Float64 = 0.0
```
动画时间累加器（秒），每帧 += deltaTime，驱动 rand 噪声动态变化

