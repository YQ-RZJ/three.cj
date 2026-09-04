# 类
## class Timer
```cj
public class Timer
```
高性能计时器类

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放资源

### func getDelta\(\)
```cj
public func getDelta(): Float64
```
获取时间增量（秒）

返回: 

- 自上次 update() 以来的时间增量（秒）

### func getElapsed\(\)
```cj
public func getElapsed(): Float64
```
获取累计经过时间（秒）

返回: 

- 自计时器启动以来的累计时间（秒）

### func getTimescale\(\)
```cj
public func getTimescale(): Float64
```
获取时间缩放因子

返回: 

- 当前的时间缩放因子

### func init\(\)
```cj
public init()
```
构造一个新的计时器

### func reset\(\)
```cj
public func reset(): Timer
```
重置计时器，将当前时间重置为 0

返回: 

- 当前计时器实例（支持链式调用）

### func setTimescale\(Float64\)
```cj
public func setTimescale(timescale: Float64): Timer
```
设置时间缩放因子

参数: 

|名称|类型|描述|
|---|---|---|
|timescale|Float64|时间缩放因子，1.0 为正常速度|

返回: 

- 当前计时器实例（支持链式调用）

### func start\(\)
```cj
public func start(): Unit
```
启动计时器（旧版兼容）

### func stop\(\)
```cj
public func stop(): Unit
```
停止计时器（旧版兼容）

### func update\(Float64\)
```cj
public func update(timestamp!: Float64 = - 1.0): Timer
```
更新计时器内部状态

参数: 

|名称|类型|描述|
|---|---|---|
|timestamp|Float64|可选的时间戳（毫秒），如果不提供则使用当前时间|

返回: 

- 当前计时器实例（支持链式调用）

### var fixedDelta
```cj
public var fixedDelta: Float64
```
固定时间步长值（秒）

### var useFixedDelta
```cj
public var useFixedDelta: Bool
```
是否使用固定时间步长

