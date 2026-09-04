# 类
## class RenderTarget
```cj
public open class RenderTarget <: EventDispatcher
```
渲染目标类，存储离屏渲染缓冲描述

### func clone\(\)
```cj
public open func clone(): RenderTarget
```
返回从此实例复制值的新渲染目标

返回: 

- 此实例的克隆

### func copy\(RenderTarget\)
```cj
public func copy(source: RenderTarget): RenderTarget
```
将给定渲染目标的设置复制到此实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|RenderTarget|要复制的渲染目标|

返回: 

- 当前实例的引用

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放此实例分配的 GPU 相关资源

### func getDepthTexture\(\)
```cj
public func getDepthTexture():?IRenderTargetTexture
```
获取深度纹理

返回: 

- 深度纹理

### func getTexture\(\)
```cj
public func getTexture(): Option < IRenderTargetTexture >
```
获取默认颜色附件纹理

返回: 

- 默认颜色附件纹理（textures[0]）

### func init\(Int64,Int64,?RenderTargetOptions\)
```cj
public init(width!: Int64 = 1, height!: Int64 = 1, options!:?RenderTargetOptions = None)
```
构造新的渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|渲染目标宽度，默认为 1height 渲染目标高度，默认为 1options 渲染目标选项，默认为空（使用默认值）|
|height|Int64||
|options|?RenderTargetOptions||

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
兼容重载：2 参数形式（options 为空）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### func setDepthTexture\(?IRenderTargetTexture\)
```cj
public func setDepthTexture(current:?IRenderTargetTexture): Unit
```
设置深度纹理，会解绑旧纹理的反向引用并建立新纹理的反向引用

参数: 

|名称|类型|描述|
|---|---|---|
|current|?IRenderTargetTexture|新的深度纹理|

### func setSize\(Int64,Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64, depth!: Int64 = 1): Unit
```
设置此渲染目标的大小

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|新的宽度height 新的高度depth 新的深度，默认为 1|
|height|Int64||
|depth|Int64||

### func setTexture\(Option<IRenderTargetTexture>\)
```cj
public func setTexture(value: Option < IRenderTargetTexture >): Unit
```
设置默认颜色附件纹理

参数: 

|名称|类型|描述|
|---|---|---|
|value|Option<IRenderTargetTexture>|纹理值|

### var depthBuffer
```cj
public var depthBuffer: Bool
```
是否分配深度缓冲

### var depth
```cj
public var depth: Int64
```
渲染目标深度

### var height
```cj
public var height: Int64
```
渲染目标高度

### var kind
```cj
public var kind: String
```
几何体类型字符串

### var multiview
```cj
public var multiview: Bool
```
是否用于 multiview 渲染（WebGL OVR_multiview2 扩展）

### var resolveColorBuffer
```cj
public var resolveColorBuffer: Bool
```
是否解析颜色缓冲（仅多采样渲染目标相关），设为 false 时颜色附件不接收解析输出

### var resolveDepthBuffer
```cj
public var resolveDepthBuffer: Bool
```
是否解析深度缓冲（仅多采样渲染目标相关），设为 false 节省内存带宽

### var resolveStencilBuffer
```cj
public var resolveStencilBuffer: Bool
```
是否解析模板缓冲

### var samples
```cj
public var samples: Int64
```
MSAA 采样数，0 表示禁用 MSAA

### var scissorTest
```cj
public var scissorTest: Bool
```
是否在渲染到此目标时启用 scissor 测试

### var scissor
```cj
public var scissor: Vector4
```
渲染目标内的矩形裁剪区域，区域外的片元会被丢弃

### var stencilBuffer
```cj
public var stencilBuffer: Bool
```
是否分配模板缓冲

### var storeMultisampledColorBuffer
```cj
public var storeMultisampledColorBuffer: Bool
```
是否存储多采样颜色缓冲，设为 false 在 render pass 结束后丢弃多采样数据

### var storeMultisampledDepthBuffer
```cj
public var storeMultisampledDepthBuffer: Bool
```
是否存储多采样深度缓冲，设为 false 节省带宽；WebGPU 中若需采样多采样深度纹理须为 true

### var storeMultisampledStencilBuffer
```cj
public var storeMultisampledStencilBuffer: Bool
```
是否存储多采样模板缓冲

### var textures
```cj
public var textures: ArrayList < Option < IRenderTargetTexture >>
```
纹理数组，每个颜色附件用一个独立纹理表示，至少有一个默认颜色附件条目

### var useArrayDepthTexture
```cj
public var useArrayDepthTexture: Bool
```
是否创建为分层深度纹理（独立于 multiview）

### var userData
```cj
public var userData: HashMap < String, Any >
```
自定义数据存储对象

### var viewport
```cj
public var viewport: Vector4
```
渲染目标的视口矩形

### var width
```cj
public var width: Int64
```
渲染目标宽度

