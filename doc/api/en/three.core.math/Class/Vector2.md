# Class
## class Vector2
```cj
public class Vector2
```
2D vector class, represents an ordered pair (x, y)

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Vector2
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func \+\(Vector2\)
```cj
public operator func +(v: Vector2): Vector2
```
===== 运算符重载 =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2||

### func \-\(Vector2\)
```cj
public operator func -(v: Vector2): Vector2
```


Parameter: 

|Name|Type|Describe|
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Vector2
```
Adds a scalar value to all components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func addScaledVector\(Vector2,Float64\)
```cj
public func addScaledVector(v: Vector2, s: Float64): Vector2
```
Adds the given vector scaled by a factor to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Vectors Scale factor|
|s|Float64||

Return: 

- This instance

### func addVectors\(Vector2,Vector2\)
```cj
public func addVectors(a: Vector2, b: Vector2): Vector2
```
Adds two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|First vectorb Second vector|
|b|Vector2||

Return: 

- This instance

### func add\(Vector2\)
```cj
public func add(v: Vector2): Vector2
```
Adds the given vector to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Vector to add|

Return: 

- This instance

### func angleTo\(Vector2\)
```cj
public func angleTo(v: Vector2): Float64
```
Computes the angle between this vector and the given vector (radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Another vector|

Return: 

- Angle in radians

### func angle\(\)
```cj
public func angle(): Float64
```
Computes the angle of this vector relative to the positive x-axis (radians)

Return: 

- Angle in radians

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): Vector2
```
Multiplies this vector (with implied 1 as third component) by the given 3x3 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 matrix|

Return: 

- This instance

### func ceil\(\)
```cj
public func ceil(): Vector2
```
Rounds components up to the nearest integer

Return: 

- This instance

### func clampLength\(Float64,Float64\)
```cj
public func clampLength(min: Float64, max: Float64): Vector2
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
public func clampScalar(minVal: Float64, maxVal: Float64): Vector2
```
Clamps the components of this vector within [minVal, maxVal]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minVal|Float64|Minimum valuemaxVal Maximum value|
|maxVal|Float64||

Return: 

- This instance

### func clamp\(Vector2,Vector2\)
```cj
public func clamp(min: Vector2, max: Vector2): Vector2
```
Clamps the components of this vector within [min, max]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Minimum vectormax Maximum vector|
|max|Vector2||

Return: 

- This instance

### func clone\(\)
```cj
public func clone(): Vector2
```
Clones the current vector

Return: 

- New vector instance

### func copy\(Vector2\)
```cj
public func copy(v: Vector2): Vector2
```
Copies another vector's values to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Source vector|

Return: 

- This instance

### func cross\(Vector2\)
```cj
public func cross(v: Vector2): Float64
```
Computes the cross product with the given vector (2D cross product returns a scalar)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Another vector|

Return: 

- Cross product result

### func distanceToSquared\(Vector2\)
```cj
public func distanceToSquared(v: Vector2): Float64
```
Computes the squared distance to the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Target vector|

Return: 

- Squared distance

### func distanceTo\(Vector2\)
```cj
public func distanceTo(v: Vector2): Float64
```
Computes the distance to the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Target vector|

Return: 

- Distance

### func divideScalar\(Float64\)
```cj
public func divideScalar(s: Float64): Vector2
```
Divides this vector by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func divide\(Vector2\)
```cj
public func divide(v: Vector2): Vector2
```
Divides this instance by the given vector component-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Divisor vector|

Return: 

- This instance

### func dot\(Vector2\)
```cj
public func dot(v: Vector2): Float64
```
Computes the dot product with the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Another vector|

Return: 

- Dot product result

### func equals\(Vector2\)
```cj
public func equals(v: Vector2): Bool
```
Checks if this vector equals the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Vector to compare|

Return: 

- Whether equal

### func floor\(\)
```cj
public func floor(): Vector2
```
Rounds components down to the nearest integer

Return: 

