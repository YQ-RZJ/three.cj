# Class
## class AnimationEvent
```cj
public class AnimationEvent
```
Animation event definition

### func init\(String,Float32,\(String\)\->Unit\)
```cj
public init(name: String, ratio: Float32, callback:(String) -> Unit)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|ratio|Float32||
|callback|(String)->Unit||

### let callback
```cj
public let callback:(String) -> Unit
```
Event callback

### let name
```cj
public let name: String
```
Event name

### let ratio
```cj
public let ratio: Float32
```
Trigger time ratio [0, 1]

### var triggered
```cj
public var triggered: Bool
```
Whether the event has been triggered (prevents repeated triggering within a single frame)

