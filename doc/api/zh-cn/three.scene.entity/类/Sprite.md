# 类
## class Sprite
```cj
public class Sprite <: Object3D
```
精灵渲染对象，始终朝向相机的 2D 平面

### func \_getUnitQuadGeometry\(\)
```cj
public static func _getUnitQuadGeometry(): BufferGeometry
```


### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新精灵实例

返回: 

- 新精灵实例

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定精灵实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 返回 this

### func getWorldBoundingSphere\(\)
```cj
public override func getWorldBoundingSphere(): Option < Array < Float64 >>
```
计算精灵的世界空间包围球（覆写 Object3D）

返回: 

- Some([cx, cy, cz, radius]) 或 None

### func init\(Material\)
```cj
public init(material!: Material = SpriteMaterial())
```
构造一个新的精灵

参数: 

|名称|类型|描述|
|---|---|---|
|material|Material|精灵材质，默认空 SpriteMaterial|

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

### var center
```cj
public var center: Vector2
```
中心点偏移（归一化 UV 坐标系下，0.0~1.0），默认 (0.5, 0.5) 即中心

### var material
```cj
public var material: Material
```
精灵材质（必为 SpriteMaterial）

