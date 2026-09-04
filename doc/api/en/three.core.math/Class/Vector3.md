# Class
## class Vector3
```cj
public class Vector3
```
3D vector class, represents an ordered triple (x, y, z)

### func \*\(Float64\)
```cj
public operator func *(s: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func \+\(Vector3\)
```cj
public operator func +(v: Vector3): Vector3
```
===== 运算符重载 =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3||

### func \-\(Vector3\)
```cj
public operator func -(v: Vector3): Vector3
```


Parameter: 

|Name|Type|Describe|
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64||

### func addScalar\(Float64\)
```cj
public func addScalar(s: Float64): Vector3
```
Adds a scalar value to all components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func addScaledVector\(Vector3,Float64\)
```cj
public func addScaledVector(v: Vector3, s: Float64): Vector3
```
Adds the given vector scaled by a factor to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vectors Scale factor|
|s|Float64||

Return: 

- This instance

### func addVectors\(Vector3,Vector3\)
```cj
public func addVectors(a: Vector3, b: Vector3): Vector3
```
Adds two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|First vectorb Second vector|
|b|Vector3||

Return: 

- This instance

### func add\(Vector3\)
```cj
public func add(v: Vector3): Vector3
```
Adds the given vector to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector to add|

Return: 

- This instance

### func angleTo\(Vector3\)
```cj
public func angleTo(v: Vector3): Float64
```
Computes the angle between this vector and the given vector (radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Another vector|

Return: 

- Angle in radians

### func applyAxisAngle\(Vector3,Float64\)
```cj
public func applyAxisAngle(axis: Vector3, angle: Float64): Vector3
```
Rotates this vector by an axis-angle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3|Rotation axis (should be a unit vector)angle Rotation angle in radians|
|angle|Float64||

Return: 

- This instance

### func applyEuler\(Euler\)
```cj
public func applyEuler(euler: Euler): Vector3
```
Rotates this vector by Euler angles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|euler|Euler|Euler angles|

Return: 

- This instance

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): Vector3
```
Multiplies this vector by the given 3x3 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 matrix|

Return: 

- This instance

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): Vector3
```
Multiplies this vector (with implied 1 as 4th component) by the given 4x4 matrix with perspective division

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix|

Return: 

- This instance

### func applyNormalMatrix\(Matrix3\)
```cj
public func applyNormalMatrix(m: Matrix3): Vector3
```
Multiplies this vector by the given normal matrix and normalizes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|Normal matrix|

Return: 

- This instance

### func applyQuaternion\(Quaternion\)
```cj
public func applyQuaternion(q: Quaternion): Vector3
```
Applies the given quaternion to this vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Quaternion|

Return: 

- This instance

### func ceil\(\)
```cj
public func ceil(): Vector3
```
Rounds components up to the nearest integer

Return: 

- This instance

### func clampLength\(Float64,Float64\)
```cj
public func clampLength(min: Float64, max: Float64): Vector3
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
public func clampScalar(minVal: Float64, maxVal: Float64): Vector3
```
Clamps the components of this vector within [minVal, maxVal]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minVal|Float64|Minimum valuemaxVal Maximum value|
|maxVal|Float64||

Return: 

- This instance

### func clamp\(Vector3,Vector3\)
```cj
public func clamp(min: Vector3, max: Vector3): Vector3
```
Clamps the components of this vector within [min, max]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector3|Minimum vectormax Maximum vector|
|max|Vector3||

Return: 

- This instance

### func clone\(\)
```cj
public func clone(): Vector3
```
Clones the current vector

Return: 

- New vector instance

### func copy\(Vector3\)
```cj
public func copy(v: Vector3): Vector3
```
Copies another vector's values to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Source vector|

Return: 

- This instance

### func crossVectors\(Vector3,Vector3\)
```cj
public func crossVectors(a: Vector3, b: Vector3): Vector3
```
Computes the cross product of two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|First vectorb Second vector|
|b|Vector3||

Return: 

- This instance

### func cross\(Vector3\)
```cj
public func cross(v: Vector3): Vector3
```
Computes the cross product with the given vector, storing the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Another vector|

Return: 

- This instance

### func distanceToSquared\(Vector3\)
```cj
public func distanceToSquared(v: Vector3): Float64
```
Computes the squared distance to the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Target vector|

Return: 

- Squared distance

### func distanceTo\(Vector3\)
```cj
public func distanceTo(v: Vector3): Float64
```
Computes the distance to the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Target vector|

Return: 

- Distance

### func divideScalar\(Float64\)
```cj
public func divideScalar(s: Float64): Vector3
```
Divides this vector by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func divide\(Vector3\)
```cj
public func divide(v: Vector3): Vector3
```
Divides this instance by the given vector component-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Divisor vector|

Return: 

- This instance

### func dot\(Vector3\)
```cj
public func dot(v: Vector3): Float64
```
Computes the dot product with the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Another vector|

Return: 

- Dot product result

### func equals\(Vector3\)
```cj
public func equals(v: Vector3): Bool
```
Checks if this vector equals the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector to compare|

Return: 

- Whether equal

### func floor\(\)
```cj
public func floor(): Vector3
```
Rounds components down to the nearest integer

Return: 

- This instance

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Vector3
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
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector3
```
Reads vector components from a vertex attribute (cf. JS: Vector3.fromBufferAttribute)

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
Gets component value by index (0=x, 1=y, 2=z)

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
Default constructor, initializes to zero vector (0, 0, 0)

