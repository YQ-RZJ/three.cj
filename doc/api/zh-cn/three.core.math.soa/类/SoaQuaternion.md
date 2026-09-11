# 类
## class SoaQuaternion
```cj
public class SoaQuaternion
```
SoA 四元数结构体，存储 4 个四元数

### func conjugate\(\)
```cj
public func conjugate(): Unit
```
共轭：将 4 个四元数各自取共轭（-x, -y, -z, w）

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(x0: Float32, y0: Float32, z0: Float32, w0: Float32, x1: Float32, y1: Float32, z1: Float32, w1: Float32, x2: Float32, y2: Float32, z2: Float32, w2: Float32, x3: Float32, y3: Float32, z3: Float32, w3: Float32): SoaQuaternion
```
从 4 个单四元数值构造

参数: 

|名称|类型|描述|
|---|---|---|
|x0|Float32||
|y0|Float32||
|z0|Float32||
|w0|Float32||
|x1|Float32||
|y1|Float32||
|z1|Float32||
|w1|Float32||
|x2|Float32||
|y2|Float32||
|z2|Float32||
|w2|Float32||
|x3|Float32||
|y3|Float32||
|z3|Float32||
|w3|Float32||

### func get\(Int\)
```cj
public func get(slot: Int): QuaternionF
```
获取指定槽位的四元数分量

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|

返回: 

- (x, y, z, w)

### func identity\(\)
```cj
public static func identity(): SoaQuaternion
```
创建 4 个单位四元数

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为 4 个单位四元数

### func init\(Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(x: Array < Float32 >, y: Array < Float32 >, z: Array < Float32 >, w: Array < Float32 >)
```
从原始数组构造

参数: 

|名称|类型|描述|
|---|---|---|
|x|Array<Float32>|x 分量数组（4 个元素）|
|y|Array<Float32>|y 分量数组（4 个元素）|
|z|Array<Float32>|z 分量数组（4 个元素）|
|w|Array<Float32>|w 分量数组（4 个元素）|

### func mul\(SoaQuaternion\)
```cj
public func mul(rhs: SoaQuaternion): Unit
```
逐槽位乘法：this[i] = this[i] * rhs[i]

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SoaQuaternion|右操作数|

### func nlerp\(SoaQuaternion,SoaQuaternion,Array<Float32>\)
```cj
public static func nlerp(a: SoaQuaternion, b: SoaQuaternion, t: Array < Float32 >): SoaQuaternion
```
逐槽位 nlerp（归一化线性插值）

参数: 

|名称|类型|描述|
|---|---|---|
|a|SoaQuaternion||
|b|SoaQuaternion||
|t|Array<Float32>|插值因子数组（4 个元素，每个槽位独立）|

### func normalize\(\)
```cj
public func normalize(): Unit
```
归一化：将 4 个四元数各自归一化

### func set\(Int,Float32,Float32,Float32,Float32\)
```cj
public func set(slot: Int, qx: Float32, qy: Float32, qz: Float32, qw: Float32): Unit
```
设置指定槽位的四元数分量

参数: 

|名称|类型|描述|
|---|---|---|
|slot|Int|槽位索引 (0-3)|
|qx|Float32|x 分量|
|qy|Float32|y 分量|
|qz|Float32|z 分量|
|qw|Float32|w 分量|

### var w
```cj
public var w: Array < Float32 >
```
4 个四元数的 w 分量

### var x
```cj
public var x: Array < Float32 >
```
4 个四元数的 x 分量

### var y
```cj
public var y: Array < Float32 >
```
4 个四元数的 y 分量

### var z
```cj
public var z: Array < Float32 >
```
4 个四元数的 z 分量

