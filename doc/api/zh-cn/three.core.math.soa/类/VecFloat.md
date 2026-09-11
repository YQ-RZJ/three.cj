# 类
## class VecFloat
```cj
public class VecFloat
```
Float32 三分量向量工具对象

### func add\(Array<Float32>,Array<Float32>\)
```cj
public func add(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
加法：result = a + b

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>|左操作数（长度≥3）|
|b|Array<Float32>|右操作数（长度≥3）|

返回: 

- 结果（长度3）

### func cross\(Array<Float32>,Array<Float32>\)
```cj
public func cross(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
叉积：result = a × b

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

返回: 

- 结果（长度3）

### func distance\(Array<Float32>,Array<Float32>\)
```cj
public func distance(a: Array < Float32 >, b: Array < Float32 >): Float32
```
两点间距离

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>|起点|
|b|Array<Float32>|终点|

返回: 

- Float32 距离值

### func dot\(Array<Float32>,Array<Float32>\)
```cj
public func dot(a: Array < Float32 >, b: Array < Float32 >): Float32
```
点积：result = a·b

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

返回: 

- Float32 标量结果

### func lengthSq\(Array<Float32>\)
```cj
public func lengthSq(v: Array < Float32 >): Float32
```
向量长度的平方（避免开方）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Array<Float32>||

返回: 

- Float32 长度平方值

### func length\(Array<Float32>\)
```cj
public func length(v: Array < Float32 >): Float32
```
向量长度

参数: 

|名称|类型|描述|
|---|---|---|
|v|Array<Float32>||

返回: 

- Float32 长度值

### func lerp\(Array<Float32>,Array<Float32>,Float32\)
```cj
public func lerp(a: Array < Float32 >, b: Array < Float32 >, t: Float32): Array < Float32 >
```
线性插值：result = a + (b - a) * t

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>|起始向量|
|b|Array<Float32>|目标向量|
|t|Float32|插值因子|

返回: 

- 插值结果（长度3）

### func max\(Array<Float32>,Array<Float32>\)
```cj
public func max(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
逐元素最大值

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

### func min\(Array<Float32>,Array<Float32>\)
```cj
public func min(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
逐元素最小值

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

### func negate\(Array<Float32>\)
```cj
public func negate(v: Array < Float32 >): Array < Float32 >
```
向量取反：result = -v

参数: 

|名称|类型|描述|
|---|---|---|
|v|Array<Float32>||

### func normalize\(Array<Float32>\)
```cj
public func normalize(v: Array < Float32 >): Array < Float32 >
```
归一化：result = v / |v|

参数: 

|名称|类型|描述|
|---|---|---|
|v|Array<Float32>|向量（长度≥3）|

返回: 

- 归一化后的向量（长度3），若长度接近零则返回原向量

### func one\(\)
```cj
public static func one(): Array < Float32 >
```
单位向量 (1, 1, 1)

### func scale\(Array<Float32>,Float32\)
```cj
public func scale(v: Array < Float32 >, s: Float32): Array < Float32 >
```
标量乘法：result = v * s

参数: 

|名称|类型|描述|
|---|---|---|
|v|Array<Float32>|向量（长度≥3）|
|s|Float32|标量|

返回: 

- 结果（长度3）

### func sub\(Array<Float32>,Array<Float32>\)
```cj
public func sub(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
减法：result = a - b

参数: 

|名称|类型|描述|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

### func zero\(\)
```cj
public static func zero(): Array < Float32 >
```
零向量

