# 类
## class Interpolant
```cj
public open class Interpolant
```
插值器基类，提供区间查找和插值模板方法

### func copySampleValue\_\(Int64\)
```cj
public func copySampleValue_(index: Int64): Array < Float64 >
```
复制采样值到结果缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|采样值缓冲区索引|

返回: 

- 结果缓冲区

### func evaluate\(Float64\)
```cj
public func evaluate(t: Float64): Array < Float64 >
```
在位置 t 处求值

参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子|

返回: 

- 结果缓冲区

### func getSettings\_\(\)
```cj
public func getSettings_(): HashMap < String, Int64 >
```
获取插值设置

返回: 

- 设置对象

### func init\(Array<Float64>,Array<Float64>,Int64,Option<Array<Float64>>\)
```cj
public init(parameterPositions: Array < Float64 >, sampleValues: Array < Float64 >, sampleSize: Int64, resultBuffer: Option < Array < Float64 >>)
```


参数: 

|名称|类型|描述|
|---|---|---|
|parameterPositions|Array<Float64>||
|sampleValues|Array<Float64>||
|sampleSize|Int64||
|resultBuffer|Option<Array<Float64>>||

### func interpolate\_\(Int64,Float64,Float64,Float64\)
```cj
public open func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array < Float64 >
```
插值方法，子类重写

参数: 

|名称|类型|描述|
|---|---|---|
|i1|Int64|采样值缓冲区索引t0 上一个插值因子t 当前插值因子t1 下一个插值因子|
|t0|Float64||
|t|Float64||
|t1|Float64||

返回: 

- 结果缓冲区

### func intervalChanged\_\(Int64,Float64,Float64\)
```cj
public open func intervalChanged_(i1: Int64, t0: Float64, t1: Float64): Unit
```
区间变化时调用，子类可重写

参数: 

|名称|类型|描述|
|---|---|---|
|i1|Int64|采样值缓冲区索引t0 上一个插值因子t1 下一个插值因子|
|t0|Float64||
|t1|Float64||

### var DefaultSettings\_
```cj
public var DefaultSettings_: HashMap < String, Int64 >
```
默认设置

### var \_\_cacheIndex
```cj
public var __cacheIndex: Option < Int64 >
```
缓存索引（AnimationMixer 内存管理用）

### var parameterPositions
```cj
public var parameterPositions: Array < Float64 >
```
参数位置数组

### var resultBuffer
```cj
public var resultBuffer: Array < Float64 >
```
结果缓冲区

### var sampleValues
```cj
public var sampleValues: Array < Float64 >
```
采样值数组

### var settings
```cj
public var settings: Option < HashMap < String, Int64 >>
```
插值设置

### var valueSize
```cj
public var valueSize: Int64
```
值大小（每个采样值的分量数）

