# Class
## class InstancedMesh
```cj
public class InstancedMesh <: Mesh
```
Instanced mesh that renders the same geometry/material multiple times with independent transform/color

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新实例化网格实例。

### func computeBoundingBox\(\)
```cj
public func computeBoundingBox(): Unit
```
expand 到 boundingBox；几何本身包围盒由 Mesh.computeBoundingBox 处理（此处仅实例位置）。

### func computeBoundingSphere\(\)
```cj
public func computeBoundingSphere(): Unit
```
计算包围球。与 JS side 一致：先 computeBoundingBox，再用 box.getBoundingSphere 填充。

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定实例化网格实例的值复制到本实例。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D||
|recursive|Bool||

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放本实例分配的 GPU 相关资源。

### func getColorAt\(Int64,Color\)
```cj
public func getColorAt(index: Int64, color: Color): Color
```
color - 接收结果的目标颜色。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64||
|color|Color||

### func getMatrixAt\(Int64,Matrix4\)
```cj
public func getMatrixAt(index: Int64, matrix: Matrix4): Matrix4
```
matrix - 接收结果的目标矩阵。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64||
|matrix|Matrix4||

### func getMorphAt\(Int64,Array<Float64>\)
```cj
public func getMorphAt(index: Int64, influences: Array < Float64 >): Array < Float64 >
```
influences - 接收结果的目标数组（长度需 ≥ objectInfluences.length，本实现按目标数组长度读回）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64||
|influences|Array<Float64>||

### func init\(BufferGeometry,Material,Int64\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material(), count!: Int64 = 0)
```
count - 实例数量。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry||
|material|Material||
|count|Int64||

### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public override func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
intersects - 命中结果累加数组。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|raycaster|Raycaster||
|intersects|ArrayList<Intersection>||

### func setColorAt\(Int64,Color\)
```cj
public func setColorAt(index: Int64, color: Color): Unit
```
color - 颜色。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64||
|color|Color||

### func setMatrixAt\(Int64,Matrix4\)
```cj
public func setMatrixAt(index: Int64, matrix: Matrix4): Unit
```
matrix - 变换矩阵。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64||
|matrix|Matrix4||

### func setMorphAt\(Int64,Array<Float64>\)
```cj
public func setMorphAt(index: Int64, influences: Array < Float64 >): Unit
```
influences - morph target 影响系数数组（即 JS 的 object.morphTargetInfluences）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64||
|influences|Array<Float64>||

### func updateMorphTargets\(\)
```cj
public override func updateMorphTargets(): Unit
```
但 morph target 数据存储在 morphTexture 中（每实例独立）。

### var boundingBox
```cj
public var boundingBox: Option < Box3 >
```
包围盒（可选，computeBoundingBox 后填充）。

### var boundingSphere
```cj
public var boundingSphere: Option < Sphere >
```
包围球（可选，computeBoundingSphere 后填充）。

### var instanceColor
```cj
public var instanceColor: Option < InstancedBufferAttribute >
```
实例颜色缓冲（可选，None 表示无独立颜色，用材质颜色）。

### var instanceMatrix
```cj
public var instanceMatrix: InstancedBufferAttribute
```
Instance transform matrix buffer (16 Float64 per instance, column-major)

### var morphTexture
```cj
public var morphTexture: Option < DataTexture >
```
morph target 贴图（可选，用于实例化 morph target 的纹理存储）。

