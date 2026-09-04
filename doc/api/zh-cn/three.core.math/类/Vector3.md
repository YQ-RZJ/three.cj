# 类
## class Vector3
```cj
public class Vector3
```
3D 向量类，表示有序三元组 (x, y, z)

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64||

### func \+\(Vector3\)
```cj
public operator func +(v: Vector3): Vector3
```
===== 运算符重载 =====

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3||

### func \-\(Vector3\)
```cj
public operator func -(v: Vector3): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3||

### func \-\(\)
```cj
public operator func -(): Vector3
```


### func /\(Float64\)
```cj
public operator func /(s: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64||

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Vector3
```
将给定标量值加到所有分量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func addScaledVector\(Vector3,Float64\)
```cj
public func addScaledVector(v: Vector3, s: Float64): Vector3
```
将给定向量按给定因子缩放后加到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|向量s 缩放因子|
|s|Float64||

返回: 

- 当前实例

### func addVectors\(Vector3,Vector3\)
```cj
public func addVectors(a: Vector3, b: Vector3): Vector3
```
将两个向量相加并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|第一个向量b 第二个向量|
|b|Vector3||

返回: 

- 当前实例

### func add\(Vector3\)
```cj
public func add(v: Vector3): Vector3
```
将给定向量加到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|要添加的向量|

返回: 

- 当前实例

### func angleTo\(Vector3\)
```cj
public func angleTo(v: Vector3): Float64
```
计算当前向量与给定向量之间的角度（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|另一个向量|

返回: 

- 角度（弧度）

### func applyAxisAngle\(Vector3,Float64\)
```cj
public func applyAxisAngle(axis: Vector3, angle: Float64): Vector3
```
通过轴角旋转向量

参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3|旋转轴（应为单位向量）angle 旋转角度（弧度）|
|angle|Float64||

返回: 

- 当前实例

### func applyEuler\(Euler\)
```cj
public func applyEuler(euler: Euler): Vector3
```
通过欧拉角旋转向量

参数: 

|名称|类型|描述|
|---|---|---|
|euler|Euler|欧拉角|

返回: 

- 当前实例

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): Vector3
```
将当前向量乘以给定 3x3 矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|3x3 矩阵|

返回: 

- 当前实例

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): Vector3
```
将当前向量（隐含 1 作为第 4 分量）乘以给定 4x4 矩阵，并进行透视除法

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵|

返回: 

- 当前实例

### func applyNormalMatrix\(Matrix3\)
```cj
public func applyNormalMatrix(m: Matrix3): Vector3
```
将当前向量乘以给定法线矩阵并归一化

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|法线矩阵|

返回: 

- 当前实例

### func applyQuaternion\(Quaternion\)
```cj
public func applyQuaternion(q: Quaternion): Vector3
```
将给定四元数应用到当前向量

参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion|四元数|

返回: 

- 当前实例

### func ceil\(\)
```cj
public func ceil(): Vector3
```
将分量向上取整

返回: 

- 当前实例

### func clampLength\(Float64,Float64\)
```cj
public func clampLength(min: Float64, max: Float64): Vector3
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
public func clampScalar(minVal: Float64, maxVal: Float64): Vector3
```
将当前向量的分量限制在 [minVal, maxVal] 范围内

参数: 

|名称|类型|描述|
|---|---|---|
|minVal|Float64|最小值maxVal 最大值|
|maxVal|Float64||

返回: 

- 当前实例

### func clamp\(Vector3,Vector3\)
```cj
public func clamp(min: Vector3, max: Vector3): Vector3
```
将当前向量的分量限制在 [min, max] 范围内

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector3|最小值向量max 最大值向量|
|max|Vector3||

返回: 

- 当前实例

### func clone\(\)
```cj
public func clone(): Vector3
```
克隆当前向量

返回: 

- 新的向量实例

### func copy\(Vector3\)
```cj
public func copy(v: Vector3): Vector3
```
复制另一个向量的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|源向量|

返回: 

- 当前实例

### func crossVectors\(Vector3,Vector3\)
```cj
public func crossVectors(a: Vector3, b: Vector3): Vector3
```
计算两个向量的叉积并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|第一个向量b 第二个向量|
|b|Vector3||

返回: 

- 当前实例

### func cross\(Vector3\)
```cj
public func cross(v: Vector3): Vector3
```
计算与给定向量的叉积，结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|另一个向量|

返回: 

- 当前实例

### func distanceToSquared\(Vector3\)
```cj
public func distanceToSquared(v: Vector3): Float64
```
计算到给定向量的距离的平方

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|目标向量|

返回: 

- 距离的平方

### func distanceTo\(Vector3\)
```cj
public func distanceTo(v: Vector3): Float64
```
计算到给定向量的距离

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|目标向量|

返回: 

- 距离

### func divideScalar\(Float64\)
```cj
public func divideScalar(s: Float64): Vector3
```
将当前向量除以给定标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func divide\(Vector3\)
```cj
public func divide(v: Vector3): Vector3
```
将当前实例除以给定向量（逐分量）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|除数向量|

返回: 

- 当前实例

### func dot\(Vector3\)
```cj
public func dot(v: Vector3): Float64
```
计算与给定向量的点积

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|另一个向量|

返回: 

- 点积结果

### func equals\(Vector3\)
```cj
public func equals(v: Vector3): Bool
```
判断当前向量是否与给定向量相等

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|比较向量|

返回: 

- 是否相等

### func floor\(\)
```cj
public func floor(): Vector3
```
将分量向下取整

返回: 

- 当前实例

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Vector3
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
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector3
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
通过索引获取分量值（0=x, 1=y, 2=z）

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
默认构造函数，初始化为零向量 (0, 0, 0)

### func init\(Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64)
```
使用指定分量值构造向量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量值y y 分量值z z 分量值|
|y|Float64||
|z|Float64||

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

