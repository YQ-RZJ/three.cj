# 类
## class SamplingContext
```cj
public class SamplingContext
```
采样上下文（帧间缓存）

### func init\(\)
```cj
public init()
```


### func invalidate\(\)
```cj
public func invalidate(): Unit
```
使缓存失效（切换动画时调用）

### func resize\(Int\)
```cj
public func resize(numTracks: Int): Unit
```
调整缓存大小以匹配轨道数

参数: 

|名称|类型|描述|
|---|---|---|
|numTracks|Int||

### var lastAnimation
```cj
public var lastAnimation:?SkeletalAnimationData
```
上一帧的动画

### var lastRatio
```cj
public var lastRatio: Float32
```
上一帧的时间比

### var lastRotKeyframe
```cj
public var lastRotKeyframe: Array < Int >
```
每轨道旋转的上一帧关键帧索引

### var lastScaleKeyframe
```cj
public var lastScaleKeyframe: Array < Int >
```
每轨道缩放的上一帧关键帧索引

### var lastTransKeyframe
```cj
public var lastTransKeyframe: Array < Int >
```
每轨道平移的上一帧关键帧索引

### var maxTracks
```cj
public var maxTracks: Int
```
最大支持的轨道数

