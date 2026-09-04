# 类
## class PointsMaterial
```cj
public class PointsMaterial <: Material
```
点材质，用于点云渲染，支持点大小和距离衰减

### func copy\(PointsMaterial,Bool\)
```cj
public func copy(source: PointsMaterial, recursive!: Bool = true): PointsMaterial
```
将给定点材质实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|PointsMaterial|源材质recursive 是否递归复制|
|recursive|Bool||

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的点材质

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
透明度贴图

### var map
```cj
public var map: Option < Texture >
```
点纹理贴图

### var sizeAttenuation
```cj
public var sizeAttenuation: Bool
```
是否随距离衰减，默认true

### var size
```cj
public var size: Float64
```
点大小，默认1

