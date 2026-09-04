# 类
## class Quaternion
```cj
public class Quaternion
```
四元数类，用于表示三维旋转

### func angleTo\(Quaternion\)
```cj
public func angleTo(q: Quaternion): Float64
```
计算当前四元数与给定四元数之间的角度（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|另一个四元数|

返回: 

- 角度（弧度）

### func clone\(\)
```cj
public func clone(): Quaternion
```
克隆当前四元数

返回: 

- 新的四元数实例

### func conjugate\(\)
```cj
public func conjugate(): Quaternion
```
计算四元数的共轭（反转旋转方向），假设四元数为单位四元数

返回: 

- 当前实例

### func copy\(Quaternion\)
```cj
public func copy(q: Quaternion): Quaternion
```
复制另一个四元数的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|源四元数|

返回: 

- 当前实例

### func dot\(Quaternion\)
```cj
public func dot(q: Quaternion): Float64
```
计算与给定四元数的点积

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|另一个四元数|

返回: 

- 点积结果

### func equals\(Quaternion\)
```cj
public func equals(q: Quaternion): Bool
```
判断当前四元数是否与给定四元数相等

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|另一个四元数|

返回: 

- 是否相等

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Quaternion
```
从数组设置四元数分量

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|包含分量值的数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### func fromBufferAttribute\(AttributeReader,Int64\)
```cj
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Quaternion
```
从顶点属性读取四元数分量

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|AttributeReader|顶点属性（AttributeReader 接口，由 BufferAttribute 实现）index 顶点索引|
|index|Int64||

返回: 

- 当前实例

### func identity\(\)
```cj
public func identity(): Quaternion
```
将四元数设置为单位四元数（无旋转）

返回: 

- 当前实例

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为单位四元数 (0,0,0,1)

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64, w: Float64)
```
使用指定分量构造四元数

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量y y 分量z z 分量w w 分量|
|y|Float64||
|z|Float64||
|w|Float64||

### func invert\(\)
```cj
public func invert(): Quaternion
```
反转四元数（假设为单位四元数，等价于共轭）

返回: 

- 当前实例

### func lengthSq\(\)
```cj
public func lengthSq(): Float64
```
计算四元数长度的平方

返回: 

- 长度的平方

### func length\(\)
```cj
public func length(): Float64
```
计算四元数的欧几里得长度

返回: 

- 长度

### func multiplyQuaternionsFlat\(Array<Float64>,Int64,Array<Float64>,Int64,Array<Float64>,Int64\)
```cj
public static func multiplyQuaternionsFlat(dst: Array < Float64 >, dstOffset: Int64, src0: Array < Float64 >, srcOffset0: Int64, src1: Array < Float64 >, srcOffset1: Int64): Unit
```
将两个四元数相乘（扁平数组版本）

参数: 

|名称|类型|描述|
|---|---|---|
|dst|Array<Float64>|目标数组dstOffset 目标偏移src0 第一个源数组srcOffset0 第一个源偏移src1 第二个源数组srcOffset1 第二个源偏移|
|dstOffset|Int64||
|src0|Array<Float64>||
|srcOffset0|Int64||
|src1|Array<Float64>||
|srcOffset1|Int64||

### func multiplyQuaternions\(Quaternion,Quaternion\)
```cj
public func multiplyQuaternions(a: Quaternion, b: Quaternion): Quaternion
```
将两个四元数相乘并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Quaternion|第一个四元数b 第二个四元数|
|b|Quaternion||

返回: 

