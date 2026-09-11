# 类
## class AnimationEventSystem
```cj
public class AnimationEventSystem
```
动画事件系统

### func addEvent\(String,String,Float32,\(String\)\->Unit\)
```cj
public func addEvent(clipName: String, eventName: String, ratio: Float32, callback:(String) -> Unit): Unit
```
注册帧事件

参数: 

|名称|类型|描述|
|---|---|---|
|clipName|String|动画片段名称|
|eventName|String|事件名称|
|ratio|Float32|触发时间比 [0, 1]|
|callback|(String)->Unit|回调函数|

### func checkEvents\(String,Float32,Float32,Bool\)
```cj
public func checkEvents(clipName: String, currentRatio: Float32, previousRatio: Float32, looping: Bool): Unit
```
检测事件触发

参数: 

|名称|类型|描述|
|---|---|---|
|clipName|String|当前播放的动画名称|
|currentRatio|Float32|当前时间比 [0, 1]|
|previousRatio|Float32|上一帧时间比 [0, 1]|
|looping|Bool|是否循环播放|

### func clearAll\(\)
```cj
public func clearAll(): Unit
```
清除所有事件和回调

### func clearEvents\(String\)
```cj
public func clearEvents(clipName: String): Unit
```
清除指定 clip 的所有事件

参数: 

|名称|类型|描述|
|---|---|---|
|clipName|String|动画片段名称|

### func init\(\)
```cj
public init()
```


### func onComplete\(String,\(String\)\->Unit\)
```cj
public func onComplete(clipName: String, callback:(String) -> Unit): Unit
```
注册动画完成回调

参数: 

|名称|类型|描述|
|---|---|---|
|clipName|String|动画片段名称|
|callback|(String)->Unit|完成时的回调|

### func resetTriggered\(String\)
```cj
public func resetTriggered(clipName: String): Unit
```
重置指定 clip 的事件触发状态

参数: 

|名称|类型|描述|
|---|---|---|
|clipName|String||

