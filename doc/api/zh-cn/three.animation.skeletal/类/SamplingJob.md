# 类
## class SamplingJob
```cj
public class SamplingJob
```
动画采样 Job

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

返回: 

- true 表示可以执行

### var animation
```cj
public var animation:?SkeletalAnimationData
```
要采样的动画数据

### var context
```cj
public var context: SamplingContext
```
采样上下文（帧间缓存）

### var output
```cj
public var output: Array < SoaTransform >
```
输出缓冲区

### var ratio
```cj
public var ratio: Float32
```
时间比 [0, 1]