- This instance

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Vector2
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
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector2
```
Reads vector components from a vertex attribute (cf. JS: Vector2.fromBufferAttribute)

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
Gets component value by index (0=x, 1=y)

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
Default constructor, initializes to zero vector (0, 0)

### func init\(Float64,Float64\)
```cj
public init(x: Float64, y: Float64)
```
Constructs a vector with specified component values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component valuey y component value|
|y|Float64||

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

### func lerpVectors\(Vector2,Vector2,Float64\)
```cj
public func lerpVectors(v1: Vector2, v2: Vector2, alpha: Float64): Vector2
```
Performs linear interpolation between two given vectors, storing result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v1|Vector2|First vectorv2 Second vectoralpha Interpolation factor, closed interval [0, 1]|
|v2|Vector2||
|alpha|Float64||

Return: 

- This instance

### func lerp\(Vector2,Float64\)
```cj
public func lerp(v: Vector2, alpha: Float64): Vector2
```
Performs linear interpolation between this vector and the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Target vectoralpha Interpolation factor, closed interval [0, 1]|
|alpha|Float64||

Return: 

- This instance

### func manhattanDistanceTo\(Vector2\)
```cj
public func manhattanDistanceTo(v: Vector2): Float64
```
Computes the Manhattan distance to the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Target vector|

Return: 

- Manhattan distance

### func manhattanLength\(\)
```cj
public func manhattanLength(): Float64
```
Computes the Manhattan length of the vector

Return: 

- Manhattan length

### func max\(Vector2\)
```cj
public func max(v: Vector2): Vector2
```
Replaces each component with the maximum of this and the given vector's corresponding component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Vector to compare|

Return: 

- This instance

### func min\(Vector2\)
```cj
public func min(v: Vector2): Vector2
```
Replaces each component with the minimum of this and the given vector's corresponding component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Vector to compare|

Return: 

- This instance

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Vector2
```
Multiplies all components by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func multiply\(Vector2\)
```cj
public func multiply(v: Vector2): Vector2
```
Multiplies this instance by the given vector component-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Multiplier vector|

Return: 

- This instance

### func negate\(\)
```cj
public func negate(): Vector2
```
Negates the vector, setting x = -x, y = -y

Return: 

- This instance

### func normalize\(\)
```cj
public func normalize(): Vector2
```
Converts this vector to a unit vector (length of 1)

Return: 

- This instance

### func random\(\)
```cj
public func random(): Vector2
```
Sets each component to a pseudo-random value in [0, 1)

Return: 

- This instance

### func rotateAround\(Vector2,Float64\)
```cj
public func rotateAround(center: Vector2, angle: Float64): Vector2
```
Rotates this vector around the given center by the specified angle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Rotation centerangle Rotation angle in radians|
|angle|Float64||

Return: 

- This instance

### func roundToZero\(\)
```cj
public func roundToZero(): Vector2
```
Rounds components toward zero (negative up, positive down)

Return: 

- This instance

### func round\(\)
```cj
public func round(): Vector2
```
Rounds components to the nearest integer

Return: 

- This instance

### func setComponent\(Int64,Float64\)
```cj
public func setComponent(index: Int64, value: Float64): Vector2
```
Sets component value by index (0=x, 1=y)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Component indexvalue Value to set|
|value|Float64||

Return: 

- This instance

### func setLength\(Float64\)
```cj
public func setLength(length: Float64): Vector2
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
public func setScalar(s: Float64): Vector2
```
Sets all components to the same value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func setX\(Float64\)
```cj
public func setX(x: Float64): Vector2
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
public func setY(y: Float64): Vector2
```
Sets the y component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|y|Float64|y component value|

Return: 

- This instance

### func set\(Float64,Float64\)
```cj
public func set(x: Float64, y: Float64): Vector2
```
Sets vector components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component valuey y component value|
|y|Float64||

Return: 

- This instance

### func subScalar\(Float64\)
```cj
public func subScalar(s: Float64): Vector2
```
Subtracts a scalar value from all components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func subVectors\(Vector2,Vector2\)
```cj
public func subVectors(a: Vector2, b: Vector2): Vector2
```
Subtracts two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector2|Minuend vectorb Subtrahend vector|
|b|Vector2||

Return: 

- This instance

### func sub\(Vector2\)
```cj
public func sub(v: Vector2): Vector2
```
Subtracts the given vector from this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Vector to subtract|

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
height property, alias for y

### prop width: Float64
```cj
public mut prop width: Float64
```
width property, alias for x

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

