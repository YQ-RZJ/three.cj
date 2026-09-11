# Class
## class SimdQuaternion
```cj
public class SimdQuaternion
```
4-wide scalar quaternion

### func conjugate\(\)
```cj
public func conjugate(): Unit
```
Conjugate: conjugates each of the 4 quaternions (-x, -y, -z, w)

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(x0: Float32, y0: Float32, z0: Float32, w0: Float32, x1: Float32, y1: Float32, z1: Float32, w1: Float32, x2: Float32, y2: Float32, z2: Float32, w2: Float32, x3: Float32, y3: Float32, z3: Float32, w3: Float32): SimdQuaternion
```
Construct from 4 individual quaternion values

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

### func fromSoa\(SoaQuaternion\)
```cj
public static func fromSoa(soa: SoaQuaternion): SimdQuaternion
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|soa|SoaQuaternion||

### func identity\(\)
```cj
public static func identity(): SimdQuaternion
```
Creates 4 identity quaternions

### func init\(\)
```cj
public init()
```
Default constructor, initializes to 4 identity quaternions

### func init\(Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(x: Array < Float32 >, y: Array < Float32 >, z: Array < Float32 >, w: Array < Float32 >)
```
Construct from raw arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Array<Float32>||
|y|Array<Float32>||
|z|Array<Float32>||
|w|Array<Float32>||

### func mul\(SimdQuaternion\)
```cj
public func mul(rhs: SimdQuaternion): Unit
```
Per-slot multiplication: this[i] = this[i] * rhs[i]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdQuaternion||

### func normalize\(\)
```cj
public func normalize(): Unit
```
Normalize: normalizes each of the 4 quaternions

### func splat\(Float32,Float32,Float32,Float32\)
```cj
public static func splat(qx: Float32, qy: Float32, qz: Float32, qw: Float32): SimdQuaternion
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|qx|Float32||
|qy|Float32||
|qz|Float32||
|qw|Float32||

### func toSoa\(\)
```cj
public func toSoa(): SoaQuaternion
```


### var w
```cj
public var w: Array < Float32 >
```
w components of the 4 lanes

### var x
```cj
public var x: Array < Float32 >
```
x components of the 4 lanes

### var y
```cj
public var y: Array < Float32 >
```
y components of the 4 lanes

### var z
```cj
public var z: Array < Float32 >
```
z components of the 4 lanes

