# Class
## class Plane
```cj
public class Plane
```
Plane class, represented by unit normal and constant

### func applyMatrix4\(Matrix4,Option<Matrix3>\)
```cj
public func applyMatrix4(matrix: Matrix4, optionalNormalMatrix!: Option < Matrix3 >= None): Plane
```
Apply 4x4 matrix transformation to plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Matrix4|Transformation matrixoptionalNormalMatrix Optional normal matrix|
|optionalNormalMatrix|Option<Matrix3>||

Return: 

- This instance

### func clone\(\)
```cj
public func clone(): Plane
```
Clone current plane

Return: 

- New plane instance

### func coplanarPoint\(Vector3\)
```cj
public func coplanarPoint(target: Vector3): Vector3
```
Get coplanar point on the plane (projection of origin onto the plane)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector|

Return: 

- Coplanar point

### func copy\(Plane\)
```cj
public func copy(p: Plane): Plane
```
Copy values from another plane to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Plane|Source plane|

Return: 

- This instance

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
Compute signed distance from point to plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Target point|

Return: 

- Signed distance

### func distanceToSphere\(Sphere\)
```cj
public func distanceToSphere(sphere: Sphere): Float64
```
Compute signed distance from sphere to plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Target sphere|

Return: 

- Signed distance

### func equals\(Plane\)
```cj
public func equals(p: Plane): Bool
```
Check if equal to another plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Plane|Plane to compare|

Return: 

- Whether equal

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Float64\)
```cj
public init(normal: Vector3, constant: Float64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3||
|constant|Float64||

### func intersectLine\(Line3,Vector3,Bool\)
```cj
public func intersectLine(line: Line3, target: Vector3, clampToLine!: Bool = true): Option < Vector3 >
```
Compute intersection point of line and plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|line|Line3|Linetarget Target vectorclampToLine Whether to clamp to line segment range, defaults to true|
|target|Vector3||
|clampToLine|Bool||

Return: 

- Intersection point, or None if not intersecting

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
Check if bounding box intersects the plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3|Bounding box|

Return: 

- Whether intersecting

### func intersectsLine\(Line3\)
```cj
public func intersectsLine(line: Line3): Bool
```
Check if line segment intersects the plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|line|Line3|Line segment|

Return: 

- Whether intersecting

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
Check if sphere intersects the plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Sphere|

Return: 

- Whether intersecting

### func negate\(\)
```cj
public func negate(): Plane
```
Negate plane (negate normal and constant)

Return: 

- This instance

### func normalize\(\)
```cj
public func normalize(): Plane
```
Normalize normal vector and adjust constant

Return: 

- This instance

### func projectPoint\(Vector3,Vector3\)
```cj
public func projectPoint(point: Vector3, target: Vector3): Vector3
```
Project point onto the plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to projecttarget Target vector|
|target|Vector3||

Return: 

- Projected point

### func setComponents\(Float64,Float64,Float64,Float64\)
```cj
public func setComponents(x: Float64, y: Float64, z: Float64, w: Float64): Plane
```
Set plane by component values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Normal vector x componenty Normal vector y componentz Normal vector z componentw Constant|
|y|Float64||
|z|Float64||
|w|Float64||

Return: 

- This instance

### func setFromCoplanarPoints\(Vector3,Vector3,Vector3\)
```cj
public func setFromCoplanarPoints(a: Vector3, b: Vector3, c: Vector3): Plane
```
Set plane from three coplanar points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|First pointb Second pointc Third point|
|b|Vector3||
|c|Vector3||

Return: 

- This instance

### func setFromNormalAndCoplanarPoint\(Vector3,Vector3\)
```cj
public func setFromNormalAndCoplanarPoint(normal: Vector3, point: Vector3): Plane
```
Set plane from normal and coplanar point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vectorpoint Coplanar point|
|point|Vector3||

Return: 

- This instance

### func set\(Vector3,Float64\)
```cj
public func set(normal: Vector3, constant: Float64): Plane
```
Set plane components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vectorconstant Constant|
|constant|Float64||

Return: 

- This instance

### func translate\(Vector3\)
```cj
public func translate(offset: Vector3): Plane
```
Translate plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Vector3|Offset vector|

Return: 

- This instance

### var constant
```cj
public var constant: Float64
```
Signed distance from origin to plane

### var normal
```cj
public var normal: Vector3
```
Plane normal vector (unit vector)