- 当前实例

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Quaternion
```
将四元数的每个分量乘以标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量|

返回: 

- 当前实例

### func multiply\(Quaternion\)
```cj
public func multiply(q: Quaternion): Quaternion
```
将当前四元数乘以给定四元数

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|四元数|

返回: 

- 当前实例

### func negate\(\)
```cj
public func negate(): Quaternion
```
取反四元数的所有分量

返回: 

- 当前实例

### func normalize\(\)
```cj
public func normalize(): Quaternion
```
将四元数归一化为单位长度，如果长度为 0 则设置为单位四元数 (0,0,0,1)

返回: 

- 当前实例

### func onChange\(\(\)\->Unit\)
```cj
public func onChange(callback:() -> Unit): Quaternion
```
设置变更回调函数，当四元数的值被修改时回调函数将被调用

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|回调函数|

返回: 

- 当前实例

### func premultiply\(Quaternion\)
```cj
public func premultiply(q: Quaternion): Quaternion
```
将给定四元数乘以当前四元数（前乘）

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|四元数|

返回: 

- 当前实例

### func random\(\)
```cj
public func random(): Quaternion
```
将四元数设置为随机单位四元数

返回: 

- 当前实例

### func rotateTowards\(Quaternion,Float64\)
```cj
public func rotateTowards(q: Quaternion, step: Float64): Quaternion
```
旋转当前四元数朝向目标四元数，最大步长为 step（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|目标四元数step 最大旋转角度（弧度）|
|step|Float64||

返回: 

- 当前实例

### func rotateVector\(Vector3\)
```cj
public func rotateVector(v: Vector3): Vector3
```
使用当前四元数旋转向量

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|要旋转的向量|

返回: 

- 旋转后的新向量

### func setFromAxisAngle\(Vector3,Float64\)
```cj
public func setFromAxisAngle(axis: Vector3, angle: Float64): Quaternion
```
从轴角设置四元数

参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3|旋转轴（应为单位向量）angle 旋转角度（弧度）|
|angle|Float64||

返回: 

- 当前实例

### func setFromEuler\(Euler\)
```cj
public func setFromEuler(euler: Euler): Quaternion
```
从欧拉角设置四元数

参数: 

|名称|类型|描述|
|---|---|---|
|euler|Euler|欧拉角|

返回: 

- 当前实例

### func setFromRotationMatrix\(Matrix4\)
```cj
public func setFromRotationMatrix(m: Matrix4): Quaternion
```
从旋转矩阵设置四元数

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 旋转矩阵|

返回: 

- 当前实例

### func setFromUnitVectors\(Vector3,Vector3\)
```cj
public func setFromUnitVectors(vFrom: Vector3, vTo: Vector3): Quaternion
```
从两个单位向量设置四元数旋转

参数: 

|名称|类型|描述|
|---|---|---|
|vFrom|Vector3|起始方向向量（应为单位向量）vTo 目标方向向量（应为单位向量）|
|vTo|Vector3||

返回: 

- 当前实例

### func set\(Float64,Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64, w: Float64): Quaternion
```
设置四元数分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量y y 分量z z 分量w w 分量|
|y|Float64||
|z|Float64||
|w|Float64||

返回: 

- 当前实例

### func slerpFlat\(Array<Float64>,Int64,Array<Float64>,Int64,Array<Float64>,Int64,Float64\)
```cj
public static func slerpFlat(dst: Array < Float64 >, dstOffset: Int64, src0: Array < Float64 >, srcOffset0: Int64, src1: Array < Float64 >, srcOffset1: Int64, t: Float64): Unit
```
在两个四元数之间进行球面线性插值（扁平数组版本）

参数: 

|名称|类型|描述|
|---|---|---|
|dst|Array<Float64>|目标数组dstOffset 目标偏移src0 第一个源数组srcOffset0 第一个源偏移src1 第二个源数组srcOffset1 第二个源偏移t 插值因子|
|dstOffset|Int64||
|src0|Array<Float64>||
|srcOffset0|Int64||
|src1|Array<Float64>||
|srcOffset1|Int64||
|t|Float64||

### func slerpQuaternions\(Quaternion,Quaternion,Float64\)
```cj
public func slerpQuaternions(qa: Quaternion, qb: Quaternion, t: Float64): Quaternion
```
在两个四元数之间进行球面线性插值，结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|qa|Quaternion|第一个四元数qb 第二个四元数t 插值因子|
|qb|Quaternion||
|t|Float64||

返回: 

- 当前实例

### func slerp\(Quaternion,Float64\)
```cj
public func slerp(qb: Quaternion, t: Float64): Quaternion
```
球面线性插值（SLERP）

参数: 

|名称|类型|描述|
|---|---|---|
|qb|Quaternion|目标四元数t 插值因子，闭区间 [0, 1]|
|t|Float64||

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将四元数分量写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 包含分量值的数组

### var w
```cj
public var w: Float64
```
w 分量（标量部分）

### var x
```cj
public var x: Float64
```
x 分量

### var y
```cj
public var y: Float64
```
y 分量

### var z
```cj
public var z: Float64
```
z 分量

