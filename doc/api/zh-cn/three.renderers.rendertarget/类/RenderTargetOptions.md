# 类
## class RenderTargetOptions
```cj
public class RenderTargetOptions
```
渲染目标选项

### func init\(\)
```cj
public init()
```
构造渲染目标选项，使用默认值

### var \`type\`
```cj
public var `type`: Int64
```
纹理数据类型

### var anisotropy
```cj
public var anisotropy: Int64
```
各向异性过滤值

### var colorSpace
```cj
public var colorSpace: String
```
颜色空间

### var count
```cj
public var count: Int64
```
颜色附件数量

### var depthBuffer
```cj
public var depthBuffer: Bool
```
是否分配深度缓冲

### var depthTexture
```cj
public var depthTexture:?IRenderTargetTexture
```
深度纹理引用（可选）

### var depth
```cj
public var depth: Int64
```
纹理深度

### var format
```cj
public var format: Int64
```
纹理格式

### var generateMipmaps
```cj
public var generateMipmaps: Bool
```
是否生成 mipmap

### var internalFormat
```cj
public var internalFormat:?String
```
内部格式（可选）

### var magFilter
```cj
public var magFilter: Int64
```
放大过滤模式

### var minFilter
```cj
public var minFilter: Int64
```
缩小过滤模式

### var multiview
```cj
public var multiview: Bool
```
是否用于 multiview 渲染

### var resolveColorBuffer
```cj
public var resolveColorBuffer: Bool
```
是否解析颜色缓冲

### var resolveDepthBuffer
```cj
public var resolveDepthBuffer: Bool
```
是否解析深度缓冲

### var resolveStencilBuffer
```cj
public var resolveStencilBuffer: Bool
```
是否解析模板缓冲

### var samples
```cj
public var samples: Int64
```
MSAA 采样数，0 表示禁用

### var stencilBuffer
```cj
public var stencilBuffer: Bool
```
是否分配模板缓冲

### var storeMultisampledColorBuffer
```cj
public var storeMultisampledColorBuffer: Bool
```
是否存储多采样颜色缓冲

### var storeMultisampledDepthBuffer
```cj
public var storeMultisampledDepthBuffer: Bool
```
是否存储多采样深度缓冲

### var storeMultisampledStencilBuffer
```cj
public var storeMultisampledStencilBuffer: Bool
```
是否存储多采样模板缓冲

### var useArrayDepthTexture
```cj
public var useArrayDepthTexture: Bool
```
是否创建为分层深度纹理

### var wrapR
```cj
public var wrapR: Int64
```
R 轴包裹模式

### var wrapS
```cj
public var wrapS: Int64
```
S 轴包裹模式

### var wrapT
```cj
public var wrapT: Int64
```
T 轴包裹模式

