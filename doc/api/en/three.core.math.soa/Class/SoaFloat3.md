# Class
## class SoaFloat3
```cj
public class SoaFloat3
```
SoA float3 struct storing 4 vectors

### func add\(SoaFloat3\)
```cj
public func add(rhs: SoaFloat3): Unit
```
Add rhs element-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SoaFloat3||

### func cross\(SoaFloat3\)
```cj
public func cross(rhs: SoaFloat3): SoaFloat3
```
Per-slot cross product

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SoaFloat3|Right-hand operand|

Return: 

- SoaFloat3 containing the 4 cross product results

### func dot\(SoaFloat3\)
```cj
public func dot(rhs: SoaFloat3): SimdFloat
```
Per-slot dot product, returns 4 results as SimdFloat

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SoaFloat3|Right-hand operand|

Return: 

- SimdFloat containing the 4 dot product values

### func fromFour\(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(x0: Float32, y0: Float32, z0: Float32, x1: Float32, y1: Float32, z1: Float32, x2: Float32, y2: Float32, z2: Float32, x3: Float32, y3: Float32, z3: Float32): SoaFloat3
```
Construct from 4 individual float3 vectors

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x0|Float32||
|y0|Float32||
|z0|Float32||
|x1|Float32||
|y1|Float32||
|z1|Float32||
|x2|Float32||
|y2|Float32||
|z2|Float32||
|x3|Float32||
|y3|Float32||
|z3|Float32||

### func get\(Int\)
```cj
public func get(slot: Int): Vector3F
```
Get the float3 vector for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|

Return: 

- (x, y, z)

### func init\(\)
```cj
public init()
```
Default constructor, initializes to zero vectors

### func init\(Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(x: Array < Float32 >, y: Array < Float32 >, z: Array < Float32 >)
```
Construct from raw arrays

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Array<Float32>|x-component array (4 elements)|
|y|Array<Float32>|y-component array (4 elements)|
|z|Array<Float32>|z-component array (4 elements)|

### func length\(\)
```cj
public func length(): SimdFloat
```
Per-slot vector length

Return: 

- SimdFloat containing the 4 length values

### func lerp\(SoaFloat3,SoaFloat3,SimdFloat\)
```cj
public static func lerp(a: SoaFloat3, b: SoaFloat3, t: SimdFloat): SoaFloat3
```
Per-slot linear interpolation: result = a + (b - a) * t

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|SoaFloat3|Start value|
|b|SoaFloat3|Target value|
|t|SimdFloat|Interpolation factor (SimdFloat, independent per slot)|

Return: 

- Interpolation result

### func negate\(\)
```cj
public func negate(): Unit
```
Negate all 4 vectors

### func normalize\(\)
```cj
public func normalize(): Unit
```
Normalize all 4 vectors in place

### func scale\(Float32\)
```cj
public func scale(scalar: Float32): Unit
```
Multiply by scalar element-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scalar|Float32||

### func set\(Int,Float32,Float32,Float32\)
```cj
public func set(slot: Int, vx: Float32, vy: Float32, vz: Float32): Unit
```
Set the float3 vector for a given slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|Int|Slot index (0-3)|
|vx|Float32|x component|
|vy|Float32|y component|
|vz|Float32|z component|

### func sub\(SoaFloat3\)
```cj
public func sub(rhs: SoaFloat3): Unit
```
Subtract rhs element-wise

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SoaFloat3||

### func zero\(\)
```cj
public static func zero(): SoaFloat3
```
Create zero vectors

### var x
```cj
public var x: Array < Float32 >
```
x components of 4 vectors

### var y
```cj
public var y: Array < Float32 >
```
y components of 4 vectors

### var z
```cj
public var z: Array < Float32 >
```
z components of 4 vectors

