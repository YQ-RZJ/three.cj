# 类
## class DiscreteInterpolant
```cj
public class DiscreteInterpolant <: Interpolant
```
离散插值器

### func init\(Array<Float64>,Array<Float64>,Int64,Option<Array<Float64>>\)
```cj
public init(parameterPositions: Array < Float64 >, sampleValues: Array < Float64 >, sampleSize: Int64, resultBuffer: Option < Array < Float64 >>)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|parameterPositions|Array<Float64>|参数位置数组sampleValues 采样值数组sampleSize 采样大小resultBuffer 结果缓冲区|
|sampleValues|Array<Float64>||
|sampleSize|Int64||
|resultBuffer|Option<Array<Float64>>||

### func interpolate\_\(Int64,Float64,Float64,Float64\)
```cj
public override func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array < Float64 >
```
离散插值计算，直接返回前一个关键帧的值

参数: 

|名称|类型|描述|
|---|---|---|
|i1|Int64|右侧关键帧索引t0 左侧时间t 当前插值时间t1 右侧时间|
|t0|Float64||
|t|Float64||
|t1|Float64||

返回: 

- 插值结果数组

