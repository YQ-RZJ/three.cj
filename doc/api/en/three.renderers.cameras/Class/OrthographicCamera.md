# Class
## class OrthographicCamera
```cj
public open class OrthographicCamera <: Camera
```
Orthographic camera

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

### func init\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(left!: Float64 = - 1.0, right!: Float64 = 1.0, top!: Float64 = 1.0, bottom!: Float64 = - 1.0, near!: Float64 = 0.1, far!: Float64 = 2000.0)
```
Construct orthographic camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|left|Float64|View frustum left boundary, default -1right View frustum right boundary, default 1top View frustum top boundary, default 1bottom View frustum bottom boundary, default -1near Near clipping plane distance, default 0.1far Far clipping plane distance, default 2000|
|right|Float64||
|top|Float64||
|bottom|Float64||
|near|Float64||
|far|Float64||

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

### var bottom
```cj
public var bottom: Float64
```
View frustum bottom boundary

### var left
```cj
public var left: Float64
```
View frustum left boundary

### var right
```cj
public var right: Float64
```
View frustum right boundary

### var top
```cj
public var top: Float64
```
View frustum top boundary

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

