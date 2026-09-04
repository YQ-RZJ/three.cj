# Class
## class Sphere
```cj
public class Sphere
```
Sphere class, represented by center and radius

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Sphere
```
Apply 4x4 matrix transformation to sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Matrix4|Transformation matrix|

Return: 

- This instance

### func clampPoint\(Vector3,Vector3\)
```cj
public func clampPoint(point: Vector3, target: Vector3): Vector3
```
Clamp point to sphere surface

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Pointtarget Target vector|
|target|Vector3||

Return: 

- Clamped point

### func clone\(\)
```cj
public func clone(): Sphere
```
Clone current sphere

Return: 

- New sphere instance

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
Check if point is inside the sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Target point|

Return: 

- Whether contained

### func copy\(Sphere\)
```cj
public func copy(s: Sphere): Sphere
```
Copy values from another sphere to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Sphere|Source sphere|

Return: 

- This instance

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
Compute distance from point to sphere surface

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Target point|

Return: 

- Distance

### func equals\(Sphere\)
```cj
public func equals(s: Sphere): Bool
```
Check if equal to another sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Sphere|Sphere to compare|

Return: 

- Whether equal

### func expandByPoint\(Vector3\)
```cj
public func expandByPoint(point: Vector3): Sphere
```
Expand sphere to include a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to include|

Return: 

- This instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Sphere
```
Deserialize sphere from JSON

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|Serialized bounding sphere HashMap|

Return: 

- Reference to this instance

### func getBoundingBox\(\)
```cj
public func getBoundingBox(): Box3
```
Get bounding box of the sphere (creates new box)

Return: 

- Bounding box

### func getBoundingBox\(Box3\)
```cj
public func getBoundingBox(target: Box3): Box3
```
Get bounding box of the sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Box3|Target bounding box|

Return: 

- Bounding box

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Float64\)
```cj
public init(center: Vector3, radius: Float64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector3||
|radius|Float64||

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
Check if intersects with a bounding box

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
Check if intersects with a plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|Plane|

Return: 

- Whether intersecting

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(s: Sphere): Bool
```
Check if intersects with another sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Sphere|Another sphere|

Return: 

- Whether intersecting

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Check if the sphere is empty

Return: 

- Whether empty

### func makeEmpty\(\)
```cj
public func makeEmpty(): Sphere
```
Make the sphere empty (set radius to -1)

Return: 

- This instance

### func setFromPoints\(ArrayList<Vector3>,Option<Vector3>\)
```cj
public func setFromPoints(points: ArrayList < Vector3 >, optionalCenter!: Option < Vector3 >= None): Sphere
```
Set sphere from point set

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|ArrayList<Vector3>|Point collectionoptionalCenter Optional center point|
|optionalCenter|Option<Vector3>||

Return: 

- This instance

### func set\(Vector3,Float64\)
```cj
public func set(center: Vector3, radius: Float64): Sphere
```
Set the center and radius of the sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector3|Centerradius Radius|
|radius|Float64||

Return: 

- This instance

### func translate\(Vector3\)
```cj
public func translate(offset: Vector3): Sphere
```
Translate sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Vector3|Offset|

Return: 

- This instance

### func union\(Sphere\)
```cj
public func union(sphere: Sphere): Sphere
```
Expand sphere to include another sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Sphere to include|

Return: 

- This instance

### var center
```cj
public var center: Vector3
```
Center

### var radius
```cj
public var radius: Float64
```
Radius

