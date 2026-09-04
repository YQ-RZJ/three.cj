# 类
## class Matrix3
```cj
public class Matrix3
```
3x3 矩阵类，列主序存储

### func clone\(\)
```cj
public func clone(): Matrix3
```
创建此矩阵的副本

返回: 

- 新的 Matrix3 实例

### func copy\(Matrix3\)
```cj
public func copy(m: Matrix3): Matrix3
```
将另一个矩阵的值复制到此矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|源矩阵|

返回: 

- 当前实例

### func determinant\(\)
```cj
public func determinant(): Float64
```
计算矩阵的行列式

返回: 

- 行列式值

### func equals\(Matrix3\)
```cj
public func equals(m: Matrix3): Bool
```
检查此矩阵是否与另一个矩阵相等

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|要比较的矩阵|

返回: 

- 如果所有元素相等则返回 true

### func extractBasis\(Vector3,Vector3,Vector3\)
```cj
public func extractBasis(xAxis: Vector3, yAxis: Vector3, zAxis: Vector3): Matrix3
```
提取矩阵的基向量

参数: 

|名称|类型|描述|
|---|---|---|
|xAxis|Vector3|x 轴基向量yAxis y 轴基向量zAxis z 轴基向量|
|yAxis|Vector3||
|zAxis|Vector3||

返回: 

- 当前实例

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Matrix3
```
从数组中读取矩阵元素（列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|源数组offset 数组中的起始偏移量，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### func getInverse\(Matrix4\)
```cj
public func getInverse(m: Matrix4): Matrix3
```
从 4x4 矩阵中提取 3x3 逆矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|源 4x4 矩阵|

返回: 

- 当前实例

### func getNormalMatrix\(Matrix4\)
```cj
public func getNormalMatrix(m: Matrix4): Matrix3
```
从 4x4 矩阵计算法线矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|源 4x4 矩阵|

返回: 

- 当前实例

### func identity\(\)
```cj
public func identity(): Matrix3
```
设置矩阵为单位矩阵

返回: 

- 当前实例

### func init\(\)
```cj
public init()
```
默认构造函数，初始化为单位矩阵

### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(n11: Float64, n12: Float64, n13: Float64, n21: Float64, n22: Float64, n23: Float64, n31: Float64, n32: Float64, n33: Float64)
```
使用指定元素构造 3x3 矩阵（行主序参数）

参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float64|第 1 行第 1 列元素n12 第 1 行第 2 列元素n13 第 1 行第 3 列元素n21 第 2 行第 1 列元素n22 第 2 行第 2 列元素n23 第 2 行第 3 列元素n31 第 3 行第 1 列元素n32 第 3 行第 2 列元素n33 第 3 行第 3 列元素|
|n12|Float64||
|n13|Float64||
|n21|Float64||
|n22|Float64||
|n23|Float64||
|n31|Float64||
|n32|Float64||
|n33|Float64||

### func invert\(\)
```cj
public func invert(): Matrix3
```
求逆矩阵（使用解析方法）

返回: 

- 当前实例

### func makeRotation\(Float64\)
```cj
public func makeRotation(theta: Float64): Matrix3
```
设置为 2D 旋转矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float64|旋转角度（弧度），逆时针方向|

返回: 

- 当前实例

### func makeScale\(Float64,Float64\)
```cj
public func makeScale(x: Float64, y: Float64): Matrix3
```
设置为 2D 缩放矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 轴缩放量y Y 轴缩放量|
|y|Float64||

返回: 

- 当前实例

### func makeTranslation\(Float64,Float64\)
```cj
public func makeTranslation(x: Float64, y: Float64): Matrix3
```
设置为 2D 平移矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 轴平移量y Y 轴平移量|
|y|Float64||

返回: 

- 当前实例

### func multiplyMatrices\(Matrix3,Matrix3\)
```cj
public func multiplyMatrices(a: Matrix3, b: Matrix3): Matrix3
```
计算两个矩阵的乘积并存储到此矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|a|Matrix3|左操作数矩阵b 右操作数矩阵|
|b|Matrix3||

返回: 

- 当前实例

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Matrix3
```
将矩阵的每个元素乘以标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前实例

### func multiply\(Matrix3\)
```cj
public func multiply(m: Matrix3): Matrix3
```
将此矩阵与另一个矩阵相乘

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|右操作数矩阵|

返回: 

- 当前实例

### func premultiply\(Matrix3\)
```cj
public func premultiply(m: Matrix3): Matrix3
```
前置乘以给定矩阵：m * this

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|矩阵|

返回: 

- 当前实例

### func rotate\(Float64\)
```cj
public func rotate(theta: Float64): Matrix3
```
旋转矩阵（deprecated，用 makeRotation 替代）

参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float64|旋转角度（弧度）|

返回: 

- 当前实例

### func scale\(Float64\)
```cj
public func scale(v: Float64): Matrix3
```
缩放矩阵的前两列

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float64|缩放值|

返回: 

- 当前实例

### func setFromMatrix4\(Matrix4\)
```cj
public func setFromMatrix4(m: Matrix4): Matrix3
```
从 4x4 矩阵中提取 3x3 子矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|源 4x4 矩阵|

返回: 

- 当前实例

### func setUvTransform\(Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func setUvTransform(tx: Float64, ty: Float64, sx: Float64, sy: Float64, rotation: Float64, cx: Float64, cy: Float64): Matrix3
```
设置 UV 变换矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|tx|Float64|X 轴平移量ty Y 轴平移量sx X 轴缩放因子sy Y 轴缩放因子rotation 旋转角度（弧度）cx 旋转中心 X 坐标cy 旋转中心 Y 坐标|
|ty|Float64||
|sx|Float64||
|sy|Float64||
|rotation|Float64||
|cx|Float64||
|cy|Float64||

返回: 

- 当前实例

### func set\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func set(n11: Float64, n12: Float64, n13: Float64, n21: Float64, n22: Float64, n23: Float64, n31: Float64, n32: Float64, n33: Float64): Matrix3
```
按行主序设置矩阵元素

参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float64|第 1 行第 1 列元素n12 第 1 行第 2 列元素n13 第 1 行第 3 列元素n21 第 2 行第 1 列元素n22 第 2 行第 2 列元素n23 第 2 行第 3 列元素n31 第 3 行第 1 列元素n32 第 3 行第 2 列元素n33 第 3 行第 3 列元素|
|n12|Float64||
|n13|Float64||
|n21|Float64||
|n22|Float64||
|n23|Float64||
|n31|Float64||
|n32|Float64||
|n33|Float64||

返回: 

- 当前实例

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
将矩阵元素写入数组（列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 起始偏移量，默认为 0|
|offset|Int64||

返回: 

- 包含矩阵元素的数组

### func translate\(Float64,Float64\)
```cj
public func translate(tx: Float64, ty: Float64): Matrix3
```
平移矩阵（deprecated，用 makeTranslation 替代）

参数: 

|名称|类型|描述|
|---|---|---|
|tx|Float64|X 轴平移量ty Y 轴平移量|
|ty|Float64||

返回: 

- 当前实例

### func transposeIntoArray\(Array<Float64>\)
```cj
public func transposeIntoArray(r: Array < Float64 >): Matrix3
```
将转置后的矩阵元素写入数组

参数: 

|名称|类型|描述|
|---|---|---|
|r|Array<Float64>|目标数组|

返回: 

- 当前实例

### func transpose\(\)
```cj
public func transpose(): Matrix3
```
转置矩阵

返回: 

- 当前实例

### var elements
```cj
public var elements: Array < Float64 >
```
矩阵元素，列主序存储

