# Class
## class XRManager
```cj
public class XRManager <: EventDispatcher
```
XRManager — manages XR sessions, view matrices, and controller tracking

### func endSession\(\)
```cj
public func endSession(): Unit
```
End XR session

### func getCamera\(\)
```cj
public func getCamera(): ArrayCamera
```
Get XR camera (left-right eye combination)

Return: 

- Array camera

### func getControllerGrip\(Int64\)
```cj
public func getControllerGrip(index: Int64): XRControllerSpace
```
Get grip space of controller at given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Controller index|

Return: 

- Controller space

### func getController\(Int64\)
```cj
public func getController(index: Int64): XRControllerSpace
```
Get target ray space of controller at given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Controller index|

Return: 

- Controller space

### func getEnvironmentBlendMode\(\)
```cj
public func getEnvironmentBlendMode(): String
```
Get environment blend mode

Return: 

- Environment blend mode

### func getFoveation\(\)
```cj
public func getFoveation(): Float64
```
Get foveation level

Return: 

- Foveation level

### func getHand\(Int64\)
```cj
public func getHand(index: Int64): XRControllerSpace
```
Get hand space of controller at given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Controller index|

Return: 

- Controller space

### func getReferenceSpaceType\(\)
```cj
public func getReferenceSpaceType(): XRReferenceSpaceType
```
Get reference space type

Return: 

- Reference space type

### func init\(ThreeRenderer\)
```cj
public init(renderer: ThreeRenderer)
```
Construct XR manager

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Bgfx renderer instance|

### func isXRPresenting\(\)
```cj
public func isXRPresenting(): Bool
```
Whether XR is presenting

Return: 

- Whether presenting

### func requestSession\(String\)
```cj
public func requestSession(mode: String): Unit
```
Request XR session

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mode|String|Session mode (e.g. "immersive-vr")|

### func setEnabled\(Bool\)
```cj
public func setEnabled(value: Bool): Unit
```
Set whether XR is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Bool|Whether enabled|

### func setFoveation\(Float64\)
```cj
public func setFoveation(value: Float64): Unit
```
Set foveation level

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Foveation level|

### func setFramebufferScaleFactor\(Float64\)
```cj
public func setFramebufferScaleFactor(factor: Float64): Unit
```
Set framebuffer scale factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|factor|Float64|Scale factor|

### func setReferenceSpaceType\(XRReferenceSpaceType\)
```cj
public func setReferenceSpaceType(`type`: XRReferenceSpaceType): Unit
```
Set reference space type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|XRReferenceSpaceType|Reference space type|

### func updateCamera\(PerspectiveCamera\)
```cj
public func updateCamera(camera: PerspectiveCamera): Unit
```
Update camera (left-right eye projection matrix and pose)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|PerspectiveCamera|Main perspective camera|

