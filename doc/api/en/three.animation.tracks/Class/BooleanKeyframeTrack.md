# Class
## class BooleanKeyframeTrack
```cj
public class BooleanKeyframeTrack <: KeyframeTrack
```
Boolean keyframe track

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
Overrides the linear interpolation factory method with discrete interpolation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer|

Return: 

- Discrete interpolant

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
Overrides the smooth interpolation factory method with discrete interpolation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer|

Return: 

- Discrete interpolant

### func init\(String,Array<Float64>,Array<Float64>\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >)
```
Constructs a new boolean keyframe track

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Keyframe track nametimes Keyframe time arrayvalues Keyframe value array|
|times|Array<Float64>||
|values|Array<Float64>||

### func setInterpolation\(Int64\)
```cj
public override func setInterpolation(interpolation: Int64): KeyframeTrack
```
Overrides the interpolation setter; booleans always use discrete interpolation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|interpolation|Int64|The interpolation type to set|

Return: 

- The keyframe track after setting

