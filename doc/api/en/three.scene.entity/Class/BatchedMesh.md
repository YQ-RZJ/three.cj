# Class
## class BatchedMesh
```cj
public class BatchedMesh <: Mesh
```
Batched mesh that packs multiple independent geometries into a single BufferGeometry for rendering

### func addGeometry\(BufferGeometry\)
```cj
public func addGeometry(geometry: BufferGeometry): Int64
```
geometry - 待添加的独立几何。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry||

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新批化网格实例。

### func computeBoundingBoxAt\(Int64\)
```cj
public func computeBoundingBoxAt(geometryId: Int64): Unit
```
geometryId - 几何 id。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||

### func computeBoundingSphereAt\(Int64\)
```cj
public func computeBoundingSphereAt(geometryId: Int64): Unit
```
geometryId - 几何 id。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定批化网格实例的值复制到本实例。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D||
|recursive|Bool||

### func deleteGeometry\(Int64\)
```cj
public func deleteGeometry(geometryId: Int64): Unit
```
geometryId - 待删除的几何 id。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放本实例分配的 GPU 相关资源。

### func getInstanceCount\(Int64\)
```cj
public func getInstanceCount(geometryId: Int64): Int64
```
geometryId - 几何 id。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||

### func getMatrixAt\(Int64,Matrix4\)
```cj
public func getMatrixAt(geometryId: Int64, matrix: Matrix4): Matrix4
```
matrix - 接收结果的目标矩阵。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||
|matrix|Matrix4||

### func getVisibleAt\(Int64\)
```cj
public func getVisibleAt(geometryId: Int64): Bool
```
geometryId - 几何 id。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||

### func init\(Int64,Int64,Int64,Material\)
```cj
public init(maxGeometryCount: Int64, maxVertexCount: Int64, maxIndexCount: Int64, material!: Material = Material())
```
material - 材质。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxGeometryCount|Int64||
|maxVertexCount|Int64||
|maxIndexCount|Int64||
|material|Material||

### func optimize\(\)
```cj
public func optimize(): Unit
```
与 JS side 一致：紧缩 active 几何到连续区间，提升后续渲染效率。

### func setInstanceCount\(Int64,Int64\)
```cj
public func setInstanceCount(geometryId: Int64, count: Int64): Unit
```
count - 实例数量。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||
|count|Int64||

### func setMatrixAt\(Int64,Matrix4\)
```cj
public func setMatrixAt(geometryId: Int64, matrix: Matrix4): Unit
```
matrix - 变换矩阵。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||
|matrix|Matrix4||

### func setVisibleAt\(Int64,Bool\)
```cj
public func setVisibleAt(geometryId: Int64, visible: Bool): Unit
```
visible - 是否可见。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64||
|visible|Bool||

### var \_colorsTexture
```cj
public var _colorsTexture: Option < DataTexture >
```
对照 JS `this._colorsTexture = null`（BatchedMesh.js:279），渲染器初始化时注入。

### var \_indirectTexture
```cj
public var _indirectTexture: Option < DataTexture >
```
对照 JS `this._indirectTexture = null`（BatchedMesh.js:278），渲染器初始化时注入。

### var \_matricesTexture
```cj
public var _matricesTexture: Option < DataTexture >
```
对照 JS `this._matricesTexture = null`（BatchedMesh.js:277），渲染器初始化时注入。

### var activeGeometryCount
```cj
public var activeGeometryCount: Int64
```
已激活几何数量（已 addGeometry 且未 deleteGeometry 的）。

### var activeInstanceCount
```cj
public var activeInstanceCount: Int64
```
已激活实例数量（各几何 instanceCount 之和）。

### var boundingBox
```cj
public var boundingBox: Array < Option < Box3 >>
```
各几何的包围盒数组（按 geometryId 索引，computeBoundingBoxAt 后填充）。

### var boundingSphere
```cj
public var boundingSphere: Array < Option < Sphere >>
```
各几何的包围球数组（按 geometryId 索引，computeBoundingSphereAt 后填充）。

### var geometryVisible
```cj
public var geometryVisible: Array < Bool >
```
命名为 geometryVisible 以避免与父类 Object3D.visible 同名遮蔽。

### var indexCount
```cj
public var indexCount: Array < Int64 >
```
各几何的索引数量数组（按 geometryId 索引）。

### var instanceCount
```cj
public var instanceCount: Array < Int64 >
```
各几何的实例数量数组（按 geometryId 索引）。

### var matrices
```cj
public var matrices: Array < Matrix4 >
```
各几何的空间变换矩阵数组（按 geometryId 索引）。

### var maxGeometryCount
```cj
public var maxGeometryCount: Int64
```
Maximum geometry count (fixed at construction)

### var maxIndexCount
```cj
public var maxIndexCount: Int64
```
最大索引数量上限（所有几何合并后的索引总数上限）。

### var maxVertexCount
```cj
public var maxVertexCount: Int64
```
最大顶点数量上限（所有几何合并后的顶点总数上限）。

### var vertexCount
```cj
public var vertexCount: Array < Int64 >
```
各几何的顶点数量数组（按 geometryId 索引）。

