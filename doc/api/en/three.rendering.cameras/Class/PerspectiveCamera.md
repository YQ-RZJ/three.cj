# Class
## class PerspectiveCamera
```cj
public open class PerspectiveCamera <: Camera
```
Perspective camera

### func clearViewOffset\(\)
```cj
public func clearViewOffset(): Unit
```
Clear viewport offset

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given source camera to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- This instance

### func getEffectiveFOV\(\)
```cj
public func getEffectiveFOV(): Float64
```
Get effective field of view considering zoom

Return: 

- Effective field of view (degrees)

### func getFilmHeight\(\)
```cj
public func getFilmHeight(): Float64
```
Get film height

Return: 

- Film height

### func getFilmWidth\(\)
```cj
public func getFilmWidth(): Float64
```
Get film width

Return: 

- Film width

### func getFocalLength\(\)
```cj
public func getFocalLength(): Float64
```
Get focal length

Return: 

- Focal length

### func getViewBounds\(Float64,Vector2,Vector2\)
```cj
public func getViewBounds(distance: Float64, minTarget: Vector2, maxTarget: Vector2): Unit
```
Get view bounds at specified distance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64|DistanceminTarget Minimum target vectormaxTarget Maximum target vector|
|minTarget|Vector2||
|maxTarget|Vector2||

### func getViewSize\(Float64,Vector2\)
```cj
public func getViewSize(distance: Float64, target: Vector2): Vector2
```
Get view size at specified distance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64|Distancetarget Target vector|
|target|Vector2||

Return: 

- View size

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(fov!: Float64 = 50.0, aspect!: Float64 = 1.0, near!: Float64 = 0.1, far!: Float64 = 2000.0)
```
Construct perspective camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fov|Float64|Vertical field of view (degrees), default 50aspect Aspect ratio, default 1near Near clipping plane distance, default 0.1far Far clipping plane distance, default 2000|
|aspect|Float64||
|near|Float64||
|far|Float64||

### func setFocalLength\(Float64\)
```cj
public func setFocalLength(focalLength: Float64): Unit
```
Set field of view based on focal length

Parameter: 

|Name|Type|Describe|
|---|---|---|
|focalLength|Float64|Focal length|

### func setViewOffset\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func setViewOffset(fullWidth: Float64, fullHeight: Float64, x: Float64, y: Float64, width: Float64, height: Float64): Unit
```
Set viewport offset

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fullWidth|Float64|Full viewport widthfullHeight Full viewport heightx Viewport offset Xy Viewport offset Ywidth Viewport widthheight Viewport height|
|fullHeight|Float64||
|x|Float64||
|y|Float64||
|width|Float64||
|height|Float64||

### func updateProjectionMatrix\(\)
```cj
public func updateProjectionMatrix(): Unit
```
Update projection matrix

### var aspect
```cj
public var aspect: Float64
```
Aspect ratio

### var filmGauge
```cj
public var filmGauge: Float64
```
Film gauge (millimeters)

### var filmOffset
```cj
public var filmOffset: Float64
```
Film offset

### var focus
```cj
public var focus: Float64
```
Focus distance

### var fov
```cj
public var fov: Float64
```
Vertical field of view (degrees)

### var view
```cj
public var view: Option < CameraView >
```
Multi-viewport clipping configuration (VR/multi-display), uses concrete type CameraView for fastjson macro constraint

### var zoom
```cj
public var zoom: Float64
```
Zoom factor

