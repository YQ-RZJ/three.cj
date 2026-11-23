# 类
## class MeshMatcapMaterial
```cj
public class MeshMatcapMaterial <: Material
```
Matcap材质，使用材质捕获贴图进行渲染

### func init\(\)
```cj
public init()
```
构造一个新的Matcap材质

### var bumpMap
```cj
public var bumpMap: Option < Texture >
```
凹凸贴图

### var bumpScale
```cj
public var bumpScale: Float64
```
凹凸贴图缩放，默认1

### var map
```cj
public var map: Option < Texture >
```
漫反射贴图

### var matcap
```cj
public var matcap: Option < Texture >
```
材质捕获贴图

### var normalMap
```cj
public var normalMap: Option < Texture >
```
法线贴图

### var normalScale
```cj
public var normalScale: Vector2
```
法线贴图缩放，默认(1,1)

