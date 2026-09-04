# 类
## class Raycaster
```cj
public class Raycaster
```
射线投射器类，用于鼠标拾取等射线相交测试

### func init\(Vector3,Vector3,Float64,Float64\)
```cj
public init(origin!: Vector3 = Vector3(), direction!: Vector3 = Vector3(0.0, 0.0, 1.0), near!: Float64 = 0.0, far!: Float64 = Float64.Inf)
```
构造新的射线投射器

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线原点向量direction 射线方向向量（应已归一化）near 所有返回结果都比 near 更远，near 不能为负数，默认为 0far 所有返回结果都比 far 更近，far 不能低于 near，默认为 Infinity|
|direction|Vector3||
|near|Float64||
|far|Float64||

### func intersectObject\(Object3D,Bool\)
```cj
public func intersectObject(object: Object3D, recursive!: Bool = true): ArrayList < Intersection >
```
检查射线与对象的全部相交（含/不含后代），结果按距离升序排列

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|要检查的 3D 对象recursive 是否递归检查后代，默认为 true|
|recursive|Bool||

返回: 

- 保存相交结果的数组

### func intersectObjects\(Array<Object3D>,Bool\)
```cj
public func intersectObjects(objects: Array < Object3D >, recursive!: Bool = true): ArrayList < Intersection >
```
检查射线与多个对象的全部相交（含/不含后代），结果按距离升序排列

参数: 

|名称|类型|描述|
|---|---|---|
|objects|Array<Object3D>|要检查的 3D 对象数组recursive 是否递归检查后代，默认为 true|
|recursive|Bool||

返回: 

- 保存相交结果的数组

### func setFromCamera\(Vector2,Object3D\)
```cj
public func setFromCamera(coords: Vector2, camera: Object3D): Unit
```
使用给定的坐标和相机计算射线内部的新原点和方向

参数: 

|名称|类型|描述|
|---|---|---|
|coords|Vector2|鼠标的 2D 坐标，使用 NDC（标准化设备坐标），X 和 Y 分量应在 -1 到 1 之间camera 射线应从其发出的相机|
|camera|Object3D||

### func set\(Vector3,Vector3\)
```cj
public func set(origin: Vector3, direction: Vector3): Unit
```
使用新原点和方向更新射线

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线原点向量direction 射线方向向量（应已归一化）|
|direction|Vector3||

### var camera
```cj
public var camera:?Object3D
```
当对视图相关对象（如 Sprite）进行射线投射时使用的相机

### var far
```cj
public var far: Float64
```
所有返回的结果都比 far 更近。far 不能低于 near

### var layers
```cj
public var layers: Layers
```
允许在执行相交测试时选择性地忽略 3D 对象

### var near
```cj
public var near: Float64
```
所有返回的结果都比 near 更远。near 不能为负数

### var params
```cj
public var params: RaycasterParams
```
配置射线投射的参数对象（Line/Points 阈值等）

### var ray
```cj
public var ray: Ray
```
用于射线投射的射线

