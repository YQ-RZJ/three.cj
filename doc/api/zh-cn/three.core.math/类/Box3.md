# 类
## class Box3
```cj
public class Box3
```
3D 轴对齐包围盒类，用最小点和最大点表示

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Box3
```
应用 4x4 矩阵变换包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Matrix4|变换矩阵|

返回: 

- 当前实例

### func clampPoint\(Vector3,Vector3\)
```cj
public func clampPoint(point: Vector3, target: Vector3): Vector3
```
将点限制在包围盒内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要限制的点target 目标向量|
|target|Vector3||

返回: 

- 限制后的点

### func clone\(\)
```cj
public func clone(): Box3
```
克隆当前包围盒

返回: 

- 新的包围盒实例

### func containsBox\(Box3\)
```cj
public func containsBox(b: Box3): Bool
```
判断是否完全包含另一个包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box3|另一个包围盒|

返回: 

- 是否包含

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
判断点是否在包围盒内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要检测的点|

返回: 

- 是否包含

### func copy\(Box3\)
```cj
public func copy(b: Box3): Box3
```
复制另一个包围盒的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box3|源包围盒|

返回: 

- 当前实例

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
计算点到包围盒的欧几里得距离

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要计算距离的点|

返回: 

- 距离

### func equals\(Box3\)
```cj
public func equals(b: Box3): Bool
```
判断是否与另一个包围盒相等

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box3|另一个包围盒|

返回: 

- 是否相等

### func expandByObject\(IBox3Expandable,Bool\)
```cj
public func expandByObject(object: IBox3Expandable, precise: Bool): Box3
```
递归展开对象（含子对象）的几何体包围盒并合并

参数: 

|名称|类型|描述|
|---|---|---|
|object|IBox3Expandable|实现 IBox3Expandable 的对象precise 是否精确计算|
|precise|Bool||

返回: 

- 当前实例

### func expandByPoint\(Vector3\)
```cj
public func expandByPoint(point: Vector3): Box3
```
扩展包围盒以包含给定点

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要包含的点|

返回: 

- 当前实例

### func expandByScalar\(Float64\)
```cj
public func expandByScalar(s: Float64): Box3
```
按标量扩展包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|扩展标量|

返回: 

- 当前实例

### func expandByVector\(Vector3\)
```cj
public func expandByVector(v: Vector3): Box3
```
按向量扩展包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|扩展向量|

返回: 

- 当前实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Box3
```
从 JSON 反序列化设置包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|序列化的包围盒 HashMap|

返回: 

- 当前实例

### func getBoundingSphere\(\)
```cj
public func getBoundingSphere(): Sphere
```
获取包围盒的外接球（创建新球体）

返回: 

- 外接球

### func getBoundingSphere\(Sphere\)
```cj
public func getBoundingSphere(target: Sphere): Sphere
```
获取包围盒的外接球

参数: 

|名称|类型|描述|
|---|---|---|
|target|Sphere|目标球体|

返回: 

- 外接球

### func getCenter\(\)
```cj
public func getCenter(): Vector3
```
获取包围盒的中心点（创建新向量）

返回: 

- 中心点

### func getCenter\(Vector3\)
```cj
public func getCenter(target: Vector3): Vector3
```
获取包围盒的中心点

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量，用于存储结果|

返回: 

- 中心点

### func getParameter\(Vector3,Vector3\)
```cj
public func getParameter(point: Vector3, target: Vector3): Vector3
```
获取点在包围盒中的参数化位置（0-1 范围）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要检测的点target 目标向量|
|target|Vector3||

返回: 

- 参数化位置

### func getSize\(\)
```cj
public func getSize(): Vector3
```
获取包围盒的尺寸（创建新向量）

返回: 

- 尺寸向量

### func getSize\(Vector3\)
```cj
public func getSize(target: Vector3): Vector3
```
获取包围盒的尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量，用于存储结果|

返回: 

- 尺寸向量

### func init\(\)
```cj
public init()
```
构造空包围盒（min=+Inf, max=-Inf）

### func init\(Vector3,Vector3\)
```cj
public init(min: Vector3, max: Vector3)
```
用指定的最小点和最大点构造包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector3|最小点max 最大点|
|max|Vector3||

### func intersect\(Box3\)
```cj
public func intersect(b: Box3): Box3
```
计算与另一个包围盒的交集

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box3|另一个包围盒|

返回: 

- 当前实例

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(b: Box3): Bool
```
判断是否与另一个包围盒相交

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box3|另一个包围盒|

返回: 

- 是否相交

### func intersectsPlane\(Plane\)
```cj
public func intersectsPlane(plane: Plane): Bool
```
判断是否与平面相交

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
判断是否与球体相交

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|球体|

返回: 

- 是否相交

### func intersectsTriangle\(Triangle\)
```cj
public func intersectsTriangle(triangle: Triangle): Bool
```
判断是否与三角形相交（使用 SAT 分离轴定理）

参数: 

|名称|类型|描述|
|---|---|---|
|triangle|Triangle|三角形|

返回: 

- 是否相交

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
判断包围盒是否为空

返回: 

- 是否为空

### func makeEmpty\(\)
```cj
public func makeEmpty(): Box3
```
将包围盒置空（使其不包含任何点）

返回: 

- 当前实例

### func setFromArray\(Array<Float64>\)
```cj
public func setFromArray(array: Array < Float64 >): Box3
```
从浮点数组设置包围盒（每3个元素一个点）

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|包含坐标数据的数组|

返回: 

- 当前实例

### func setFromBufferAttribute\(AttributeReader\)
```cj
public func setFromBufferAttribute(attribute: AttributeReader): Box3
```
从顶点属性设置包围盒，使其包含属性中的全部位置数据

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|AttributeReader|顶点属性（AttributeReader 接口，由 BufferAttribute 实现）|

返回: 

- 当前实例

### func setFromCenterAndSize\(Vector3,Vector3\)
```cj
public func setFromCenterAndSize(center: Vector3, size: Vector3): Box3
```
从中心和大小设置包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector3|中心点size 尺寸|
|size|Vector3||

返回: 

- 当前实例

### func setFromObject\(IBox3Expandable,Bool\)
```cj
public func setFromObject(object: IBox3Expandable, precise!: Bool = false): Box3
```
从对象（含子对象）设置包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|object|IBox3Expandable|实现 IBox3Expandable 的对象（Object3D 及子类）precise 是否精确计算（当前实现走保守路径）|
|precise|Bool||

返回: 

- 当前实例

### func setFromPoints\(ArrayList<Vector3>\)
```cj
public func setFromPoints(points: ArrayList < Vector3 >): Box3
```
从点集设置包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|points|ArrayList<Vector3>|点集合|

返回: 

- 当前实例

### func setFromPoints\(Array<Vector3>\)
```cj
public func setFromPoints(points: Array < Vector3 >): Box3
```
从点集设置包围盒（Array 版本）

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|点数组|

返回: 

- 当前实例

### func set\(Vector3,Vector3\)
```cj
public func set(min: Vector3, max: Vector3): Box3
```
设置包围盒的上下边界

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector3|最小点max 最大点|
|max|Vector3||

返回: 

- 当前实例

### func translate\(Vector3\)
```cj
public func translate(offset: Vector3): Box3
```
平移包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Vector3|偏移量|

返回: 

- 当前实例

### func union\(Box3\)
```cj
public func union(b: Box3): Box3
```
计算与另一个包围盒的并集

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box3|另一个包围盒|

返回: 

- 当前实例

### var max
```cj
public var max: Vector3
```
包围盒的上边界

### var min
```cj
public var min: Vector3
```
包围盒的下边界

