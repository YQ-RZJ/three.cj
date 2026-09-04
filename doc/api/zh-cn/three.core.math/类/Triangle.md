# 类
## class Triangle
```cj
public class Triangle
```
三角形类，由三个顶点定义

### func clone\(\)
```cj
public func clone(): Triangle
```
克隆当前三角形

返回: 

- 新的三角形实例

### func closestPointToPoint\(Vector3,Vector3\)
```cj
public func closestPointToPoint(p: Vector3, target: Vector3): Vector3
```
计算三角形上离给定点最近的点

参数: 

|名称|类型|描述|
|---|---|---|
|p|Vector3|点target 目标向量|
|target|Vector3||

返回: 

- 最近点

### func closestPointToPoint\(Vector3\)
```cj
public func closestPointToPoint(p: Vector3): Vector3
```
计算三角形上离给定点最近的点（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|p|Vector3|点|

返回: 

- 最近点

### func computeBarycoord\(Vector3,Vector3,Vector3,Vector3,Vector3\)
```cj
public static func computeBarycoord(point: Vector3, a: Vector3, b: Vector3, c: Vector3, target: Vector3): Option < Vector3 >
```
静态方法：计算重心坐标

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点a 顶点 ab 顶点 bc 顶点 ctarget 目标向量|
|a|Vector3||
|b|Vector3||
|c|Vector3||
|target|Vector3||

返回: 

- 重心坐标，退化三角形返回 None

### func computeInterpolation\(Vector3,Vector3,Vector3,Vector3,Vector3,Vector3,Vector3,Vector3\)
```cj
public static func computeInterpolation(point: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, target: Vector3): Option < Vector3 >
```
静态方法：使用重心坐标插值

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|插值点位置p1 顶点 1p2 顶点 2p3 顶点 3v1 顶点 1 的值v2 顶点 2 的值v3 顶点 3 的值target 目标向量|
|p1|Vector3||
|p2|Vector3||
|p3|Vector3||
|v1|Vector3||
|v2|Vector3||
|v3|Vector3||
|target|Vector3||

返回: 

- 插值结果，退化三角形返回 None

### func computeNormal\(Vector3,Vector3,Vector3,Vector3\)
```cj
public static func computeNormal(a: Vector3, b: Vector3, c: Vector3, target: Vector3): Vector3
```
静态方法：计算三角形法向量

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|顶点 ab 顶点 bc 顶点 ctarget 目标向量|
|b|Vector3||
|c|Vector3||
|target|Vector3||

返回: 

- 法向量

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
判断点是否在三角形内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点|

返回: 

- 是否在三角形内

### func copy\(Triangle\)
```cj
public func copy(t: Triangle): Triangle
```
复制另一个三角形的值

参数: 

|名称|类型|描述|
|---|---|---|
|t|Triangle|源三角形|

返回: 

- 当前实例

### func equals\(Triangle\)
```cj
public func equals(t: Triangle): Bool
```
判断是否与另一个三角形相等

参数: 

|名称|类型|描述|
|---|---|---|
|t|Triangle|另一个三角形|

返回: 

- 是否相等

### func getArea\(\)
```cj
public func getArea(): Float64
```
计算三角形面积

返回: 

- 面积

### func getBarycoord\(Vector3,Vector3\)
```cj
public func getBarycoord(point: Vector3, target: Vector3): Option < Vector3 >
```
计算给定点的重心坐标

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点target 目标向量|
|target|Vector3||

返回: 

- 重心坐标，退化三角形返回 None

### func getBarycoord\(Vector3\)
```cj
public func getBarycoord(point: Vector3): Vector3
```
计算给定点的重心坐标（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点|

返回: 

- 重心坐标

### func getInterpolatedAttribute\(AttributeReader,Int64,Int64,Int64,Vector3,Vector3\)
```cj
public static func getInterpolatedAttribute(attr: AttributeReader, i1: Int64, i2: Int64, i3: Int64, barycoord: Vector3, target: Vector3): Vector3
```
插值顶点属性，用重心坐标对属性三个顶点的值做线性插值，写入 target

参数: 

|名称|类型|描述|
|---|---|---|
|attr|AttributeReader|顶点属性（AttributeReader 接口，由 BufferAttribute 实现）i1 顶点 a 的属性索引i2 顶点 b 的属性索引i3 顶点 c 的属性索引barycoord 重心坐标target 输出向量（写入插值结果）|
|i1|Int64||
|i2|Int64||
|i3|Int64||
|barycoord|Vector3||
|target|Vector3||

返回: 

- 插值后的 target

