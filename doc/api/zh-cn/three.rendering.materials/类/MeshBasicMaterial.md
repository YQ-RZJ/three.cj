# 类
## class MeshBasicMaterial
```cj
public class MeshBasicMaterial <: Material
```
网格基础材质，以简单方式（无光照）渲染几何体

### func copy\(MeshBasicMaterial,Bool\)
```cj
public func copy(source: MeshBasicMaterial, recursive!: Bool = true): MeshBasicMaterial
```
将给定MeshBasicMaterial的属性复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|MeshBasicMaterial|源材质recursive 是否递归复制|
|recursive|Bool||

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的网格基础材质

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
透明度贴图

### var aoMapIntensity
```cj
public var aoMapIntensity: Float64
```
环境光遮蔽贴图强度，默认1

### var aoMap
```cj
public var aoMap: Option < Texture >
```
环境光遮蔽贴图

### var combine
```cj
public var combine: Int64
```
环境贴图与漫反射的组合方式

### var lightMapIntensity
```cj
public var lightMapIntensity: Float64
```
光照贴图强度，默认1

### var lightMap
```cj
public var lightMap: Option < Texture >
```
光照贴图

### var map
```cj
public var map: Option < Texture >
```
漫反射颜色贴图

### var reflectivity
```cj
public var reflectivity: Float64
```
环境贴图反射强度，默认1

### var refractionRatio
```cj
public var refractionRatio: Float64
```
折射率，默认0.98

### var specularMap
```cj
public var specularMap: Option < Texture >
```
镜面高光贴图

### var wireframeLinewidth
```cj
public var wireframeLinewidth: Float64
```
线框线条粗细，默认1

