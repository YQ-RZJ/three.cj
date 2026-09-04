# 类
## class KeyframeTrack
```cj
public open class KeyframeTrack <: IKeyframeTrack
```
关键帧轨道

### func InterpolantFactoryMethodBezier\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodBezier(result: Option < Array < Float64 >>): Interpolant
```
创建贝塞尔插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲数组|

返回: 

- 返回贝塞尔插值器

### func InterpolantFactoryMethodDiscrete\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodDiscrete(result: Option < Array < Float64 >>): Interpolant
```
创建离散插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲数组|

返回: 

- 返回离散插值器

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
创建线性插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲数组|

返回: 

- 返回线性插值器

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
public open func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
创建平滑插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲数组|

返回: 

- 返回平滑插值器

### func clone\(\)
```cj
public func clone(): KeyframeTrack
```
克隆轨道

返回: 

- 返回一个新的轨道副本

### func createInterpolant\(Option<Array<Float64>>\)
```cj
public func createInterpolant(result: Option < Array < Float64 >>): Interpolant
```
创建插值器（根据当前插值类型自动选择工厂方法）

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲数组|

返回: 

- 返回根据当前插值类型创建的插值器

### func getInterpolation\(\)
```cj
public func getInterpolation(): Int64
```
获取当前插值类型

返回: 

- 返回当前的插值类型

### func getValueSize\(\)
```cj
public func getValueSize(): Int64
```
获取值大小（每个关键帧的数值数量）

返回: 

- 返回每个关键帧的数值数量

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(String,Array<Float64>,Array<Float64>,Int64\)
```cj
public init(name: String, times: Array < Float64 >, values: Array < Float64 >, interpolation!: Int64 = InterpolateLinear)
```
以指定名称、时间与取值创建关键帧轨道

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|轨道名称，不能为空times 各关键帧的时间序列values 各关键帧对应的取值序列interpolation 插值方式，默认为线性插值|
|times|Array<Float64>||
|values|Array<Float64>||
|interpolation|Int64||

异常: 

- Exception 当名称为空或不存在任何关键帧时

### func optimize\(\)
```cj
public func optimize(): KeyframeTrack
```
优化关键帧（移除等效的连续关键帧）

返回: 

- 返回自身以支持链式调用

### func scale\(Float64\)
```cj
public func scale(timeScale: Float64): KeyframeTrack
```
缩放时间

参数: 

|名称|类型|描述|
|---|---|---|
|timeScale|Float64|时间缩放系数|

返回: 

- 返回自身以支持链式调用

### func setInterpolation\(Int64\)
```cj
public open func setInterpolation(interpolation: Int64): KeyframeTrack
```
设置插值方式

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>不支持的类型会回退到默认插值。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|interpolation|Int64|插值方式|

返回: 

- 返回自身以支持链式调用

### func shift\(Float64\)
```cj
public func shift(timeOffset: Float64): KeyframeTrack
```
平移时间

参数: 

|名称|类型|描述|
|---|---|---|
|timeOffset|Float64|时间偏移量|

返回: 

- 返回自身以支持链式调用

### func trim\(Float64,Float64\)
```cj
public func trim(startTime: Float64, endTime: Float64): KeyframeTrack
```
裁剪时间范围

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>空轨道不允许，至少保留一个关键帧。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|startTime|Float64|起始时间endTime 结束时间|
|endTime|Float64||

返回: 

- 返回自身以支持链式调用

### func validate\(\)
```cj
public func validate(): Bool
```
验证关键帧数据有效性

返回: 

- 数据有效时返回 true，否则返回 false

### prop DefaultInterpolation: Int64
```cj
public mut prop DefaultInterpolation: Int64
```
用于访问默认插值方式

### prop ValueBufferType: String
```cj
public mut prop ValueBufferType: String
```
用于访问值缓冲类型名称

### prop ValueTypeName: String
```cj
public mut prop ValueTypeName: String
```
用于访问类型属性名称

### prop name: String
```cj
public mut prop name: String
```
用于访问轨道名称

### prop times: Array < Float64 >
```cj
public mut prop times: Array < Float64 >
```
用于访问各关键帧的时间序列

### prop values: Array < Float64 >
```cj
public mut prop values: Array < Float64 >
```
用于访问各关键帧对应的取值序列

