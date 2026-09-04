# Class
## class QuaternionLinearInterpolant
```cj
public class QuaternionLinearInterpolant <: Interpolant
```
Quaternion spherical linear interpolant (SLERP)

### func init\(Array<Float64>,Array<Float64>,Int64,Option<Array<Float64>>\)
```cj
public init(parameterPositions: Array < Float64 >, sampleValues: Array < Float64 >, sampleSize: Int64, resultBuffer: Option < Array < Float64 >>)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|parameterPositions|Array<Float64>|Parameter positions arraysampleValues Sample values arraysampleSize Sample sizeresultBuffer Result buffer|
|sampleValues|Array<Float64>||
|sampleSize|Int64||
|resultBuffer|Option<Array<Float64>>||

### func interpolate\_\(Int64,Float64,Float64,Float64\)
```cj
public override func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array < Float64 >
```
Quaternion spherical linear interpolation calculation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i1|Int64|Right keyframe indext0 Left timet Current interpolation timet1 Right time|
|t0|Float64||
|t|Float64||
|t1|Float64||

Return: 

- Interpolated result array

