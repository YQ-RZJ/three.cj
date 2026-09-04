# 类
## class VideoTexture
```cj
public open class VideoTexture <: Texture
```
Video 纹理类

### func clone\(\)
```cj
public open override func clone(): Texture
```
返回一个与本实例值相同的新 Video 纹理实例

返回: 

- 克隆的 Video 纹理实例

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放本实例分配的 GPU 相关资源

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64\)
```cj
public init(video: Array < UInt8 >, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1)
```
构造一个新的 Video 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|video|Array<UInt8>|Video 像素数据mapping UV 映射模式，默认 UVMappingwrapS 水平环绕模式，默认 ClampToEdgeWrappingwrapT 垂直环绕模式，默认 ClampToEdgeWrappingmagFilter 放大过滤器，默认 LinearFilterminFilter 缩小过滤器，默认 LinearFilterformat 像素格式，默认 RGBAFormattype 像素数据类型，默认 UnsignedByteTypeanisotropy 各向异性等级，默认 1|
|mapping|Int64||
|wrapS|Int64||
|wrapT|Int64||
|magFilter|Int64||
|minFilter|Int64||
|format|Int64||
|`type`|Int64||
|anisotropy|Int64||

### func update\(\)
```cj
public func update(): Unit
```
更新纹理内容，bgfx4cj 下为 stub（像素数据由调用方通过 image 字段直接传入）

