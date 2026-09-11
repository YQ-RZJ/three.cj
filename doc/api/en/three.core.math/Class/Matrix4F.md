# Class
## class Matrix4F
```cj
public class Matrix4F
```
Float32 4x4 matrix class (column-major storage)

### func clone\(\)
```cj
public func clone(): Matrix4F
```
===== Core =====

### func compose\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func compose(px: Float32, py: Float32, pz: Float32, qx: Float32, qy: Float32, qz: Float32, qw: Float32, sx: Float32, sy: Float32, sz: Float32): Matrix4F
```
Compose a matrix from position, quaternion and scale

Parameter: 

|Name|Type|Describe|
|---|---|---|
|px|Float32|Position x|
|py|Float32|Position y|
|pz|Float32|Position z|
|qx|Float32|Rotation quaternion x|
|qy|Float32|Rotation quaternion y|
|qz|Float32||
|qw|Float32|Rotation quaternion w|
|sx|Float32|Scale x|
|sy|Float32|Scale y|
|sz|Float32|Scale z|

### func copy\(Matrix4F\)
```cj
public func copy(m: Matrix4F): Matrix4F
```


Parameter: 

|Name|Type|Describe|
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
Convert from Matrix4 (Float64) to Matrix4F

Parameter: 

|Name|Type|Describe|
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


Parameter: 

|Name|Type|Describe|
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
Build a rotation matrix from a quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|Quaternion x|
|y|Float32|Quaternion y|
|z|Float32|Quaternion z|
|w|Float32|Quaternion w|

### func makeRotationX\(Float32\)
```cj
public func makeRotationX(theta: Float32): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|theta|Float32||

### func makeRotationY\(Float32\)
```cj
public func makeRotationY(theta: Float32): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|theta|Float32||

### func makeRotationZ\(Float32\)
```cj
public func makeRotationZ(theta: Float32): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|theta|Float32||

### func makeScale\(Float32,Float32,Float32\)
```cj
public func makeScale(x: Float32, y: Float32, z: Float32): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func makeTranslation\(Float32,Float32,Float32\)
```cj
public func makeTranslation(x: Float32, y: Float32, z: Float32): Matrix4F
```
===== Build transforms =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|z|Float32||

### func multiplyMatrices\(Matrix4F,Matrix4F\)
```cj
public func multiplyMatrices(a: Matrix4F, b: Matrix4F): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Matrix4F||
|b|Matrix4F||

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32||

### func multiply\(Matrix4F\)
```cj
public func multiply(m: Matrix4F): Matrix4F
```
===== Multiply =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4F||

### func premultiply\(Matrix4F\)
```cj
public func premultiply(m: Matrix4F): Matrix4F
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4F||

### func set\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func set(n11: Float32, n12: Float32, n13: Float32, n14: Float32, n21: Float32, n22: Float32, n23: Float32, n24: Float32, n31: Float32, n32: Float32, n33: Float32, n34: Float32, n41: Float32, n42: Float32, n43: Float32, n44: Float32): Matrix4F
```


Parameter: 

|Name|Type|Describe|
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
Convert to Array<Float32> (length 16)

### func transpose\(\)
```cj
public func transpose(): Matrix4F
```
===== Transpose =====

### var elements
```cj
public var elements: Array < Float32 >
```
16 matrix elements, stored in column-major order

