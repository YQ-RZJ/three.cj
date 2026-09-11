# 类
## class SoaFloat3
```cj
public class SoaFloat3
```
SoA 三分量向量结构体，存储 4 个向量

### func add\(SoaFloat3\)
```cj
public func add(rhs: SoaFloat3): Unit
```
加法：this += rhs（逐元素）

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SoaFloat3||

### func cross\(SoaFloat3\)
```cj
public func cross(rhs: SoaFloat3): SoaFloat3
```
逐槽位叉积

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SoaFloat3|右操作数|

返回: 

- SoaFloat3 包含 4 个叉积结果

### func dot\(SoaFloat3\)
```cj
public func dot(rhs: SoaFloat3): SimdFloat
```
逐槽位点积，返回 4 个点积结果

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SoaFloat3|右操作数|

返回: 

- SimdFloat 包含 4 个点积值

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(x0: Float32, y0: Float32, z0: Float32, x1: Float32, y1: Float32, z1: Float32, x2: Float32, y2: Float32, z2: Float32, x3: Float32, y3: Float32, z3: Float32): SoaFloat3
```
从 4 个单向量构造

参数: 

|名称|类型|描述|
|---|---|---|
|x0|Float32||
|y0|Float32||
|z0|Float32||
|x1|Float32||
|y1|Float32||
|z1|Float32||
|x2|Float32||
|y2|Float32||
|z2|Float32||
|x3|Float32||
|y3|Float32||
|z3|Float32||

### func get\(Int\)
```cj
public func get(slot: Int): Vector3F
```
获取指定槽位的三分量向量

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|

返回: 

- (x, y, z)

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为零向量

### func init\(Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(x: Array < Float32 >, y: Array < Float32 >, z: Array < Float32 >)
```
从原始数组构造

参数: 

|名称|类型|描述|
|---|---|---|
|x|Array<Float32>|x 分量数组（4 个元素）|
|y|Array<Float32>|y 分量数组（4 个元素）|
|z|Array<Float32>|z 分量数组（4 个元素）|

### func length\(\)
```cj
public func length(): SimdFloat
```
逐槽位 length（向量长度）

返回: 

- SimdFloat 包含 4 个长度值

### func lerp\(SoaFloat3,SoaFloat3,SimdFloat\)
```cj
public static func lerp(a: SoaFloat3, b: SoaFloat3, t: SimdFloat): SoaFloat3
```
线性插值：result = a + (b - a) * t

参数: 

|名称|类型|描述|
|---|---|---|
|a|SoaFloat3|起始值|
|b|SoaFloat3|目标值|
|t|SimdFloat|插值因子（SimdFloat，每槽独立）|

返回: 

- 插值结果

### func negate\(\)
```cj
public func negate(): Unit
```
逐槽位取反

### func normalize\(\)
```cj
public func normalize(): Unit
```
逐槽位归一化

### func scale\(Float32\)
```cj
public func scale(scalar: Float32): Unit
```
标量乘法：this *= scalar（逐元素）

参数: 

|名称|类型|描述|
|---|---|---|
|scalar|Float32||

### func set\(Int,Float32,Float32,Float32\)
```cj
public func set(slot: Int, vx: Float32, vy: Float32, vz: Float32): Unit
```
设置指定槽位的三分量向量

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|
|vx|Float32|x 分量|
|vy|Float32|y 分量|
|vz|Float32|z 分量|

### func sub\(SoaFloat3\)
```cj
public func sub(rhs: SoaFloat3): Unit
```
减法：this -= rhs（逐元素）

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SoaFloat3||

### func zero\(\)
```cj
public static func zero(): SoaFloat3
```
创建零向量

### var x
```cj
public var x: Array < Float32 >
```
4 个向量的 x 分量

### var y
```cj
public var y: Array < Float32 >
```
4 个向量的 y 分量

### var z
```cj
public var z: Array < Float32 >
```
4 个向量的 z 分量

