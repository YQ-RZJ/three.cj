# 类
## class SimdFloat
```cj
public class SimdFloat
```
4-wide 标量浮点数

### func add\(SimdFloat\)
```cj
public func add(rhs: SimdFloat): Unit
```
加法：this = this + rhs

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

### func fromFour\(Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(v0: Float32, v1: Float32, v2: Float32, v3: Float32): SimdFloat
```
从 4 个标量值构造

参数: 

|名称|类型|描述|
|---|---|---|
|v0|Float32|lane 0|
|v1|Float32|lane 1|
|v2|Float32|lane 2|
|v3|Float32|lane 3|

### func greaterThan\(SimdFloat\)
```cj
public func greaterThan(rhs: SimdFloat): SimdFloat
```
逐 lane 大于比较

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

返回: 

- SimdFloat，结果为 1.0f32或 0.0f

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为零

### func init\(Float32\)
```cj
public init(scalar: Float32)
```
从标量值构造（4 个 lane 相同）

参数: 

|名称|类型|描述|
|---|---|---|
|scalar|Float32|标量值|

### func init\(Array<Float32>\)
```cj
public init(values: Array < Float32 >)
```
从原始数组构造

参数: 

|名称|类型|描述|
|---|---|---|
|values|Array<Float32>|4 个元素的数组|

### func lerp\(SimdFloat,SimdFloat,SimdFloat\)
```cj
public static func lerp(a: SimdFloat, b: SimdFloat, t: SimdFloat): SimdFloat
```
逐 lane 线性插值：result = a + (b - a) * t

参数: 

|名称|类型|描述|
|---|---|---|
|a|SimdFloat|起始值|
|b|SimdFloat|目标值|
|t|SimdFloat|插值因子|

返回: 

- 插值结果

### func lessThan\(SimdFloat\)
```cj
public func lessThan(rhs: SimdFloat): SimdFloat
```
逐 lane 小于比较

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

返回: 

- SimdFloat，结果为 1.0f32或 0.0f

### func max\(SimdFloat\)
```cj
public func max(rhs: SimdFloat): Unit
```
逐 lane 取最大值

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

### func min\(SimdFloat\)
```cj
public func min(rhs: SimdFloat): Unit
```
逐 lane 取最小值

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

### func mulScalar\(Float32\)
```cj
public func mulScalar(scalar: Float32): Unit
```
标量乘法：this = this * scalar

参数: 

|名称|类型|描述|
|---|---|---|
|scalar|Float32||

### func mul\(SimdFloat\)
```cj
public func mul(rhs: SimdFloat): Unit
```
乘法：this = this * rhs

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

### func negate\(\)
```cj
public func negate(): SimdFloat
```
逐 lane 取反

### func one\(\)
```cj
public static func one(): SimdFloat
```
创建全一

### func sqrt\(\)
```cj
public func sqrt(): SimdFloat
```
逐 lane 平方根

### func sub\(SimdFloat\)
```cj
public func sub(rhs: SimdFloat): Unit
```
减法：this = this - rhs

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|SimdFloat||

### func zero\(\)
```cj
public static func zero(): SimdFloat
```
创建全零

### var values
```cj
public var values: Array < Float32 >
```
4 个 lane 的值

