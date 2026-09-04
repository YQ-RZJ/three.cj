# Class
## class MathUtils
```cj
public class MathUtils
```
Math utility class providing a collection of commonly used math functions

### func ceilPowerOfTwo\(Int64\)
```cj
public static func ceilPowerOfTwo(value: Int64): Int64
```
Return the smallest power of two greater than or equal to the given value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Value to find, must be greater than 0|

Return: 

- Smallest power of two

### func clamp\(Float64,Float64,Float64\)
```cj
public static func clamp(v: Float64, min: Float64, max: Float64): Float64
```
Clamp value to the [min, max] range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float64|Value to clampmin Minimum valuemax Maximum value|
|min|Float64||
|max|Float64||

Return: 

- Clamped value

### func damp\(Float64,Float64,Float64,Float64\)
```cj
public static func damp(x: Float64, y: Float64, lambda: Float64, dt: Float64): Float64
```
Smooth interpolation using spring damping, frame rate independent

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Current valuey Target valuelambda Damping coefficient, larger values mean more abrupt changesdt Time delta in seconds|
|y|Float64||
|lambda|Float64||
|dt|Float64||

Return: 

- Interpolated result

### func degToRad\(Float64\)
```cj
public static func degToRad(degrees: Float64): Float64
```
Convert degrees to radians

Parameter: 

|Name|Type|Describe|
|---|---|---|
|degrees|Float64|Degree value|

Return: 

- Radian value

### func denormalize\(Float64,Int64\)
```cj
public static func denormalize(value: Float64, componentType: Int64): Float64
```
Denormalize a value based on the typed array type, converting [0,1] float to the corresponding integer type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Value to denormalizecomponentType Component type identifier (0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8)|
|componentType|Int64||

Return: 

- Denormalized value

### func euclideanModulo\(Int64,Int64\)
```cj
public static func euclideanModulo(n: Int64, m: Int64): Int64
```
Compute Euclidean modulo: ((n % m) + m) % m

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Int64|Dividendm Divisor|
|m|Int64||

Return: 

- Euclidean modulo result

### func euclideanModulo\(Float64,Float64\)
```cj
public static func euclideanModulo(n: Float64, m: Float64): Float64
```
Compute float Euclidean modulo: result is always non-negative

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Float64|Dividendm Divisor|
|m|Float64||

Return: 

- Euclidean modulo result

### func floorPowerOfTwo\(Int64\)
```cj
public static func floorPowerOfTwo(value: Int64): Int64
```
Return the largest power of two less than or equal to the given value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Value to find, must be greater than 0|

Return: 

- Largest power of two

### func generateUUID\(\)
```cj
public static func generateUUID(): String
```
Generate UUID (Universally Unique Identifier)

Return: 

- UUID string

### func inverseLerp\(Float64,Float64,Float64\)
```cj
public static func inverseLerp(x: Float64, y: Float64, value: Float64): Float64
```
Return the percentage of the given value between start and end in the closed interval [0, 1]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Start valuey End valuevalue Value between start and end|
|y|Float64||
|value|Float64||

Return: 

- Interpolation factor

### func isPowerOfTwo\(Int64\)
```cj
public static func isPowerOfTwo(value: Int64): Bool
```
Check if the given value is a power of two

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Value to check|

Return: 

- Whether the value is a power of two

### func lerp\(Float64,Float64,Float64\)
```cj
public static func lerp(x: Float64, y: Float64, t: Float64): Float64
```
Linear interpolation: t = 0 returns x, t = 1 returns y

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Start valuey End valuet Interpolation factor, closed interval [0, 1]|
|y|Float64||
|t|Float64||

Return: 

- Interpolated result

### func mapLinear\(Float64,Float64,Float64,Float64,Float64\)
```cj
public static func mapLinear(x: Float64, a1: Float64, a2: Float64, b1: Float64, b2: Float64): Float64
```
Map value linearly from range [a1, a2] to range [b1, b2]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Value to mapa1 Range A minimuma2 Range A maximumb1 Range B minimumb2 Range B maximum|
|a1|Float64||
|a2|Float64||
|b1|Float64||
|b2|Float64||

Return: 

- Mapped value

### func normalize\(Float64,Int64\)
```cj
public static func normalize(value: Float64, componentType: Int64): Float64
```
Normalize a value based on the typed array type, converting integer to [0,1] float

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Float value to normalizecomponentType Component type identifier (0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8)|
|componentType|Int64||

Return: 

- Normalized value

### func pingpong\(Float64,Float64\)
```cj
public static func pingpong(x: Float64, length!: Float64 = 1.0): Float64
```
Return a value that alternates between 0 and the given length

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Value to ping-ponglength Positive value to ping-pong to, default 1|
|length|Float64||

Return: 

- Alternated value

### func radToDeg\(Float64\)
```cj
public static func radToDeg(radians: Float64): Float64
```
Convert radians to degrees

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radians|Float64|Radian value|

Return: 

- Degree value

### func randFloatSpread\(Float64\)
```cj
public static func randFloatSpread(range: Float64): Float64
```
Return a random float in the [-range/2, range/2] range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|range|Float64|Range|

Return: 

- Random float

### func randFloat\(Float64,Float64\)
```cj
public static func randFloat(low: Float64, high: Float64): Float64
```
Return a random float in the [low, high] range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|low|Float64|Lower boundhigh Upper bound|
|high|Float64||

Return: 

- Random float

### func randInt\(Int64,Int64\)
```cj
public static func randInt(low: Int64, high: Int64): Int64
```
Return a random integer in the [low, high] range

Parameter: 

|Name|Type|Describe|
|---|---|---|
|low|Int64|Lower boundhigh Upper bound|
|high|Int64||

Return: 

- Random integer

### func seededRandom\(Option<Int64>\)
```cj
public static func seededRandom(s!: Option < Int64 >= None): Float64
```
Return a deterministic pseudo-random float in [0, 1] (Mulberry32 generator)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Option<Int64>|Optional integer seed|

Return: 

- Pseudo-random float

### func setQuaternionFromProperEuler\(Quaternion,Float64,Float64,Float64,String\)
```cj
public static func setQuaternionFromProperEuler(q: Quaternion, a: Float64, b: Float64, c: Float64, order: String): Unit
```
Set quaternion from intrinsic proper Euler angles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion|Quaternion to seta First axis rotation angle in radiansb Second axis rotation angle in radiansc Third axis rotation angle in radiansorder Axis order string, e.g. "XYX", "XZX", "YXY", etc.|
|a|Float64||
|b|Float64||
|c|Float64||
|order|String||

### func smootherstep\(Float64,Float64,Float64\)
```cj
public static func smootherstep(x: Float64, min: Float64, max: Float64): Float64
```
Variant of smoothstep with zero first and second derivatives at x=0 and x=1

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Value to evaluatemin Minimum value, returns 0 below thismax Maximum value, returns 1 above this|
|min|Float64||
|max|Float64||

Return: 

- Smoother interpolation result

### func smoothstep\(Float64,Float64,Float64\)
```cj
public static func smoothstep(x: Float64, min: Float64, max: Float64): Float64
```
Return the smooth percentage of x moving between [min, max], range [0, 1]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Value to evaluatemin Minimum value, returns 0 below thismax Maximum value, returns 1 above this|
|min|Float64||
|max|Float64||

Return: 

- Smooth interpolation result

