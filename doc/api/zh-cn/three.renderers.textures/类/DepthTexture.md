# 类
## class DepthTexture
```cj
public open class DepthTexture <: Texture
```
深度纹理类

### func copy\(Texture\)
```cj
public override func copy(source: Texture): Texture
```
将给定深度纹理实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Texture|源纹理|

返回: 

- 当前实例

### func init\(Int64,Int64,Int64\)
```cj
public init(width: Int64, height: Int64, `type`!: Int64 = UnsignedIntType)
```
构造一个新的深度纹理

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|纹理宽度（像素）height 纹理高度（像素）type 像素数据类型，默认 UnsignedIntType|
|height|Int64||
|`type`|Int64||

### var compareFunction
```cj
public var compareFunction: Option < Int64 >
```
深度比较函数（WebGL compareFunction），None 表示无比较

