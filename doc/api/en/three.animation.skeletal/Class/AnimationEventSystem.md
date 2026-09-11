# Class
## class AnimationEventSystem
```cj
public class AnimationEventSystem
```
Animation event system

### func addEvent\(String,String,Float32,\(String\)\->Unit\)
```cj
public func addEvent(clipName: String, eventName: String, ratio: Float32, callback:(String) -> Unit): Unit
```
Registers a frame event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clipName|String|The animation clip name|
|eventName|String|The event name|
|ratio|Float32|Trigger time ratio [0, 1]|
|callback|(String)->Unit|The callback function|

### func checkEvents\(String,Float32,Float32,Bool\)
```cj
public func checkEvents(clipName: String, currentRatio: Float32, previousRatio: Float32, looping: Bool): Unit
```
Detects event triggering

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clipName|String|The name of the currently playing animation|
|currentRatio|Float32|The current time ratio [0, 1]|
|previousRatio|Float32|The time ratio of the previous frame [0, 1]|
|looping|Bool|Whether the animation loops|

### func clearAll\(\)
```cj
public func clearAll(): Unit
```
Clears all events and callbacks

### func clearEvents\(String\)
```cj
public func clearEvents(clipName: String): Unit
```
Clears all events of the specified clip

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clipName|String|The animation clip name|

### func init\(\)
```cj
public init()
```


### func onComplete\(String,\(String\)\->Unit\)
```cj
public func onComplete(clipName: String, callback:(String) -> Unit): Unit
```
Registers an animation completion callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clipName|String|The animation clip name|
|callback|(String)->Unit|The callback invoked on completion|

### func resetTriggered\(String\)
```cj
public func resetTriggered(clipName: String): Unit
```
Resets the triggered state of events for the specified clip

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clipName|String||

