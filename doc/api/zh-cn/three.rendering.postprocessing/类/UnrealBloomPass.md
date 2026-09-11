# 类
## class UnrealBloomPass
```cj
public class UnrealBloomPass <: Pass
```
Bloom 后处理 pass（UnrealBloom 完整 5 级金字塔实现）

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 bloom pass 占用的所有 GPU 资源。

### func init\(Float64,Float64,Float64\)
```cj
public init(strength!: Float64 = 1.0, threshold!: Float64 = 1.0, radius!: Float64 = 0.4)
```
构造 BgfxUnrealBloomPass。

参数: 

|名称|类型|描述|
|---|---|---|
|strength|Float64|Bloom 强度|
|threshold|Float64|亮度阈值|
|radius|Float64|Bloom 半径|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 Bloom pass。

流程（对照 UnrealBloomPass.render）：
1. 亮度提取 → bright RT
2. 5 级高斯金字塔（水平+垂直模糊）
3. composite → renderTargetsHorizontal[0]
4. blend → writeBuffer（加性叠加）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（最终 bloom 结果写入这里）|
|readBuffer|FrameBufferHandle|读 buffer（上一 pass 的场景渲染结果）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸，创建/重建所有 RT。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let BLOOM\_VIEW\_ID\_BASE
```cj
public static let BLOOM_VIEW_ID_BASE: UInt16 = 200u16
```
分配给本 pass 的 bgfx view ID 段。
+0: 亮度提取
+1..+10: 5 级 × (水平+垂直)
+11: composite
+12: blend（写屏幕）
取 200 起避开阴影（64+）/SSAO（160+）段。

### let bloomFactors
```cj
public let bloomFactors: Array < Float64 >=[1.0, 0.8, 0.6, 0.4, 0.2]
```
各级 bloom 因子（大 mip 贡献小）。

### let kernelSizeArray
```cj
public let kernelSizeArray: Array < Int64 >=[6, 10, 14, 18, 22]
```
各级高斯核半径，逐级递增。

### let nMips
```cj
public let nMips: Int64 = 5
```
金字塔级数（固定 5）。

### var radius
```cj
public var radius: Float64
```
Bloom 半径（0~1）

### var strength
```cj
public var strength: Float64
```
Bloom 强度

### var threshold
```cj
public var threshold: Float64
```
亮度阈值（超过此亮度才贡献 bloom）

