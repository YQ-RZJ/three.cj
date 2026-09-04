# 类
## class Line
```cj
public open class Line <: Object3D
```
线渲染对象，从一组顶点按顺序连接的连续折线

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新线实例

返回: 

- 新线实例

### func computeLineDistances\(\)
```cj
public open func computeLineDistances(): Line
```
计算并写入几何的 lineDistance 属性（各顶点沿折线累计距离）

返回: 

- 返回 this 以支持链式调用

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定线实例的值复制到本实例

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
提供本线几何体供裁剪/包围盒计算（覆写 Object3D 钩子）

返回: 

- 本线几何体

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial())
```
构造一个新的线渲染对象

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|顶点/索引几何，默认空 BufferGeometrymaterial 线材质，默认空 LineBasicMaterial|
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

### var geometry
```cj
public var geometry: BufferGeometry
```
顶点/索引几何

### var material
```cj
public var material: Material
```
线材质

