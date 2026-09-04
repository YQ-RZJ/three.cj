# 类
## class PMREMGenerator
```cj
public class PMREMGenerator
```
PMREM 生成器类

### func fromScene\(IScene,Float64,Float64,Float64\)
```cj
public func fromScene(scene: IScene, sigma: Float64, near: Float64, far: Float64): Any
```
从场景生成预过滤 Mipmap 环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|scene|IScene|场景接口sigma 模糊强度near 近裁剪面far 远裁剪面|
|sigma|Float64||
|near|Float64||
|far|Float64||

返回: 

- 生成的环境贴图

### func init\(\)
```cj
public init()
```
构造 PMREM 生成器

### var kind
```cj
public var kind: String
```
类型标签

