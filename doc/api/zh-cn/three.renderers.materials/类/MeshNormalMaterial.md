# 类
## class MeshNormalMaterial
```cj
public class MeshNormalMaterial <: Material
```
法线材质，将法线向量映射为RGB颜色进行渲染

### func init\(\)
```cj
public init()
```
构造一个新的法线材质

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

### var displacementBias
```cj
public var displacementBias: Float64
```
位移贴图偏移量，默认0

### var displacementMap
```cj
public var displacementMap: Option < Texture >
```
位移贴图

### var displacementScale
```cj
public var displacementScale: Float64
```
位移贴图缩放，默认1

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

