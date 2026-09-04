# 类
## class ReflectorMaterial
```cj
public class ReflectorMaterial <: Material
```
反射面材质，GroundReflector专用

### func copy\(ReflectorMaterial\)
```cj
public func copy(source: ReflectorMaterial): ReflectorMaterial
```
将给定ReflectorMaterial的属性复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|ReflectorMaterial|源材质|

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的反射面材质

### var distanceAttenuation
```cj
public var distanceAttenuation: Bool = true
```
距离衰减开关，默认true，仅useDepthTexture=true时生效

### var fresnelCoe
```cj
public var fresnelCoe: Float64 = 1.0
```
菲涅尔系数（doRender每帧计算），默认1

### var fresnel
```cj
public var fresnel: Bool = true
```
菲涅尔开关，默认true，仅useDepthTexture=true时生效

### var maxDistance
```cj
public var maxDistance: Float64 = 180.0
```
最大反射距离（距离衰减上界），默认180

### var reflectorColor
```cj
public var reflectorColor: Color = Color(0x7f, 0x7f, 0x7f)
```
反射贴图混合色（RGB），默认0x7F7F7F

### var resolutionX
```cj
public var resolutionX: Float64 = 1.0
```
分辨率宽度，默认1

### var resolutionY
```cj
public var resolutionY: Float64 = 1.0
```
分辨率高度，默认1

### var tDepth
```cj
public var tDepth: TextureHandle = INVALID_TEXTURE_HANDLE
```
反射RT的深度纹理句柄（tDepth，RGBA32F存NDC深度，useDepthTexture=true时有效）

### var tDiffuse
```cj
public var tDiffuse: TextureHandle = INVALID_TEXTURE_HANDLE
```
反射RT的color纹理句柄（tDiffuse）

### var textureMatrix
```cj
public var textureMatrix: Matrix4 = Matrix4()
```
纹理投影矩阵（反射RT→地面UV）

### var useDepthTexture
```cj
public var useDepthTexture: Bool = false
```
是否使用深度纹理，默认false

### var virtualCameraFar
```cj
public var virtualCameraFar: Float64 = 100.0
```
镜像虚拟相机far，默认100

### var virtualCameraMatrixWorld
```cj
public var virtualCameraMatrixWorld: Matrix4 = Matrix4()
```
镜像虚拟相机世界矩阵

### var virtualCameraNear
```cj
public var virtualCameraNear: Float64 = 0.1
```
镜像虚拟相机near，默认0.1

### var virtualCameraProjectionMatrixInverse
```cj
public var virtualCameraProjectionMatrixInverse: Matrix4 = Matrix4()
```
镜像虚拟相机投影逆矩阵

### var virtualCameraProjectionMatrix
```cj
public var virtualCameraProjectionMatrix: Matrix4 = Matrix4()
```
镜像虚拟相机投影矩阵

