# 类
## class Clock
```cj
public class Clock
```
用于跟踪时间的时钟类

### func getDelta\(\)
```cj
public func getDelta(): Float64
```
获取自上次调用 getDelta() 以来的时间增量（秒）

返回: 

- 时间增量（秒）

### func getElapsedTime\(\)
```cj
public func getElapsedTime(): Float64
```
获取自时钟启动以来经过的总时间（秒）

返回: 

- 经过的总时间（秒）

### func init\(Bool\)
```cj
public init(autoStart!: Bool = true)
```
构造一个新的时钟

参数: 

|名称|类型|描述|
|---|---|---|
|autoStart|Bool|是否在第一次调用 getDelta() 时自动启动，默认为 true|

### func start\(\)
```cj
public func start(): Unit
```
启动时钟

### func stop\(\)
```cj
public func stop(): Unit
```
停止时钟

### var autoStart
```cj
public var autoStart: Bool
```
是否在第一次调用 getDelta() 时自动启动时钟

