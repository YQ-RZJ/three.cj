# Interface
## interface IKeyframeTrack
```cj
public interface IKeyframeTrack
```
Keyframe track interface: the element type of AnimationClip.tracks

### func InterpolantFactoryMethodBezier\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodBezier(result: Option < Array < Float64 >>): Interpolant
```
Creates a bezier interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer to reuse|

Return: 

- A bezier interpolant

### func InterpolantFactoryMethodDiscrete\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodDiscrete(result: Option < Array < Float64 >>): Interpolant
```
Creates a discrete interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer to reuse|

Return: 

- A discrete interpolant

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
Creates a linear interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer to reuse|

Return: 

- A linear interpolant

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
Creates a smooth (cubic) interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer to reuse|

Return: 

- A smooth interpolant

### func clone\(\)
```cj
func clone(): IKeyframeTrack
```
Clones the track

Return: 

- A copy of the track

### func createInterpolant\(Option<Array<Float64>>\)
```cj
func createInterpolant(result: Option < Array < Float64 >>): Interpolant
```
Creates an interpolant (choosing the factory method by the current _interpolation)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer to reuse|

Return: 

- The newly created interpolant

### func getInterpolation\(\)
```cj
func getInterpolation(): Int64
```
Returns the current interpolation type

Return: 

- The interpolation type

### func getValueSize\(\)
```cj
func getValueSize(): Int64
```
Returns the value size (number of numbers per keyframe)

Return: 

- The value size

### func optimize\(\)
```cj
func optimize(): IKeyframeTrack
```
Optimizes the keyframes (removes equivalent consecutive keyframes, returns this)

Return: 

- This track

### func scale\(Float64\)
```cj
func scale(timeScale: Float64): IKeyframeTrack
```
Scales the times (returns this)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeScale|Float64|Time scale factor|

Return: 

- This track

### func setInterpolation\(Int64\)
```cj
func setInterpolation(interpolation: Int64): IKeyframeTrack
```
Sets the interpolation type (returns this)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|interpolation|Int64|Interpolation type|

Return: 

- This track

### func shift\(Float64\)
```cj
func shift(timeOffset: Float64): IKeyframeTrack
```
Shifts the times by an offset (returns this for chaining)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeOffset|Float64|Time offset (seconds)|

Return: 

- This track

### func trim\(Float64,Float64\)
```cj
func trim(startTime: Float64, endTime: Float64): IKeyframeTrack
```
Trims the time range (returns this)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|startTime|Float64|Trim start time (seconds)endTime Trim end time (seconds)|
|endTime|Float64||

Return: 

- This track

### func validate\(\)
```cj
func validate(): Bool
```
Validates the keyframe data

Return: 

- Whether the data is valid

### prop DefaultInterpolation: Int64
```cj
mut prop DefaultInterpolation: Int64
```
Default interpolation type (InterpolateLinear/InterpolateDiscrete, etc.)

### prop ValueBufferType: String
```cj
mut prop ValueBufferType: String
```
Value buffer type ("Array" or a TypedArray name)

### prop ValueTypeName: String
```cj
mut prop ValueTypeName: String
```
Value type name (set by subclasses, e.g. "number"/"vector"/"quaternion"/"bool"/"string"/"color")

### prop name: String
```cj
mut prop name: String
```
Track name (used by PropertyBinding to bind the target property)

### prop times: Array < Float64 >
```cj
mut prop times: Array < Float64 >
```
Keyframe time array (seconds)

### prop values: Array < Float64 >
```cj
mut prop values: Array < Float64 >
```
Keyframe value array (grouped by getValueSize)

