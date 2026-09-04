# Class
## class Vector4
```cj
public class Vector4
```
4D vector class, represents an ordered quadruple (x, y, z, w)

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Vector4
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func \+\(Vector4\)
```cj
public operator func +(v: Vector4): Vector4
```
===== 运算符重载 =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4||

### func \-\(Vector4\)
```cj
public operator func -(v: Vector4): Vector4
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4||

### func \-\(\)
```cj
public operator func -(): Vector4
```


### func /\(Float64\)
```cj
public operator func /(s: Float64): Vector4
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Vector4
```
Adds a scalar value to all components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func addScaledVector\(Vector4,Float64\)
```cj
public func addScaledVector(v: Vector4, s: Float64): Vector4
```
Adds the given vector scaled by a factor to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Vectors Scale factor|
|s|Float64||

Return: 

- This instance

### func addVectors\(Vector4,Vector4\)
```cj
public func addVectors(a: Vector4, b: Vector4): Vector4
```
Adds two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector4|First vectorb Second vector|
|b|Vector4||

Return: 

- This instance

### func add\(Vector4\)
```cj
public func add(v: Vector4): Vector4
```
Adds the given vector to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Vector to add|

Return: 

- This instance

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): Vector4
```
Multiplies this vector by the given 4x4 matrix (row vector multiplication, no perspective division)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix|

Return: 

- This instance

### func ceil\(\)
```cj
public func ceil(): Vector4
```
Rounds components up to the nearest integer

Return: 

- This instance

### func clampLength\(Float64,Float64\)
```cj
public func clampLength(min: Float64, max: Float64): Vector4
```
Clamps the length of this vector within [min, max]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Float64|Minimum lengthmax Maximum length|
|max|Float64||

Return: 

- This instance

### func clampScalar\(Float64,Float64\)
```cj
public func clampScalar(minVal: Float64, maxVal: Float64): Vector4
```
Clamps the components of this vector within [minVal, maxVal]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minVal|Float64|Minimum valuemaxVal Maximum value|
|maxVal|Float64||

Return: 

- This instance

### func clamp\(Vector4,Vector4\)
```cj
public func clamp(min: Vector4, max: Vector4): Vector4
```
Clamps the components of this vector within [min, max]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector4|Minimum vectormax Maximum vector|
|max|Vector4||

Return: 

- This instance

### func clone\(\)
```cj
public func clone(): Vector4
```
Clones the current vector

Return: 

- New vector instance

### func copy\(Vector4\)
```cj
public func copy(v: Vector4): Vector4
```
Copies another vector's values to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Source vector|

Return: 

- This instance

### func divideScalar\(Float64\)
```cj
public func divideScalar(s: Float64): Vector4
```
Divides this vector by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func divide\(Vector4\)
```cj
public func divide(v: Vector4): Vector4
```
Divides this instance by the given vector component-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Divisor vector|

Return: 

- This instance

### func dot\(Vector4\)
```cj
public func dot(v: Vector4): Float64
```
Computes the dot product with the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Another vector|

Return: 

- Dot product result

### func equals\(Vector4\)
```cj
public func equals(v: Vector4): Bool
```
Checks if this vector equals the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Vector to compare|

Return: 

- Whether equal

### func floor\(\)
```cj
public func floor(): Vector4
```
Rounds components down to the nearest integer

Return: 

- This instance

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Vector4
```
Sets vector components from an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array containing vector component valuesoffset Array offset, defaults to 0|
|offset|Int64||

Return: 

- This instance

### func fromBufferAttribute\(AttributeReader,Int64\)
```cj
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector4
```
Reads vector components from a vertex attribute (cf. JS: Vector4.fromBufferAttribute)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|AttributeReader|Vertex attribute (AttributeReader interface, implemented by BufferAttribute)index Vertex index|
|index|Int64||

Return: 

- This instance

### func getComponent\(Int64\)
```cj
public func getComponent(index: Int64): Float64
```
Gets component value by index (0=x, 1=y, 2=z, 3=w)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Component index|

Return: 

- Component value

### func init\(\)
```cj
public init()
```
Default constructor, initializes to (0, 0, 0, 1)

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64, w: Float64)
```
Constructs a vector with specified component values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component valuey y component valuez z component valuew w component value|
|y|Float64||
|z|Float64||
|w|Float64||

### func lengthSq\(\)
```cj
public func lengthSq(): Float64
```
Computes the squared length of the vector

Return: 

- Squared length

### func length\(\)
```cj
public func length(): Float64
```
Computes the Euclidean length of the vector

Return: 

- Vector length

### func lerpVectors\(Vector4,Vector4,Float64\)
```cj
public func lerpVectors(v1: Vector4, v2: Vector4, alpha: Float64): Vector4
```
Performs linear interpolation between two given vectors, storing result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v1|Vector4|First vectorv2 Second vectoralpha Interpolation factor, closed interval [0, 1]|
|v2|Vector4||
|alpha|Float64||

