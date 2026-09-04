# Class
## class Mesh
```cj
public open class Mesh <: Object3D & IMesh
```
Mesh rendering object, the most commonly used triangle face rendering entity in 3D scenes

### func copy\(Mesh,Bool\)
```cj
public func copy(source: Mesh, recursive!: Bool = true): Mesh
```
Copy values from the given mesh instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Mesh|Source meshrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Returns this

### func getCullingGeometry\(\)
```cj
public override func getCullingGeometry(): Option < IGeometryProvider >
```
Provide this mesh geometry for culling/bounding box calculation (overrides Object3D hook)

Return: 

- This mesh geometry

### func getPreciseVertexCount\(\)
```cj
public override func getPreciseVertexCount(): Int64
```
Vertex count for precise mode per-vertex traversal (overrides Object3D)

Return: 

- Vertex count (returns 0 for InstancedMesh or missing position attribute)

### func getPreciseVertexPosition\(Int64\)
```cj
public override func getPreciseVertexPosition(i: Int64): Array < Float64 >
```
World space position of vertex i (overrides Object3D)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Vertex index|

Return: 

- World space coordinates [x, y, z]

### func getVertexPosition\(Int64,Vector3\)
```cj
public open func getVertexPosition(index: Int64, target: Vector3): Vector3
```
Get the position of the specified vertex

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex indextarget Target vector to receive the result|
|target|Vector3||

Return: 

- Vertex position

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material())
```
Construct a new mesh

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Vertex/index geometry, default empty BufferGeometrymaterial Material, default empty Material|
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
public open func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
Ray intersection test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|raycaster|Raycaster|The raycasterintersects Intersection result accumulator|
|intersects|ArrayList<Intersection>||

### func updateMorphTargets\(\)
```cj
public open func updateMorphTargets(): Unit
```
Update morph target dictionary and influence coefficients

### var count
```cj
public var count: Int64
```
Instance count (used by InstancedMesh)

### var geometry
```cj
public var geometry: BufferGeometry
```
Vertex/index geometry

### var material
```cj
public var material: Material
```
Material

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

