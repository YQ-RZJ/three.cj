# Class
## class KeyframeTrack
```cj
public open class KeyframeTrack <: IKeyframeTrack
```
Keyframe track

### func InterpolantFactoryMethodBezier\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodBezier(result: Option < Array < Float64 >>): Interpolant
```
Creates a Bezier interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer array|

Return: 

- Returns the Bezier interpolant

### func InterpolantFactoryMethodDiscrete\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodDiscrete(result: Option < Array < Float64 >>): Interpolant
```
Creates a discrete interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer array|

Return: 

- Returns the discrete interpolant

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
Creates a linear interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer array|

Return: 

- Returns the linear interpolant

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
Creates a smooth (cubic) interpolant

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer array|

Return: 

- Returns the smooth interpolant

### func clone\(\)
```cj
public func clone(): KeyframeTrack
```
Clones the track

Return: 

- Returns a new copy of the track

### func createInterpolant\(Option<Array<Float64>>\)
```cj
public func createInterpolant(result: Option < Array < Float64 >>): Interpolant
```
Creates an interpolant, automatically selecting the factory method based on the current interpolation type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|result|Option<Array<Float64>>|Optional result buffer array|

Return: 

- Returns the interpolant created for the current interpolation type

### func getInterpolation\(\)
```cj
public func getInterpolation(): Int64
```
Returns the current interpolation type

Return: 

- Returns the current interpolation type

### func getValueSize\(\)
```cj
public func getValueSize(): Int64
```
Returns the value size (number of numbers per keyframe)

Return: 

- Returns the number of values per keyframe

### func init\(\)
```cj
public init()
```
Parameterless constructor (used by fastjson deserialization)

### func init\(String,Array<Float64>,Array<Float64>,Int64\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >, interpolation!: Int64 = InterpolateLinear)
```
Creates a keyframe track with the given name, times and values

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Track name, must not be emptytimes The time sequence of each keyframevalues The value sequence corresponding to each keyframeinterpolation The interpolation mode, defaults to linear interpolation|
|times|Array<Float64>||
|values|Array<Float64>||
|interpolation|Int64||

Exception: 

- Exception When the name is empty or there are no keyframes

### func optimize\(\)
```cj
public func optimize(): KeyframeTrack
```
Optimizes the track by removing equivalent consecutive keyframes

Return: 

- Returns itself for chaining

### func scale\(Float64\)
```cj
public func scale(timeScale: Float64): KeyframeTrack
```
Scales the times by a factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeScale|Float64|The time scale factor|

Return: 

- Returns itself for chaining

### func setInterpolation\(Int64\)
```cj
public open func setInterpolation(interpolation: Int64): KeyframeTrack
```
Sets the interpolation mode

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Unsupported types fall back to the default interpolation.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|interpolation|Int64|The interpolation mode|

Return: 

- Returns itself for chaining

### func shift\(Float64\)
```cj
public func shift(timeOffset: Float64): KeyframeTrack
```
Shifts the times by an offset

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeOffset|Float64|The time offset|

Return: 

- Returns itself for chaining

### func trim\(Float64,Float64\)
```cj
public func trim(startTime: Float64, endTime: Float64): KeyframeTrack
```
Trims the track to the given time range

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Empty tracks are not allowed; at least one keyframe is kept.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|startTime|Float64|The start timeendTime The end time|
|endTime|Float64||

Return: 

- Returns itself for chaining

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the keyframe data

Return: 

- Returns true if the data is valid, false otherwise

### prop DefaultInterpolation: Int64
```cj
public mut prop DefaultInterpolation: Int64
```
Used to access the default interpolation mode

### prop ValueBufferType: String
```cj
public mut prop ValueBufferType: String
```
Used to access the value buffer type name

### prop ValueTypeName: String
```cj
public mut prop ValueTypeName: String
```
Used to access the type property name

### prop name: String
```cj
public mut prop name: String
```
Used to access the track name

### prop times: Array < Float64 >
```cj
public mut prop times: Array < Float64 >
```
Used to access the time sequence of each keyframe

### prop values: Array < Float64 >
```cj
public mut prop values: Array < Float64 >
```
Used to access the value sequence corresponding to each keyframe

