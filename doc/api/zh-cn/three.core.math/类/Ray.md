# 类
## class Ray
```cj
public class Ray
```
射线类，由起点和方向向量定义

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): Ray
```
应用 4x4 矩阵变换射线

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|变换矩阵|

返回: 

- 当前实例

### func at\(Float64,Vector3\)
```cj
public func at(t: Float64, target: Vector3): Vector3
```
获取射线上参数 t 处的点

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|参数值target 目标向量|
|target|Vector3||

返回: 

- 射线上的点

### func at\(Float64\)
```cj
public func at(t: Float64): Vector3
```
获取射线上参数 t 处的点（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|参数值|

返回: 

- 射线上的点

### func clone\(\)
```cj
public func clone(): Ray
```
克隆当前射线

返回: 

- 新的射线实例

### func closestPointToPoint\(Vector3,Vector3\)
```cj
public func closestPointToPoint(point: Vector3, target: Vector3): Vector3
```
计算点到射线的最近点

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点target 目标向量|
|target|Vector3||

返回: 

- 最近点

### func closestPointToPoint\(Vector3\)
```cj
public func closestPointToPoint(point: Vector3): Vector3
```
计算点到射线的最近点（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点|

返回: 

- 最近点

### func copy\(Ray\)
```cj
public func copy(r: Ray): Ray
```
复制另一条射线的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|r|Ray|源射线|

返回: 

- 当前实例

### func distanceSqToPoint\(Vector3\)
```cj
public func distanceSqToPoint(point: Vector3): Float64
```
计算点到射线距离的平方

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|目标点|

返回: 

- 距离的平方

### func distanceSqToSegment\(Vector3,Vector3,Option<Vector3>,Option<Vector3>\)
```cj
public func distanceSqToSegment(v0: Vector3, v1: Vector3, optionalPointOnRay!: Option < Vector3 >= None, optionalPointOnSegment!: Option < Vector3 >= None): Float64
```
计算射线与线段之间的最短距离平方

参数: 

|名称|类型|描述|
|---|---|---|
|v0|Vector3|线段起点v1 线段终点optionalPointOnRay 射线上最近点（可选）optionalPointOnSegment 线段上最近点（可选）|
|v1|Vector3||
|optionalPointOnRay|Option<Vector3>||
|optionalPointOnSegment|Option<Vector3>||

返回: 

- 距离平方

### func distanceToPlane\(Plane\)
```cj
public func distanceToPlane(plane: Plane): Float64
```
计算射线到平面的距离

参数: 

|名称|类型|描述|
|---|---|---|
|plane|Plane|平面|

返回: 

- 距离，如果平行返回 -1

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
计算点到射线的距离

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|目标点|

返回: 

- 距离

### func equals\(Ray\)
```cj
public func equals(r: Ray): Bool
```
判断是否与另一条射线相等

参数: 

|名称|类型|描述|
|---|---|---|
|r|Ray|比较的射线|

返回: 

- 是否相等

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Vector3\)
```cj
public init(origin: Vector3, direction: Vector3)
```


参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3||
|direction|Vector3||

### func intersectBox\(Box3,Vector3\)
```cj
public func intersectBox(box: Box3, target: Vector3): Option < Vector3 >
```
计算射线与包围盒的交点

参数: 

|名称|类型|描述|
|---|---|---|
|box|Box3|包围盒target 目标向量|
|target|Vector3||

返回: 

- 交点，如果不相交返回 None

### func intersectPlane\(Plane,Vector3\)
```cj
public func intersectPlane(plane: Plane, target: Vector3): Option < Vector3 >
```
计算射线与平面的交点

参数: 

|名称|类型|描述|
|---|---|---|
|plane|Plane|平面target 目标向量|
|target|Vector3||

返回: 

- 交点，如果不相交返回 None

### func intersectSphere\(Sphere,Vector3\)
```cj
public func intersectSphere(sphere: Sphere, target: Vector3): Option < Vector3 >
```
计算射线与球体的交点

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|球体target 目标向量|
|target|Vector3||

返回: 

- 交点，如果不相交返回 None

### func intersectTriangle\(Vector3,Vector3,Vector3,Bool,Vector3\)
```cj
public func intersectTriangle(a: Vector3, b: Vector3, c: Vector3, backfaceCulling: Bool, target: Vector3): Option < Vector3 >
```
计算射线与三角形的交点（Watertight 算法）

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|三角形顶点 ab 三角形顶点 bc 三角形顶点 cbackfaceCulling 是否启用背面剔除target 目标向量|
|b|Vector3||
|c|Vector3||
|backfaceCulling|Bool||
|target|Vector3||

返回: 

- 交点，如果不相交返回 None

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
判断射线是否与包围盒相交

参数: 

|名称|类型|描述|
|---|---|---|
|box|Box3|包围盒|

返回: 

- 是否相交

### func intersectsPlane\(Plane\)
```cj
public func intersectsPlane(plane: Plane): Bool
```
判断射线是否与平面相交

参数: 

|名称|类型|描述|
|---|---|---|
|plane|Plane|平面|

返回: 

- 是否相交

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
判断射线是否与球体相交

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|球体|

返回: 

- 是否相交

### func lookAt\(Vector3\)
```cj
public func lookAt(v: Vector3): Ray
```
使射线朝向目标点

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|目标点|

返回: 

- 当前实例

### func recast\(Float64\)
```cj
public func recast(t: Float64): Ray
```
沿射线方向移动起点

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|移动距离|

返回: 

- 当前实例

### func set\(Vector3,Vector3\)
```cj
public func set(origin: Vector3, direction: Vector3): Ray
```
设置射线的起点和方向

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|起点direction 方向|
|direction|Vector3||

返回: 

- 当前实例

### var direction
```cj
public var direction: Vector3
```
射线方向（应为单位向量）

### var origin
```cj
public var origin: Vector3
```
射线起点

