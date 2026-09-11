# 类
## class TrackSamplingJob
```cj
public class TrackSamplingJob
```
通道采样 Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行采样

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var output
```cj
public var output: TrackSampleOutput
```
输出

### var ratio
```cj
public var ratio: Float32
```
时间比 [0, 1]

### var track
```cj
public var track:?SkeletalTrackData
```
要采样的通道

