# Class
## class CameraHelper
```cj
public class CameraHelper <: LineSegments
```
Camera frustum helper for visualizing camera frustums

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(\)
```cj
public init()
```
Construct a camera helper

### func init\(Camera\)
```cj
public init(camera: Camera)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|Camera||

### func setColors\(Color,Color,Color,Color,Color\)
```cj
public func setColors(frustum: Color, cone: Color, up: Color, target: Color, cross: Color): CameraHelper
```
Set colors for each section of the helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustum|Color|Frustum line colorcone Cone line colorup Up direction line colortarget Target line colorcross Cross line color|
|cone|Color||
|up|Color||
|target|Color||
|cross|Color||

Return: 

- Self reference

### func update\(\)
```cj
public func update(): Unit
```
Update camera frustum wireframe

### var camera
```cj
public var camera: Camera
```
The camera being visualized

### var pointMap
```cj
public var pointMap: HashMap < String, ArrayList < Int64 >>
```
Vertex mapping: point name to array of geometry vertex indices