### func lerpVectors\(Vector3,Vector3,Float64\)
```cj
public func lerpVectors(v1: Vector3, v2: Vector3, alpha: Float64): Vector3
```
在两个给定向量之间进行线性插值，结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|v1|Vector3|第一个向量v2 第二个向量alpha 插值因子，闭区间 [0, 1]|
|v2|Vector3||
|alpha|Float64||

返回: 

- 当前实例

### func lerp\(Vector3,Float64\)
```cj
public func lerp(v: Vector3, alpha: Float64): Vector3
```
在当前向量与给定向量之间进行线性插值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|目标向量alpha 插值因子，闭区间 [0, 1]|
|alpha|Float64||

返回: 

- 当前实例

### func manhattanDistanceTo\(Vector3\)
```cj
public func manhattanDistanceTo(v: Vector3): Float64
```
计算到给定向量的曼哈顿距离

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|目标向量|

返回: 

- 曼哈顿距离

### func manhattanLength\(\)
```cj
public func manhattanLength(): Float64
```
计算向量的曼哈顿长度

返回: 

- 曼哈顿长度

### func max\(Vector3\)
```cj
public func max(v: Vector3): Vector3
```
将各分量替换为当前向量与给定向量对应分量的较大值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|比较向量|

返回: 

- 当前实例

### func min\(Vector3\)
```cj
public func min(v: Vector3): Vector3
```
将各分量替换为当前向量与给定向量对应分量的较小值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|比较向量|

返回: 

