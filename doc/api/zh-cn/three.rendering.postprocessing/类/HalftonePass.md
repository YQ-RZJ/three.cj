# 类
## class HalftonePass
```cj
public class HalftonePass <: Pass
```
RGB 半色调后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 halftone pass 占用的所有 GPU 资源

### func init\(Int64,Float64,Float64,Float64,Float64,Float64,Float64,Int64,Bool,Bool\)
```cj
public init(shape!: Int64 = 1, radius!: Float64 = 4.0, rotateR!: Float64 = 3.141592653589793 / 12.0, rotateG!: Float64 = 3.141592653589793 / 12.0 * 2.0, rotateB!: Float64 = 3.141592653589793 / 12.0 * 3.0, scatter!: Float64 = 0.0, blending!: Float64 = 1.0, blendingMode!: Int64 = 1, greyscale!: Bool = false, disable!: Bool = false)
```
构造 HalftonePass

参数: 

|名称|类型|描述|
|---|---|---|
|shape|Int64|网点形状（默认 1=Dot）|
|radius|Float64|网点半径（默认 4）|
|rotateR|Float64|R 通道旋转角（默认 PI/12）|
|rotateG|Float64|G 通道旋转角（默认 PI/12*2）|
|rotateB|Float64|B 通道旋转角（默认 PI/12*3）|
|scatter|Float64|散点抖动（默认 0）|
|blending|Float64|混合强度（默认 1）|
|blendingMode|Int64|混合模式（默认 1=Linear）|
|greyscale|Bool|灰度（默认 false）|
|disable|Bool|禁用透传（默认 false）|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 halftone pass

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
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

### let HALFTONE\_VIEW\_ID\_BASE
```cj
public static let HALFTONE_VIEW_ID_BASE: UInt16 = 227u16
```
分配给本 pass 的 bgfx view ID 段。
+0: halftone pass（RGB 半色调网点处理）
取 227 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
DotScreenPass 226。

### var blendingMode
```cj
public var blendingMode: Int64
```
混合模式（1=Linear 2=Multiply 3=Add 4=Lighter 5=Darker），默认 1

### var blending
```cj
public var blending: Float64
```
混合强度（0=全原色 1=全 halftone），默认 1

### var disable
```cj
public var disable: Bool
```
是否禁用（true=直接透传原图），默认 false

### var greyscale
```cj
public var greyscale: Bool
```
是否灰度输出，默认 false

### var radius
```cj
public var radius: Float64
```
网点半径（像素），默认 4

### var rotateB
```cj
public var rotateB: Float64
```
B 通道网格旋转角（弧度），默认 PI/12*3

### var rotateG
```cj
public var rotateG: Float64
```
G 通道网格旋转角（弧度），默认 PI/12*2

### var rotateR
```cj
public var rotateR: Float64
```
R 通道网格旋转角（弧度），默认 PI/12

### var scatter
```cj
public var scatter: Float64
```
散点抖动量（0=无抖动），默认 0

### var shape
```cj
public var shape: Int64
```
网点形状（1=Dot 2=Ellipse 3=Line 4=Square 5=Diamond），默认 1

