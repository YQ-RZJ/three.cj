# 类
## class VectorKeyframeTrack
```cj
public class VectorKeyframeTrack <: KeyframeTrack
```
向量关键帧轨道

### func init\(String,Array<Float64>,Array<Float64>,Int64\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >, interpolation!: Int64 = 0)
```
构造一个新的向量关键帧轨道

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|关键帧轨道名称times 关键帧时间数组values 关键帧值数组interpolation 插值类型，默认为线性插值|
|times|Array<Float64>||
|values|Array<Float64>||
|interpolation|Int64||