- 当前实例

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Vector3
```
将所有分量乘以给定标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func multiplyVectors\(Vector3,Vector3\)
```cj
public func multiplyVectors(a: Vector3, b: Vector3): Vector3
```
将两个向量逐分量相乘并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|第一个向量b 第二个向量|
|b|Vector3||

返回: 

- 当前实例

### func multiply\(Vector3\)
```cj
public func multiply(v: Vector3): Vector3
```
将当前实例与给定向量逐分量相乘

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|乘数向量|

返回: 

- 当前实例

### func negate\(\)
```cj
public func negate(): Vector3
```
反转向量，即设置 x = -x, y = -y, z = -z

返回: 

- 当前实例

### func normalize\(\)
```cj
public func normalize(): Vector3
```
将当前向量转换为单位向量（长度为 1）

返回: 

- 当前实例

### func projectOnPlane\(Vector3\)
```cj
public func projectOnPlane(planeNormal: Vector3): Vector3
```
将当前向量投影到给定法线的平面上

参数: 

|名称|类型|描述|
|---|---|---|
|planeNormal|Vector3|平面法线|

返回: 

- 当前实例

### func projectOnVector\(Vector3\)
```cj
public func projectOnVector(v: Vector3): Vector3
```
将当前向量投影到给定向量上

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|投影目标向量|

返回: 

- 当前实例

### func project\(Matrix4\)
```cj
public func project(cameraProjectionMatrix: Matrix4): Vector3
```
通过相机投影矩阵投影向量

参数: 

|名称|类型|描述|
|---|---|---|
|cameraProjectionMatrix|Matrix4|相机投影矩阵|

返回: 

- 当前实例

### func randomDirection\(\)
```cj
public func randomDirection(): Vector3
```
将当前向量设置为单位球面上的均匀随机方向

返回: 

- 当前实例

### func random\(\)
```cj
public func random(): Vector3
```
将每个分量设置为 [0, 1) 之间的伪随机值

返回: 

- 当前实例

### func reflect\(Vector3\)
```cj
public func reflect(normal: Vector3): Vector3
```
将当前向量沿给定法线反射

参数: 

|名称|类型|描述|
|---|---|---|
|normal|Vector3|（归一化的）法线向量|

返回: 

- 当前实例

### func roundToZero\(\)
```cj
public func roundToZero(): Vector3
```
将分量向零取整（负数向上，正数向下）

返回: 

- 当前实例

### func round\(\)
```cj
public func round(): Vector3
```
将分量四舍五入到最近整数

返回: 

- 当前实例

### func setComponent\(Int64,Float64\)
```cj
public func setComponent(index: Int64, value: Float64): Vector3
```
通过索引设置分量值（0=x, 1=y, 2=z）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|分量索引value 要设置的值|
|value|Float64||

返回: 

- 当前实例

### func setFromColor\(Color\)
```cj
public func setFromColor(c: Color): Vector3
```
从颜色的 RGB 分量设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|c|Color|颜色|

返回: 

- 当前实例

### func setFromCylindricalCoords\(Float64,Float64,Float64\)
```cj
public func setFromCylindricalCoords(radius: Float64, theta: Float64, y: Float64): Vector3
```
从圆柱坐标参数设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径theta 角度（弧度）y 高度|
|theta|Float64||
|y|Float64||

返回: 

- 当前实例

### func setFromCylindrical\(Cylindrical\)
```cj
public func setFromCylindrical(c: Cylindrical): Vector3
```
从圆柱坐标设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|c|Cylindrical|圆柱坐标对象|

返回: 

- 当前实例

### func setFromEuler\(Euler\)
```cj
public func setFromEuler(e: Euler): Vector3
```
从欧拉角设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|e|Euler|欧拉角|

返回: 

- 当前实例

### func setFromMatrix3Column\(Matrix3,Int64\)
```cj
public func setFromMatrix3Column(m: Matrix3, index: Int64): Vector3
```
从 3x3 矩阵的指定列设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|3x3 矩阵index 列索引|
|index|Int64||

返回: 

- 当前实例

### func setFromMatrixColumn\(Matrix4,Int64\)
```cj
public func setFromMatrixColumn(m: Matrix4, index: Int64): Vector3
```
从 4x4 矩阵的指定列设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵index 列索引|
|index|Int64||

返回: 

- 当前实例

### func setFromMatrixPosition\(Matrix4\)
```cj
public func setFromMatrixPosition(m: Matrix4): Vector3
```
从 4x4 矩阵的位置元素设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵|

返回: 

- 当前实例

### func setFromMatrixScale\(Matrix4\)
```cj
public func setFromMatrixScale(m: Matrix4): Vector3
```
从 4x4 矩阵的缩放元素设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 矩阵|

返回: 

- 当前实例

### func setFromSphericalCoords\(Float64,Float64,Float64\)
```cj
public func setFromSphericalCoords(radius: Float64, phi: Float64, theta: Float64): Vector3
```
从球坐标参数设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径phi 极角（弧度）theta 方位角（弧度）|
|phi|Float64||
|theta|Float64||

返回: 

- 当前实例

### func setFromSpherical\(Spherical\)
```cj
public func setFromSpherical(s: Spherical): Vector3
```
从球坐标设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Spherical|球坐标对象|

返回: 

- 当前实例

### func setLength\(Float64\)
```cj
public func setLength(length: Float64): Vector3
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
public func setScalar(s: Float64): Vector3
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
public func setX(x: Float64): Vector3
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
public func setY(y: Float64): Vector3
```
设置 y 分量

参数: 

|名称|类型|描述|
|---|---|---|
|y|Float64|y 分量值|

返回: 

- 当前实例

### func setZ\(Float64\)
```cj
public func setZ(z: Float64): Vector3
```
设置 z 分量

参数: 

|名称|类型|描述|
|---|---|---|
|z|Float64|z 分量值|

返回: 

- 当前实例

### func set\(Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64): Vector3
```
设置向量分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|x 分量值y y 分量值z z 分量值|
|y|Float64||
|z|Float64||

返回: 

- 当前实例

### func subScalar\(Float64\)
```cj
public func subScalar(s: Float64): Vector3
```
从所有分量减去给定标量值

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func subVectors\(Vector3,Vector3\)
```cj
public func subVectors(a: Vector3, b: Vector3): Vector3
```
将两个向量相减并将结果存储在当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|a|Vector3|被减向量b 减向量|
|b|Vector3||

返回: 

- 当前实例

### func sub\(Vector3\)
```cj
public func sub(v: Vector3): Vector3
```
从当前实例减去给定向量

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|要减去的向量|

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

### func transformDirection\(Matrix4\)
```cj
public func transformDirection(m: Matrix4): Vector3
```
用给定 4x4 矩阵的左上 3x3 子矩阵变换当前向量，并归一化结果

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|4x4 仿射矩阵|

返回: 

- 当前实例

### func unproject\(Matrix4\)
```cj
public func unproject(cameraProjectionMatrix: Matrix4): Vector3
```
通过相机逆投影矩阵反投影向量

参数: 

|名称|类型|描述|
|---|---|---|
|cameraProjectionMatrix|Matrix4|相机投影矩阵|

返回: 

- 当前实例

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

