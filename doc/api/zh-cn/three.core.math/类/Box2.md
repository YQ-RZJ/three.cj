# 类
## class Box2
```cj
public class Box2
```
2D 轴对齐包围盒类，用最小点和最大点表示

### func clampPoint\(Vector2,Vector2\)
```cj
public func clampPoint(point: Vector2, target: Vector2): Vector2
```
将点限制在包围盒内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector2|要限制的点target 目标向量|
|target|Vector2||

返回: 

- 限制后的点

### func clone\(\)
```cj
public func clone(): Box2
```
克隆当前包围盒

返回: 

- 新的包围盒实例

### func containsBox\(Box2\)
```cj
public func containsBox(b: Box2): Bool
```
判断是否完全包含另一个包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box2|另一个包围盒|

返回: 

- 是否包含

### func containsPoint\(Vector2\)
```cj
public func containsPoint(point: Vector2): Bool
```
判断点是否在包围盒内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector2|要检测的点|

返回: 

- 是否包含

### func copy\(Box2\)
```cj
public func copy(b: Box2): Box2
```
复制另一个包围盒的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box2|源包围盒|

返回: 

- 当前实例

### func distanceToPoint\(Vector2\)
```cj
public func distanceToPoint(point: Vector2): Float64
```
计算点到包围盒的欧几里得距离

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector2|要计算距离的点|

返回: 

- 距离

### func equals\(Box2\)
```cj
public func equals(b: Box2): Bool
```
判断是否与另一个包围盒相等

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box2|另一个包围盒|

返回: 

- 是否相等

### func expandByPoint\(Vector2\)
```cj
public func expandByPoint(point: Vector2): Box2
```
扩展包围盒以包含给定点

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector2|要包含的点|

返回: 

- 当前实例

### func expandByScalar\(Float64\)
```cj
public func expandByScalar(s: Float64): Box2
```
按标量扩展包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|扩展标量|

返回: 

- 当前实例

### func expandByVector\(Vector2\)
```cj
public func expandByVector(v: Vector2): Box2
```
按向量扩展包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|扩展向量|

返回: 

- 当前实例

### func getCenter\(Vector2\)
```cj
public func getCenter(target: Vector2): Vector2
```
获取包围盒的中心点

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector2|目标向量，用于存储结果|

返回: 

- 中心点

### func getParameter\(Vector2,Vector2\)
```cj
public func getParameter(point: Vector2, target: Vector2): Vector2
```
获取点在包围盒中的参数化位置（0-1 范围）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector2|要检测的点target 目标向量|
|target|Vector2||

返回: 

- 参数化位置

### func getSize\(Vector2\)
```cj
public func getSize(target: Vector2): Vector2
```
获取包围盒的尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector2|目标向量，用于存储结果|

返回: 

- 尺寸向量

### func init\(\)
```cj
public init()
```
构造空包围盒（min=+Inf, max=-Inf）

### func init\(Vector2,Vector2\)
```cj
public init(min: Vector2, max: Vector2)
```
用指定的最小点和最大点构造包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|最小点max 最大点|
|max|Vector2||

### func intersect\(Box2\)
```cj
public func intersect(b: Box2): Box2
```
计算与另一个包围盒的交集

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box2|另一个包围盒|

返回: 

- 当前实例

### func intersectsBox\(Box2\)
```cj
public func intersectsBox(b: Box2): Bool
```
判断是否与另一个包围盒相交

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box2|另一个包围盒|

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
public func makeEmpty(): Box2
```
将包围盒置空（使其不包含任何点）

返回: 

- 当前实例

### func setFromCenterAndSize\(Vector2,Vector2\)
```cj
public func setFromCenterAndSize(center: Vector2, size: Vector2): Box2
```
从中心和大小设置包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|中心点size 尺寸|
|size|Vector2||

返回: 

- 当前实例

### func setFromPoints\(ArrayList<Vector2>\)
```cj
public func setFromPoints(points: ArrayList < Vector2 >): Box2
```
从点集设置包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|points|ArrayList<Vector2>|点集合|

返回: 

- 当前实例

### func set\(Vector2,Vector2\)
```cj
public func set(min: Vector2, max: Vector2): Box2
```
设置包围盒的上下边界

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|最小点max 最大点|
|max|Vector2||

返回: 

- 当前实例

### func translate\(Vector2\)
```cj
public func translate(offset: Vector2): Box2
```
平移包围盒

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Vector2|偏移量|

返回: 

- 当前实例

### func union\(Box2\)
```cj
public func union(b: Box2): Box2
```
计算与另一个包围盒的并集

参数: 

|名称|类型|描述|
|---|---|---|
|b|Box2|另一个包围盒|

返回: 

- 当前实例

### var max
```cj
public var max: Vector2
```
包围盒的上边界

### var min
```cj
public var min: Vector2
```
包围盒的下边界

