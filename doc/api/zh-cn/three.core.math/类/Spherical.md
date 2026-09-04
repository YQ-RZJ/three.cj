# 类
## class Spherical
```cj
public class Spherical
```
球坐标类，用于表示三维空间中的点

### func clone\(\)
```cj
public func clone(): Spherical
```
克隆当前球坐标

返回: 

- 新的球坐标实例

### func copy\(Spherical\)
```cj
public func copy(other: Spherical): Spherical
```
复制另一个球坐标的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|other|Spherical|要复制的球坐标|

返回: 

- 当前实例

### func init\(\)
```cj
public init()
```


### func init\(Float64,Float64,Float64\)
```cj
public init(radius: Float64, phi: Float64, theta: Float64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64||
|phi|Float64||
|theta|Float64||

### func makeSafe\(\)
```cj
public func makeSafe(): Spherical
```
将极角 phi 限制在 [0.000001, π - 0.000001] 范围内，避免极点奇异性

返回: 

- 当前实例

### func setFromCartesianCoords\(Float64,Float64,Float64\)
```cj
public func setFromCartesianCoords(x: Float64, y: Float64, z: Float64): Spherical
```
从笛卡尔坐标设置球坐标

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 坐标y y 坐标z z 坐标|
|y|Float64||
|z|Float64||

返回: 

- 当前实例

### func setFromVector3\(Vector3\)
```cj
public func setFromVector3(v: Vector3): Spherical
```
从笛卡尔坐标向量设置球坐标

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|包含笛卡尔坐标的向量|

返回: 

- 当前实例

### func set\(Float64,Float64,Float64\)
```cj
public func set(radius: Float64, phi: Float64, theta: Float64): Spherical
```
设置球坐标分量

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径phi 极角（弧度）theta 方位角（弧度）|
|phi|Float64||
|theta|Float64||

返回: 

- 当前实例

### func toVector3\(\)
```cj
public func toVector3(): Vector3
```
将球坐标转换为三维向量

返回: 

- 对应的三维向量

### var phi
```cj
public var phi: Float64
```
从 y（上）轴开始的极角（弧度）

### var radius
```cj
public var radius: Float64
```
半径，即从原点到点的欧几里得距离

### var theta
```cj
public var theta: Float64
```
绕 y（上）轴的方位角（弧度）

