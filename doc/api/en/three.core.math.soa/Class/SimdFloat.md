# Class
## class SimdFloat
```cj
public class SimdFloat
```
4-wide scalar float

### func add\(SimdFloat\)
```cj
public func add(rhs: SimdFloat): Unit
```
Addition: this = this + rhs

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

### func fromFour\(Float32,Float32,Float32,Float32\)
```cj
public static func fromFour(v0: Float32, v1: Float32, v2: Float32, v3: Float32): SimdFloat
```
Construct from 4 scalar values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v0|Float32|Lane 0|
|v1|Float32|Lane 1|
|v2|Float32|Lane 2|
|v3|Float32|Lane 3|

### func greaterThan\(SimdFloat\)
```cj
public func greaterThan(rhs: SimdFloat): SimdFloat
```
Per-lane greater-than comparison

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

Return: 

- SimdFloat with results of 1.0f32 or 0.0f32

### func init\(\)
```cj
public init()
```
Default constructor, initializes to zero

### func init\(Float32\)
```cj
public init(scalar: Float32)
```
Construct from a scalar (same value in all 4 lanes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scalar|Float32|Scalar value|

### func init\(Array<Float32>\)
```cj
public init(values: Array < Float32 >)
```
Construct from raw array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|Array<Float32>|Array of 4 elements|

### func lerp\(SimdFloat,SimdFloat,SimdFloat\)
```cj
public static func lerp(a: SimdFloat, b: SimdFloat, t: SimdFloat): SimdFloat
```
Per-lane linear interpolation: result = a + (b - a) * t

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|SimdFloat|Start value|
|b|SimdFloat|Target value|
|t|SimdFloat|Interpolation factor|

Return: 

- Interpolation result

### func lessThan\(SimdFloat\)
```cj
public func lessThan(rhs: SimdFloat): SimdFloat
```
Per-lane less-than comparison

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

Return: 

- SimdFloat with results of 1.0f32 or 0.0f32

### func max\(SimdFloat\)
```cj
public func max(rhs: SimdFloat): Unit
```
Per-lane maximum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

### func min\(SimdFloat\)
```cj
public func min(rhs: SimdFloat): Unit
```
Per-lane minimum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

### func mulScalar\(Float32\)
```cj
public func mulScalar(scalar: Float32): Unit
```
Scalar multiplication: this = this * scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scalar|Float32||

### func mul\(SimdFloat\)
```cj
public func mul(rhs: SimdFloat): Unit
```
Multiplication: this = this * rhs

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

### func negate\(\)
```cj
public func negate(): SimdFloat
```
Per-lane negation

### func one\(\)
```cj
public static func one(): SimdFloat
```
Creates all ones

### func sqrt\(\)
```cj
public func sqrt(): SimdFloat
```
Per-lane square root

### func sub\(SimdFloat\)
```cj
public func sub(rhs: SimdFloat): Unit
```
Subtraction: this = this - rhs

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|SimdFloat||

### func zero\(\)
```cj
public static func zero(): SimdFloat
```
Creates all zeros

### var values
```cj
public var values: Array < Float32 >
```
Values for the 4 lanes

