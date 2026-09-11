# 类
## class BloomPass
```cj
public class BloomPass <: Pass
```
Bloom 后处理 pass（简单版）

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 bloom pass 占用的所有 GPU 资源。

### func init\(Float64,Int64,Float64\)
```cj
public init(strength!: Float64 = 1.0, kernelSize!: Int64 = 25, sigma!: Float64 = 4.0)
```
构造 BgfxBloomPass。

参数: 

|名称|类型|描述|
|---|---|---|
|strength|Float64|Bloom 强度（默认 1.0）|
|kernelSize|Int64|卷积核大小（默认 25，shader 循环次数）|
|sigma|Float64|高斯 sigma（默认 4，决定核实际展宽）needsSwap=false（结果直接合成回 readBuffer，不依赖 composer swap）。|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 Bloom pass。

流程：
1. 水平卷积：readBuffer → renderTargetX
2. 垂直卷积：renderTargetX → renderTargetY
3. 合成：scene + strength × blur → 屏幕（renderToScreen）或 readBuffer

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer|
|readBuffer|FrameBufferHandle|读 buffer（上一 pass 的场景渲染结果）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸，创建/重建中间 RT。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let BLOOM\_VIEW\_ID\_BASE
```cj
public static let BLOOM_VIEW_ID_BASE: UInt16 = 237u16
```
分配给本 pass 的 bgfx view ID 段。
+0: 水平卷积（readBuffer → renderTargetX）
+1: 垂直卷积（renderTargetX → renderTargetY）
+2: 合成（scene + strength × blur → 屏幕 / readBuffer）
取 237 起避开既有硬编码段：SSAO 160 / SSR 176 / Bloom(Unreal) 200~212 /
Mask 220 / Afterimage 221~223 / Outline 223 / Film 224 / Glitch 225 /
DotScreen 226 / Halftone 227 / Bokeh 228~229 / Pixelated 230~233 /
Transition 234~236。

### var kernelSize
```cj
public var kernelSize: Int64
```
卷积核大小（shader 循环次数）

### var sigma
```cj
public var sigma: Float64
```
高斯 sigma（控制核展宽，buildKernel 用）

### var strength
```cj
public var strength: Float64
```
Bloom 强度（合成时 blur 乘数）

