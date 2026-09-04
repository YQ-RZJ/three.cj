# 类
## class Vector2
```cj
public class Vector2
```
2D 向量类，表示有序对 (x, y)

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Vector2
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64||

### func \+\(Vector2\)
```cj
public operator func +(v: Vector2): Vector2
```
===== 运算符重载 =====

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2||

### func \-\(Vector2\)
```cj
public operator func -(v: Vector2): Vector2
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2||

### func \-\(\)
```cj
public operator func -(): Vector2
```


### func /\(Float64\)
```cj
public operator func /(s: Float64): Vector2
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64||

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Vector2
```
将给定标量值加到所有分量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func addScaledVector\(Vector2,Float64\)
```cj
public func addScaledVector(v: Vector2, s: Float64): Vector2
```
将给定向量按给定因子缩放后加到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|向量s 缩放因子|
|s|Float64||

返回: 

- 当前实例

### func addVectors\(Vector2,Vector2\)
```cj
public func addVectors(a: Vector2, b: Vector2): Vector2
```
将两个向量相加并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2|第一个向量b 第二个向量|
|b|Vector2||

返回: 

- 当前实例

### func add\(Vector2\)
```cj
public func add(v: Vector2): Vector2
```
将给定向量加到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|要添加的向量|

返回: 

- 当前实例

### func angleTo\(Vector2\)
```cj
public func angleTo(v: Vector2): Float64
```
计算当前向量与给定向量之间的角度（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|另一个向量|

返回: 

- 角度（弧度）

### func angle\(\)
```cj
public func angle(): Float64
```
计算当前向量相对于正 x 轴的角度（弧度）

返回: 

- 角度（弧度）

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): Vector2
```
将当前向量（隐含 1 作为第三分量）乘以给定 3x3 矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|3x3 矩阵|

返回: 

- 当前实例

### func ceil\(\)
```cj
public func ceil(): Vector2
```
将分量向上取整

返回: 

- 当前实例

### func clampLength\(Float64,Float64\)
```cj
public func clampLength(min: Float64, max: Float64): Vector2
```
将当前向量的长度限制在 [min, max] 范围内

参数: 

|名称|类型|描述|
|---|---|---|
|min|Float64|最小长度max 最大长度|
|max|Float64||

返回: 

- 当前实例

### func clampScalar\(Float64,Float64\)
```cj
public func clampScalar(minVal: Float64, maxVal: Float64): Vector2
```
将当前向量的分量限制在 [minVal, maxVal] 范围内

参数: 

|名称|类型|描述|
|---|---|---|
|minVal|Float64|最小值maxVal 最大值|
|maxVal|Float64||

返回: 

- 当前实例

### func clamp\(Vector2,Vector2\)
```cj
public func clamp(min: Vector2, max: Vector2): Vector2
```
将当前向量的分量限制在 [min, max] 范围内

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|最小值向量max 最大值向量|
|max|Vector2||

返回: 

- 当前实例

### func clone\(\)
```cj
public func clone(): Vector2
```
克隆当前向量

返回: 

- 新的向量实例

### func copy\(Vector2\)
```cj
public func copy(v: Vector2): Vector2
```
复制另一个向量的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|源向量|

返回: 

- 当前实例

### func cross\(Vector2\)
```cj
public func cross(v: Vector2): Float64
```
计算与给定向量的叉积（2D 叉积返回标量）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|另一个向量|

返回: 

- 叉积结果

### func distanceToSquared\(Vector2\)
```cj
public func distanceToSquared(v: Vector2): Float64
```
计算到给定向量的距离的平方

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|目标向量|

返回: 

- 距离的平方

### func distanceTo\(Vector2\)
```cj
public func distanceTo(v: Vector2): Float64
```
计算到给定向量的距离

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|目标向量|

返回: 

- 距离

### func divideScalar\(Float64\)
```cj
public func divideScalar(s: Float64): Vector2
```
将当前向量除以给定标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func divide\(Vector2\)
```cj
public func divide(v: Vector2): Vector2
```
将当前实例除以给定向量（逐分量）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|除数向量|

返回: 

- 当前实例

### func dot\(Vector2\)
```cj
public func dot(v: Vector2): Float64
```
计算与给定向量的点积

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|另一个向量|

返回: 

- 点积结果

### func equals\(Vector2\)
```cj
public func equals(v: Vector2): Bool
```
判断当前向量是否与给定向量相等

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|比较向量|

返回: 

- 是否相等

### func floor\(\)
```cj
public func floor(): Vector2
```
将分量向下取整

返回: 

