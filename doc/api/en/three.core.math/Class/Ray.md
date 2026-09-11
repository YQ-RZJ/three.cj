# Class
## class Ray
```cj
public class Ray
```
Ray class, defined by origin and direction vector

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): Ray
```
Apply 4x4 matrix transformation to ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|Transformation matrix|

Return: 

- This instance

### func at\(Float64,Vector3\)
```cj
public func at(t: Float64, target: Vector3): Vector3
```
Get the point at parameter t on the ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Parameter valuetarget Target vector|
|target|Vector3||

Return: 

- Point on the ray

### func at\(Float64\)
```cj
public func at(t: Float64): Vector3
```
Get the point at parameter t on the ray (creates new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Parameter value|

Return: 

- Point on the ray

### func clone\(\)
```cj
public func clone(): Ray
```
Clone current ray

Return: 

- New ray instance

### func closestPointToPoint\(Vector3,Vector3\)
```cj
public func closestPointToPoint(point: Vector3, target: Vector3): Vector3
```
Compute the closest point on the ray to a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Pointtarget Target vector|
|target|Vector3||

Return: 

- Closest point

### func closestPointToPoint\(Vector3\)
```cj
public func closestPointToPoint(point: Vector3): Vector3
```
Compute the closest point on the ray to a given point (creates new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point|

Return: 

- Closest point

### func copy\(Ray\)
```cj
public func copy(r: Ray): Ray
```
Copy values from another ray to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Ray|Source ray|

Return: 

- This instance

### func distanceSqToPoint\(Vector3\)
```cj
public func distanceSqToPoint(point: Vector3): Float64
```
Compute squared distance from point to ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Target point|

Return: 

- Squared distance

### func distanceSqToSegment\(Vector3,Vector3,Option<Vector3>,Option<Vector3>\)
```cj
public func distanceSqToSegment(v0: Vector3, v1: Vector3, optionalPointOnRay!: Option < Vector3 >= None, optionalPointOnSegment!: Option < Vector3 >= None): Float64
```
Compute squared shortest distance between ray and line segment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v0|Vector3|Segment start pointv1 Segment end pointoptionalPointOnRay Closest point on ray (optional)optionalPointOnSegment Closest point on segment (optional)|
|v1|Vector3||
|optionalPointOnRay|Option<Vector3>||
|optionalPointOnSegment|Option<Vector3>||

Return: 

- Squared distance

### func distanceToPlane\(Plane\)
```cj
public func distanceToPlane(plane: Plane): Float64
```
Compute distance from ray to plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|Plane|

Return: 

- Distance, returns -1 if parallel

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
Compute distance from point to ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Target point|

Return: 

- Distance

### func equals\(Ray\)
```cj
public func equals(r: Ray): Bool
```
Check if equal to another ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|r|Ray|Ray to compare|

Return: 

- Whether equal

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Vector3\)
```cj
public init(origin: Vector3, direction: Vector3)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3||
|direction|Vector3||

### func intersectBox\(Box3,Vector3\)
```cj
public func intersectBox(box: Box3, target: Vector3): Option < Vector3 >
```
Compute intersection point of ray with bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3|Bounding boxtarget Target vector|
|target|Vector3||

Return: 

- Intersection point, or None if not intersecting

### func intersectPlane\(Plane,Vector3\)
```cj
public func intersectPlane(plane: Plane, target: Vector3): Option < Vector3 >
```
Compute intersection point of ray with plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|Planetarget Target vector|
|target|Vector3||

Return: 

- Intersection point, or None if not intersecting

### func intersectSphere\(Sphere,Vector3\)
```cj
public func intersectSphere(sphere: Sphere, target: Vector3): Option < Vector3 >
```
Compute intersection point of ray with sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Spheretarget Target vector|
|target|Vector3||

Return: 

- Intersection point, or None if not intersecting

### func intersectTriangle\(Vector3,Vector3,Vector3,Bool,Vector3\)
```cj
public func intersectTriangle(a: Vector3, b: Vector3, c: Vector3, backfaceCulling: Bool, target: Vector3): Option < Vector3 >
```
Compute intersection point of ray with triangle (Watertight algorithm)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|Triangle vertex ab Triangle vertex bc Triangle vertex cbackfaceCulling Whether to enable backface cullingtarget Target vector|
|b|Vector3||
|c|Vector3||
|backfaceCulling|Bool||
|target|Vector3||

Return: 

- Intersection point, or None if not intersecting

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
Check if ray intersects with bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3|Bounding box|

Return: 

- Whether intersecting

### func intersectsPlane\(Plane\)
```cj
public func intersectsPlane(plane: Plane): Bool
```
Check if ray intersects with plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|Plane|

Return: 

- Whether intersecting

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
Check if ray intersects with sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Sphere|

Return: 

- Whether intersecting

### func lookAt\(Vector3\)
```cj
public func lookAt(v: Vector3): Ray
```
Point the ray at a target point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Target point|

Return: 

- This instance

### func recast\(Float64\)
```cj
public func recast(t: Float64): Ray
```
Move the ray origin along its direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Distance to move|

Return: 

- This instance

### func set\(Vector3,Vector3\)
```cj
public func set(origin: Vector3, direction: Vector3): Ray
```
Set the origin and direction of the ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|Origindirection Direction|
|direction|Vector3||

Return: 

- This instance

### var direction
```cj
public var direction: Vector3
```
Ray direction (should be a unit vector)

### var origin
```cj
public var origin: Vector3
```
Ray origin

