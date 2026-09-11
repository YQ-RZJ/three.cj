# Class
## class Quaternion
```cj
public class Quaternion
```
Quaternion class for representing 3D rotations

### func angleTo\(Quaternion\)
```cj
public func angleTo(q: Quaternion): Float64
```
Calculate the angle in radians between this quaternion and the given quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Another quaternion|

Return: 

- Angle in radians

### func clone\(\)
```cj
public func clone(): Quaternion
```
Clone this quaternion

Return: 

- A new quaternion instance

### func conjugate\(\)
```cj
public func conjugate(): Quaternion
```
Calculate the conjugate of the quaternion (reverse rotation direction), assuming unit quaternion

Return: 

- This instance

### func copy\(Quaternion\)
```cj
public func copy(q: Quaternion): Quaternion
```
Copy another quaternion's values to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Source quaternion|

Return: 

- This instance

### func dot\(Quaternion\)
```cj
public func dot(q: Quaternion): Float64
```
Calculate the dot product with the given quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Another quaternion|

Return: 

- Dot product result

### func equals\(Quaternion\)
```cj
public func equals(q: Quaternion): Bool
```
Check if this quaternion equals the given quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Another quaternion|

Return: 

- Whether equal

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Quaternion
```
Set quaternion components from an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array containing component valuesoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- This instance

### func fromBufferAttribute\(AttributeReader,Int64\)
```cj
public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Quaternion
```
Read quaternion components from vertex attribute (aligned with JS: Quaternion.fromBufferAttribute)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|AttributeReader|Vertex attribute (AttributeReader interface, implemented by BufferAttribute)index Vertex index|
|index|Int64||

Return: 

- This instance

### func identity\(\)
```cj
public func identity(): Quaternion
```
Set the quaternion to identity (no rotation)

Return: 

- This instance

### func init\(Float64,Float64,Float64,Float64\)
```cj
public init(x: Float64, y: Float64, z: Float64, w: Float64)
```
Construct quaternion with specified components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x componenty y componentz z componentw w component|
|y|Float64||
|z|Float64||
|w|Float64||

### func init\(\)
```cj
public init()
```
Default constructor, initializes to identity quaternion (0,0,0,1)

### func invert\(\)
```cj
public func invert(): Quaternion
```
Invert the quaternion (equivalent to conjugate for unit quaternions)

Return: 

- This instance

### func lengthSq\(\)
```cj
public func lengthSq(): Float64
```
Calculate the squared length of the quaternion

Return: 

- Squared length

### func length\(\)
```cj
public func length(): Float64
```
Calculate the Euclidean length of the quaternion

Return: 

- Length

### func multiplyQuaternionsFlat\(Array<Float64>,Int64,Array<Float64>,Int64,Array<Float64>,Int64\)
```cj
public static func multiplyQuaternionsFlat(dst: Array < Float64 >, dstOffset: Int64, src0: Array < Float64 >, srcOffset0: Int64, src1: Array < Float64 >, srcOffset1: Int64): Unit
```
Multiply two quaternions (flat array version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dst|Array<Float64>|Destination arraydstOffset Destination offsetsrc0 First source arraysrcOffset0 First source offsetsrc1 Second source arraysrcOffset1 Second source offset|
|dstOffset|Int64||
|src0|Array<Float64>||
|srcOffset0|Int64||
|src1|Array<Float64>||
|srcOffset1|Int64||

### func multiplyQuaternions\(Quaternion,Quaternion\)
```cj
public func multiplyQuaternions(a: Quaternion, b: Quaternion): Quaternion
```
Multiply two quaternions and store the result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Quaternion|First quaternionb Second quaternion|
|b|Quaternion||

Return: 

- This instance

### func multiplyScalar\(Float64\)
```cj
public func multiplyScalar(s: Float64): Quaternion
```
Multiply each component of the quaternion by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scalar value|

Return: 

- This instance

### func multiply\(Quaternion\)
```cj
public func multiply(q: Quaternion): Quaternion
```
Multiply this quaternion by the given quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Quaternion|

Return: 

- This instance

### func negate\(\)
```cj
public func negate(): Quaternion
```
Negate all components of the quaternion

Return: 

- This instance

### func normalize\(\)
```cj
public func normalize(): Quaternion
```
Normalize the quaternion to unit length; if length is 0, set to identity (0,0,0,1)

Return: 

- This instance

### func onChange\(\(\)\->Unit\)
```cj
public func onChange(callback:() -> Unit): Quaternion
```
Set the change callback function, which will be called when the quaternion value is modified

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Callback function|

Return: 

- This instance

### func premultiply\(Quaternion\)
```cj
public func premultiply(q: Quaternion): Quaternion
```
Pre-multiply the given quaternion with this quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Quaternion|

Return: 

- This instance

### func random\(\)
```cj
public func random(): Quaternion
```
Set the quaternion to a random unit quaternion

Return: 

- This instance

### func rotateTowards\(Quaternion,Float64\)
```cj
public func rotateTowards(q: Quaternion, step: Float64): Quaternion
```
Rotate this quaternion towards the target quaternion with a maximum step in radians

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Target quaternionstep Maximum rotation angle in radians|
|step|Float64||

Return: 

- This instance

### func rotateVector\(Vector3\)
```cj
public func rotateVector(v: Vector3): Vector3
```
Rotate a vector using this quaternion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector to rotate|

Return: 

- New rotated vector

### func setFromAxisAngle\(Vector3,Float64\)
```cj
public func setFromAxisAngle(axis: Vector3, angle: Float64): Quaternion
```
Set quaternion from axis-angle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3|Rotation axis (should be a unit vector)angle Rotation angle in radians|
|angle|Float64||

Return: 

- This instance

### func setFromEuler\(Euler\)
```cj
public func setFromEuler(euler: Euler): Quaternion
```
Set quaternion from Euler angles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|euler|Euler|Euler angles|

Return: 

- This instance

### func setFromRotationMatrix\(Matrix4\)
```cj
public func setFromRotationMatrix(m: Matrix4): Quaternion
```
Set quaternion from rotation matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|4x4 rotation matrix|

Return: 

- This instance

### func setFromUnitVectors\(Vector3,Vector3\)
```cj
public func setFromUnitVectors(vFrom: Vector3, vTo: Vector3): Quaternion
```
Set quaternion rotation from two unit vectors

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vFrom|Vector3|Source direction vector (should be a unit vector)vTo Target direction vector (should be a unit vector)|
|vTo|Vector3||

Return: 

- This instance

### func set\(Float64,Float64,Float64,Float64\)
```cj
public func set(x: Float64, y: Float64, z: Float64, w: Float64): Quaternion
```
Set quaternion components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x componenty y componentz z componentw w component|
|y|Float64||
|z|Float64||
|w|Float64||

Return: 

- This instance

### func slerpFlat\(Array<Float64>,Int64,Array<Float64>,Int64,Array<Float64>,Int64,Float64\)
```cj
public static func slerpFlat(dst: Array < Float64 >, dstOffset: Int64, src0: Array < Float64 >, srcOffset0: Int64, src1: Array < Float64 >, srcOffset1: Int64, t: Float64): Unit
```
Perform spherical linear interpolation between two quaternions (flat array version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dst|Array<Float64>|Destination arraydstOffset Destination offsetsrc0 First source arraysrcOffset0 First source offsetsrc1 Second source arraysrcOffset1 Second source offsett Interpolation factor|
|dstOffset|Int64||
|src0|Array<Float64>||
|srcOffset0|Int64||
|src1|Array<Float64>||
|srcOffset1|Int64||
|t|Float64||

### func slerpQuaternions\(Quaternion,Quaternion,Float64\)
```cj
public func slerpQuaternions(qa: Quaternion, qb: Quaternion, t: Float64): Quaternion
```
Perform spherical linear interpolation between two quaternions, store result in this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|qa|Quaternion|First quaternionqb Second quaterniont Interpolation factor|
|qb|Quaternion||
|t|Float64||

Return: 

- This instance

### func slerp\(Quaternion,Float64\)
```cj
public func slerp(qb: Quaternion, t: Float64): Quaternion
```
Spherical linear interpolation (SLERP)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|qb|Quaternion|Target quaterniont Interpolation factor, closed interval [0, 1]|
|t|Float64||

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Write quaternion components to an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Starting index, defaults to 0|
|offset|Int64||

Return: 

- Array containing component values

### var w
```cj
public var w: Float64
```
w component (scalar part)

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

