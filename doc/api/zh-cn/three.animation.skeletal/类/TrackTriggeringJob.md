# 类
## class TrackTriggeringJob
```cj
public class TrackTriggeringJob
```
通道事件触发 Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行触发检测

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var currentRatio
```cj
public var currentRatio: Float32
```
当前帧的时间比 [0, 1]

### var events
```cj
public var events: ArrayList < TriggerEvent >
```
输出：触发事件列表

### var fallingOnly
```cj
public var fallingOnly: Bool
```
是否只检测下降穿越（从上到下）

### var previousRatio
```cj
public var previousRatio: Float32
```
上一帧的时间比 [0, 1]

### var risingOnly
```cj
public var risingOnly: Bool
```
是否只检测上升穿越（从下到上）

### var threshold
```cj
public var threshold: Float32
```
阈值

### var track
```cj
public var track:?SkeletalTrackData
```
要检测的浮点通道

