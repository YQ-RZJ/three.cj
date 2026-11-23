# 类
## class MeshLambertMaterial
```cj
public class MeshLambertMaterial <: Material
```
Lambert材质，支持自发光、环境贴图和flatShading

### func init\(\)
```cj
public init()
```
构造一个新的Lambert材质

### var combine
```cj
public var combine: Int64
```
环境贴图与漫反射的组合方式

### var emissiveIntensity
```cj
public var emissiveIntensity: Float64
```
自发光强度，默认1

### var emissiveMap
```cj
public var emissiveMap: Option < Texture >
```
自发光贴图

### var emissive
```cj
public var emissive: Color
```
自发光颜色，默认0x000000

### var map
```cj
public var map: Option < Texture >
```
漫反射贴图

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

