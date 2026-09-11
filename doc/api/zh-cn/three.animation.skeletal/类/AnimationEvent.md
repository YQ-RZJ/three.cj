# 类
## class AnimationEvent
```cj
public class AnimationEvent
```
动画事件定义

### func init\(String,Float32,\(String\)\->Unit\)
```cj
public init(name: String, ratio: Float32, callback:(String) -> Unit)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|ratio|Float32||
|callback|(String)->Unit||

### let callback
```cj
public let callback:(String) -> Unit
```
事件回调

### let name
```cj
public let name: String
```
事件名称

### let ratio
```cj
public let ratio: Float32
```
触发时间比 [0, 1]

### var triggered
```cj
public var triggered: Bool
```
是否已触发（防止单帧内重复触发）

