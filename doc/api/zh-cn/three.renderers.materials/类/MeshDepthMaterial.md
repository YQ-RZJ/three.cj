# 类
## class MeshDepthMaterial
```cj
public class MeshDepthMaterial <: Material
```
基于深度绘制几何体的材质

### func copy\(MeshDepthMaterial\)
```cj
public func copy(source: MeshDepthMaterial): MeshDepthMaterial
```
将给定MeshDepthMaterial的属性复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|MeshDepthMaterial|源材质|

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的网格深度材质

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
Alpha贴图，灰度纹理控制表面透明度

### var depthPacking
```cj
public var depthPacking: Int64
```
深度打包类型，默认BasicDepthPacking

### var displacementBias
```cj
public var displacementBias: Float64
```
位移贴图偏移量，默认0

### var displacementMap
```cj
public var displacementMap: Option < Texture >
```
位移贴图，影响网格顶点位置

### var displacementScale
```cj
public var displacementScale: Float64
```
位移贴图影响强度，默认1

### var map
```cj
public var map: Option < Texture >
```
颜色贴图

### var wireframeLinewidth
```cj
public var wireframeLinewidth: Float64
```
线框线条粗细，默认1

