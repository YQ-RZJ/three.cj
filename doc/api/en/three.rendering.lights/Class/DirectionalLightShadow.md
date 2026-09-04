# Class
## class DirectionalLightShadow
```cj
public class DirectionalLightShadow <: LightShadow
```
Directional light shadow configuration, specific to DirectionalLight

### func enableCSM\(Camera\)
```cj
public func enableCSM(mainCamera: Camera): Unit
```
Enable CSM cascaded shadows

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mainCamera|Camera|Main camera (provides near/far for splitting)|

### func getCascadeCamera\(Int64\)
```cj
public func getCascadeCamera(cascadeIndex: Int64): OrthographicCamera
```
Get the shadow camera for the specified cascade index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cascadeIndex|Int64|Cascade index|

Return: 

- Shadow camera

### func getCascadeFrustum\(Int64\)
```cj
public func getCascadeFrustum(cascadeIndex: Int64): Frustum
```
Get the frustum for the specified cascade index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cascadeIndex|Int64|Cascade index|

Return: 

- Frustum

### func getCascadeMatrix\(Int64\)
```cj
public func getCascadeMatrix(cascadeIndex: Int64): Matrix4
```
Get the shadow matrix for the specified cascade index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cascadeIndex|Int64|Cascade index|

Return: 

- Shadow matrix

### func init\(\)
```cj
public init()
```
Construct a new directional light shadow configuration

### func updateCSMMatrices\(Light,Camera\)
```cj
public func updateCSMMatrices(light: Light, mainCamera: Camera): Unit
```
Update CSM cascade shadow camera matrices

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The DirectionalLight currently rendering shadowsmainCamera Main cameramainCameraNear Main camera nearmainCameraFar Main camera far|
|mainCamera|Camera||

### var cascadeFrustums
```cj
public var cascadeFrustums: ArrayList < Frustum >
```
CSM cascade frustums (used for object culling)

### var cascadeMatrices
```cj
public var cascadeMatrices: ArrayList < Matrix4 >
```
CSM cascade shadow matrices array (length = cascadeCount)