- 当前实例

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Vector2
```
从数组设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|包含向量分量值的数组offset 数组偏移量，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### func fromBufferAttribute\(AttributeReader,Int64\)
```cj
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector2
```
从顶点属性读取向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|AttributeReader|顶点属性（AttributeReader 接口，由 BufferAttribute 实现）index 顶点索引|
|index|Int64||

返回: 

- 当前实例

### func getComponent\(Int64\)
```cj
public func getComponent(index: Int64): Float64
```
通过索引获取分量值（0=x, 1=y）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|分量索引|

返回: 

- 分量值

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为零向量 (0, 0)

### func init\(Float64,Float64\)
```cj
public init(x: Float64, y: Float64)
```
使用指定分量值构造向量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量值y y 分量值|
|y|Float64||

### func lengthSq\(\)
```cj
public func lengthSq(): Float64
```
计算向量长度的平方

返回: 

- 长度的平方

### func length\(\)
```cj
public func length(): Float64
```
计算向量的欧几里得长度

返回: 

- 向量长度

### func lerpVectors\(Vector2,Vector2,Float64\)
```cj
public func lerpVectors(v1: Vector2, v2: Vector2, alpha: Float64): Vector2
```
在两个给定向量之间进行线性插值，结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v1|Vector2|第一个向量v2 第二个向量alpha 插值因子，闭区间 [0, 1]|
|v2|Vector2||
|alpha|Float64||

返回: 

- 当前实例

### func lerp\(Vector2,Float64\)
```cj
public func lerp(v: Vector2, alpha: Float64): Vector2
```
在当前向量与给定向量之间进行线性插值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|目标向量alpha 插值因子，闭区间 [0, 1]|
|alpha|Float64||

返回: 

- 当前实例

### func manhattanDistanceTo\(Vector2\)
```cj
public func manhattanDistanceTo(v: Vector2): Float64
```
计算到给定向量的曼哈顿距离

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|目标向量|

返回: 

- 曼哈顿距离

### func manhattanLength\(\)
```cj
public func manhattanLength(): Float64
```
计算向量的曼哈顿长度

返回: 

- 曼哈顿长度

### func max\(Vector2\)
```cj
public func max(v: Vector2): Vector2
```
将各分量替换为当前向量与给定向量对应分量的较大值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|比较向量|

返回: 

- 当前实例

### func min\(Vector2\)
```cj
public func min(v: Vector2): Vector2
```
将各分量替换为当前向量与给定向量对应分量的较小值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|比较向量|

返回: 

- 当前实例

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Vector2
```
将所有分量乘以给定标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func multiply\(Vector2\)
```cj
public func multiply(v: Vector2): Vector2
```
将当前实例与给定向量逐分量相乘

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|乘数向量|

返回: 

- 当前实例

### func negate\(\)
```cj
public func negate(): Vector2
```
反转向量，即设置 x = -x, y = -y

返回: 

- 当前实例

### func normalize\(\)
```cj
public func normalize(): Vector2
```
将当前向量转换为单位向量（长度为 1）

返回: 

- 当前实例

### func random\(\)
```cj
public func random(): Vector2
```
将每个分量设置为 [0, 1) 之间的伪随机值

返回: 

- 当前实例

### func rotateAround\(Vector2,Float64\)
```cj
public func rotateAround(center: Vector2, angle: Float64): Vector2
```
将当前向量绕给定中心旋转指定角度

参数: 

|名称|类型|描述|
|---|---|---|
|center|Vector2|旋转中心angle 旋转角度（弧度）|
|angle|Float64||

返回: 

- 当前实例

### func roundToZero\(\)
```cj
public func roundToZero(): Vector2
```
将分量向零取整（负数向上，正数向下）

返回: 

- 当前实例

### func round\(\)
```cj
public func round(): Vector2
```
将分量四舍五入到最近整数

返回: 

- 当前实例

### func setComponent\(Int64,Float64\)
```cj
public func setComponent(index: Int64, value: Float64): Vector2
```
通过索引设置分量值（0=x, 1=y）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|分量索引value 要设置的值|
|value|Float64||

返回: 

- 当前实例

### func setLength\(Float64\)
```cj
public func setLength(length: Float64): Vector2
```
将当前向量设置为指定长度的同方向向量

参数: 

|名称|类型|描述|
|---|---|---|
|length|Float64|新长度|

返回: 

- 当前实例

### func setScalar\(Float64\)
```cj
public func setScalar(s: Float64): Vector2
```
将所有分量设置为相同值

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func setX\(Float64\)
```cj
public func setX(x: Float64): Vector2
```
设置 x 分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量值|

返回: 

- 当前实例

### func setY\(Float64\)
```cj
public func setY(y: Float64): Vector2
```
设置 y 分量

参数: 

|名称|类型|描述|
|---|---|---|
|y|Float64|y 分量值|

返回: 

- 当前实例

### func set\(Float64,Float64\)
```cj
public func set(x: Float64, y: Float64): Vector2
```
设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量值y y 分量值|
|y|Float64||

返回: 

- 当前实例

### func subScalar\(Float64\)
```cj
public func subScalar(s: Float64): Vector2
```
从所有分量减去给定标量值

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func subVectors\(Vector2,Vector2\)
```cj
public func subVectors(a: Vector2, b: Vector2): Vector2
```
将两个向量相减并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector2|被减向量b 减向量|
|b|Vector2||

返回: 

- 当前实例

### func sub\(Vector2\)
```cj
public func sub(v: Vector2): Vector2
```
从当前实例减去给定向量

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector2|要减去的向量|

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将向量分量写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 起始索引，默认为 0|
|offset|Int64||

返回: 

- 包含向量分量的数组

### prop height: Float64
```cj
public mut prop height: Float64
```
height 属性，y 的别名

### prop width: Float64
```cj
public mut prop width: Float64
```
width 属性，x 的别名

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

