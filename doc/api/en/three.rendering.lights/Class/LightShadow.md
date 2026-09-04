# Class
## class LightShadow
```cj
public open class LightShadow
```
Abstract base class for light shadow configuration, subclassed by concrete shadow types

### func calculateCascadeSplits\(Int64,Float64,Float64,Float64\)
```cj
public func calculateCascadeSplits(numSplits: Int64, nearClip: Float64, farClip: Float64, splitLambda: Float64): ArrayList < Float64 >
```
Calculate cascade shadow map (CSM) split distances

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numSplits|Int64|Number of cascades (default CSM_CASCADE_COUNT=4)nearClip Main camera near clipping planefarClip Main camera far clipping planesplitLambda Split lambda (0=uniform, 1=logarithmic, default 0.5)|
|nearClip|Float64||
|farClip|Float64||
|splitLambda|Float64||

Return: 

- Split distance array (length=numSplits+1, index 0=nearClip, index numSplits=farClip)

### func clone\(\)
```cj
public func clone(): LightShadow
```
Return a new light shadow instance with the same values as this instance

Return: 

- Cloned light shadow instance

### func copy\(LightShadow\)
```cj
public open func copy(source: LightShadow): LightShadow
```
Copy the values from the given light shadow instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|LightShadow|The source light shadow instance|

Return: 

- This instance

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU-related resources allocated by this instance, should be called when the instance is no longer used

### func getFrameExtents\(\)
```cj
public func getFrameExtents(): Vector2
```
Return the frame extents

Return: 

- Frame extents vector

### func getFrustum\(\)
```cj
public func getFrustum(): Frustum
```
Get the shadow camera frustum, used internally by the renderer for culling

Return: 

- The frustum

### func getViewportCount\(\)
```cj
public func getViewportCount(): Int64
```
Get the number of viewports to render for this shadow

Return: 

- Number of viewports

### func getViewport\(Int64\)
```cj
public func getViewport(viewportIndex: Int64): Vector4
```
Return the viewport definition at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewportIndex|Int64|Viewport index|

Return: 

- Viewport definition vector

### func initCascadeCameras\(\)
```cj
public func initCascadeCameras(): Unit
```
Initialize CSM cascade shadow camera array, only called when smType==Cascade

### func init\(Camera\)
```cj
public init(camera: Camera)
```
Construct a new light shadow configuration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|Camera|The camera used to view the world from the light's perspective|

### func init\(\)
```cj
public init()
```
No-argument constructor, used by fastjson deserialization

### func updateCascadeMatrices\(Light,Camera,Int64\)
```cj
public open func updateCascadeMatrices(light: Light, mainCamera: Camera, cascadeIndex: Int64): Unit
```
Update CSM cascade shadow camera parameters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The DirectionalLight for which the shadow is being renderedmainCamera The main camera providing near/far for splittingcascadeIndex Current cascade index (0..cascadeCount-1)|
|mainCamera|Camera||
|cascadeIndex|Int64||

### func updateMatrices\(Light\)
```cj
public open func updateMatrices(light: Light): Unit
```
Update the camera and shadow matrix, called internally by the renderer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The light for which the shadow is being rendered|

### var autoUpdate
```cj
public var autoUpdate: Bool
```
Whether to automatically update the light shadow, set to false when dynamic lighting/shadow is not needed

### var bias
```cj
public var bias: Float64
```
Shadow map bias, default 0, small adjustments reduce shadow artifacts

### var blurSamples
```cj
public var blurSamples: Int64
```
Number of samples when blurring VSM shadow maps, default 8

### var camera
```cj
public var camera: Camera
```
The camera used to view the world from the light's perspective

### var cascadeCameras
```cj
public var cascadeCameras: ArrayList < OrthographicCamera >
```
CSM per-cascade shadow camera array, length=cascadeCount, each with independent OrthographicCamera

### var cascadeCount
```cj
public var cascadeCount: Int64
```
CSM cascade count, only effective when smType==Cascade, default 4

### var cascadeLambda
```cj
public var cascadeLambda: Float64
```
CSM cascade split lambda, 0=uniform split, 1=logarithmic split, default 0.5

### var cascadeSplits
```cj
public var cascadeSplits: ArrayList < Float64 >
```
CSM per-cascade near/far distance array, length=cascadeCount+1, computed by updateMatrices

### var depthImpl
```cj
public var depthImpl: Int64
```
Depth calculation method (InvZ/Linear)

### var intensity
```cj
public var intensity: Float64
```
Shadow intensity, default 1, valid range [0, 1]

### var kind
```cj
public var kind: String
```
Type label, aligned with the type field on the JS side

### var mapPass
```cj
public var mapPass: Option < RenderTarget >
```
Distribution map generated by the internal camera, computes occlusion from depth distribution

### var mapSize
```cj
public var mapSize: Vector2
```
Shadow map width and height (must be power of 2), larger values improve quality but cost more

### var mapType
```cj
public var mapType: Int64
```
Shadow map texture type, default UnsignedByteType

### var map
```cj
public var map: Option < RenderTarget >
```
Depth map generated by the internal camera, positions exceeding pixel depth are in shadow

### var matrix
```cj
public var matrix: Matrix4
```
Matrix from model space to shadow camera space, used to query position and depth in the shadow map

### var needsUpdate
```cj
public var needsUpdate: Bool
```
When set to true, the next render call will update the shadow map

### var normalBias
```cj
public var normalBias: Float64
```
Normal bias for sample position offset along surface normal, default 0

### var packDepth
```cj
public var packDepth: Int64
```
Depth packing method (RGBA/VSM)

### var radius
```cj
public var radius: Float64
```
Shadow edge blur radius, values > 1 blur edges, too large causes banding artifacts

### var smType
```cj
public var smType: Int64
```
Shadow map distribution type (Single/Omni/Cascade)