### func getInterpolation\(Vector3,Vector3,Vector3,Vector3,Vector3\)
```cj
public func getInterpolation(point: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, target: Vector3): Option < Vector3 >
```
使用重心坐标插值

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|插值点位置v1 顶点 1 的值v2 顶点 2 的值v3 顶点 3 的值target 目标向量|
|v1|Vector3||
|v2|Vector3||
|v3|Vector3||
|target|Vector3||

返回: 

- 插值结果，退化三角形返回 None

### func getMidpoint\(Vector3\)
```cj
public func getMidpoint(target: Vector3): Vector3
```
计算三角形的中点

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量|

返回: 

- 中点

### func getMidpoint\(\)
```cj
public func getMidpoint(): Vector3
```
计算三角形的中点（创建新向量）

返回: 

- 中点

### func getNormal\(Vector3\)
```cj
public func getNormal(target: Vector3): Vector3
```
计算三角形的法向量

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量|

返回: 

- 法向量

### func getNormal\(\)
```cj
public func getNormal(): Vector3
```
计算三角形的法向量（创建新向量）

返回: 

- 法向量

### func getPlane\(Plane\)
```cj
public func getPlane(target: Plane): Plane
```
计算三角形所在的平面

参数: 

|名称|类型|描述|
|---|---|---|
|target|Plane|目标平面|

返回: 

- 平面

### func getPlane\(\)
```cj
public func getPlane(): Plane
```
计算三角形所在的平面（创建新平面）

返回: 

- 平面

### func init\(\)
```cj
public init()
```
默认构造函数，初始化三个零向量顶点

### func init\(Vector3,Vector3,Vector3\)
```cj
public init(a: Vector3, b: Vector3, c: Vector3)
```
使用指定顶点构造三角形

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|顶点 ab 顶点 bc 顶点 c|
|b|Vector3||
|c|Vector3||

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
判断三角形是否与包围盒相交

参数: 

|名称|类型|描述|
|---|---|---|
|box|Box3|包围盒|

返回: 

- 是否相交

### func isFrontFacing\(Vector3\)
```cj
public func isFrontFacing(direction: Vector3): Bool
```
判断三角形是否朝向给定方向

参数: 

|名称|类型|描述|
|---|---|---|
|direction|Vector3|方向向量|

返回: 

- 是否朝向给定方向

### func setFromAttributeAndIndices\(AttributeReader,Int64,Int64,Int64\)
```cj
public func setFromAttributeAndIndices(attribute: AttributeReader, i0: Int64, i1: Int64, i2: Int64): Triangle
```
从顶点属性与索引设置三角形顶点

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|AttributeReader|顶点属性（AttributeReader 接口，由 BufferAttribute 实现）i0 顶点 a 的索引i1 顶点 b 的索引i2 顶点 c 的索引|
|i0|Int64||
|i1|Int64||
|i2|Int64||

返回: 

- 当前实例

### func setFromPointsAndIndices\(Array<Vector3>,Int64,Int64,Int64\)
```cj
public func setFromPointsAndIndices(points: Array < Vector3 >, i0: Int64, i1: Int64, i2: Int64): Triangle
```
从点数组和索引设置三角形顶点

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|点数组i0 顶点 a 的索引i1 顶点 b 的索引i2 顶点 c 的索引|
|i0|Int64||
|i1|Int64||
|i2|Int64||

返回: 

- 当前实例

### func set\(Vector3,Vector3,Vector3\)
```cj
public func set(a: Vector3, b: Vector3, c: Vector3): Triangle
```
设置三角形的顶点

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|顶点 ab 顶点 bc 顶点 c|
|b|Vector3||
|c|Vector3||

返回: 

- 当前实例

### func testContainsPoint\(Vector3,Vector3,Vector3,Vector3\)
```cj
public static func testContainsPoint(point: Vector3, a: Vector3, b: Vector3, c: Vector3): Bool
```
静态方法：判断点是否在三角形内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点a 顶点 ab 顶点 bc 顶点 c|
|a|Vector3||
|b|Vector3||
|c|Vector3||

返回: 

- 是否在三角形内

### func testIsFrontFacing\(Vector3,Vector3,Vector3,Vector3\)
```cj
public static func testIsFrontFacing(a: Vector3, b: Vector3, c: Vector3, direction: Vector3): Bool
```
静态方法：判断三角形是否朝向给定方向

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|顶点 ab 顶点 bc 顶点 cdirection 方向向量（应为单位向量）|
|b|Vector3||
|c|Vector3||
|direction|Vector3||

返回: 

- 是否朝向给定方向

### var a
```cj
public var a: Vector3
```
顶点 a

### var b
```cj
public var b: Vector3
```
顶点 b

### var c
```cj
public var c: Vector3
```
顶点 c