### func init\(Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64)
```
Constructs a vector with specified component values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component valuey y component valuez z component value|
|y|Float64||
|z|Float64||

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

### func lerpVectors\(Vector3,Vector3,Float64\)
```cj
public func lerpVectors(v1: Vector3, v2: Vector3, alpha: Float64): Vector3
```
Performs linear interpolation between two given vectors, storing result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v1|Vector3|First vectorv2 Second vectoralpha Interpolation factor, closed interval [0, 1]|
|v2|Vector3||
|alpha|Float64||

Return: 

- This instance

### func lerp\(Vector3,Float64\)
```cj
public func lerp(v: Vector3, alpha: Float64): Vector3
```
Performs linear interpolation between this vector and the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Target vectoralpha Interpolation factor, closed interval [0, 1]|
|alpha|Float64||

Return: 

- This instance

### func manhattanDistanceTo\(Vector3\)
```cj
public func manhattanDistanceTo(v: Vector3): Float64
```
Computes the Manhattan distance to the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Target vector|

Return: 

- Manhattan distance

### func manhattanLength\(\)
```cj
public func manhattanLength(): Float64
```
Computes the Manhattan length of the vector

Return: 

- Manhattan length

### func max\(Vector3\)
```cj
public func max(v: Vector3): Vector3
```
Replaces each component with the maximum of this and the given vector's corresponding component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector to compare|

Return: 

- This instance

### func min\(Vector3\)
```cj
public func min(v: Vector3): Vector3
```
Replaces each component with the minimum of this and the given vector's corresponding component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector to compare|

Return: 

- This instance

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Vector3
```
Multiplies all components by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func multiplyVectors\(Vector3,Vector3\)
```cj
public func multiplyVectors(a: Vector3, b: Vector3): Vector3
```
Multiplies two vectors component-wise and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|First vectorb Second vector|
|b|Vector3||

Return: 

- This instance

### func multiply\(Vector3\)
```cj
public func multiply(v: Vector3): Vector3
```
Multiplies this instance by the given vector component-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Multiplier vector|

Return: 

- This instance

### func negate\(\)
```cj
public func negate(): Vector3
```
Negates the vector, setting x = -x, y = -y, z = -z

Return: 

- This instance

### func normalize\(\)
```cj
public func normalize(): Vector3
```
Converts this vector to a unit vector (length of 1)

Return: 

- This instance

### func projectOnPlane\(Vector3\)
```cj
public func projectOnPlane(planeNormal: Vector3): Vector3
```
Projects this vector onto the plane defined by the given normal

Parameter: 

|Name|Type|Describe|
|---|---|---|
|planeNormal|Vector3|Plane normal|

Return: 

- This instance

### func projectOnVector\(Vector3\)
```cj
public func projectOnVector(v: Vector3): Vector3
```
Projects this vector onto the given vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Target vector to project onto|

Return: 

- This instance

### func project\(Matrix4\)
```cj
public func project(cameraProjectionMatrix: Matrix4): Vector3
```
Projects the vector through a camera projection matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cameraProjectionMatrix|Matrix4|Camera projection matrix|

Return: 

- This instance

### func randomDirection\(\)
```cj
public func randomDirection(): Vector3
```
Sets this vector to a uniformly random direction on the unit sphere surface

Return: 

- This instance

### func random\(\)
```cj
public func random(): Vector3
```
Sets each component to a pseudo-random value in [0, 1)

Return: 

- This instance

### func reflect\(Vector3\)
```cj
public func reflect(normal: Vector3): Vector3
```
Reflects this vector along the given normal

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normalized normal vector|

Return: 

- This instance

### func roundToZero\(\)
```cj
public func roundToZero(): Vector3
```
Rounds components toward zero (negative up, positive down)

