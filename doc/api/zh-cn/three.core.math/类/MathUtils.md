# 类
## class MathUtils
```cj
public class MathUtils
```
数学工具类，提供常用的数学函数集合

### func ceilPowerOfTwo\(Int64\)
```cj
public static func ceilPowerOfTwo(value: Int64): Int64
```
返回大于或等于给定数的最小 2 的幂

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|要查找的值，必须大于 0|

返回: 

- 最小的 2 的幂

### func clamp\(Float64,Float64,Float64\)
```cj
public static func clamp(v: Float64, min: Float64, max: Float64): Float64
```
将值限制在 [min, max] 范围内

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float64|要限制的值min 最小值max 最大值|
|min|Float64||
|max|Float64||

返回: 

- 限制后的值

### func damp\(Float64,Float64,Float64,Float64\)
```cj
public static func damp(x: Float64, y: Float64, lambda: Float64, dt: Float64): Float64
```
使用弹簧阻尼方式平滑插值，帧率无关

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|当前值y 目标值lambda 阻尼系数，值越大变化越突然dt 时间增量（秒）|
|y|Float64||
|lambda|Float64||
|dt|Float64||

返回: 

- 插值结果

### func degToRad\(Float64\)
```cj
public static func degToRad(degrees: Float64): Float64
```
将角度转换为弧度

参数: 

|名称|类型|描述|
|---|---|---|
|degrees|Float64|角度值|

返回: 

- 弧度值

### func denormalize\(Float64,Int64\)
```cj
public static func denormalize(value: Float64, componentType: Int64): Float64
```
根据类型数组的类型对值进行反归一化，将 [0,1] 范围的浮点值转换为对应类型的整数值

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|要反归一化的值componentType 组件类型标识（0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8）|
|componentType|Int64||

返回: 

- 反归一化后的值

### func euclideanModulo\(Int64,Int64\)
```cj
public static func euclideanModulo(n: Int64, m: Int64): Int64
```
计算欧几里得取模：((n % m) + m) % m

参数: 

|名称|类型|描述|
|---|---|---|
|n|Int64|被除数m 除数|
|m|Int64||

返回: 

- 欧几里得取模结果

### func euclideanModulo\(Float64,Float64\)
```cj
public static func euclideanModulo(n: Float64, m: Float64): Float64
```
计算浮点数欧几里得取模：结果始终为非负数

参数: 

|名称|类型|描述|
|---|---|---|
|n|Float64|被除数m 除数|
|m|Float64||

返回: 

- 欧几里得取模结果

### func floorPowerOfTwo\(Int64\)
```cj
public static func floorPowerOfTwo(value: Int64): Int64
```
返回小于或等于给定数的最大 2 的幂

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|要查找的值，必须大于 0|

返回: 

- 最大的 2 的幂

### func generateUUID\(\)
```cj
public static func generateUUID(): String
```
生成 UUID（通用唯一标识符）

返回: 

- UUID 字符串

### func inverseLerp\(Float64,Float64,Float64\)
```cj
public static func inverseLerp(x: Float64, y: Float64, value: Float64): Float64
```
返回给定值在起点和终点之间的闭区间 [0, 1] 中的百分比

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|起点值y 终点值value 介于起点和终点之间的值|
|y|Float64||
|value|Float64||

返回: 

- 插值因子

### func isPowerOfTwo\(Int64\)
```cj
public static func isPowerOfTwo(value: Int64): Bool
```
判断给定数值是否为 2 的幂

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|要检查的值|

返回: 

- 是否为 2 的幂

### func lerp\(Float64,Float64,Float64\)
```cj
public static func lerp(x: Float64, y: Float64, t: Float64): Float64
```
线性插值：t = 0 返回 x，t = 1 返回 y

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|起点值y 终点值t 插值因子，闭区间 [0, 1]|
|y|Float64||
|t|Float64||

返回: 

- 插值结果

