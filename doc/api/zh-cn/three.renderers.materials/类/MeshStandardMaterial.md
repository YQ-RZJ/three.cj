# 类
## class MeshStandardMaterial
```cj
public class MeshStandardMaterial <: Material
```
基于PBR的标准材质，支持金属度/粗糙度工作流

### func init\(\)
```cj
public init()
```
构造一个新的标准PBR材质

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
环境光遮蔽贴图（红色通道，需要第二套UV）

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

### var displacementScale
```cj
public var displacementScale: Float64
```
位移贴图缩放，默认1

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

### var lightMapIntensity
```cj
public var lightMapIntensity: Float64
```
光照贴图强度，默认1

### var lightMap
```cj
public var lightMap: Option < Texture >
```
光照贴图（需要第二套UV）

### var map
```cj
public var map: Option < Texture >
```
漫反射颜色贴图

### var metalnessMap
```cj
public var metalnessMap: Option < Texture >
```
金属度贴图（蓝色通道）

### var metalness
```cj
public var metalness: Float64
```
金属度，默认0

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

### var roughnessMap
```cj
public var roughnessMap: Option < Texture >
```
粗糙度贴图（绿色通道）

### var roughness
```cj
public var roughness: Float64
```
粗糙度，默认1

