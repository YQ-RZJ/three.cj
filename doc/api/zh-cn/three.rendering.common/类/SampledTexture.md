# 类
## class SampledTexture
```cj
public open class SampledTexture <: Sampler
```
采样纹理类，关联纹理与采样器参数

### func init\(Texture\)
```cj
public init(texture: Texture)
```
使用纹理对象构造采样纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理对象|

### func init\(Texture,String\)
```cj
public init(texture: Texture, name: String)
```
使用纹理对象和名称构造采样纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理对象name 纹理名称|
|name|String||

### var bindGroupIndex
```cj
public var bindGroupIndex: Int64
```
绑定组索引

### var name
```cj
public var name: String
```
纹理名称

### var texture
```cj
public var texture: Texture
```
关联的纹理对象

