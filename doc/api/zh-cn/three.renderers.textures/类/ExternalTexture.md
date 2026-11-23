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

### func init\(\)
```cj
public init()
```
构造一个无外部源的外部纹理（句柄源仅经 copy 复制，为模块内受控路径）

