# Class
## class Raycaster
```cj
public class Raycaster
```
Raycaster class, used for mouse picking and other ray intersection tests

### func init\(Vector3,Vector3,Float64,Float64\)
```cj
public init(origin!: Vector3 = Vector3(), direction!: Vector3 = Vector3(0.0, 0.0, 1.0), near!: Float64 = 0.0, far!: Float64 = Float64.Inf)
```
Construct a new raycaster

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|Ray origin vectordirection Ray direction vector (should be normalized)near All results are further than near, near cannot be negative, default 0far All results are closer than far, far cannot be less than near, default Infinity|
|direction|Vector3||
|near|Float64||
|far|Float64||

### func intersectObject\(Object3D,Bool\)
```cj
public func intersectObject(object: Object3D, recursive!: Bool = true): ArrayList < Intersection >
```
Check ray intersection with an object (with/without descendants), results sorted by distance ascending

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|The 3D object to checkrecursive Whether to recursively check descendants, default true|
|recursive|Bool||

Return: 

- Array holding intersection results

### func intersectObjects\(Array<Object3D>,Bool\)
```cj
public func intersectObjects(objects: Array < Object3D >, recursive!: Bool = true): ArrayList < Intersection >
```
Check ray intersection with multiple objects (with/without descendants), results sorted by distance ascending

Parameter: 

|Name|Type|Describe|
|---|---|---|
|objects|Array<Object3D>|Array of 3D objects to checkrecursive Whether to recursively check descendants, default true|
|recursive|Bool||

Return: 

- Array holding intersection results

### func setFromCamera\(Vector2,Object3D\)
```cj
public func setFromCamera(coords: Vector2, camera: Object3D): Unit
```
Calculate new ray origin and direction from given coordinates and camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|coords|Vector2|Mouse 2D coordinates in NDC (normalized device coordinates), X and Y should be between -1 and 1camera The camera from which the ray should originate|
|camera|Object3D||

### func set\(Vector3,Vector3\)
```cj
public func set(origin: Vector3, direction: Vector3): Unit
```
Update the ray with new origin and direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|Ray origin vectordirection Ray direction vector (should be normalized)|
|direction|Vector3||

### var camera
```cj
public var camera:?Object3D
```
The camera used when ray casting against view-dependent objects (like Sprites)

### var far
```cj
public var far: Float64
```
All returned results are closer than far. far cannot be less than near

### var layers
```cj
public var layers: Layers
```
Allows selectively ignoring 3D objects during intersection testing

### var near
```cj
public var near: Float64
```
All returned results are further than near. near cannot be negative

### var params
```cj
public var params: RaycasterParams
```
Configuration parameters for ray casting (Line/Points thresholds, etc.)

### var ray
```cj
public var ray: Ray
```
The ray used for casting

