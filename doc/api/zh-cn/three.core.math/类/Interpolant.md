# 类
## class Interpolant
```cj
public open class Interpolant
```
插值器基类，提供区间查找和插值模板方法

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

