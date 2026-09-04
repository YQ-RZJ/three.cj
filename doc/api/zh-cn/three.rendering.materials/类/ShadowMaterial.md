# 类
## class ShadowMaterial
```cj
public class ShadowMaterial <: Material
```
阴影材质，可以接收阴影但本身完全透明

### func copy\(ShadowMaterial\)
```cj
public func copy(source: ShadowMaterial): ShadowMaterial
```
将给定ShadowMaterial的属性复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|ShadowMaterial|源材质|

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的阴影材质

