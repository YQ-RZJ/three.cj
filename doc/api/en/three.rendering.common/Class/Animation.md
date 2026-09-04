# Class
## class Animation
```cj
public open class Animation
```
Rendering common animation class, managing animation callbacks and frame updates

### func init\(\)
```cj
public init()
```
Constructs a default animation instance

### func setAnimationLoop\(\(Float64\)\->Unit\)
```cj
public func setAnimationLoop(cb:(Float64) -> Unit): Unit
```
Sets the animation loop callback function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cb|(Float64)->Unit|Animation callback function|

### func start\(\)
```cj
public func start(): Unit
```
Starts the animation

### func stop\(\)
```cj
public func stop(): Unit
```
Stops the animation

### func update\(Float64\)
```cj
public func update(delta: Float64): Unit
```
Updates the animation each frame, invoking the callback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|delta|Float64|Frame delta time (seconds)|

### var callback
```cj
public var callback:(Float64) -> Unit
```
Animation callback function, parameter is frame delta time (seconds)

### var id
```cj
public var id: Int64
```
Animation identifier

