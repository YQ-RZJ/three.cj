# Class
## class SkinnedMesh
```cj
public class SkinnedMesh <: Mesh
```
Skinned mesh, a Mesh with bone skinning deformation

### func applyBoneTransform\(Int64,Vector3\)
```cj
public func applyBoneTransform(index: Int64, target: Vector3): Vector3
```
Apply bone transform to the specified vertex position and return the transformed position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex indextarget Target vector to receive the result|
|target|Vector3||

Return: 

- Transformed vertex position

### func applySkinningJob\(\)
```cj
public func applySkinningJob(): Unit
```
Skins all vertices in batch using SkinningJob

### func bind\(Skeleton,Option<Matrix4>\)
```cj
public func bind(skeleton: Skeleton, bindMatrix!: Option < Matrix4 >= None): Unit
```
Bind skeleton to this mesh

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|Skeleton|Skeleton instancebindMatrix Custom bind matrix, default None means use this object's matrixWorld|
|bindMatrix|Option<Matrix4>||

### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new skinned mesh instance with the same values as this instance

Return: 

- New skinned mesh instance

### func computeBoundingBox\(\)
```cj
public func computeBoundingBox(): Unit
```
Compute geometry bounding box

### func computeBoundingSphere\(\)
```cj
public func computeBoundingSphere(): Unit
```
Compute geometry bounding sphere

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given skinned mesh instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Returns this

### func getVertexPosition\(Int64,Vector3\)
```cj
public override func getVertexPosition(index: Int64, target: Vector3): Vector3
```
Get specified vertex position (after skinning transform), overrides Mesh.getVertexPosition

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Vertex indextarget Target vector to receive the result|
|target|Vector3||

Return: 

- Vertex position after skinning transform

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material())
```
Construct a new skinned mesh

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Vertex/index geometrymaterial Material|
|material|Material||

### func normalizeSkinWeights\(\)
```cj
public func normalizeSkinWeights(): Unit
```
Normalize skinWeight attribute: scale each vertex's weights to sum to 1, avoiding rendering artifacts

### func pose\(\)
```cj
public func pose(): Unit
```
Pose skeleton to initial pose

### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public override func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
Ray intersection test (reuses base Mesh.raycast, getVertexPosition overridden to applyBoneTransform)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|raycaster|Raycaster|The raycasterintersects Intersection result accumulator|
|intersects|ArrayList<Intersection>||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Update this object's and its skeleton's world matrices

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force update|

### var bindMatrixInverse
```cj
public var bindMatrixInverse: Matrix4
```
Inverse of the bind pose matrix (derived: recomputed each frame by updateMatrixWorld, not serialized)

### var bindMatrix
```cj
public var bindMatrix: Matrix4
```
Bind pose matrix (world space)

### var bindMode
```cj
public var bindMode: String
```
Bind pose mode: AttachedBindMode (follows object matrix) or DetachedBindMode (fixed bindMatrix)

### var skeleton
```cj
public var skeleton: Skeleton
```
Skeleton instance (manages bones/boneInverses/boneMatrices)

