# Class
## class RenderObject
```cj
public open class RenderObject <: IRenderObject
```
Render object

### func getGeometryId\(\)
```cj
public func getGeometryId(): Int64
```
Return geometry ID

Return: 

- Geometry hash ID

### func getGroupOrder\(\)
```cj
public func getGroupOrder(): Float64
```
Return group order

Return: 

- Group order value

### func getHash\(\)
```cj
public func getHash(): Int64
```
Return render object hash (used for deduplication cache)

Return: 

- Render object hash value

### func getMaterialId\(\)
```cj
public func getMaterialId(): Int64
```
Return material ID

Return: 

- Material hash ID

### func getMatrix\(\)
```cj
public func getMatrix(): Array < Float64 >
```
Return world matrix (16 Float64 elements in column-major order)

Return: 

- World matrix elements array

### func getNodeChain\(\)
```cj
public func getNodeChain(): ArrayList < Object3D >
```
Return node chain

Return: 

- Node chain list

### func getObjectId\(\)
```cj
public func getObjectId(): Int64
```
Return object ID

Return: 

- Object ID

### func getRenderOrder\(\)
```cj
public func getRenderOrder(): Float64
```
Return render order

Return: 

- Render order value

### func init\(Int64,Object3D,BufferGeometry,Material,RenderContext,Camera,Scene\)
```cj
public init(id: Int64, `object`: Object3D, geometry: BufferGeometry, material: Material, context: RenderContext, camera: Camera, scene: Scene)
```
Full constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Unique identifierobject Render objectgeometry Geometrymaterial Materialcontext Render contextcamera Camerascene Scene|
|`object`|Object3D||
|geometry|BufferGeometry||
|material|Material||
|context|RenderContext||
|camera|Camera||
|scene|Scene||

### func init\(Int64,Object3D,BufferGeometry,Material,Matrix4\)
```cj
public init(id: Int64, mesh: Object3D, geometry: BufferGeometry, material: Material, worldMatrix: Matrix4)
```
Simplified constructor (for backward compatibility), uses defaults when context/camera/scene are not provided

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Unique identifiermesh Render objectgeometry Geometrymaterial MaterialworldMatrix World matrix (used only for extracting position)|
|mesh|Object3D||
|geometry|BufferGeometry||
|material|Material||
|worldMatrix|Matrix4||

### func onAdd\(\)
```cj
public func onAdd(): Unit
```
Called when added to the renderer

### func onDispose\(\)
```cj
public func onDispose(): Unit
```
Called when disposed

### func onRemove\(\)
```cj
public func onRemove(): Unit
```
Called when removed from the renderer

### func onUpdate\(\)
```cj
public func onUpdate(): Unit
```
Called when properties are updated

### func updateWorldMatrix\(\)
```cj
public func updateWorldMatrix(): Unit
```
Update transform matrices, computing world matrix from root node level by level

### var \`object\`
```cj
public var `object`: Object3D
```
Render object (Mesh/Line/Points etc., Object3D subclass)

### var bindings
```cj
public var bindings: ArrayList < Binding >= ArrayList < Binding >()
```
Bind group list

### var camera
```cj
public var camera: Camera
```
Camera

### var context
```cj
public var context: RenderContext
```
Render context

### var geometry
```cj
public var geometry: BufferGeometry
```
Geometry

### var groupOrder
```cj
public var groupOrder: Float64 = 0.0
```
Group order

### var id
```cj
public var id: Int64
```
Unique identifier

### var initialized
```cj
public var initialized: Bool = false
```
Whether initialized

### var material
```cj
public var material: Material
```
Material

### var mesh
```cj
public var mesh: Object3D
```
mesh alias (for compatible ro.mesh access in ThreeRenderer)

### var modelViewMatrix
```cj
public var modelViewMatrix: Matrix4 = Matrix4()
```
Model-view matrix

### var nodeChain
```cj
public var nodeChain: ArrayList < Object3D >= ArrayList < Object3D >()
```
Node chain (for transform hierarchy traversal)

### var normalMatrix
```cj
public var normalMatrix: Matrix3 = Matrix3()
```
Normal matrix

### var position
```cj
public var position: Vector3 = Vector3()
```
Position (extracted from worldMatrix, used for sorting/occlusion queries)

### var renderOrder
```cj
public var renderOrder: Float64 = 0.0
```
Render order

### var scene
```cj
public var scene: Scene
```
Scene

### var sortKey
```cj
public var sortKey: Float64 = 0.0
```
Sort key (used for transparent object sorting)

### var worldMatrix
```cj
public var worldMatrix: Matrix4 = Matrix4()
```
World matrix (object to world space)

### var z
```cj
public var z: Float64 = 0.0
```
Depth value (camera-space z, used for sorting)

