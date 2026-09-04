# 类
## class Points
```cj
public class Points <: Object3D
```
点集渲染对象，将一组顶点渲染为独立像素方块

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新点集实例

返回: 

- 新点集实例

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定点集实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 返回 this

### func getCullingGeometry\(\)
```cj
public override func getCullingGeometry(): Option < IGeometryProvider >
```
提供本点云几何体供裁剪/包围盒计算（覆写 Object3D 钩子）

返回: 

- 本点云几何体

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material())
```
构造一个新的点集

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|顶点/索引几何，默认空 BufferGeometrymaterial 点材质，默认空 Material|
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
public func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
射线相交检测

参数: 

|名称|类型|描述|
|---|---|---|
|raycaster|Raycaster|射线发射器intersects 命中结果累加数组|
|intersects|ArrayList<Intersection>||

### func updateMorphTargets\(\)
```cj
public func updateMorphTargets(): Unit
```
更新 morph target 字典与影响系数

### var geometry
```cj
public var geometry: BufferGeometry
```
顶点/索引几何

### var material
```cj
public var material: Material
```
点材质

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

