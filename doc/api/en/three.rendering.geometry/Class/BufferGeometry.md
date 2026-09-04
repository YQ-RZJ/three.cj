# Class
## class BufferGeometry
```cj
public open class BufferGeometry <: ILoadResult & IGeometryProvider
```
Buffer geometry class: describes geometry data (vertex/normal/UV attributes)

### func addGroup\(Int64,Int64,Int64\)
```cj
public func addGroup(start: Int64, count: Int64, materialIndex!: Int64 = 0): Unit
```
Adds a draw group to this geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int64|First element in this draw callcount How many vertices (or indices) this group containsmaterialIndex Material array index to use, default 0|
|count|Int64||
|materialIndex|Int64||

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): BufferGeometry
```
Applies the given 4x4 transformation matrix to the geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Matrix4|4x4 matrix to apply|

Return: 

- Reference to this instance

### func applyQuaternion\(Quaternion\)
```cj
public func applyQuaternion(q: Quaternion): BufferGeometry
```
Applies the rotation represented by the given quaternion to the geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Quaternion to apply|

Return: 

- Reference to this instance

### func center\(\)
```cj
public func center(): BufferGeometry
```
Centers the geometry based on its bounding box

Return: 

- Reference to this instance

### func clearGroups\(\)
```cj
public func clearGroups(): Unit
```
Clears all draw groups

### func clone\(\)
```cj
public func clone(): BufferGeometry
```
Returns a new geometry with values copied from this instance

Return: 

- Clone of this instance

### func computeBoundingBox\(\)
```cj
public func computeBoundingBox(): Unit
```
Computes the bounding box and updates the boundingBox member

### func computeBoundingSphere\(\)
```cj
public func computeBoundingSphere(): Unit
```
Computes the bounding sphere and updates the boundingSphere member

### func computeTangents\(\)
```cj
public func computeTangents(): Unit
```
Computes and adds tangent attributes for this geometry

### func computeVertexNormals\(\)
```cj
public func computeVertexNormals(): Unit
```
Computes vertex normals for the given vertex data

### func copy\(BufferGeometry\)
```cj
public func copy(source: BufferGeometry): BufferGeometry
```
Copies the values of the given geometry to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|BufferGeometry|Geometry to copy from|

Return: 

- Reference to this instance

### func deleteAttribute\(String\)
```cj
public func deleteAttribute(name: String): BufferGeometry
```
Deletes the attribute with the specified name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Attribute name|

Return: 

- Reference to this instance

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases GPU-related resources allocated by this instance

### func getAttributeReader\(String\)
```cj
public func getAttributeReader(name: String): Option < AttributeReader >
```
Gets vertex attribute by name (interface implementation, converts to AttributeReader read-only view)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func getAttribute\(String\)
```cj
public func getAttribute(name: String):?BufferAttribute
```
Returns the attribute with the given name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Attribute name|

Return: 

- Corresponding buffer attribute; returns None if not found

### func getBoundingBox\(\)
```cj
public func getBoundingBox(): Option < Box3 >
```
Gets the bounding box (interface implementation, returns current boundingBox)

### func getBoundingSphere\(\)
```cj
public func getBoundingSphere(): Option < Sphere >
```
Gets the bounding sphere (interface implementation, returns current boundingSphere)

### func getIndex\(\)
```cj
public func getIndex():?BufferAttribute
```
Returns the index of this geometry

Return: 

- Index buffer attribute; returns None if index is not defined

### func getIndirect\(\)
```cj
public func getIndirect():?BufferAttribute
```
Returns the indirect draw attribute of this geometry

Return: 

- Indirect draw attribute; returns None if not defined

### func getParameters\(\)
```cj
public open func getParameters():?HashMap < String, Any >
```
Returns the generation parameters of this geometry

Return: 

- Generation parameters HashMap, returns None when no parameters

### func hasAttribute\(String\)
```cj
public func hasAttribute(name: String): Bool
```
Returns whether this geometry has an attribute with the specified name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Attribute name|

Return: 

- Whether the attribute exists

### func init\(\)
```cj
public init()
```
Constructs a new buffer geometry

### func lookAt\(Vector3\)
```cj
public func lookAt(vector: Vector3): BufferGeometry
```
Rotates the geometry to face a point in 3D space

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vector|Vector3|Target point|

Return: 

- Reference to this instance

### func normalizeNormals\(\)
```cj
public func normalizeNormals(): Unit
```
Ensures each normal vector in the geometry has unit length

### func rotateX\(Float64\)
```cj
public func rotateX(angle: Float64): BufferGeometry
```
Rotates the geometry around the world X-axis

Parameter: 

|Name|Type|Describe|
|---|---|---|
|angle|Float64|Rotation angle (radians)|

Return: 

- Reference to this instance

### func rotateY\(Float64\)
```cj
public func rotateY(angle: Float64): BufferGeometry
```
Rotates the geometry around the world Y-axis

Parameter: 

|Name|Type|Describe|
|---|---|---|
|angle|Float64|Rotation angle (radians)|

Return: 

- Reference to this instance

### func rotateZ\(Float64\)
```cj
public func rotateZ(angle: Float64): BufferGeometry
```
Rotates the geometry around the world Z-axis

Parameter: 

|Name|Type|Describe|
|---|---|---|
|angle|Float64|Rotation angle (radians)|

Return: 

- Reference to this instance

### func scale\(Float64,Float64,Float64\)
```cj
public func scale(x: Float64, y: Float64, z: Float64): BufferGeometry
```
Scales the geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Scale in x directiony Scale in y directionz Scale in z direction|
|y|Float64||
|z|Float64||

Return: 

- Reference to this instance

### func setAttribute\(String,BufferAttribute\)
```cj
public func setAttribute(name: String, attribute: BufferAttribute): BufferGeometry
```
Sets the given attribute for the specified name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Attribute nameattribute Attribute to set|
|attribute|BufferAttribute||

Return: 

- Reference to this instance

### func setDrawRange\(Int64,Int64\)
```cj
public func setDrawRange(start: Int64, count: Int64): Unit
```
Sets the draw range of this geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int64|First vertex for non-indexed geometry, or first triangle index otherwisecount Number of vertices to render for non-indexed geometry, or indices for indexed geometry|
|count|Int64||

### func setFromPoints\(Array<Vector3>\)
```cj
public func setFromPoints(points: Array < Vector3 >): BufferGeometry
```
Defines geometry from an array of points (creates position attribute)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of points|

Return: 

- Reference to this instance

### func setIndex\(BufferAttribute\)
```cj
public func setIndex(index: BufferAttribute): BufferGeometry
```
Sets the index of this geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|BufferAttribute|Index buffer attribute|

Return: 

- Reference to this instance

### func setIndirect\(BufferAttribute,Int64\)
```cj
public func setIndirect(indirect: BufferAttribute, indirectOffset!: Int64 = 0): BufferGeometry
```
Sets the indirect draw attribute of this geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|indirect|BufferAttribute|Attribute holding indirect draw callsindirectOffset Offset in the indirect draw buffer (bytes)|
|indirectOffset|Int64||

Return: 

- Reference to this instance

### func toNonIndexed\(\)
```cj
public func toNonIndexed(): BufferGeometry
```
Returns a non-indexed version of this indexed geometry

Return: 

- Non-indexed version of this indexed geometry

### func translate\(Float64,Float64,Float64\)
```cj
public func translate(x: Float64, y: Float64, z: Float64): BufferGeometry
```
Translates the geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Offset in x directiony Offset in y directionz Offset in z direction|
|y|Float64||
|z|Float64||

Return: 

- Reference to this instance

### var attributes
```cj
public var attributes: HashMap < String, BufferAttribute >
```
Named vertex attribute dictionary, accessed via setAttribute/getAttribute

### var boundingBox
```cj
public var boundingBox:?Box3
```
Bounding box, can be computed via computeBoundingBox()

### var boundingSphere
```cj
public var boundingSphere:?Sphere
```
Bounding sphere, can be computed via computeBoundingSphere()

### var drawRange
```cj
public var drawRange:(Int64, Int64)
```
Determines the part of geometry to render, set via setDrawRange()

### var groups
```cj
public var groups: ArrayList < BufferGeometryGroup >
```
Divides geometry into multiple draw groups, each using different materials, edited via addGroup/clearGroups

### var index
```cj
public var index:?BufferAttribute
```
Index buffer attribute enabling vertex reuse; if not set, renderer assumes every three consecutive vertices form a triangle

### var indirectOffset
```cj
public var indirectOffset: Int64
```
Offset in the indirect draw buffer (bytes)

### var indirect
```cj
public var indirect:?BufferAttribute
```
Indirect draw attribute (WebGPU backend only)

### var kind
```cj
public var kind: String
```
Geometry type string

### var morphAttributes
```cj
public var morphAttributes: HashMap < String, ArrayList < BufferAttribute >>
```
Morph target attribute dictionary; once rendered, morph attribute data cannot be changed, need dispose() and rebuild

### var morphTargetsRelative
```cj
public var morphTargetsRelative: Bool
```
Controls morph target behavior: true for relative offsets, false for absolute positions/normals

### var name
```cj
public var name: String
```
Geometry name

### var userData
```cj
public var userData: HashMap < String, Any >
```
序列化忽略：userData 为运行时自定义数据（JsonValue 容器，fastjson 宏不支持）。

### var uuid
```cj
public var uuid: String
```
UUID of the geometry

