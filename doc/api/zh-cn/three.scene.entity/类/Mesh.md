# 类
## class Mesh
```cj
public open class Mesh <: Object3D & IMesh
```
网格渲染对象，3D 场景中最常用的三角形面片渲染实体

### func copy\(Mesh,Bool\)
```cj
public func copy(source: Mesh, recursive!: Bool = true): Mesh
```
将给定网格实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Mesh|源网格recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 返回 this

### func getCullingGeometry\(\)
```cj
public override func getCullingGeometry(): Option < IGeometryProvider >
```
提供本网格几何体供裁剪/包围盒计算（覆写 Object3D 钩子）

返回: 

- 本网格几何体

### func getPreciseVertexCount\(\)
```cj
public override func getPreciseVertexCount(): Int64
```
精确模式逐顶点遍历的顶点数（覆写 Object3D）

返回: 

- 顶点数（InstancedMesh/无 position 属性返回 0）

### func getPreciseVertexPosition\(Int64\)
```cj
public override func getPreciseVertexPosition(i: Int64): Array < Float64 >
```
第 i 个顶点的世界空间位置（覆写 Object3D）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|顶点索引|

返回: 

- 世界空间坐标 [x, y, z]

### func getVertexPosition\(Int64,Vector3\)
```cj
public open func getVertexPosition(index: Int64, target: Vector3): Vector3
```
获取指定顶点位置

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引target 接收结果的目标向量|
|target|Vector3||

返回: 

- 顶点位置

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material())
```
构造一个新的网格

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|顶点/索引几何，默认空 BufferGeometrymaterial 材质，默认空 Material|
|material|Material||

### func intersectsFrustum\(Frustum\)
```cj
public func intersectsFrustum(frustum: Frustum): Bool
```
视锥剔除测试

参数: 

|名称|类型|描述|
|---|---|---|
|frustum|Frustum|视锥体|

返回: 

- 与视锥相交返回 true

### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public open func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
射线相交检测

参数: 

|名称|类型|描述|
|---|---|---|
|raycaster|Raycaster|射线发射器intersects 命中结果累加数组|
|intersects|ArrayList<Intersection>||

### func updateMorphTargets\(\)
```cj
public open func updateMorphTargets(): Unit
```
更新 morph target 字典与影响系数

### var count
```cj
public var count: Int64
```
实例计数（InstancedMesh 使用）

### var geometry
```cj
public var geometry: BufferGeometry
```
顶点/索引几何

### var material
```cj
public var material: Material
```
材质

### var morphTargetDictionary
```cj
public var morphTargetDictionary: HashMap < String, Int64 >
```
morph target 名称→索引字典（动画混合形状）

### var morphTargetInfluences
```cj
public var morphTargetInfluences: Array < Float64 >
```
morph target 影响系数数组

