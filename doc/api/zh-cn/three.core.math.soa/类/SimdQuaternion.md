# 类
## class SimdQuaternion
```cj
public class SimdQuaternion
```
4-wide 标量四元数

### func conjugate\(\)
```cj
public func conjugate(): Unit
```
共轭：将 4 个四元数各自取共轭（-x, -y, -z, w）

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(x0: Float32, y0: Float32, z0: Float32, w0: Float32, x1: Float32, y1: Float32, z1: Float32, w1: Float32, x2: Float32, y2: Float32, z2: Float32, w2: Float32, x3: Float32, y3: Float32, z3: Float32, w3: Float32): SimdQuaternion
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

### func fromSoa\(SoaQuaternion\)
```cj
public static func fromSoa(soa: SoaQuaternion): SimdQuaternion
```


参数: 

|名称|类型|描述|
|---|---|---|
|soa|SoaQuaternion||

### func identity\(\)
```cj
public static func identity(): SimdQuaternion
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
|x|Array<Float32>||
|y|Array<Float32>||
|z|Array<Float32>||
|w|Array<Float32>||

### func mul\(SimdQuaternion\)
```cj
public func mul(rhs: SimdQuaternion): Unit
```
逐槽位乘法：this[i] = this[i] * rhs[i]

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdQuaternion||

### func normalize\(\)
```cj
public func normalize(): Unit
```
归一化：将 4 个四元数各自归一化

### func splat\(Float32,Float32,Float32,Float32\)
```cj
public static func splat(qx: Float32, qy: Float32, qz: Float32, qw: Float32): SimdQuaternion
```


参数: 

|名称|类型|描述|
|---|---|---|
|qx|Float32||
|qy|Float32||
|qz|Float32||
|qw|Float32||

### func toSoa\(\)
```cj
public func toSoa(): SoaQuaternion
```


### var w
```cj
public var w: Array < Float32 >
```
4 个 lane 的 w 分量

### var x
```cj
public var x: Array < Float32 >
```
4 个 lane 的 x 分量

### var y
```cj
public var y: Array < Float32 >
```
4 个 lane 的 y 分量

### var z
```cj
public var z: Array < Float32 >
```
4 个 lane 的 z 分量

