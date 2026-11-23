# 类
## class ShadowBlitMaterial
```cj
public class ShadowBlitMaterial <: Material
```
阴影贴图全屏blit材质，用全屏四边形采样shadowMap铺满屏幕

### func copy\(ShadowBlitMaterial\)
```cj
public func copy(source: ShadowBlitMaterial): ShadowBlitMaterial
```
将给定ShadowBlitMaterial的属性复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|ShadowBlitMaterial|源材质|

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的阴影贴图全屏blit材质