Return: 

- This instance

### func round\(\)
```cj
public func round(): Vector3
```
Rounds components to the nearest integer

Return: 

- This instance

### func setComponent\(Int64,Float64\)
```cj
public func setComponent(index: Int64, value: Float64): Vector3
```
Sets component value by index (0=x, 1=y, 2=z)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Component indexvalue Value to set|
|value|Float64||

Return: 

- This instance

### func setFromColor\(Color\)
```cj
public func setFromColor(c: Color): Vector3
```
Sets vector components from a color's RGB components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Color|Color|

Return: 

- This instance

### func setFromCylindricalCoords\(Float64,Float64,Float64\)
```cj
public func setFromCylindricalCoords(radius: Float64, theta: Float64, y: Float64): Vector3
```
Sets vector components from cylindrical coordinate parameters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radiustheta Angle in radiansy Height|
|theta|Float64||
|y|Float64||

Return: 

- This instance

### func setFromCylindrical\(Cylindrical\)
```cj
public func setFromCylindrical(c: Cylindrical): Vector3
```
Sets vector components from cylindrical coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Cylindrical|Cylindrical coordinate object|

Return: 

- This instance

### func setFromEuler\(Euler\)
```cj
public func setFromEuler(e: Euler): Vector3
```
Sets vector components from Euler angles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|e|Euler|Euler angles|

Return: 

- This instance

### func setFromMatrix3Column\(Matrix3,Int64\)
```cj
public func setFromMatrix3Column(m: Matrix3, index: Int64): Vector3
```
Sets vector components from the specified column of a 3x3 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix3|3x3 matrixindex Column index|
|index|Int64||

Return: 

- This instance

### func setFromMatrixColumn\(Matrix4,Int64\)
```cj
public func setFromMatrixColumn(m: Matrix4, index: Int64): Vector3
```
Sets vector components from the specified column of a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrixindex Column index|
|index|Int64||

Return: 

- This instance

### func setFromMatrixPosition\(Matrix4\)
```cj
public func setFromMatrixPosition(m: Matrix4): Vector3
```
Sets vector components from the position elements of a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix|

Return: 

- This instance

### func setFromMatrixScale\(Matrix4\)
```cj
public func setFromMatrixScale(m: Matrix4): Vector3
```
Sets vector components from the scale elements of a 4x4 matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 matrix|

Return: 

- This instance

### func setFromSphericalCoords\(Float64,Float64,Float64\)
```cj
public func setFromSphericalCoords(radius: Float64, phi: Float64, theta: Float64): Vector3
```
Sets vector components from spherical coordinate parameters

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radiusphi Polar angle in radianstheta Azimuthal angle in radians|
|phi|Float64||
|theta|Float64||

Return: 

- This instance

### func setFromSpherical\(Spherical\)
```cj
public func setFromSpherical(s: Spherical): Vector3
```
Sets vector components from spherical coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Spherical|Spherical coordinate object|

Return: 

- This instance

### func setLength\(Float64\)
```cj
public func setLength(length: Float64): Vector3
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
public func setScalar(s: Float64): Vector3
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
public func setX(x: Float64): Vector3
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
public func setY(y: Float64): Vector3
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
public func setZ(z: Float64): Vector3
```
Sets the z component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|z|Float64|z component value|

Return: 

- This instance

### func set\(Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64): Vector3
```
Sets vector components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x component valuey y component valuez z component value|
|y|Float64||
|z|Float64||

Return: 

- This instance

### func subScalar\(Float64\)
```cj
public func subScalar(s: Float64): Vector3
```
Subtracts a scalar value from all components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func subVectors\(Vector3,Vector3\)
```cj
public func subVectors(a: Vector3, b: Vector3): Vector3
```
Subtracts two vectors and stores the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Vector3|Minuend vectorb Subtrahend vector|
|b|Vector3||

Return: 

- This instance

### func sub\(Vector3\)
```cj
public func sub(v: Vector3): Vector3
```
Subtracts the given vector from this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector to subtract|

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

### func transformDirection\(Matrix4\)
```cj
public func transformDirection(m: Matrix4): Vector3
```
Transforms this vector by the upper-left 3x3 submatrix of the given 4x4 matrix and normalizes the result

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 affine matrix|

Return: 

- This instance

### func unproject\(Matrix4\)
```cj
public func unproject(cameraProjectionMatrix: Matrix4): Vector3
```
Unprojects the vector through a camera inverse projection matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cameraProjectionMatrix|Matrix4|Camera projection matrix|

Return: 

- This instance

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

