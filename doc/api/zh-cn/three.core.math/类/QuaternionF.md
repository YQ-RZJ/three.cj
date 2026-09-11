# 类
## class QuaternionF
```cj
public class QuaternionF
```
Float32 四元数类，用于表示三维旋转

### func angleTo\(QuaternionF\)
```cj
public func angleTo(q: QuaternionF): Float32
```
计算与另一个四元数之间的角度

参数: 

|名称|类型|描述|
|---|---|---|
|q|QuaternionF|另一个四元数|

返回: 

- 两个四元数之间的角度（弧度）

### func clone\(\)
```cj
public func clone(): QuaternionF
```
克隆当前四元数

返回: 

- 新的四元数实例

### func conjugate\(\)
```cj
public func conjugate(): QuaternionF
```
计算四元数的共轭（反转旋转方向），假设四元数为单位四元数

返回: 

- 当前实例

### func copy\(QuaternionF\)
```cj
public func copy(q: QuaternionF): QuaternionF
```
复制另一个四元数的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|q|QuaternionF|源四元数|

返回: 

- 当前实例

### func dot\(QuaternionF\)
```cj
public func dot(q: QuaternionF): Float32
```
计算与给定四元数的点积

参数: 

|名称|类型|描述|
|---|---|---|
|q|QuaternionF|另一个四元数|

返回: 

- 点积结果

### func equals\(QuaternionF\)
```cj
public func equals(q: QuaternionF): Bool
```
比较两个四元数是否相等

参数: 

|名称|类型|描述|
|---|---|---|
|q|QuaternionF|另一个四元数|

返回: 

- 是否相等

### func fromArray\(Array<Float32>\)
```cj
public static func fromArray(arr: Array < Float32 >): QuaternionF
```
从 Array<Float32>（长度4）构造

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<Float32>|Float32 数组|

返回: 

- QuaternionF 实例

### func fromQuaternion\(Quaternion\)
```cj
public static func fromQuaternion(q: Quaternion): QuaternionF
```
从 Quaternion (Float64) 转换为 QuaternionF

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|Float64 四元数|

返回: 

- Float32 四元数

### func identity\(\)
```cj
public func identity(): QuaternionF
```
设置为单位四元数 (0,0,0,1)

返回: 

- 当前实例

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(x: Float32, y: Float32, z: Float32, w: Float32)
```
使用指定分量构造四元数

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|x 分量y y 分量z z 分量w w 分量|
|y|Float32||
|z|Float32||
|w|Float32||

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为单位四元数 (0,0,0,1)

### func invert\(\)
```cj
public func invert(): QuaternionF
```
反转四元数（假设为单位四元数，等价于共轭）

返回: 

- 当前实例

### func lengthSq\(\)
```cj
public func lengthSq(): Float32
```
计算四元数长度的平方

返回: 

- 长度的平方

### func length\(\)
```cj
public func length(): Float32
```
计算四元数的欧几里得长度

返回: 

- 长度

### func multiplyQuaternions\(QuaternionF,QuaternionF\)
```cj
public func multiplyQuaternions(a: QuaternionF, b: QuaternionF): QuaternionF
```
将两个四元数相乘并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|QuaternionF|第一个四元数b 第二个四元数|
|b|QuaternionF||

返回: 

- 当前实例

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): QuaternionF
```
将四元数的每个分量乘以标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32|标量|

返回: 

- 当前实例

### func multiply\(QuaternionF\)
```cj
public func multiply(q: QuaternionF): QuaternionF
```
将当前四元数乘以给定四元数

参数: 

|名称|类型|描述|
|---|---|---|
|q|QuaternionF|四元数|

返回: 

- 当前实例

### func negate\(\)
```cj
public func negate(): QuaternionF
```
取反四元数的所有分量

返回: 

- 当前实例

### func normalize\(\)
```cj
public func normalize(): QuaternionF
```
将四元数归一化为单位长度，如果长度为 0 则设置为单位四元数 (0,0,0,1)

返回: 

- 当前实例

### func premultiply\(QuaternionF\)
```cj
public func premultiply(q: QuaternionF): QuaternionF
```
将给定四元数乘以当前四元数（前乘）

参数: 

|名称|类型|描述|
|---|---|---|
|q|QuaternionF|四元数|

返回: 

- 当前实例

### func setFromAxisAngle\(Vector3F,Float32\)
```cj
public func setFromAxisAngle(axis: Vector3F, angle: Float32): QuaternionF
```
从轴角设置四元数

参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3F|旋转轴（应为单位向量）angle 旋转角度（弧度）|
|angle|Float32||

返回: 

- 当前实例

### func setFromRotationMatrix\(Matrix4F\)
```cj
public func setFromRotationMatrix(m: Matrix4F): QuaternionF
```
从旋转矩阵设置四元数

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4F|4x4 旋转矩阵|

返回: 

- 当前实例

### func set\(Float32,Float32,Float32,Float32\)
```cj
public func set(x: Float32, y: Float32, z: Float32, w: Float32): QuaternionF
```
设置四元数分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|x 分量y y 分量z z 分量w w 分量|
|y|Float32||
|z|Float32||
|w|Float32||

返回: 

- 当前实例

### func slerpQuaternions\(QuaternionF,QuaternionF,Float32\)
```cj
public func slerpQuaternions(qa: QuaternionF, qb: QuaternionF, t: Float32): QuaternionF
```
在两个四元数之间进行球面线性插值，结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|qa|QuaternionF|第一个四元数qb 第二个四元数t 插值因子|
|qb|QuaternionF||
|t|Float32||

返回: 

- 当前实例

### func slerp\(QuaternionF,Float32\)
```cj
public func slerp(qb: QuaternionF, t: Float32): QuaternionF
```
球面线性插值（SLERP）

参数: 

|名称|类型|描述|
|---|---|---|
|qb|QuaternionF|目标四元数t 插值因子，闭区间 [0, 1]|
|t|Float32||

返回: 

- 当前实例

### func toArray\(\)
```cj
public func toArray(): Array < Float32 >
```
转换为 Array<Float32>（长度4）

返回: 

- Float32 数组

### func toQuaternion\(\)
```cj
public func toQuaternion(): Quaternion
```
转换为 Quaternion (Float64)

返回: 

- Float64 四元数

### var w
```cj
public var w: Float32
```
w 分量（标量部分）

### var x
```cj
public var x: Float32
```
x 分量

### var y
```cj
public var y: Float32
```
y 分量

### var z
```cj
public var z: Float32
```
z 分量

