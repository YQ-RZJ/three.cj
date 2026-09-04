# Class
## class Line
```cj
public open class Line <: Object3D
```
Line rendering object, a continuous polyline from vertices connected in order

### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new line instance with the same values as this instance

Return: 

- New line instance

### func computeLineDistances\(\)
```cj
public open func computeLineDistances(): Line
```
Compute and write lineDistance attribute to geometry (cumulative distance along polyline)

Return: 

- Returns this for method chaining

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given line instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Returns this

### func getCullingGeometry\(\)
```cj
public override func getCullingGeometry(): Option < IGeometryProvider >
```
Provide this line geometry for culling/bounding box calculation (overrides Object3D hook)

Return: 

- This line geometry

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial())
```
Construct a new line rendering object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Vertex/index geometry, default empty BufferGeometrymaterial Line material, default empty LineBasicMaterial|
|material|Material||

### func intersectsFrustum\(Frustum\)
```cj
public func intersectsFrustum(frustum: Frustum): Bool
```
Frustum culling test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustum|Frustum|The frustum|

Return: 

- Returns true if intersects with frustum

### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
Ray intersection test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|raycaster|Raycaster|The raycasterintersects Intersection result accumulator|
|intersects|ArrayList<Intersection>||

### var geometry
```cj
public var geometry: BufferGeometry
```
Vertex/index geometry

### var material
```cj
public var material: Material
```
Line material

