# 类
## class Plane
```cj
public class Plane
```
平面类，使用单位法向量和常数表示

### func applyMatrix4\(Matrix4,Option<Matrix3>\)
```cj
public func applyMatrix4(matrix: Matrix4, optionalNormalMatrix!: Option < Matrix3 >= None): Plane
```
应用 4x4 矩阵变换平面

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Matrix4|变换矩阵optionalNormalMatrix 可选的法线矩阵|
|optionalNormalMatrix|Option<Matrix3>||

返回: 

- 当前实例

### func clone\(\)
```cj
public func clone(): Plane
```
克隆当前平面

返回: 

- 新的平面实例

### func coplanarPoint\(Vector3\)
```cj
public func coplanarPoint(target: Vector3): Vector3
```
获取平面上的共面点（原点在平面上的投影）

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量|

返回: 

- 共面点

### func copy\(Plane\)
```cj
public func copy(p: Plane): Plane
```
复制另一个平面的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|p|Plane|源平面|

返回: 

- 当前实例

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
计算点到平面的有符号距离

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|目标点|

返回: 

- 有符号距离

### func distanceToSphere\(Sphere\)
```cj
public func distanceToSphere(sphere: Sphere): Float64
```
计算球体到平面的有符号距离

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|目标球体|

返回: 

- 有符号距离

### func equals\(Plane\)
```cj
public func equals(p: Plane): Bool
```
判断是否与另一个平面相等

参数: 

|名称|类型|描述|
|---|---|---|
|p|Plane|比较的平面|

返回: 

- 是否相等

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Float64\)
```cj
public init(normal: Vector3, constant: Float64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3||
|constant|Float64||

### func intersectLine\(Line3,Vector3,Bool\)
```cj
public func intersectLine(line: Line3, target: Vector3, clampToLine!: Bool = true): Option < Vector3 >
```
计算直线与平面的交点

参数: 

|名称|类型|描述|
|---|---|---|
|line|Line3|直线target 目标向量clampToLine 是否限制在线段范围内，默认为 true|
|target|Vector3||
|clampToLine|Bool||

返回: 

- 交点，如果不相交返回 None

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
判断包围盒是否与平面相交

参数: 

|名称|类型|描述|
|---|---|---|
|box|Box3|包围盒|

返回: 

- 是否相交

### func intersectsLine\(Line3\)
```cj
public func intersectsLine(line: Line3): Bool
```
判断线段是否与平面相交

参数: 

|名称|类型|描述|
|---|---|---|
|line|Line3|线段|

返回: 

- 是否相交

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
判断球体是否与平面相交

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|球体|

返回: 

- 是否相交

### func negate\(\)
```cj
public func negate(): Plane
```
反转平面（法向量和常数取反）

返回: 

- 当前实例

### func normalize\(\)
```cj
public func normalize(): Plane
```
归一化法向量并调整常数

返回: 

- 当前实例

### func projectPoint\(Vector3,Vector3\)
```cj
public func projectPoint(point: Vector3, target: Vector3): Vector3
```
将点投影到平面上

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要投影的点target 目标向量|
|target|Vector3||

返回: 

- 投影点

### func setComponents\(Float64,Float64,Float64,Float64\)
```cj
public func setComponents(x: Float64, y: Float64, z: Float64, w: Float64): Plane
```
通过分量值设置平面

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|法向量 x 分量y 法向量 y 分量z 法向量 z 分量w 常数|
|y|Float64||
|z|Float64||
|w|Float64||

返回: 

- 当前实例

### func setFromCoplanarPoints\(Vector3,Vector3,Vector3\)
```cj
public func setFromCoplanarPoints(a: Vector3, b: Vector3, c: Vector3): Plane
```
从三个共面点设置平面

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|第一个点b 第二个点c 第三个点|
|b|Vector3||
|c|Vector3||

返回: 

- 当前实例

### func setFromNormalAndCoplanarPoint\(Vector3,Vector3\)
```cj
public func setFromNormalAndCoplanarPoint(normal: Vector3, point: Vector3): Plane
```
从法向量和共面点设置平面

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法向量point 共面点|
|point|Vector3||

返回: 

- 当前实例

### func set\(Vector3,Float64\)
```cj
public func set(normal: Vector3, constant: Float64): Plane
```
设置平面分量

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|法向量constant 常数|
|constant|Float64||

返回: 

- 当前实例

### func translate\(Vector3\)
```cj
public func translate(offset: Vector3): Plane
```
平移平面

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Vector3|偏移向量|

返回: 

- 当前实例

### var constant
```cj
public var constant: Float64
```
从原点到平面的有符号距离

### var normal
```cj
public var normal: Vector3
```
平面法向量（单位向量）

