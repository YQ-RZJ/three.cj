# 类
## class Matrix2
```cj
public class Matrix2
```
2x2 矩阵类，列主序存储

### func clone\(\)
```cj
public func clone(): Matrix2
```
创建此矩阵的副本

返回: 

- 新的 Matrix2 实例

### func copyTo\(Matrix2\)
```cj
public func copyTo(m: Matrix2): Matrix2
```
将此矩阵的值复制到目标矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix2|目标矩阵|

返回: 

- 当前矩阵实例（支持链式调用）

### func copy\(Matrix2\)
```cj
public func copy(m: Matrix2): Matrix2
```
将另一个矩阵的值复制到此矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix2|源矩阵|

返回: 

- 当前矩阵实例（支持链式调用）

### func determinant\(\)
```cj
public func determinant(): Float64
```
计算矩阵的行列式

返回: 

- 行列式值

### func equals\(Matrix2\)
```cj
public func equals(m: Matrix2): Bool
```
检查此矩阵是否与另一个矩阵相等

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix2|要比较的矩阵|

返回: 

- 如果所有元素相等则返回 true

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Matrix2
```
从数组中读取矩阵元素（列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|源数组|
|offset|Int64|数组中的起始偏移量，默认为 0|

返回: 

- 当前矩阵实例（支持链式调用）

### func identity\(\)
```cj
public func identity(): Matrix2
```
设置矩阵为单位矩阵

返回: 

- 当前矩阵实例（支持链式调用）

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(n11!: Float64 = 1.0, n12!: Float64 = 0.0, n21!: Float64 = 0.0, n22!: Float64 = 1.0)
```
构造一个新的 2x2 矩阵，如果提供参数则按行主序设置矩阵元素

参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float64|第 1 行第 1 列元素|
|n12|Float64|第 1 行第 2 列元素|
|n21|Float64|第 2 行第 1 列元素|
|n22|Float64|第 2 行第 2 列元素|

### func inverse\(\)
```cj
public func inverse(): Matrix2
```
计算矩阵的逆矩阵，如果行列式为 0 则将矩阵重置为单位矩阵

返回: 

- 当前矩阵实例（支持链式调用）

### func makeRotation\(Float64\)
```cj
public func makeRotation(theta: Float64): Matrix2
```
创建旋转矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float64|旋转角度（弧度）|

返回: 

- 当前矩阵实例（支持链式调用）

### func makeScale\(Float64,Float64\)
```cj
public func makeScale(sx: Float64, sy: Float64): Matrix2
```
创建缩放矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|sx|Float64|X 轴缩放因子|
|sy|Float64|Y 轴缩放因子|

返回: 

- 当前矩阵实例（支持链式调用）

### func makeTranslation\(Float64,Float64\)
```cj
public func makeTranslation(tx: Float64, ty: Float64): Matrix2
```
创建平移矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|tx|Float64|X 轴平移量|
|ty|Float64|Y 轴平移量|

返回: 

- 当前矩阵实例（支持链式调用）

### func multiplyMatrices\(Matrix2,Matrix2\)
```cj
public func multiplyMatrices(a: Matrix2, b: Matrix2): Matrix2
```
计算两个矩阵的乘积并存储到此矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|a|Matrix2|左操作数矩阵|
|b|Matrix2|右操作数矩阵|

返回: 

- 当前矩阵实例（支持链式调用）

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Matrix2
```
将矩阵的每个元素乘以标量

参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64|标量值|

返回: 

- 当前矩阵实例（支持链式调用）

### func multiply\(Matrix2\)
```cj
public func multiply(m: Matrix2): Matrix2
```
将此矩阵与另一个矩阵相乘

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix2|右操作数矩阵|

返回: 

- 当前矩阵实例（支持链式调用）

### func setFromMatrix3\(Matrix3\)
```cj
public func setFromMatrix3(m: Matrix3): Matrix2
```
从 3x3 矩阵中提取 2x2 子矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|源 3x3 矩阵|

返回: 

- 当前矩阵实例（支持链式调用）

### func set\(Float64,Float64,Float64,Float64\)
```cj
public func set(n11: Float64, n12: Float64, n21: Float64, n22: Float64): Matrix2
```
按行主序设置矩阵元素

参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float64|第 1 行第 1 列元素|
|n12|Float64|第 1 行第 2 列元素|
|n21|Float64|第 2 行第 1 列元素|
|n22|Float64|第 2 行第 2 列元素|

返回: 

- 当前矩阵实例（支持链式调用）

### func toArray\(Option<Array<Float64>>,Int64\)
```cj
public func toArray(array!: Option < Array < Float64 >>= None, offset!: Int64 = 0): Array < Float64 >
```
将矩阵元素写入数组（列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|array|Option<Array<Float64>>|目标数组，如果为 None 则创建新数组|
|offset|Int64|数组中的起始偏移量，默认为 0|

返回: 

- 包含矩阵元素的数组

### func transpose\(\)
```cj
public func transpose(): Matrix2
```
转置矩阵

返回: 

- 当前矩阵实例（支持链式调用）

### var elements
```cj
public var elements: Array < Float64 >
```
矩阵元素，列主序存储

