# 类
## class Texture
```cj
public open class Texture <: EventDispatcher & IRenderTargetTexture & IBackground & ILoadResult
```
纹理资源基类

### func clone\(\)
```cj
public open func clone(): Texture
```
返回一个与本实例值相同的新纹理实例

返回: 

- 克隆的纹理实例

### func copy\(Texture\)
```cj
public open func copy(source: Texture): Texture
```
将给定纹理实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Texture|源纹理|

返回: 

- 当前实例

### func dispose\(\)
```cj
public open func dispose(): Unit
```
释放本实例分配的 GPU 相关资源，并派发 dispose 事件

### func getIsData3DTexture\(\)
```cj
public open func getIsData3DTexture(): Bool
```
是否 3D 数据纹理（子类 override 为 true）

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(image!: Array < UInt8 >= Array < UInt8 >(), width!: Int64 = 0, height!: Int64 = 0, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, mapping!: Int64 = UVMapping, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
构造一个新的纹理

参数: 

|名称|类型|描述|
|---|---|---|
|image|Array<UInt8>|像素数组，默认空width 贴图宽度（像素），默认 0height 贴图高度（像素），默认 0wrapS 水平环绕模式，默认 ClampToEdgeWrappingwrapT 垂直环绕模式，默认 ClampToEdgeWrappingmagFilter 放大过滤器，默认 LinearFilterminFilter 缩小过滤器，默认 LinearMipmapLinearFiltermapping UV 映射模式，默认 UVMappingformat 像素格式，默认 RGBAFormattype 像素数据类型，默认 UnsignedByteTypeanisotropy 各向异性等级，默认 1colorSpace 颜色空间，默认空|
|width|Int64||
|height|Int64||
|wrapS|Int64||
|wrapT|Int64||
|magFilter|Int64||
|minFilter|Int64||
|mapping|Int64||
|format|Int64||
|`type`|Int64||
|anisotropy|Int64||
|colorSpace|String||

### func rtClone\(\)
```cj
public func rtClone(): IRenderTargetTexture
```
IRenderTargetTexture 接口：克隆自身

### func rtIsData3DTexture\(\)
```cj
public func rtIsData3DTexture(): Bool
```
IRenderTargetTexture 接口：是否 3D 数据纹理

### func setValues\(HashMap<String,Any>\)
```cj
public func setValues(values: HashMap < String, Any >): Unit
```
用 HashMap 中的值批量设置本纹理的字段（键名匹配字段名）

参数: 

|名称|类型|描述|
|---|---|---|
|values|HashMap<String,Any>|字段值字典|

### func transformUv\(Vector2,Vector2\)
```cj
public func transformUv(uv: Vector2, target: Vector2): Vector2
```
将 UV 坐标按本纹理的 offset/repeat/center/rotation 变换后写入 target

参数: 

|名称|类型|描述|
|---|---|---|
|uv|Vector2|待变换的 UV 坐标target 接收结果的目标向量|
|target|Vector2||

返回: 

- 变换后的 UV 坐标

### func updateMatrix\(\)
```cj
public func updateMatrix(): Unit
```
重算 UV 变换矩阵（按 offset/repeat/rotation/center）

### func update\(\)
```cj
public open func update(): Unit
```
通知渲染器纹理内容已变，下次 render 会重传 GPU 纹理

### prop needsUpdate: Bool
```cj
public mut prop needsUpdate: Bool
```
渲染器内部增量更新标志，true 时下次 render 会重传 GPU 纹理

### prop rtDepth: Int64
```cj
public mut prop rtDepth: Int64
```
IRenderTargetTexture 接口：贴图深度

### prop rtHeight: Int64
```cj
public mut prop rtHeight: Int64
```
IRenderTargetTexture 接口：贴图高度

### prop rtIsArrayTexture: Bool
```cj
public mut prop rtIsArrayTexture: Bool
```
IRenderTargetTexture 接口：是否数组纹理

### prop rtIsRenderTargetTexture: Bool
```cj
public mut prop rtIsRenderTargetTexture: Bool
```
IRenderTargetTexture 接口：是否渲染目标纹理

### prop rtRenderTarget:?RenderTarget
```cj
public mut prop rtRenderTarget:?RenderTarget
```
IRenderTargetTexture 接口：渲染目标反向引用

### prop rtWidth: Int64
```cj
public mut prop rtWidth: Int64
```
IRenderTargetTexture 接口：贴图宽度

### var \`type\`
```cj
public var `type`: Int64
```
纹理像素数据类型，默认 UnsignedByteType

### var anisotropy
```cj
public var anisotropy: Int64
```
各向异性采样等级，默认 1

### var center
```cj
public var center: Vector2
```
UV 旋转中心

### var channel
```cj
public var channel: Int64
```
通道偏移（WebGL2/GLSL3 中将某通道重解释为另一通道，0=不偏移）

### var colorSpace
```cj
public var colorSpace: String
```
颜色空间，默认空（按渲染器全局）

### var depth
```cj
public var depth: Int64
```
贴图深度（3D 纹理用，默认 1）

### var flipY
```cj
public var flipY: Bool
```
上传时是否沿 Y 轴翻转

### var format
```cj
public var format: Int64
```
纹理像素格式，默认 RGBAFormat

### var generateMipmaps
```cj
public var generateMipmaps: Bool
```
是否自动生成 mipmap

### var height
```cj
public var height: Int64
```
贴图高度（像素）

### var image
```cj
public var image: Array < UInt8 >
```
贴图数据（像素数组）

### var internalFormat
```cj
public var internalFormat: Option < String >
```
像素格式覆盖（如 "GL_RGBA16F"/"GL_R32F" 等），None 表示由 format+type 自动派生

### var isArrayTexture
```cj
public var isArrayTexture: Bool
```
是否数组纹理

### var isRenderTargetTexture
```cj
public var isRenderTargetTexture: Bool
```
是否渲染目标纹理

### var kind
```cj
public var kind: String
```
类型标签

### var magFilter
```cj
public var magFilter: Int64
```
放大采样过滤器，默认 LinearFilter

### var mapping
```cj
public var mapping: Int64
```
UV 映射模式，默认 UVMapping

### var matrixAutoUpdate
```cj
public var matrixAutoUpdate: Bool
```
是否自动更新 UV 变换矩阵

### var matrix
```cj
public var matrix: Matrix3
```
UV 变换矩阵（3×3）

### var minFilter
```cj
public var minFilter: Int64
```
缩小采样过滤器，默认 LinearMipmapLinearFilter

### var mipmaps
```cj
public var mipmaps: ArrayList < Any >
```
预生成 mipmap 数组（手动 mipmap 时填充）

### var name
```cj
public var name: String
```
用户可命名标签

### var normalized
```cj
public var normalized: Bool
```
是否使用 16 位归一化整数格式，默认 false

### var offset
```cj
public var offset: Vector2
```
UV 偏移

### var premultiplyAlpha
```cj
public var premultiplyAlpha: Bool
```
上传前是否预乘 alpha

### var renderTarget
```cj
public var renderTarget:?RenderTarget
```
渲染目标反向引用

### var repeat
```cj
public var repeat: Vector2
```
UV 重复

### var rotation
```cj
public var rotation: Float64
```
UV 旋转角度（弧度）

### var source
```cj
public var source: Source
```
贴图数据源（持有 data + needsUpdate + version）

### var unpackAlignment
```cj
public var unpackAlignment: Int64
```
像素行对齐字节数（1/2/4/8），默认 4

### var userData
```cj
public var userData: HashMap < String, Any >
```
用户自定义数据容器

### var uuid
```cj
public var uuid: String
```
唯一标识

### var version
```cj
public var version: Int64
```
渲染器内部版本号，每次 update() 递增

### var width
```cj
public var width: Int64
```
贴图宽度（像素）

### var wrapS
```cj
public var wrapS: Int64
```
水平采样环绕模式，默认 ClampToEdgeWrapping

### var wrapT
```cj
public var wrapT: Int64
```
垂直采样环绕模式，默认 ClampToEdgeWrapping

