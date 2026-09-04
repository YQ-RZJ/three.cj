# Class
## class Triangle
```cj
public class Triangle
```
Triangle class, defined by three vertices

### func clone\(\)
```cj
public func clone(): Triangle
```
Clone this triangle

Return: 

- A new triangle instance

### func closestPointToPoint\(Vector3,Vector3\)
```cj
public func closestPointToPoint(p: Vector3, target: Vector3): Vector3
```
Calculate the closest point on the triangle to a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Vector3|Pointtarget Target vector|
|target|Vector3||

Return: 

- Closest point

### func closestPointToPoint\(Vector3\)
```cj
public func closestPointToPoint(p: Vector3): Vector3
```
Calculate the closest point on the triangle to a given point (creates a new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|Vector3|Point|

Return: 

- Closest point

### func computeBarycoord\(Vector3,Vector3,Vector3,Vector3,Vector3\)
```cj
public static func computeBarycoord(point: Vector3, a: Vector3, b: Vector3, c: Vector3, target: Vector3): Option < Vector3 >
```
Static method: compute barycentric coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Pointa Vertex ab Vertex bc Vertex ctarget Target vector|
|a|Vector3||
|b|Vector3||
|c|Vector3||
|target|Vector3||

Return: 

- Barycentric coordinates, returns None for degenerate triangles

### func computeInterpolation\(Vector3,Vector3,Vector3,Vector3,Vector3,Vector3,Vector3,Vector3\)
```cj
public static func computeInterpolation(point: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, target: Vector3): Option < Vector3 >
```
Static method: interpolate using barycentric coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Interpolation point positionp1 Vertex 1p2 Vertex 2p3 Vertex 3v1 Value at vertex 1v2 Value at vertex 2v3 Value at vertex 3target Target vector|
|p1|Vector3||
|p2|Vector3||
|p3|Vector3||
|v1|Vector3||
|v2|Vector3||
|v3|Vector3||
|target|Vector3||

Return: 

- Interpolation result, returns None for degenerate triangles

### func computeNormal\(Vector3,Vector3,Vector3,Vector3\)
```cj
public static func computeNormal(a: Vector3, b: Vector3, c: Vector3, target: Vector3): Vector3
```
Static method: compute triangle normal

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|Vertex ab Vertex bc Vertex ctarget Target vector|
|b|Vector3||
|c|Vector3||
|target|Vector3||

Return: 

- Normal vector

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
Test if a point is inside the triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point|

Return: 

- Whether the point is inside the triangle

### func copy\(Triangle\)
```cj
public func copy(t: Triangle): Triangle
```
Copy values from another triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Triangle|Source triangle|

Return: 

- This instance

### func equals\(Triangle\)
```cj
public func equals(t: Triangle): Bool
```
Check if equal to another triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Triangle|Another triangle|

Return: 

- Whether equal

### func getArea\(\)
```cj
public func getArea(): Float64
```
Calculate the area of the triangle

Return: 

- Area

### func getBarycoord\(Vector3,Vector3\)
```cj
public func getBarycoord(point: Vector3, target: Vector3): Option < Vector3 >
```
Calculate barycentric coordinates for a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Pointtarget Target vector|
|target|Vector3||

Return: 

- Barycentric coordinates, returns None for degenerate triangles

### func getBarycoord\(Vector3\)
```cj
public func getBarycoord(point: Vector3): Vector3
```
Calculate barycentric coordinates for a given point (creates a new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point|

Return: 

- Barycentric coordinates

### func getInterpolatedAttribute\(AttributeReader,Int64,Int64,Int64,Vector3,Vector3\)
```cj
public static func getInterpolatedAttribute(attr: AttributeReader, i1: Int64, i2: Int64, i3: Int64, barycoord: Vector3, target: Vector3): Vector3
```
Interpolate vertex attribute (aligned with JS: Triangle.getInterpolatedAttribute), linearly interpolate attribute values at three vertices using barycentric coordinates, write to target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attr|AttributeReader|Vertex attribute (AttributeReader interface, implemented by BufferAttribute)i1 Attribute index of vertex ai2 Attribute index of vertex bi3 Attribute index of vertex cbarycoord Barycentric coordinatestarget Output vector (writes interpolation result)|
|i1|Int64||
|i2|Int64||
|i3|Int64||
|barycoord|Vector3||
|target|Vector3||

Return: 

- The interpolated target

### func getInterpolation\(Vector3,Vector3,Vector3,Vector3,Vector3\)
```cj
public func getInterpolation(point: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, target: Vector3): Option < Vector3 >
```
Interpolate using barycentric coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Interpolation point positionv1 Value at vertex 1v2 Value at vertex 2v3 Value at vertex 3target Target vector|
|v1|Vector3||
|v2|Vector3||
|v3|Vector3||
|target|Vector3||

Return: 

- Interpolation result, returns None for degenerate triangles

### func getMidpoint\(Vector3\)
```cj
public func getMidpoint(target: Vector3): Vector3
```
Calculate the midpoint of the triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector|

Return: 

- Midpoint

### func getMidpoint\(\)
```cj
public func getMidpoint(): Vector3
```
Calculate the midpoint of the triangle (creates a new vector)

Return: 

- Midpoint

### func getNormal\(Vector3\)
```cj
public func getNormal(target: Vector3): Vector3
```
Calculate the normal vector of the triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector|

Return: 

- Normal vector

### func getNormal\(\)
```cj
public func getNormal(): Vector3
```
Calculate the normal vector of the triangle (creates a new vector)

Return: 

- Normal vector

### func getPlane\(Plane\)
```cj
public func getPlane(target: Plane): Plane
```
Calculate the plane of the triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Plane|Target plane|

Return: 

- Plane

### func getPlane\(\)
```cj
public func getPlane(): Plane
```
Calculate the plane of the triangle (creates a new plane)

Return: 

- Plane

### func init\(\)
```cj
public init()
```
Default constructor, initializes three zero-vector vertices

### func init\(Vector3,Vector3,Vector3\)
```cj
public init(a: Vector3, b: Vector3, c: Vector3)
```
Construct triangle with specified vertices

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|Vertex ab Vertex bc Vertex c|
|b|Vector3||
|c|Vector3||

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
Test if the triangle intersects with a bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3|Bounding box|

Return: 

- Whether intersecting

### func isFrontFacing\(Vector3\)
```cj
public func isFrontFacing(direction: Vector3): Bool
```
Test if the triangle is front-facing towards a given direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|direction|Vector3|Direction vector|

Return: 

- Whether front-facing towards the given direction

### func setFromAttributeAndIndices\(AttributeReader,Int64,Int64,Int64\)
```cj
public func setFromAttributeAndIndices(attribute: AttributeReader, i0: Int64, i1: Int64, i2: Int64): Triangle
```
Set triangle vertices from vertex attribute and indices (aligned with JS: Triangle.setFromAttributeAndIndices)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|AttributeReader|Vertex attribute (AttributeReader interface, implemented by BufferAttribute)i0 Index of vertex ai1 Index of vertex bi2 Index of vertex c|
|i0|Int64||
|i1|Int64||
|i2|Int64||

Return: 

- This instance

### func setFromPointsAndIndices\(Array<Vector3>,Int64,Int64,Int64\)
```cj
public func setFromPointsAndIndices(points: Array < Vector3 >, i0: Int64, i1: Int64, i2: Int64): Triangle
```
Set triangle vertices from point array and indices

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Point arrayi0 Index of vertex ai1 Index of vertex bi2 Index of vertex c|
|i0|Int64||
|i1|Int64||
|i2|Int64||

Return: 

- This instance

### func set\(Vector3,Vector3,Vector3\)
```cj
public func set(a: Vector3, b: Vector3, c: Vector3): Triangle
```
Set the vertices of the triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|Vertex ab Vertex bc Vertex c|
|b|Vector3||
|c|Vector3||

Return: 

- This instance

### func testContainsPoint\(Vector3,Vector3,Vector3,Vector3\)
```cj
public static func testContainsPoint(point: Vector3, a: Vector3, b: Vector3, c: Vector3): Bool
```
Static method: test if a point is inside the triangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Pointa Vertex ab Vertex bc Vertex c|
|a|Vector3||
|b|Vector3||
|c|Vector3||

Return: 

- Whether the point is inside the triangle

### func testIsFrontFacing\(Vector3,Vector3,Vector3,Vector3\)
```cj
public static func testIsFrontFacing(a: Vector3, b: Vector3, c: Vector3, direction: Vector3): Bool
```
Static method: test if the triangle is front-facing towards a given direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|Vertex ab Vertex bc Vertex cdirection Direction vector (should be a unit vector)|
|b|Vector3||
|c|Vector3||
|direction|Vector3||

Return: 

- Whether front-facing towards the given direction

### var a
```cj
public var a: Vector3
```
Vertex a

### var b
```cj
public var b: Vector3
```
Vertex b

### var c
```cj
public var c: Vector3
```
Vertex c

