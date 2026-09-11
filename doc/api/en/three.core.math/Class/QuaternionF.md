# Class
## class QuaternionF
```cj
public class QuaternionF
```
Float32 quaternion class for representing 3D rotations

### func angleTo\(QuaternionF\)
```cj
public func angleTo(q: QuaternionF): Float32
```
Calculate the angle between this and another quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|QuaternionF|Another quaternion|

Return: 

- Angle between the two quaternions in radians

### func clone\(\)
```cj
public func clone(): QuaternionF
```
Clone this quaternion

Return: 

- A new quaternion instance

### func conjugate\(\)
```cj
public func conjugate(): QuaternionF
```
Calculate the conjugate of the quaternion (reverse rotation direction), assuming unit quaternion

Return: 

- This instance

### func copy\(QuaternionF\)
```cj
public func copy(q: QuaternionF): QuaternionF
```
Copy another quaternion's values to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|QuaternionF|Source quaternion|

Return: 

- This instance

### func dot\(QuaternionF\)
```cj
public func dot(q: QuaternionF): Float32
```
Calculate the dot product with the given quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|QuaternionF|Another quaternion|

Return: 

- Dot product result

### func equals\(QuaternionF\)
```cj
public func equals(q: QuaternionF): Bool
```
Compare two quaternions for equality

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|QuaternionF|Another quaternion|

Return: 

- Whether equal

### func fromArray\(Array<Float32>\)
```cj
public static func fromArray(arr: Array < Float32 >): QuaternionF
```
Construct from Array<Float32> (length 4)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<Float32>|Float32 array|

Return: 

- QuaternionF instance

### func fromQuaternion\(Quaternion\)
```cj
public static func fromQuaternion(q: Quaternion): QuaternionF
```
Convert from Quaternion (Float64) to QuaternionF

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Float64 quaternion|

Return: 

- Float32 quaternion

### func identity\(\)
```cj
public func identity(): QuaternionF
```
Set to identity quaternion (0,0,0,1)

Return: 

- This instance

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(x: Float32, y: Float32, z: Float32, w: Float32)
```
Construct quaternion with specified components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|x componenty y componentz z componentw w component|
|y|Float32||
|z|Float32||
|w|Float32||

### func init\(\)
```cj
public init()
```
Default constructor, initializes to identity quaternion (0,0,0,1)

### func invert\(\)
```cj
public func invert(): QuaternionF
```
Invert the quaternion (equivalent to conjugate for unit quaternions)

Return: 

- This instance

### func lengthSq\(\)
```cj
public func lengthSq(): Float32
```
Calculate the squared length of the quaternion

Return: 

- Squared length

### func length\(\)
```cj
public func length(): Float32
```
Calculate the Euclidean length of the quaternion

Return: 

- Length

### func multiplyQuaternions\(QuaternionF,QuaternionF\)
```cj
public func multiplyQuaternions(a: QuaternionF, b: QuaternionF): QuaternionF
```
Multiply two quaternions and store the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|QuaternionF|First quaternionb Second quaternion|
|b|QuaternionF||

Return: 

- This instance

### func multiplyScalar\(Float32\)
```cj
public func multiplyScalar(s: Float32): QuaternionF
```
Multiply each component of the quaternion by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float32|Scalar value|

Return: 

- This instance

### func multiply\(QuaternionF\)
```cj
public func multiply(q: QuaternionF): QuaternionF
```
Multiply this quaternion by the given quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|QuaternionF|Quaternion|

Return: 

- This instance

### func negate\(\)
```cj
public func negate(): QuaternionF
```
Negate all components of the quaternion

Return: 

- This instance

### func normalize\(\)
```cj
public func normalize(): QuaternionF
```
Normalize the quaternion to unit length; if length is 0, set to identity (0,0,0,1)

Return: 

- This instance

### func premultiply\(QuaternionF\)
```cj
public func premultiply(q: QuaternionF): QuaternionF
```
Pre-multiply the given quaternion with this quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|QuaternionF|Quaternion|

Return: 

- This instance

### func setFromAxisAngle\(Vector3F,Float32\)
```cj
public func setFromAxisAngle(axis: Vector3F, angle: Float32): QuaternionF
```
Set quaternion from axis-angle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3F|Rotation axis (should be a unit vector)angle Rotation angle in radians|
|angle|Float32||

Return: 

- This instance

### func setFromRotationMatrix\(Matrix4F\)
```cj
public func setFromRotationMatrix(m: Matrix4F): QuaternionF
```
Set quaternion from rotation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4F|4x4 rotation matrix|

Return: 

- This instance

### func set\(Float32,Float32,Float32,Float32\)
```cj
public func set(x: Float32, y: Float32, z: Float32, w: Float32): QuaternionF
```
Set quaternion components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|x componenty y componentz z componentw w component|
|y|Float32||
|z|Float32||
|w|Float32||

Return: 

- This instance

### func slerpQuaternions\(QuaternionF,QuaternionF,Float32\)
```cj
public func slerpQuaternions(qa: QuaternionF, qb: QuaternionF, t: Float32): QuaternionF
```
Perform spherical linear interpolation between two quaternions, store result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|qa|QuaternionF|First quaternionqb Second quaterniont Interpolation factor|
|qb|QuaternionF||
|t|Float32||

Return: 

- This instance

### func slerp\(QuaternionF,Float32\)
```cj
public func slerp(qb: QuaternionF, t: Float32): QuaternionF
```
Spherical linear interpolation (SLERP)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|qb|QuaternionF|Target quaterniont Interpolation factor, closed interval [0, 1]|
|t|Float32||

Return: 

- This instance

### func toArray\(\)
```cj
public func toArray(): Array < Float32 >
```
Convert to Array<Float32> (length 4)

Return: 

- Float32 array

### func toQuaternion\(\)
```cj
public func toQuaternion(): Quaternion
```
Convert to Quaternion (Float64)

Return: 

- Float64 quaternion

### var w
```cj
public var w: Float32
```
w component (scalar part)

### var x
```cj
public var x: Float32
```
x component

### var y
```cj
public var y: Float32
```
y component

### var z
```cj
public var z: Float32
```
z component

