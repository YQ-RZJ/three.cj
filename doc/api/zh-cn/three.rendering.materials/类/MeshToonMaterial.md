# 类
## class MeshToonMaterial
```cj
public class MeshToonMaterial <: Material
```
卡通材质，使用渐变贴图控制明暗分界实现卡通渲染效果

### func init\(\)
```cj
public init()
```
构造一个新的卡通材质

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

### var gradiantMap
```cj
public var gradiantMap: Option < Texture >
```
渐变贴图，控制明暗分界

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

