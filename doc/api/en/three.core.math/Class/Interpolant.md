# Class
## class Interpolant
```cj
public open class Interpolant
```
Interpolant base class, providing interval search and interpolation template methods

### func copySampleValue\_\(Int64\)
```cj
public func copySampleValue_(index: Int64): Array < Float64 >
```
Copy sample value to result buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Sample value buffer index|

Return: 

- Result buffer

### func evaluate\(Float64\)
```cj
public func evaluate(t: Float64): Array < Float64 >
```
Evaluate at position t

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor|

Return: 

- Result buffer

### func getSettings\_\(\)
```cj
public func getSettings_(): HashMap < String, Int64 >
```
Get interpolation settings

Return: 

- Settings object

### func init\(Array<Float64>,Array<Float64>,Int64,Option<Array<Float64>>\)
```cj
public init(parameterPositions: Array < Float64 >, sampleValues: Array < Float64 >, sampleSize: Int64, resultBuffer: Option < Array < Float64 >>)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|parameterPositions|Array<Float64>||
|sampleValues|Array<Float64>||
|sampleSize|Int64||
|resultBuffer|Option<Array<Float64>>||

### func interpolate\_\(Int64,Float64,Float64,Float64\)
```cj
public open func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array < Float64 >
```
Interpolation method, override by subclasses

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i1|Int64|Sample value buffer indext0 Previous interpolation factort Current interpolation factort1 Next interpolation factor|
|t0|Float64||
|t|Float64||
|t1|Float64||

Return: 

- Result buffer

### func intervalChanged\_\(Int64,Float64,Float64\)
```cj
public open func intervalChanged_(i1: Int64, t0: Float64, t1: Float64): Unit
```
Called when interval changes, subclasses can override

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i1|Int64|Sample value buffer indext0 Previous interpolation factort1 Next interpolation factor|
|t0|Float64||
|t1|Float64||

### var DefaultSettings\_
```cj
public var DefaultSettings_: HashMap < String, Int64 >
```
Default settings

### var \_\_cacheIndex
```cj
public var __cacheIndex: Option < Int64 >
```
Cache index (for AnimationMixer memory management)

### var parameterPositions
```cj
public var parameterPositions: Array < Float64 >
```
Parameter positions array

### var resultBuffer
```cj
public var resultBuffer: Array < Float64 >
```
Result buffer

### var sampleValues
```cj
public var sampleValues: Array < Float64 >
```
Sample values array

### var settings
```cj
public var settings: Option < HashMap < String, Int64 >>
```
Interpolation settings

### var valueSize
```cj
public var valueSize: Int64
```
Value size (number of components per sample value)

