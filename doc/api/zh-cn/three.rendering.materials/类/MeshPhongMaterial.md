# 类
## class MeshPhongMaterial
```cj
public class MeshPhongMaterial <: Material
```
Phong材质，支持镜面高光和光泽度

### func init\(\)
```cj
public init()
```
构造一个新的Phong材质

### var combine
```cj
public var combine: Int64
```
环境贴图与漫反射的组合方式

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

### var shininess
```cj
public var shininess: Float64
```
光泽度，默认30

### var specularMap
```cj
public var specularMap: Option < Texture >
```
镜面高光贴图

### var specular
```cj
public var specular: Color
```
镜面高光颜色，默认0x111111

