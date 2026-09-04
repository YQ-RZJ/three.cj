# Class
## class Points
```cj
public class Points <: Object3D
```
Points rendering object, renders a set of vertices as independent pixel squares

### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new points instance with the same values as this instance

Return: 

- New points instance

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given points instance to this instance

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
Provide this point cloud geometry for culling/bounding box calculation (overrides Object3D hook)

Return: 

- This point cloud geometry

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material())
```
Construct a new points set

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Vertex/index geometry, default empty BufferGeometrymaterial Points material, default empty Material|
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

### func updateMorphTargets\(\)
```cj
public func updateMorphTargets(): Unit
```
Update morph target dictionary and influence coefficients

### var geometry
```cj
public var geometry: BufferGeometry
```
Vertex/index geometry

### var material
```cj
public var material: Material
```
Points material

### var morphTargetDictionary
```cj
public var morphTargetDictionary: HashMap < String, Int64 >
```
morph target name→index dictionary (animation blend shapes)

### var morphTargetInfluences
```cj
public var morphTargetInfluences: Array < Float64 >
```
morph target influence coefficients array

