# 类
## class Matrix4F
```cj
public class Matrix4F
```
Float32 4x4 矩阵类（列主序存储）

### func clone\(\)
```cj
public func clone(): Matrix4F
```
===== Core =====

### func compose\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func compose(px: Float32, py: Float32, pz: Float32, qx: Float32, qy: Float32, qz: Float32, qw: Float32, sx: Float32, sy: Float32, sz: Float32): Matrix4F
```
从位置、四元数、缩放组合为矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|px|Float32|位置 x|
|py|Float32|位置 y|
|pz|Float32|位置 z|
|qx|Float32|旋转四元数 x|
|qy|Float32|旋转四元数 y|
|qz|Float32||
|qw|Float32|旋转四元数 w|
|sx|Float32|缩放 x|
|sy|Float32|缩放 y|
|sz|Float32|缩放 z|

### func copy\(Matrix4F\)
```cj
public func copy(m: Matrix4F): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4F||

### func determinant\(\)
```cj
public func determinant(): Float32
```
===== Determinant & Inverse =====

### func fromMatrix4\(Matrix4\)
```cj
public static func fromMatrix4(m: Matrix4): Matrix4F
```
从 Matrix4 (Float64) 转换为 Matrix4F

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func identity\(\)
```cj
public func identity(): Matrix4F
```


### func init\(\)
```cj
public init()
```


### func init\(Array<Float32>\)
```cj
public init(elements: Array < Float32 >)
```


参数: 

|名称|类型|描述|
|---|---|---|
|elements|Array<Float32>||

### func invert\(\)
```cj
public func invert(): Matrix4F
```


### func makeRotationFromQuaternion\(Float32,Float32,Float32,Float32\)
```cj
public func makeRotationFromQuaternion(x: Float32, y: Float32, z: Float32, w: Float32): Matrix4F
```
从四元数构建旋转矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|四元数 x|
|y|Float32|四元数 y|
|z|Float32|四元数 z|
|w|Float32|四元数 w|

### func makeRotationX\(Float32\)
```cj
public func makeRotationX(theta: Float32): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float32||

### func makeRotationY\(Float32\)
```cj
public func makeRotationY(theta: Float32): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float32||

### func makeRotationZ\(Float32\)
```cj
public func makeRotationZ(theta: Float32): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|theta|Float32||

### func makeScale\(Float32,Float32,Float32\)
```cj
public func makeScale(x: Float32, y: Float32, z: Float32): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func makeTranslation\(Float32,Float32,Float32\)
```cj
public func makeTranslation(x: Float32, y: Float32, z: Float32): Matrix4F
```
===== Build transforms =====

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func multiplyMatrices\(Matrix4F,Matrix4F\)
```cj
public func multiplyMatrices(a: Matrix4F, b: Matrix4F): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|a|Matrix4F||
|b|Matrix4F||

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|s|Float32||

### func multiply\(Matrix4F\)
```cj
public func multiply(m: Matrix4F): Matrix4F
```
===== Multiply =====

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4F||

### func premultiply\(Matrix4F\)
```cj
public func premultiply(m: Matrix4F): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4F||

### func set\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func set(n11: Float32, n12: Float32, n13: Float32, n14: Float32, n21: Float32, n22: Float32, n23: Float32, n24: Float32, n31: Float32, n32: Float32, n33: Float32, n34: Float32, n41: Float32, n42: Float32, n43: Float32, n44: Float32): Matrix4F
```


参数: 

|名称|类型|描述|
|---|---|---|
|n11|Float32||
|n12|Float32||
|n13|Float32||
|n14|Float32||
|n21|Float32||
|n22|Float32||
|n23|Float32||
|n24|Float32||
|n31|Float32||
|n32|Float32||
|n33|Float32||
|n34|Float32||
|n41|Float32||
|n42|Float32||
|n43|Float32||
|n44|Float32||

### func toArray\(\)
```cj
public func toArray(): Array < Float32 >
```
转换为 Array<Float32>（长度16）

### func transpose\(\)
```cj
public func transpose(): Matrix4F
```
===== Transpose =====

### var elements
```cj
public var elements: Array < Float32 >
```
16 个矩阵元素，列主序存储

