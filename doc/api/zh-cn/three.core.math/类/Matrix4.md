# 类
## class Matrix4
```cj
public class Matrix4
```
4x4 矩阵类，列主序存储（elements 数组）

### func clone\(\)
```cj
public func clone(): Matrix4
```


### func compose\(Vector3,Quaternion,Vector3\)
```cj
public func compose(position: Vector3, quaternion: Quaternion, scale: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3||
|quaternion|Quaternion||
|scale|Vector3||

### func copyPosition\(Matrix4\)
```cj
public func copyPosition(m: Matrix4): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func copy\(Matrix4\)
```cj
public func copy(m: Matrix4): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func decompose\(Vector3,Quaternion,Vector3\)
```cj
public func decompose(position: Vector3, quaternion: Quaternion, scale: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3||
|quaternion|Quaternion||
|scale|Vector3||

### func determinantAffine\(\)
```cj
public func determinantAffine(): Float64
```


### func determinant\(\)
```cj
public func determinant(): Float64
```
===== 行列式 =====

### func equals\(Matrix4\)
```cj
public func equals(m: Matrix4): Bool
```
===== 比较 =====

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func extractBasis\(Vector3,Vector3,Vector3\)
```cj
public func extractBasis(xAxis: Vector3, yAxis: Vector3, zAxis: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|xAxis|Vector3||
|yAxis|Vector3||
|zAxis|Vector3||

### func extractRotation\(Matrix4\)
```cj
public func extractRotation(m: Matrix4): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>||
|offset|Int64||

### func getInverse\(Matrix4\)
```cj
public func getInverse(m: Matrix4): Matrix4
```
===== 提取变换 =====

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func getMaxScaleOnAxis\(\)
```cj
public func getMaxScaleOnAxis(): Float64
```


### func getPosition\(\)
```cj
public func getPosition(): Vector3
```


### func identity\(\)
```cj
public func identity(): Matrix4
```


### func init\(\)
```cj
public init()
```


### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(n11: Float64, n12: Float64, n13: Float64, n14: Float64, n21: Float64, n22: Float64, n23: Float64, n24: Float64, n31: Float64, n32: Float64, n33: Float64, n34: Float64, n41: Float64, n42: Float64, n43: Float64, n44: Float64)
```


参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float64||
|n12|Float64||
|n13|Float64||
|n14|Float64||
|n21|Float64||
|n22|Float64||
|n23|Float64||
|n24|Float64||
|n31|Float64||
|n32|Float64||
|n33|Float64||
|n34|Float64||
|n41|Float64||
|n42|Float64||
|n43|Float64||
|n44|Float64||

### func invert\(\)
```cj
public func invert(): Matrix4
```
===== 逆矩阵 =====

### func lookAt\(Vector3,Vector3,Vector3\)
```cj
public func lookAt(eye: Vector3, target: Vector3, up: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|eye|Vector3||
|target|Vector3||
|up|Vector3||

### func makeBasis\(Vector3,Vector3,Vector3\)
```cj
public func makeBasis(xAxis: Vector3, yAxis: Vector3, zAxis: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|xAxis|Vector3||
|yAxis|Vector3||
|zAxis|Vector3||

### func makeOrthographic\(Float64,Float64,Float64,Float64,Float64,Float64,Int64,Bool\)
```cj
public func makeOrthographic(left: Float64, right: Float64, top: Float64, bottom: Float64, near: Float64, far: Float64, coordinateSystem!: Int64 = 2001, reversedDepth!: Bool = false): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|left|Float64||
|right|Float64||
|top|Float64||
|bottom|Float64||
|near|Float64||
|far|Float64||
|coordinateSystem|Int64||
|reversedDepth|Bool||

### func makePerspective\(Float64,Float64,Float64,Float64,Float64,Float64,Int64,Bool\)
```cj
public func makePerspective(left: Float64, right: Float64, top: Float64, bottom: Float64, near: Float64, far: Float64, coordinateSystem!: Int64 = 2001, reversedDepth!: Bool = false): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|left|Float64||
|right|Float64||
|top|Float64||
|bottom|Float64||
|near|Float64||
|far|Float64||
|coordinateSystem|Int64||
|reversedDepth|Bool||

### func makeRotationAxis\(Vector3,Float64\)
```cj
public func makeRotationAxis(axis: Vector3, angle: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func makeRotationFromEuler\(Euler\)
```cj
public func makeRotationFromEuler(euler: Euler): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|euler|Euler||

### func makeRotationFromQuaternion\(Quaternion\)
```cj
public func makeRotationFromQuaternion(q: Quaternion): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion||

### func makeRotationX\(Float64\)
```cj
public func makeRotationX(theta: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float64||

### func makeRotationY\(Float64\)
```cj
public func makeRotationY(theta: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float64||

### func makeRotationZ\(Float64\)
```cj
public func makeRotationZ(theta: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float64||

### func makeScale\(Float64,Float64,Float64\)
```cj
public func makeScale(x: Float64, y: Float64, z: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||

### func makeShear\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func makeShear(xy: Float64, xz: Float64, yx: Float64, yz: Float64, zx: Float64, zy: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|xy|Float64||
|xz|Float64||
|yx|Float64||
|yz|Float64||
|zx|Float64||
|zy|Float64||

### func makeTranslation\(Float64,Float64,Float64\)
```cj
public func makeTranslation(x: Float64, y: Float64, z: Float64): Matrix4
```
===== 变换矩阵构造 =====

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64||
|y|Float64||
|z|Float64||

### func makeTranslation\(Vector3\)
```cj
public func makeTranslation(v: Vector3): Matrix4
```
创建平移矩阵（Vector3 版本）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3|平移向量|

返回: 

- 当前实例

### func multiplyMatrices\(Matrix4,Matrix4\)
```cj
public func multiplyMatrices(a: Matrix4, b: Matrix4): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|a|Matrix4||
|b|Matrix4||

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float64||

### func multiply\(Matrix4\)
```cj
public func multiply(m: Matrix4): Matrix4
```
===== 乘法 =====

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func premultiply\(Matrix4\)
```cj
public func premultiply(m: Matrix4): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func scale\(Vector3\)
```cj
public func scale(v: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3||

### func setFromMatrix3\(Matrix3\)
```cj
public func setFromMatrix3(m: Matrix3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3||

### func setPosition\(Vector3\)
```cj
public func setPosition(v: Vector3): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|v|Vector3||

### func setPosition\(Float64,Float64,Float64\)
```cj
public func setPosition(x: Float64, y: Float64, z: Float64): Matrix4
```
设置矩阵的平移分量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 分量y Y 分量z Z 分量|
|y|Float64||
|z|Float64||

返回: 

- 当前实例

### func set\(Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func set(n11: Float64, n12: Float64, n13: Float64, n14: Float64, n21: Float64, n22: Float64, n23: Float64, n24: Float64, n31: Float64, n32: Float64, n33: Float64, n34: Float64, n41: Float64, n42: Float64, n43: Float64, n44: Float64): Matrix4
```


参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float64||
|n12|Float64||
|n13|Float64||
|n14|Float64||
|n21|Float64||
|n22|Float64||
|n23|Float64||
|n24|Float64||
|n31|Float64||
|n32|Float64||
|n33|Float64||
|n34|Float64||
|n41|Float64||
|n42|Float64||
|n43|Float64||
|n44|Float64||

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>||
|offset|Int64||

### func transpose\(\)
```cj
public func transpose(): Matrix4
```
===== 转置 =====

### var elements
```cj
public var elements: Array < Float64 >
```
矩阵元素，列主序存储

