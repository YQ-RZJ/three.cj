# Class
## class GltfAnimationSampler
```cj
public class GltfAnimationSampler
```
Parsed glTF Animation Sampler

### func init\(Int,Int,String\)
```cj
public init(input: Int, output: Int, interpolation: String)
```
Create an Animation Sampler

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|Int|Time input accessor index|
|output|Int|Value output accessor index|
|interpolation|String|Interpolation mode|

### let input
```cj
public let input: Int
```
Time input accessor index

### let interpolation
```cj
public let interpolation: String
```
Interpolation mode (LINEAR/STEP/CUBICSPLINE)

### let output
```cj
public let output: Int
```
Value output accessor index

