# Class
## class SoaQuaternion
```cj
public class SoaQuaternion
```
SoA quaternion struct storing 4 quaternions

### func conjugate\(\)
```cj
public func conjugate(): Unit
```
Conjugate all 4 quaternions in place

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(x0: Float32, y0: Float32, z0: Float32, w0: Float32, x1: Float32, y1: Float32, z1: Float32, w1: Float32, x2: Float32, y2: Float32, z2: Float32, w2: Float32, x3: Float32, y3: Float32, z3: Float32, w3: Float32): SoaQuaternion
```
Construct from 4 individual quaternions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x0|Float32||
|y0|Float32||
|z0|Float32||
|w0|Float32||
|x1|Float32||
|y1|Float32||
|z1|Float32||
|w1|Float32||
|x2|Float32||
|y2|Float32||
|z2|Float32||
|w2|Float32||
|x3|Float32||
|y3|Float32||
|z3|Float32||
|w3|Float32||

### func get\(Int\)
```cj
public func get(slot: Int): QuaternionF
```
Get quaternion components for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|

Return: 

- (x, y, z, w)

### func identity\(\)
```cj
public static func identity(): SoaQuaternion
```
Create 4 identity quaternions

### func init\(\)
```cj
public init()
```
Default constructor, initializes to 4 identity quaternions (0,0,0,1)

### func init\(Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(x: Array < Float32 >, y: Array < Float32 >, z: Array < Float32 >, w: Array < Float32 >)
```
Construct from raw arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Array<Float32>|x-component array (4 elements)|
|y|Array<Float32>|y-component array (4 elements)|
|z|Array<Float32>|z-component array (4 elements)|
|w|Array<Float32>|w-component array (4 elements)|

### func mul\(SoaQuaternion\)
```cj
public func mul(rhs: SoaQuaternion): Unit
```
Per-slot quaternion multiplication: this[i] = this[i] * rhs[i]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SoaQuaternion|Right-hand operand|

### func nlerp\(SoaQuaternion,SoaQuaternion,Array<Float32>\)
```cj
public static func nlerp(a: SoaQuaternion, b: SoaQuaternion, t: Array < Float32 >): SoaQuaternion
```
Per-slot normalized linear interpolation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|SoaQuaternion||
|b|SoaQuaternion||
|t|Array<Float32>|Interpolation factor array (4 elements, independent per slot)|

### func normalize\(\)
```cj
public func normalize(): Unit
```
Normalize all 4 quaternions in place

### func set\(Int,Float32,Float32,Float32,Float32\)
```cj
public func set(slot: Int, qx: Float32, qy: Float32, qz: Float32, qw: Float32): Unit
```
Set quaternion components for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|
|qx|Float32|x component|
|qy|Float32|y component|
|qz|Float32|z component|
|qw|Float32|w component|

### var w
```cj
public var w: Array < Float32 >
```
w components of 4 quaternions

### var x
```cj
public var x: Array < Float32 >
```
x components of 4 quaternions

### var y
```cj
public var y: Array < Float32 >
```
y components of 4 quaternions

### var z
```cj
public var z: Array < Float32 >
```
z components of 4 quaternions

