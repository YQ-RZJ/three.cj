# 接口
## interface IKeyframeTrack
```cj
public interface IKeyframeTrack
```
关键帧轨道接口：AnimationClip.tracks 的元素类型

### func InterpolantFactoryMethodBezier\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodBezier(result: Option < Array < Float64 >>): Interpolant
```
创建贝塞尔插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲区，用于复用|

返回: 

- 贝塞尔插值器实例

### func InterpolantFactoryMethodDiscrete\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodDiscrete(result: Option < Array < Float64 >>): Interpolant
```
创建离散插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲区，用于复用|

返回: 

- 离散插值器实例

### func InterpolantFactoryMethodLinear\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodLinear(result: Option < Array < Float64 >>): Interpolant
```
创建线性插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲区，用于复用|

返回: 

- 线性插值器实例

### func InterpolantFactoryMethodSmooth\(Option<Array<Float64>>\)
```cj
func InterpolantFactoryMethodSmooth(result: Option < Array < Float64 >>): Interpolant
```
创建平滑插值器

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲区，用于复用|

返回: 

- 平滑插值器实例

### func clone\(\)
```cj
func clone(): IKeyframeTrack
```
克隆轨道

返回: 

- 轨道副本

### func createInterpolant\(Option<Array<Float64>>\)
```cj
func createInterpolant(result: Option < Array < Float64 >>): Interpolant
```
创建插值器（按当前 _interpolation 选择工厂方法）

参数: 

|名称|类型|描述|
|---|---|---|
|result|Option<Array<Float64>>|可选的结果缓冲区，用于复用|

返回: 

- 新建的插值器实例

### func getInterpolation\(\)
```cj
func getInterpolation(): Int64
```
获取当前插值类型

返回: 

- 插值类型

### func getValueSize\(\)
```cj
func getValueSize(): Int64
```
获取值大小（每个关键帧的数值数量）

返回: 

- 值大小

### func optimize\(\)
```cj
func optimize(): IKeyframeTrack
```
优化关键帧（移除等效的连续关键帧，返回 this）

返回: 

- 当前轨道

### func scale\(Float64\)
```cj
func scale(timeScale: Float64): IKeyframeTrack
```
缩放时间（返回 this）

参数: 

|名称|类型|描述|
|---|---|---|
|timeScale|Float64|时间缩放因子|

返回: 

- 当前轨道

### func setInterpolation\(Int64\)
```cj
func setInterpolation(interpolation: Int64): IKeyframeTrack
```
设置插值方式（返回 this）

参数: 

|名称|类型|描述|
|---|---|---|
|interpolation|Int64|插值类型|

返回: 

- 当前轨道

### func shift\(Float64\)
```cj
func shift(timeOffset: Float64): IKeyframeTrack
```
平移时间（返回 this 以支持链式调用）

参数: 

|名称|类型|描述|
|---|---|---|
|timeOffset|Float64|时间偏移量（秒）|

返回: 

- 当前轨道

### func trim\(Float64,Float64\)
```cj
func trim(startTime: Float64, endTime: Float64): IKeyframeTrack
```
裁剪时间范围（返回 this）

参数: 

|名称|类型|描述|
|---|---|---|
|startTime|Float64|裁剪起始时间（秒）endTime 裁剪结束时间（秒）|
|endTime|Float64||

返回: 

- 当前轨道

### func validate\(\)
```cj
func validate(): Bool
```
验证关键帧数据有效性

返回: 

- 数据是否有效

### prop DefaultInterpolation: Int64
```cj
mut prop DefaultInterpolation: Int64
```
默认插值类型（InterpolateLinear/InterpolateDiscrete 等）

### prop ValueBufferType: String
```cj
mut prop ValueBufferType: String
```
值容器类型（"Array" 或 TypedArray 名）

### prop ValueTypeName: String
```cj
mut prop ValueTypeName: String
```
值类型名（子类设置，如 "number"/"vector"/"quaternion"/"bool"/"string"/"color"）

### prop name: String
```cj
mut prop name: String
```
轨道名称（用于 PropertyBinding 绑定目标属性）

### prop times: Array < Float64 >
```cj
mut prop times: Array < Float64 >
```
关键帧时间数组（秒）

### prop values: Array < Float64 >
```cj
mut prop values: Array < Float64 >
```
关键帧值数组（按 getValueSize 分组）

