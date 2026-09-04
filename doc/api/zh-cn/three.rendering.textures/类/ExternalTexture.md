# 类
## class ExternalTexture
```cj
public open class ExternalTexture <: Texture
```
外部纹理类

### func clone\(\)
```cj
public override func clone(): Texture
```
返回一个与本实例值相同的新外部纹理实例

返回: 

- 克隆的外部纹理实例

### func copy\(Texture\)
```cj
public override func copy(source: Texture): Texture
```
将给定外部纹理实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Texture|源纹理|

返回: 

- 当前实例

### func init\(?TextureHandle\)
```cj
public init(sourceTexture!:?TextureHandle = None)
```
构造一个新的外部纹理

参数: 

|名称|类型|描述|
|---|---|---|
|sourceTexture|?TextureHandle|外部源纹理，默认 None|

### var sourceTexture
```cj
public var sourceTexture: Option < TextureHandle >
```
外部纹理缓冲引用（渲染器内部按平台具体解释）

