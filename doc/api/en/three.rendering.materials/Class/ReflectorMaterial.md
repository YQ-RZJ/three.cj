# Class
## class ReflectorMaterial
```cj
public class ReflectorMaterial <: Material
```
Reflector material, dedicated to GroundReflector

### func copy\(ReflectorMaterial\)
```cj
public func copy(source: ReflectorMaterial): ReflectorMaterial
```
Copy the properties from the given ReflectorMaterial to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|ReflectorMaterial|Source material|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new reflector material

### var distanceAttenuation
```cj
public var distanceAttenuation: Bool = true
```
Distance attenuation toggle, default true, only effective when useDepthTexture=true

### var fresnelCoe
```cj
public var fresnelCoe: Float64 = 1.0
```
Fresnel coefficient (computed each frame by doRender), default 1

### var fresnel
```cj
public var fresnel: Bool = true
```
Fresnel toggle, default true, only effective when useDepthTexture=true

### var maxDistance
```cj
public var maxDistance: Float64 = 180.0
```
Maximum reflection distance (distance attenuation upper bound), default 180

### var reflectorColor
```cj
public var reflectorColor: Color = Color(0x7f, 0x7f, 0x7f)
```
Reflection map blend color (RGB), default 0x7F7F7F

### var resolutionX
```cj
public var resolutionX: Float64 = 1.0
```
Resolution width, default 1

### var resolutionY
```cj
public var resolutionY: Float64 = 1.0
```
Resolution height, default 1

### var tDepth
```cj
public var tDepth: TextureHandle = INVALID_TEXTURE_HANDLE
```
Reflection RT depth texture handle (tDepth, RGBA32F stores NDC depth, effective when useDepthTexture=true)

### var tDiffuse
```cj
public var tDiffuse: TextureHandle = INVALID_TEXTURE_HANDLE
```
Reflection RT color texture handle (tDiffuse)

### var textureMatrix
```cj
public var textureMatrix: Matrix4 = Matrix4()
```
Texture projection matrix (reflection RT → ground UV)

### var useDepthTexture
```cj
public var useDepthTexture: Bool = false
```
Whether to use depth texture, default false

### var virtualCameraFar
```cj
public var virtualCameraFar: Float64 = 100.0
```
Mirror virtual camera far, default 100

### var virtualCameraMatrixWorld
```cj
public var virtualCameraMatrixWorld: Matrix4 = Matrix4()
```
Mirror virtual camera world matrix

### var virtualCameraNear
```cj
public var virtualCameraNear: Float64 = 0.1
```
Mirror virtual camera near, default 0.1

### var virtualCameraProjectionMatrixInverse
```cj
public var virtualCameraProjectionMatrixInverse: Matrix4 = Matrix4()
```
Mirror virtual camera projection inverse matrix

### var virtualCameraProjectionMatrix
```cj
public var virtualCameraProjectionMatrix: Matrix4 = Matrix4()
```
Mirror virtual camera projection matrix

