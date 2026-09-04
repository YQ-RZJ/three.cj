# 类
## class StringKeyframeTrack
```cj
public class StringKeyframeTrack <: KeyframeTrack
```
字符串关键帧轨道

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
重写线性插值工厂方法为离散插值

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|结果缓冲区的可选项|

返回: 

- 离散插值器

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
public override func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
重写平滑插值工厂方法为离散插值

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|结果缓冲区的可选项|

返回: 

- 离散插值器

### func init\(String,Array<Float64>,Array<Float64>\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >)
```
构造一个新的字符串关键帧轨道

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|关键帧轨道名称times 关键帧时间数组values 关键帧值数组|
|times|Array<Float64>||
|values|Array<Float64>||

### func setInterpolation\(Int64\)
```cj
public override func setInterpolation(interpolation: Int64): KeyframeTrack
```
重写设置插值方式，字符串始终使用离散插值

参数: 

|名称|类型|描述|
|---|---|---|
|interpolation|Int64|要设置的插值类型|

返回: 

- 设置后的关键帧轨道

