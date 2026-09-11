# 类
## class Line3
```cj
public class Line3
```
三维线段类，由起点和终点定义

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Line3
```
应用 4x4 变换矩阵到线段（起点与终点分别变换）

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Matrix4|变换矩阵|

返回: 

- 当前实例

### func at\(Float64,Vector3\)
```cj
public func at(t: Float64, target: Vector3): Vector3
```
获取线段上指定参数位置的点

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|参数值，0 为起点，1 为终点target 目标向量|
|target|Vector3||

返回: 

- 线段上的点

### func at\(Float64\)
```cj
public func at(t: Float64): Vector3
```
获取线段上指定参数位置的点（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|参数值，0 为起点，1 为终点|

返回: 

- 线段上的点

### func clone\(\)
```cj
public func clone(): Line3
```
克隆当前线段

返回: 

- 新的线段实例

### func closestPointToPointParameter\(Vector3,Bool\)
```cj
public func closestPointToPointParameter(point: Vector3, clampToLine!: Bool = true): Float64
```
计算点到线段的最近点参数

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点clampToLine 是否限制在线段范围内，默认为 true|
|clampToLine|Bool||

返回: 

- 参数值

### func closestPointToPoint\(Vector3,Vector3,Bool\)
```cj
public func closestPointToPoint(point: Vector3, target: Vector3, clampToLine!: Bool = true): Vector3
```
计算点到线段的最近点

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点target 目标向量clampToLine 是否限制在线段范围内，默认为 true|
|target|Vector3||
|clampToLine|Bool||

返回: 

- 最近点

### func closestPointToPoint\(Vector3,Bool\)
```cj
public func closestPointToPoint(point: Vector3, clampToLine!: Bool = true): Vector3
```
计算点到线段的最近点（创建新向量）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点clampToLine 是否限制在线段范围内，默认为 true|
|clampToLine|Bool||

返回: 

- 最近点

### func copy\(Line3\)
```cj
public func copy(l: Line3): Line3
```
复制另一个线段的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|l|Line3|源线段|

返回: 

- 当前实例

### func delta\(Vector3\)
```cj
public func delta(target: Vector3): Vector3
```
计算线段的方向向量（终点 - 起点）

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量|

返回: 

- 方向向量

### func delta\(\)
```cj
public func delta(): Vector3
```
计算线段的方向向量（创建新向量）

返回: 

- 方向向量

### func distanceSqToLine3\(Line3,Vector3,Vector3\)
```cj
public func distanceSqToLine3(line: Line3, c1: Vector3, c2: Vector3): Float64
```
计算两条线段之间的最近距离平方

参数: 

|名称|类型|描述|
|---|---|---|
|line|Line3|另一条线段c1 本线段上的最近点（输出）c2 另一线段上的最近点（输出）|
|c1|Vector3||
|c2|Vector3||

返回: 

- 最近距离的平方

### func distanceSq\(\)
```cj
public func distanceSq(): Float64
```
计算线段长度的平方

返回: 

- 长度的平方

### func distance\(\)
```cj
public func distance(): Float64
```
计算线段的长度

返回: 

- 长度

### func equals\(Line3\)
```cj
public func equals(l: Line3): Bool
```
判断是否与另一个线段相等

参数: 

|名称|类型|描述|
|---|---|---|
|l|Line3|另一个线段|

返回: 

- 是否相等

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Line3
```
从数组设置线段分量

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|包含分量值的数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### func getCenter\(Vector3\)
```cj
public func getCenter(target: Vector3): Vector3
```
获取线段中心点

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量|

返回: 

- 中心点

### func getCenter\(\)
```cj
public func getCenter(): Vector3
```
获取线段中心点（创建新向量）

返回: 

- 中心点

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Vector3\)
```cj
public init(start: Vector3, end: Vector3)
```


参数: 

|名称|类型|描述|
|---|---|---|
|start|Vector3||
|end|Vector3||

### func set\(Vector3,Vector3\)
```cj
public func set(start: Vector3, end: Vector3): Line3
```
设置线段的起点和终点

参数: 

|名称|类型|描述|
|---|---|---|
|start|Vector3|起点end 终点|
|end|Vector3||

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将线段分量写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 包含分量值的数组

### var end
```cj
public var end: Vector3
```
线段终点

### var start
```cj
public var start: Vector3
```
线段起点

