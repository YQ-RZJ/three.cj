# Class
## class VecFloat
```cj
public class VecFloat
```
Float32 3-component vector utility object

### func add\(Array<Float32>,Array<Float32>\)
```cj
public func add(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
Addition: result = a + b

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>|Left operand (length >= 3)|
|b|Array<Float32>|Right operand (length >= 3)|

Return: 

- Result (length 3)

### func cross\(Array<Float32>,Array<Float32>\)
```cj
public func cross(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
Cross product: result = a × b

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

Return: 

- Result (length 3)

### func distance\(Array<Float32>,Array<Float32>\)
```cj
public func distance(a: Array < Float32 >, b: Array < Float32 >): Float32
```
Distance between two points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>|Start point|
|b|Array<Float32>|End point|

Return: 

- Float32 distance value

### func dot\(Array<Float32>,Array<Float32>\)
```cj
public func dot(a: Array < Float32 >, b: Array < Float32 >): Float32
```
Dot product: result = a·b

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

Return: 

- Float32 scalar result

### func lengthSq\(Array<Float32>\)
```cj
public func lengthSq(v: Array < Float32 >): Float32
```
Squared vector length (avoids square root)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Array<Float32>||

Return: 

- Float32 squared length value

### func length\(Array<Float32>\)
```cj
public func length(v: Array < Float32 >): Float32
```
Vector length

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Array<Float32>||

Return: 

- Float32 length value

### func lerp\(Array<Float32>,Array<Float32>,Float32\)
```cj
public func lerp(a: Array < Float32 >, b: Array < Float32 >, t: Float32): Array < Float32 >
```
Linear interpolation: result = a + (b - a) * t

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>|Start vector|
|b|Array<Float32>|Target vector|
|t|Float32|Interpolation factor|

Return: 

- Interpolation result (length 3)

### func max\(Array<Float32>,Array<Float32>\)
```cj
public func max(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
Element-wise maximum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

### func min\(Array<Float32>,Array<Float32>\)
```cj
public func min(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
Element-wise minimum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

### func negate\(Array<Float32>\)
```cj
public func negate(v: Array < Float32 >): Array < Float32 >
```
Vector negation: result = -v

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Array<Float32>||

### func normalize\(Array<Float32>\)
```cj
public func normalize(v: Array < Float32 >): Array < Float32 >
```
Normalize: result = v / |v|

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Array<Float32>|Vector (length >= 3)|

Return: 

- Normalized vector (length 3); returns the original vector if its length is near zero

### func one\(\)
```cj
public static func one(): Array < Float32 >
```
Unit vector (1, 1, 1)

### func scale\(Array<Float32>,Float32\)
```cj
public func scale(v: Array < Float32 >, s: Float32): Array < Float32 >
```
Scalar multiplication: result = v * s

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Array<Float32>|Vector (length >= 3)|
|s|Float32|Scalar|

Return: 

- Result (length 3)

### func sub\(Array<Float32>,Array<Float32>\)
```cj
public func sub(a: Array < Float32 >, b: Array < Float32 >): Array < Float32 >
```
Subtraction: result = a - b

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Array<Float32>||
|b|Array<Float32>||

### func zero\(\)
```cj
public static func zero(): Array < Float32 >
```
Zero vector

