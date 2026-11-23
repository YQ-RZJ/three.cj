# 类
## class SpriteMaterial
```cj
public class SpriteMaterial <: Material
```
Sprite材质，用于精灵图渲染，支持尺寸衰减和UV旋转

### func copy\(SpriteMaterial,Bool\)
```cj
public func copy(source: SpriteMaterial, recursive!: Bool = true): SpriteMaterial
```
将给定Sprite材质实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|SpriteMaterial|源材质recursive 是否递归复制|
|recursive|Bool||

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的Sprite材质

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
透明度贴图

### var map
```cj
public var map: Option < Texture >
```
Sprite纹理贴图

### var rotation
```cj
public var rotation: Float64
```
UV旋转弧度，默认0

### var sizeAttenuation
```cj
public var sizeAttenuation: Bool
```
是否随距离衰减尺寸，默认true

