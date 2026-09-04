# 类
## class QuaternionKeyframeTrack
```cj
public class QuaternionKeyframeTrack <: KeyframeTrack
```
四元数关键帧轨道

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
重写线性插值工厂方法，返回四元数 SLERP 插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|结果缓冲区的可选项|

返回: 

- 四元数线性（SLERP）插值器

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
重写平滑插值工厂方法，回退到线性插值

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|结果缓冲区的可选项|

返回: 

- 四元数线性（SLERP）插值器

### func init\(String,Array<Float64>,Array<Float64>,Int64\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >, interpolation!: Int64 = InterpolateLinear)
```
构造一个新的四元数关键帧轨道

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|关键帧轨道名称times 关键帧时间数组values 关键帧值数组interpolation 插值类型，默认为线性插值|
|times|Array<Float64>||
|values|Array<Float64>||
|interpolation|Int64||

