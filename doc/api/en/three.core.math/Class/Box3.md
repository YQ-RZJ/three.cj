# Class
## class Box3
```cj
public class Box3
```
3D axis-aligned bounding box class, defined by min and max points

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Box3
```
Apply a 4x4 matrix transformation to the bounding box

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
Clamp a point within the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to clamptarget Target vector|
|target|Vector3||

Return: 

- Clamped point

### func clone\(\)
```cj
public func clone(): Box3
```
Clone the current bounding box

Return: 

- New bounding box instance

### func containsBox\(Box3\)
```cj
public func containsBox(b: Box3): Bool
```
Check if this bounding box fully contains another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box3|Another bounding box|

Return: 

- Whether the box is fully contained

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
Check if a point is inside the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to test|

Return: 

- Whether the point is contained

### func copy\(Box3\)
```cj
public func copy(b: Box3): Box3
```
Copy values from another bounding box to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box3|Source bounding box|

Return: 

- This instance

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
Compute the Euclidean distance from a point to the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to compute distance to|

Return: 

- Distance

### func equals\(Box3\)
```cj
public func equals(b: Box3): Bool
```
Check if this bounding box equals another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box3|Another bounding box|

Return: 

- Whether the boxes are equal

### func expandByObject\(IBox3Expandable,Bool\)
```cj
public func expandByObject(object: IBox3Expandable, precise: Bool): Box3
```
Recursively expand by object (including children) geometry bounding boxes and merge

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|IBox3Expandable|Object implementing IBox3Expandableprecise Whether to compute precisely|
|precise|Bool||

Return: 

- This instance

### func expandByPoint\(Vector3\)
```cj
public func expandByPoint(point: Vector3): Box3
```
Expand the bounding box to include a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to include|

Return: 

- This instance

### func expandByScalar\(Float64\)
```cj
public func expandByScalar(s: Float64): Box3
```
Expand the bounding box by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Expansion scalar|

Return: 

- This instance

### func expandByVector\(Vector3\)
```cj
public func expandByVector(v: Vector3): Box3
```
Expand the bounding box by a vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Expansion vector|

Return: 

- This instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Box3
```
Set the bounding box from JSON deserialization

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|Serialized bounding box HashMap|

Return: 

- This instance

### func getBoundingSphere\(\)
```cj
public func getBoundingSphere(): Sphere
```
Get the bounding sphere of the bounding box (creates a new sphere)

Return: 

- Bounding sphere

### func getBoundingSphere\(Sphere\)
```cj
public func getBoundingSphere(target: Sphere): Sphere
```
Get the bounding sphere of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Sphere|Target sphere|

Return: 

- Bounding sphere

### func getCenter\(\)
```cj
public func getCenter(): Vector3
```
Get the center point of the bounding box (creates a new vector)

Return: 

- Center point

### func getCenter\(Vector3\)
```cj
public func getCenter(target: Vector3): Vector3
```
Get the center point of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector for storing the result|

Return: 

- Center point

### func getParameter\(Vector3,Vector3\)
```cj
public func getParameter(point: Vector3, target: Vector3): Vector3
```
Get the parameterized position of a point within the bounding box (0-1 range)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to testtarget Target vector|
|target|Vector3||

Return: 

- Parameterized position

### func getSize\(\)
```cj
public func getSize(): Vector3
```
Get the size of the bounding box (creates a new vector)

Return: 

- Size vector

### func getSize\(Vector3\)
```cj
public func getSize(target: Vector3): Vector3
```
Get the size of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector for storing the result|

Return: 

- Size vector

### func init\(\)
```cj
public init()
```
Construct an empty bounding box (min=+Inf, max=-Inf)

### func init\(Vector3,Vector3\)
```cj
public init(min: Vector3, max: Vector3)
```
Construct a bounding box with specified min and max points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector3|Minimum pointmax Maximum point|
|max|Vector3||

### func intersect\(Box3\)
```cj
public func intersect(b: Box3): Box3
```
Compute the intersection with another bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box3|Another bounding box|

Return: 

- This instance

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(b: Box3): Bool
```
Check if this bounding box intersects another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box3|Another bounding box|

Return: 

- Whether the boxes intersect

### func intersectsPlane\(Plane\)
```cj
public func intersectsPlane(plane: Plane): Bool
```
Check if this bounding box intersects a plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|Plane|

Return: 

- Whether they intersect

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
Check if this bounding box intersects a sphere

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Sphere|

Return: 

- Whether they intersect

### func intersectsTriangle\(Triangle\)
```cj
public func intersectsTriangle(triangle: Triangle): Bool
```
Check if this bounding box intersects a triangle (using SAT - Separating Axis Theorem)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|triangle|Triangle|Triangle|

Return: 

- Whether they intersect

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Check if the bounding box is empty

Return: 

- Whether the box is empty

### func makeEmpty\(\)
```cj
public func makeEmpty(): Box3
```
Make the bounding box empty (containing no points)

Return: 

- This instance

### func setFromArray\(Array<Float64>\)
```cj
public func setFromArray(array: Array < Float64 >): Box3
```
Set the bounding box from a float array (every 3 elements form a point)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array containing coordinate data|

Return: 

- This instance

### func setFromBufferAttribute\(AttributeReader\)
```cj
public func setFromBufferAttribute(attribute: AttributeReader): Box3
```
Set the bounding box from a vertex attribute, containing all position data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|AttributeReader|Vertex attribute (AttributeReader interface, implemented by BufferAttribute)|

Return: 

- This instance

### func setFromCenterAndSize\(Vector3,Vector3\)
```cj
public func setFromCenterAndSize(center: Vector3, size: Vector3): Box3
```
Set the bounding box from center and size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector3|Center pointsize Size|
|size|Vector3||

Return: 

- This instance

### func setFromObject\(IBox3Expandable,Bool\)
```cj
public func setFromObject(object: IBox3Expandable, precise!: Bool = false): Box3
```
Set the bounding box from an object (including children)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|IBox3Expandable|Object implementing IBox3Expandable (Object3D and subclasses)precise Whether to compute precisely (current implementation uses conservative path)|
|precise|Bool||

Return: 

- This instance

### func setFromPoints\(ArrayList<Vector3>\)
```cj
public func setFromPoints(points: ArrayList < Vector3 >): Box3
```
Set the bounding box from a set of points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|ArrayList<Vector3>|Point collection|

Return: 

- This instance

### func setFromPoints\(Array<Vector3>\)
```cj
public func setFromPoints(points: Array < Vector3 >): Box3
```
Set the bounding box from a point set (Array version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Point array|

Return: 

- This instance

### func set\(Vector3,Vector3\)
```cj
public func set(min: Vector3, max: Vector3): Box3
```
Set the min and max bounds of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector3|Minimum pointmax Maximum point|
|max|Vector3||

Return: 

- This instance

### func translate\(Vector3\)
```cj
public func translate(offset: Vector3): Box3
```
Translate the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Vector3|Translation offset|

Return: 

- This instance

### func union\(Box3\)
```cj
public func union(b: Box3): Box3
```
Compute the union with another bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box3|Another bounding box|

Return: 

- This instance

### var max
```cj
public var max: Vector3
```
Upper bound of the bounding box

### var min
```cj
public var min: Vector3
```
Lower bound of the bounding box

