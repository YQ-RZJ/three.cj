# Class
## class QuaternionKeyframeTrack
```cj
public class QuaternionKeyframeTrack <: KeyframeTrack
```
Quaternion keyframe track

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
Overrides the linear interpolation factory method to return a quaternion SLERP interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer|

Return: 

- Quaternion linear (SLERP) interpolant

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
Overrides the smooth interpolation factory method, falling back to linear interpolation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer|

Return: 

- Quaternion linear (SLERP) interpolant

### func init\(String,Array<Float64>,Array<Float64>,Int64\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >, interpolation!: Int64 = InterpolateLinear)
```
Constructs a new quaternion keyframe track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Keyframe track nametimes Keyframe time arrayvalues Keyframe value arrayinterpolation Interpolation type, defaults to linear interpolation|
|times|Array<Float64>||
|values|Array<Float64>||
|interpolation|Int64||