Return: 

- This instance

### func lerp\(Vector4,Float64\)
```cj
public func lerp(v: Vector4, alpha: Float64): Vector4
```
Performs linear interpolation between this vector and the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Target vectoralpha Interpolation factor, closed interval [0, 1]|
|alpha|Float64||

Return: 

- This instance

### func manhattanLength\(\)
```cj
public func manhattanLength(): Float64
```
Computes the Manhattan length of the vector

Return: 

- Manhattan length

### func max\(Vector4\)
```cj
public func max(v: Vector4): Vector4
```
Replaces each component with the maximum of this and the given vector's corresponding component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Vector to compare|

Return: 

- This instance

### func min\(Vector4\)
```cj
public func min(v: Vector4): Vector4
```
Replaces each component with the minimum of this and the given vector's corresponding component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Vector to compare|

Return: 

- This instance

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Vector4
```
Multiplies all components by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func multiply\(Vector4\)
```cj
public func multiply(v: Vector4): Vector4
```
Multiplies this instance by the given vector component-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Multiplier vector|

Return: 

- This instance

### func negate\(\)
```cj
public func negate(): Vector4
```
Negates the vector, setting x = -x, y = -y, z = -z, w = -w

Return: 

- This instance

### func normalize\(\)
```cj
public func normalize(): Vector4
```
Converts this vector to a unit vector (length of 1)

Return: 

- This instance

### func random\(\)
```cj
public func random(): Vector4
```
Sets each component to a pseudo-random value in [0, 1)

Return: 

- This instance

### func roundToZero\(\)
```cj
public func roundToZero(): Vector4
```
Rounds components toward zero (negative up, positive down)

Return: 

- This instance

### func round\(\)
```cj
public func round(): Vector4
```
Rounds components to the nearest integer

Return: 

- This instance

### func setAxisAngleFromQuaternion\(Quaternion\)
```cj
public func setAxisAngleFromQuaternion(q: Quaternion): Vector4
```
Sets axis-angle from a quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Quaternion|

Return: 

- This instance

### func setAxisAngleFromRotationMatrix\(Matrix4\)
```cj
public func setAxisAngleFromRotationMatrix(m: Matrix4): Vector4
```
Sets axis-angle from a rotation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 rotation matrix|

Return: 

- This instance

### func setComponent\(Int64,Float64\)
```cj
public func setComponent(index: Int64, value: Float64): Vector4
```
Sets component value by index (0=x, 1=y, 2=z, 3=w)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Component indexvalue Value to set|
|value|Float64||

Return: 

- This instance

### func setFromMatrixPosition\(Matrix4\)
```cj
public func setFromMatrixPosition(m: Matrix4): Vector4
```
Sets vector components from the position elements of a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix|

Return: 

- This instance

### func setLength\(Float64\)
```cj
public func setLength(length: Float64): Vector4
```
Sets this vector to the specified length in the same direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|length|Float64|New length|

Return: 

- This instance

### func setScalar\(Float64\)
```cj
public func setScalar(s: Float64): Vector4
```
Sets all components to the same value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func setW\(Float64\)
```cj
public func setW(w: Float64): Vector4
```
Sets the w component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|Float64|w component value|

Return: 

- This instance

### func setX\(Float64\)
```cj
public func setX(x: Float64): Vector4
```
Sets the x component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component value|

Return: 

- This instance

### func setY\(Float64\)
```cj
public func setY(y: Float64): Vector4
```
Sets the y component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|y|Float64|y component value|

Return: 

- This instance

### func setZ\(Float64\)
```cj
public func setZ(z: Float64): Vector4
```
Sets the z component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|z|Float64|z component value|

Return: 

- This instance

### func set\(Float64,Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64, w: Float64): Vector4
```
Sets vector components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component valuey y component valuez z component valuew w component value|
|y|Float64||
|z|Float64||
|w|Float64||

Return: 

- This instance

### func subScalar\(Float64\)
```cj
public func subScalar(s: Float64): Vector4
```
Subtracts a scalar value from all components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func subVectors\(Vector4,Vector4\)
```cj
public func subVectors(a: Vector4, b: Vector4): Vector4
```
Subtracts two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector4|Minuend vectorb Subtrahend vector|
|b|Vector4||

Return: 

- This instance

### func sub\(Vector4\)
```cj
public func sub(v: Vector4): Vector4
```
Subtracts the given vector from this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector4|Vector to subtract|

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Writes vector components into an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- Array containing vector components

### prop height: Float64
```cj
public mut prop height: Float64
```
height property, alias for w

### prop width: Float64
```cj
public mut prop width: Float64
```
width property, alias for z

### var w
```cj
public var w: Float64
```
w component

### var x
```cj
public var x: Float64
```
x component

### var y
```cj
public var y: Float64
```
y component

### var z
```cj
public var z: Float64
```
z component