### func mapLinear\(Float64,Float64,Float64,Float64,Float64\)
```cj
public static func mapLinear(x: Float64, a1: Float64, a2: Float64, b1: Float64, b2: Float64): Float64
```
将值从范围 [a1, a2] 线性映射到范围 [b1, b2]

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|要映射的值a1 范围 A 的最小值a2 范围 A 的最大值b1 范围 B 的最小值b2 范围 B 的最大值|
|a1|Float64||
|a2|Float64||
|b1|Float64||
|b2|Float64||

返回: 

- 映射后的值

### func normalize\(Float64,Int64\)
```cj
public static func normalize(value: Float64, componentType: Int64): Float64
```
根据类型数组的类型对值进行归一化，将整数值转换为 [0,1] 范围的浮点值

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|要归一化的浮点值componentType 组件类型标识（0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8）|
|componentType|Int64||

返回: 

- 归一化后的值

### func pingpong\(Float64,Float64\)
```cj
public static func pingpong(x: Float64, length!: Float64 = 1.0): Float64
```
返回在 0 和给定 length 之间交替的值

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|要乒乓的值length 乒乓到的正值，默认为 1|
|length|Float64||

返回: 

- 交替后的值

### func radToDeg\(Float64\)
```cj
public static func radToDeg(radians: Float64): Float64
```
将弧度转换为角度

参数: 

|名称|类型|描述|
|---|---|---|
|radians|Float64|弧度值|

返回: 

- 角度值

### func randFloatSpread\(Float64\)
```cj
public static func randFloatSpread(range: Float64): Float64
```
返回 [-range/2, range/2] 区间内的随机浮点数

参数: 

|名称|类型|描述|
|---|---|---|
|range|Float64|范围|

返回: 

- 随机浮点数

### func randFloat\(Float64,Float64\)
```cj
public static func randFloat(low: Float64, high: Float64): Float64
```
返回 [low, high] 区间内的随机浮点数

参数: 

|名称|类型|描述|
|---|---|---|
|low|Float64|下界high 上界|
|high|Float64||

返回: 

- 随机浮点数

### func randInt\(Int64,Int64\)
```cj
public static func randInt(low: Int64, high: Int64): Int64
```
返回 [low, high] 区间内的随机整数

参数: 

|名称|类型|描述|
|---|---|---|
|low|Int64|下界high 上界|
|high|Int64||

返回: 

- 随机整数

### func seededRandom\(Option<Int64>\)
```cj
public static func seededRandom(s!: Option < Int64 >= None): Float64
```
返回 [0, 1] 区间内的确定性伪随机浮点数（Mulberry32 生成器）

参数: 

|名称|类型|描述|
|---|---|---|
|s|Option<Int64>|可选的整数种子|

返回: 

- 伪随机浮点数

### func setQuaternionFromProperEuler\(Quaternion,Float64,Float64,Float64,String\)
```cj
public static func setQuaternionFromProperEuler(q: Quaternion, a: Float64, b: Float64, c: Float64, order: String): Unit
```
从内禀真欧拉角设置四元数

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|要设置的四元数a 第一个轴的旋转角度（弧度）b 第二个轴的旋转角度（弧度）c 第三个轴的旋转角度（弧度）order 轴顺序字符串，如 "XYX"、"XZX"、"YXY" 等|
|a|Float64||
|b|Float64||
|c|Float64||
|order|String||

### func smootherstep\(Float64,Float64,Float64\)
```cj
public static func smootherstep(x: Float64, min: Float64, max: Float64): Float64
```
smoothstep 的变体，在 x=0 和 x=1 处具有零一阶和二阶导数

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|要评估的值min 最小值，低于此值返回 0max 最大值，高于此值返回 1|
|min|Float64||
|max|Float64||

返回: 

- 更平滑的插值结果

### func smoothstep\(Float64,Float64,Float64\)
```cj
public static func smoothstep(x: Float64, min: Float64, max: Float64): Float64
```
返回 x 在 [min, max] 之间移动的平滑百分比，值域 [0, 1]

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|要评估的值min 最小值，低于此值返回 0max 最大值，高于此值返回 1|
|min|Float64||
|max|Float64||

返回: 

- 平滑插值结果

