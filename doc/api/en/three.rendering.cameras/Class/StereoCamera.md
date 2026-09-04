# Class
## class StereoCamera
```cj
public class StereoCamera
```
Stereo camera

### func init\(\)
```cj
public init()
```
Construct stereo camera

### func update\(PerspectiveCamera\)
```cj
public func update(camera: PerspectiveCamera): Unit
```
Synchronize this stereo camera with the given main camera. Recalculates left/right eye projection matrices when main camera projection changes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|PerspectiveCamera|Main perspective camera|

### var aspect
```cj
public var aspect: Float64
```
Aspect ratio, shared by both eyes

### var cameraL
```cj
public var cameraL: PerspectiveCamera
```
Left eye camera

### var cameraR
```cj
public var cameraR: PerspectiveCamera
```
Right eye camera

### var eyeSep
```cj
public var eyeSep: Float64
```
Inter-pupillary distance (meters), default 0.064

### var kind
```cj
public var kind: String
```
Type label

