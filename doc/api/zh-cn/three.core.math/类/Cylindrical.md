# 类
## class Cylindrical
```cj
public class Cylindrical
```
圆柱坐标类，用于表示三维空间中的点

### func clone\(\)
```cj
public func clone(): Cylindrical
```
克隆当前圆柱坐标

返回: 

- 新的圆柱坐标实例

### func copy\(Cylindrical\)
```cj
public func copy(other: Cylindrical): Cylindrical
```
复制另一个圆柱坐标的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|other|Cylindrical|要复制的圆柱坐标|

返回: 

- 当前实例

### func init\(\)
```cj
public init()
```
构造默认圆柱坐标 (1, 0, 0)

### func init\(Float64,Float64,Float64\)
```cj
public init(radius: Float64, theta: Float64, y: Float64)
```
用指定分量构造圆柱坐标

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径theta 角度（弧度）y 高度|
|theta|Float64||
|y|Float64||

### func setFromCartesianCoords\(Float64,Float64,Float64\)
```cj
public func setFromCartesianCoords(x: Float64, y: Float64, z: Float64): Cylindrical
```
从笛卡尔坐标设置圆柱坐标

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
public func setFromVector3(v: Vector3): Cylindrical
```
从笛卡尔坐标向量设置圆柱坐标

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|包含笛卡尔坐标的向量|

返回: 

- 当前实例

### func set\(Float64,Float64,Float64\)
```cj
public func set(radius: Float64, theta: Float64, y: Float64): Cylindrical
```
设置圆柱坐标分量

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径theta 角度（弧度）y 高度|
|theta|Float64||
|y|Float64||

返回: 

- 当前实例

### var radius
```cj
public var radius: Float64
```
从原点到 xz 平面上某点的距离

### var theta
```cj
public var theta: Float64
```
在 xz 平面上从正 z 轴逆时针测量的角度（弧度）

### var y
```cj
public var y: Float64
```
xz 平面以上的高度

