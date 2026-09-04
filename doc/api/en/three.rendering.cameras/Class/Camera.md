# Class
## class Camera
```cj
public open class Camera <: Object3D & ICamera
```
Camera abstract base class, all concrete camera types inherit from this class

### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new camera instance with the same values as this instance

Return: 

- New camera instance

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given camera instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- This instance

### func getWorldDirection\(Vector3\)
```cj
public override func getWorldDirection(target: Vector3): Vector3
```
Return the world direction the camera is facing (in left-handed bgfx, camera faces +Z)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector|

Return: 

- World direction vector

### func init\(Float64,Float64\)
```cj
public init(near!: Float64 = 0.1, far!: Float64 = 2000.0)
```
Construct a new camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|near|Float64|Near clipping plane distance, default 0.1far Far clipping plane distance, default 2000|
|far|Float64||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Update world matrix of this camera and its parents, and sync matrixWorldInverse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force update|

### func updateWorldMatrix\(Bool,Bool,Bool\)
```cj
public override func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit
```
Update world matrix of this camera, its parents and children, and sync matrixWorldInverse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|updateParents|Bool|Whether to update parentsupdateChildren Whether to update childrenforce Whether to force update|
|updateChildren|Bool||
|force|Bool||

### prop reversedDepth: Bool
```cj
public mut prop reversedDepth: Bool
```


### var coordinateSystem
```cj
public var coordinateSystem: Int64
```
Coordinate system (WebGLCoordinateSystem / WebGPUCoordinateSystem), determines Z direction convention

### var far
```cj
public var far: Float64
```
Far clipping plane distance. Default 2000

### var matrixWorldInverse
```cj
public var matrixWorldInverse: Matrix4
```
Inverse of the view matrix (world space → view space)

### var near
```cj
public var near: Float64
```
Near clipping plane distance. Default 0.1

### var projectionMatrixInverse
```cj
public var projectionMatrixInverse: Matrix4
```
Inverse projection matrix

### var projectionMatrix
```cj
public var projectionMatrix: Matrix4
```
Projection matrix

