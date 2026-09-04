# 类
## class BgfxCapabilities
```cj
public class BgfxCapabilities
```
bgfx 渲染能力

### func getMaxAnisotropy\(\)
```cj
public func getMaxAnisotropy(): Int64
```
获取最大各向异性过滤级别

返回: 

- 最大各向异性过滤级别

### func getMaxPrecision\(String\)
```cj
public static func getMaxPrecision(precision!: String): String
```
获取最大着色器精度

参数: 

|名称|类型|描述|
|---|---|---|
|precision|String|请求的精度级别|

返回: 

- 实际支持的精度级别

### func init\(BgfxExtensions,String,Bool,Bool\)
```cj
public init(extensions!: BgfxExtensions = BgfxExtensions(), precision!: String = "highp", logarithmicDepthBuffer!: Bool = false, reversedDepthBuffer!: Bool = false)
```
构造渲染能力实例

参数: 

|名称|类型|描述|
|---|---|---|
|extensions|BgfxExtensions|扩展兼容层实例precision 着色器精度（默认 highp）logarithmicDepthBuffer 是否支持对数深度缓冲reversedDepthBuffer 是否支持反向深度缓冲|
|precision|String||
|logarithmicDepthBuffer|Bool||
|reversedDepthBuffer|Bool||

### func initialize\(\)
```cj
public func initialize(): Unit
```
从 bgfx Caps 初始化能力信息

### func textureFormatReadable\(Int64\)
```cj
public func textureFormatReadable(textureFormat: Int64): Bool
```
检查纹理格式是否可读

参数: 

|名称|类型|描述|
|---|---|---|
|textureFormat|Int64|纹理格式|

返回: 

- 是否可读

### func textureTypeReadable\(Int64\)
```cj
public func textureTypeReadable(textureType: Int64): Bool
```
检查纹理类型是否可读

参数: 

|名称|类型|描述|
|---|---|---|
|textureType|Int64|纹理类型|

返回: 

- 是否可读

### var logarithmicDepthBuffer
```cj
public var logarithmicDepthBuffer: Bool
```
是否支持对数深度缓冲

### var maxAnisotropy
```cj
public var maxAnisotropy: Int64
```
最大各向异性过滤级别

### var maxAttributes
```cj
public var maxAttributes: Int64
```
最大顶点属性数

### var maxCubemapSize
```cj
public var maxCubemapSize: Int64
```
最大立方体贴图尺寸

### var maxFragmentUniforms
```cj
public var maxFragmentUniforms: Int64
```
最大片段 Uniform 向量数

### var maxSamples
```cj
public var maxSamples: Int64
```
最大 MSAA 采样数

### var maxTextureSize
```cj
public var maxTextureSize: Int64
```
最大纹理尺寸

### var maxTextures
```cj
public var maxTextures: Int64
```
最大纹理单元数

### var maxVaryings
```cj
public var maxVaryings: Int64
```
最大 Varying 向量数

### var maxVertexTextures
```cj
public var maxVertexTextures: Int64
```
最大顶点纹理单元数

### var maxVertexUniforms
```cj
public var maxVertexUniforms: Int64
```
最大顶点 Uniform 向量数

### var precision
```cj
public var precision: String
```
着色器精度（bgfx 始终支持高精度）

### var reversedDepthBuffer
```cj
public var reversedDepthBuffer: Bool
```
是否支持反向深度缓冲

