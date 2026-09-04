# 类
## class Sphere
```cj
public class Sphere
```
球体类，用中心点和半径表示

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Sphere
```
应用 4x4 矩阵变换球体

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
将点限制在球面上

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点target 目标向量|
|target|Vector3||

返回: 

- 限制后的点

### func clone\(\)
```cj
public func clone(): Sphere
```
克隆当前球体

返回: 

- 新的球体实例

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
判断点是否在球体内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|目标点|

返回: 

- 是否包含

### func copy\(Sphere\)
```cj
public func copy(s: Sphere): Sphere
```
复制另一个球体的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|s|Sphere|源球体|

返回: 

- 当前实例

### func distanceToPoint\(Vector3\)
```cj
public func distanceToPoint(point: Vector3): Float64
```
计算点到球面的距离

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|目标点|

返回: 

- 距离

### func equals\(Sphere\)
```cj
public func equals(s: Sphere): Bool
```
判断是否与另一个球体相等

参数: 

|名称|类型|描述|
|---|---|---|
|s|Sphere|比较的球体|

返回: 

- 是否相等

### func expandByPoint\(Vector3\)
```cj
public func expandByPoint(point: Vector3): Sphere
```
扩展球体以包含给定点

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要包含的点|

返回: 

- 当前实例

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Sphere
```
从 JSON 反序列化设置包围球

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|序列化的包围球 HashMap|

返回: 

- 当前实例的引用

### func getBoundingBox\(\)
```cj
public func getBoundingBox(): Box3
```
获取球体的包围盒（创建新包围盒）

返回: 

- 包围盒

### func getBoundingBox\(Box3\)
```cj
public func getBoundingBox(target: Box3): Box3
```
获取球体的包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|target|Box3|目标包围盒|

返回: 

- 包围盒

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Float64\)
```cj
public init(center: Vector3, radius: Float64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector3||
|radius|Float64||

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
判断是否与包围盒相交

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
判断是否与平面相交

参数: 

|名称|类型|描述|
|---|---|---|
|plane|Plane|平面|

返回: 

- 是否相交

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(s: Sphere): Bool
```
判断是否与另一个球体相交

参数: 

|名称|类型|描述|
|---|---|---|
|s|Sphere|另一个球体|

返回: 

- 是否相交

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
判断球体是否为空

返回: 

- 是否为空

### func makeEmpty\(\)
```cj
public func makeEmpty(): Sphere
```
将球体置空（半径设为 -1）

返回: 

- 当前实例

### func setFromPoints\(ArrayList<Vector3>,Option<Vector3>\)
```cj
public func setFromPoints(points: ArrayList < Vector3 >, optionalCenter!: Option < Vector3 >= None): Sphere
```
从点集设置球体

参数: 

|名称|类型|描述|
|---|---|---|
|points|ArrayList<Vector3>|点集合optionalCenter 可选的中心点|
|optionalCenter|Option<Vector3>||

返回: 

- 当前实例

### func set\(Vector3,Float64\)
```cj
public func set(center: Vector3, radius: Float64): Sphere
```
设置球体的中心和半径

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector3|球心radius 半径|
|radius|Float64||

返回: 

- 当前实例

### func translate\(Vector3\)
```cj
public func translate(offset: Vector3): Sphere
```
平移球体

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Vector3|偏移量|

返回: 

- 当前实例

### func union\(Sphere\)
```cj
public func union(sphere: Sphere): Sphere
```
扩展球体以包含另一个球体

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|要包含的球体|

返回: 

- 当前实例

### var center
```cj
public var center: Vector3
```
球心

### var radius
```cj
public var radius: Float64
```
半径

