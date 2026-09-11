# 类
## class SkinnedMesh
```cj
public class SkinnedMesh <: Mesh
```
蒙皮网格，带骨骼蒙皮变形的 Mesh

### func applyBoneTransform\(Int64,Vector3\)
```cj
public func applyBoneTransform(index: Int64, target: Vector3): Vector3
```
应用髀骨变换到指定顶点位置，返回变换后位置

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引target 接收结果的目标向量|
|target|Vector3||

返回: 

- 变换后的顶点位置

### func applySkinningJob\(\)
```cj
public func applySkinningJob(): Unit
```
使用 SkinningJob 批量蒙皮所有顶点

### func bind\(Skeleton,Option<Matrix4>\)
```cj
public func bind(skeleton: Skeleton, bindMatrix!: Option < Matrix4 >= None): Unit
```
绑定骨骼到本网格

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|Skeleton|骨骼实例bindMatrix 自定义绑定矩阵，默认 None 表示用本对象 matrixWorld|
|bindMatrix|Option<Matrix4>||

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新蒙皮网格实例

返回: 

- 新蒙皮网格实例

### func computeBoundingBox\(\)
```cj
public func computeBoundingBox(): Unit
```
计算几何包围盒

### func computeBoundingSphere\(\)
```cj
public func computeBoundingSphere(): Unit
```
计算几何包围球

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定蒙皮网格实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 返回 this

### func getVertexPosition\(Int64,Vector3\)
```cj
public override func getVertexPosition(index: Int64, target: Vector3): Vector3
```
取指定顶点位置（蒙皮变换后），覆写 Mesh.getVertexPosition

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引target 接收结果的目标向量|
|target|Vector3||

返回: 

- 蒙皮变换后的顶点位置

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material())
```
构造一个新的蒙皮网格

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|顶点/索引几何material 材质|
|material|Material||

### func normalizeSkinWeights\(\)
```cj
public func normalizeSkinWeights(): Unit
```
归一化 skinWeight 属性：各顶点权重缩放为总和 1，避免渲染瑕疵

### func pose\(\)
```cj
public func pose(): Unit
```
将骨骼 pose 到初始姿势

### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public override func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
射线相交检测（复用基类 Mesh.raycast，命中处 getVertexPosition 已被覆写为 applyBoneTransform）

参数: 

|名称|类型|描述|
|---|---|---|
|raycaster|Raycaster|射线发射器intersects 命中结果累加数组|
|intersects|ArrayList<Intersection>||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
更新本对象及其骨骼的世界矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新|

### var bindMatrixInverse
```cj
public var bindMatrixInverse: Matrix4
```
绑定姿势矩阵的逆（派生量：updateMatrixWorld 每帧由 bindMatrix/matrixWorld 重算，不参与 JSON）

### var bindMatrix
```cj
public var bindMatrix: Matrix4
```
绑定姿势矩阵（世界空间）

### var bindMode
```cj
public var bindMode: String
```
绑定姿势模式：AttachedBindMode（随本对象矩阵）或 DetachedBindMode（固定 bindMatrix）

### var skeleton
```cj
public var skeleton: Skeleton
```
骨骼实例（管理 bones/boneInverses/boneMatrices）

